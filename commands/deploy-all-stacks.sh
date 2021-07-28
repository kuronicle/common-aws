#!/bin/bash

if [ $# != 2 ]; then
    echo "Usage: $(basename $0) <project-id> <env-id>"
    echo "<project-id>: project id (ex. common)"
    echo "<env-id>: environment id (ex. test00, dev00, prd00)"
    exit 1
fi

execute_dir=$(cd $(dirname $0)/../; pwd)
cd ${execute_dir}

project_id=$1
env_id=$2
read -p "Start to deploy all stacks of '${project_id}-${env_id}'. Type 'Yes!'. : " input

if [[ ${input} != "Yes!" ]]; then
    echo "Stop to deploy."
    exit 0
fi

targets=("audit-log-s3" "deploy-artifacts-s3")

for target in ${targets[@]}; do
    stack_name=${project_id}-${env_id}-${target}
    echo "Deploy a stack. stack=${stack_name}"
    command="aws cloudformation deploy --stack-name ${stack_name} --template-file ./cloudformation/templates/${target}.yml --parameter-overrides file://./cloudformation/parameters/${project_id}-${env_id}.json --no-fail-on-empty-changeset --tags Name=${project_id}-${env_id}-cloudformation-stack-${target} project-id=${project_id} environment-id=${env_id} --region ap-northeast-1 --capabilities CAPABILITY_NAMED_IAM"
    echo " > command=${command}"
    ${command}
    exit_code=$?
    echo " > exit_code=${exit_code}"
    if [ ${exit_code} == 0 ]; then
        echo " > Completed to deploy a stack. stack=${stack_name}, exit_code=${exit_code}"
    else
        echo " > Failed to deploy a stack. stack=${stack_name}, exit_code=${exit_code}"
        exit 1
    fi
done
