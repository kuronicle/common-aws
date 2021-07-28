#!/bin/bash

if [ $# != 3 ]; then
    echo "Usage: $(basename $0) <template-name> <project-id> <env-id>"
    echo "<template-name>: template name = yaml file name with out .yml. it is used stack name."
    echo "<project-id>: project id (ex. common)"
    echo "<env-id>: environment id (ex. test00, dev00, prd00)"
    exit 1
fi

execute_dir=$(cd $(dirname $0)/../; pwd)
cd ${execute_dir}

template_name=$1
project_id=$2
env_id=$3

stack_name=${project_id}-${env_id}-${template_name}
echo "Deploy a stack. stack=${stack_name}"

command="aws cloudformation deploy --stack-name ${stack_name} --template-file ./cloudformation/templates/${template_name}.yml --parameter-overrides file://./cloudformation/parameters/${project_id}-${env_id}.json --no-fail-on-empty-changeset --tags Name=${project_id}-${env_id}-cloudformation-stack-${template_name} project-id=${project_id} environment-id=${env_id} --region ap-northeast-1 --capabilities CAPABILITY_NAMED_IAM"
echo " > command=${command}"
${command}
exit_code=$?
echo " > exit_code=${exit_code}"
if [ ${exit_code} != 0 ]; then
    echo " > Failed to deploy a stack. stack=${stack_name}, exit_code=${exit_code}"
    exit 1
fi

echo " > Completed to deploy a stack. stack=${stack_name}, exit_code=${exit_code}"
exit 0
