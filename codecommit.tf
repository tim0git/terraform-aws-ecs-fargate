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

if ["${var.custom_aws_profile}" != "default"] ; then
  export "AWS_PROFILE=${var.custom_aws_profile}"
fi


aws ecs describe-task-definition --task-definition "${aws_ecs_task_definition.this.arn}"  --output json --query taskDefinition > "taskdef.json"

echo "Create Task Definition"
sed -i'.bak' 's@${var.container_definition.image}@<IMAGE1_NAME>@' taskdef.json

echo "Create AppSpec File"
sed -i'.bak' 's@<CONTAINER_NAME>@${local.container_name}@' 'resources/appspec.yaml'
sed -i'.bak' 's@<CONTAINER_PORT>@${local.container_port}@' 'resources/appspec.yaml'

if [${var.enable_appspec_hooks}] ; then
  echo "Hooks:" >> resources/appspec.yaml
  echo "  - ${var.lifecycle_event_name}: \"${var.hooks_lambda_function_arn}\""
fi

maincommitid=`aws codecommit get-branch --repository-name "${var.application_name}" --branch-name main --query '[branch][*].commitId' --output text `

if [[ -z "$maincommitid" ]]; then
  echo "Creating main branch with README.md"
  aws codecommit put-file --repository-name "${var.application_name}" --branch-name main --file-path README.md --file-content "Task def and appspec for ${var.application_name}" --commit-message "Initial commit README.md" --cli-binary-format raw-in-base64-out
fi

echo "Getting main branch head"
maincommitid=`aws codecommit get-branch --repository-name "${var.application_name}" --branch-name main --query '[branch][*].commitId' --output text `

echo "Creating temporary branch for task definition revision ${aws_ecs_task_definition.this.revision}"
aws codecommit create-branch --repository-name "${var.application_name}" --branch-name "${aws_ecs_task_definition.this.revision}" --commit-id $maincommitid

echo "Getting temporary branch head"
randomcommitid=`aws codecommit get-branch --repository-name "${var.application_name}" --branch-name "${aws_ecs_task_definition.this.revision}" --query '[branch][*].commitId' --output text `

echo "Commiting task definition revision ${aws_ecs_task_definition.this.revision}"
aws codecommit put-file --repository-name "${var.application_name}" --branch-name "${aws_ecs_task_definition.this.revision}" --parent-commit-id $randomcommitid --file-path taskdef.json --file-content file://taskdef.json --commit-message "Initial commit taskdef.json" --cli-binary-format raw-in-base64-out

echo "Getting temporary branch head"
randomcommitid=`aws codecommit get-branch --repository-name "${var.application_name}" --branch-name "${aws_ecs_task_definition.this.revision}" --query '[branch][*].commitId' --output text `

echo "Commiting appspec revision ${aws_ecs_task_definition.this.revision}"
aws codecommit put-file --repository-name "${var.application_name}" --branch-name "${aws_ecs_task_definition.this.revision}" --parent-commit-id $randomcommitid --file-path appspec.yaml --file-content file://resources/appspec.yaml --commit-message "Initial commit appspec.yaml" --cli-binary-format raw-in-base64-out

echo "Getting temporary branch head"
randomcommitid=`aws codecommit get-branch --repository-name "${var.application_name}" --branch-name "${aws_ecs_task_definition.this.revision}" --query '[branch][*].commitId' --output text `

echo "Merge branch ${aws_ecs_task_definition.this.revision} into main"
aws codecommit merge-branches-by-squash --repository-name "${var.application_name}" --source-commit-specifier $randomcommitid --destination-commit-specifier $maincommitid --target-branch main --commit-message "Task Defintion Revision ${aws_ecs_task_definition.this.revision}"

echo "Delete temporary branch ${aws_ecs_task_definition.this.revision}"
aws codecommit delete-branch --repository-name "${var.application_name}" --branch-name "${aws_ecs_task_definition.this.revision}"
EOT
  }

  triggers = {
    aws_ecs_task_definition_revision = aws_ecs_task_definition.this.revision
    enable_appspec_hooks = var.enable_appspec_hooks
    lifecycle_event_name = var.lifecycle_event_name
    hooks_lambda_function_arn = var.hooks_lambda_function_arn
  }

  depends_on = [
    aws_codecommit_repository.this,
    aws_ecs_task_definition.this
  ]
}
