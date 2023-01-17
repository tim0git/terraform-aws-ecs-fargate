import json
import boto3
import os

autoscaling_client = boto3.client('application-autoscaling')
elb_client = boto3.client('elbv2')
ecs_client = boto3.client('ecs')

service_name = os.getenv('ecs_service_name')
cluster_name = os.getenv('ecs_cluster_name')
load_balancer_name = os.getenv('load_balancer_name')
autoscaling_target_value = os.getenv("autoscale_target_value")
autoscale_policy_name = os.getenv("autoscale_policy_name")
minimum_capacity = os.getenv("minimum_capacity")
maximum_capacity = os.getenv("maximum_capacity")


def get_target_group_arn():
    response = ecs_client.describe_services(cluster=cluster_name, services=[service_name])
    return response['services'][0]['loadBalancers'][0]['targetGroupArn'].split('targetgroup')[1]


def get_load_balancer_arn():
    res = elb_client.describe_load_balancers(Names=[load_balancer_name])
    return res['LoadBalancers'][0]['LoadBalancerArn'].split('loadbalancer')[1].lstrip('/')


def lambda_handler(event, context):
    resource_label = get_load_balancer_arn() + '/targetgroup' + get_target_group_arn()
    resource_id = 'service/' + cluster_name + '/' + service_name

    print("Target group changed for %s", resource_id)
    print('generated resource label: ' + str(resource_label))
    response = autoscaling_client.register_scalable_target(
        ServiceNamespace='ecs',
        ResourceId=resource_id,
        ScalableDimension='ecs:service:DesiredCount',
        MinCapacity=int(minimum_capacity),
        MaxCapacity=int(maximum_capacity)
    )
    print(response)
    print('scalable target registered with above response')
    response = autoscaling_client.put_scaling_policy(
        PolicyName=autoscale_policy_name,
        ServiceNamespace='ecs',
        ResourceId=resource_id,
        ScalableDimension='ecs:service:DesiredCount',
        PolicyType='TargetTrackingScaling',
        TargetTrackingScalingPolicyConfiguration={
            'TargetValue': float(autoscaling_target_value),
            'PredefinedMetricSpecification': {
                'PredefinedMetricType': 'ALBRequestCountPerTarget',
                'ResourceLabel': resource_label
            }
        }
    )
    print(response)
