locals {
  container_name = local.use_reverse_proxy_side_car ? "${var.application_name}-reverse-proxy" : var.application_name
  container_port = local.use_reverse_proxy_side_car ? var.reverse_proxy_configuration.listener_port : var.container_definition.portMappings[0].containerPort

}

resource "aws_codecommit_repository" "this" {
  count           = var.enable_pipeline ? 1 : 0
  repository_name = var.application_name
  description     = "${var.application_name} repository"
}

resource "null_resource" "code-commit-files" {
  count = var.enable_pipeline ? 1 : 0

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT

get_branch_head_commit(){
  aws codecommit get-branch --repository-name "${var.application_name}" --branch-name "$1" --query '[branch][*].commitId' --output text
}

commit_file(){
  local branch_name=$1
  local parent_commit_id=$2
  local file_path=$3
  local file_content=$4
  local commit_message=$5

  if [[ -z "$parent_commit_id" ]]; then
    aws codecommit put-file --repository-name "${var.application_name}" --branch-name "$branch_name" --file-path "$file_path" --file-content "$file_content" --commit-message "$commit_message" --cli-binary-format raw-in-base64-out
  else
    aws codecommit put-file --repository-name "${var.application_name}" --branch-name "$branch_name" --parent-commit-id "$parent_commit_id" --file-path "$file_path" --file-content "$file_content" --commit-message "$commit_message" --cli-binary-format raw-in-base64-out
  fi
}

if [ "${var.custom_aws_profile}" != "default" ] ; then
  export AWS_PROFILE="${var.custom_aws_profile}"
fi

aws ecs describe-task-definition --task-definition "${aws_ecs_task_definition.this.arn}"  --output json --query taskDefinition > "taskdef.json"

echo "Create Task Definition"
sed -i'.bak' 's@${var.container_definition.image}@<IMAGE1_NAME>@' taskdef.json

echo "Create AppSpec File"
sed -i'.bak' 's@<CONTAINER_NAME>@${local.container_name}@' 'resources/appspec.yaml'
sed -i'.bak' 's@<CONTAINER_PORT>@${local.container_port}@' 'resources/appspec.yaml'

if [ "${var.appspec_hook.hooks_lambda_function_arn}" != "null" ]; then
  if [ "${var.appspec_hook.lifecycle_event_name}" != "null" ]; then
    echo "Adding Lambda Hooks"
    echo "Hooks:" >> resources/appspec.yaml
    echo "  - ${var.appspec_hook.lifecycle_event_name}: \"${var.appspec_hook.hooks_lambda_function_arn}\"" >> resources/appspec.yaml
  else
    echo "Error: The lifecycle_event_name value must not be null." >&2
    exit 1
  fi
fi

echo "Getting main branch" 
MAIN_COMMIT_ID=$(get_branch_head_commit "main")

if [[ $? -ne 0 ]]; then
  echo "Running exception" 
  echo "Creating main branch with README.md"
  commit_file "main" "" "README.md" "Task def and appspec for ${var.application_name}" "Initial commit README.md"

  echo "Getting main branch head"
  MAIN_COMMIT_ID=$(get_branch_head_commit "main")
fi

echo "Creating temporary branch for task definition revision ${aws_ecs_task_definition.this.revision}"
aws codecommit create-branch --repository-name "${var.application_name}" --branch-name "${aws_ecs_task_definition.this.revision}" --commit-id "$MAIN_COMMIT_ID"

branch_name="${aws_ecs_task_definition.this.revision}"

echo "Commiting task definition revision ${aws_ecs_task_definition.this.revision}"
REVISION_COMMIT_ID=$(get_branch_head_commit "$branch_name")
commit_file "$branch_name" "$REVISION_COMMIT_ID" "taskdef.json" "file://taskdef.json" "Initial commit taskdef.json"

echo "Commiting appspec revision ${aws_ecs_task_definition.this.revision}"
REVISION_COMMIT_ID=$(get_branch_head_commit "$branch_name")
commit_file "$branch_name" "$REVISION_COMMIT_ID" "appspec.yaml" "file://resources/appspec.yaml" "Initial commit appspec.yaml"

echo "Getting temporary branch head"
REVISION_COMMIT_ID=$(get_branch_head_commit "$branch_name")

echo "Merge branch ${aws_ecs_task_definition.this.revision} into main"
aws codecommit merge-branches-by-squash --repository-name "${var.application_name}" --source-commit-specifier "$REVISION_COMMIT_ID" --destination-commit-specifier "$MAIN_COMMIT_ID" --target-branch main

echo "Delete temporary branch ${aws_ecs_task_definition.this.revision}"
aws codecommit delete-branch --repository-name "${var.application_name}" --branch-name "${aws_ecs_task_definition.this.revision}"

EOT
  }

  triggers = {
    aws_ecs_task_definition_revision = aws_ecs_task_definition.this.revision
    lifecycle_event_name = var.appspec_hook.lifecycle_event_name
    hooks_lambda_function_arn = var.appspec_hook.hooks_lambda_function_arn
  }

  depends_on = [
    aws_codecommit_repository.this,
    aws_ecs_task_definition.this
  ]
}
