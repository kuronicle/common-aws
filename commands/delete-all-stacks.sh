#!/bin/bash
export AWS_CLI_FILE_ENCODING=UTF-8

if [ $# != 2 ]; then
    echo "Usage: $(basename $0) <project-id> <env-id>"
    echo "<project-id>: project id (ex. common)"
    echo "<env-id>: environment id (ex. test00, dev00, prd00)"
    exit 1
fi

project_id=$1
env_id=$2
read -p "Start to delete all stacks of '${project_id}-${env_id}'. Type 'Yes!'. : " input

if [[ ${input} != "Yes!" ]]; then
    echo "Stop to delete."
    exit 0
fi

targets=("deploy-artifacts-s3" "audit-log-s3")

for target in ${targets[@]}; do
    stack_name=${project_id}-${env_id}-${target}
    echo "Delete a stack. stack=${stack_name}"
    command="aws cloudformation delete-stack --stack-name ${stack_name} --region ap-northeast-1"
    echo " > command=${command}"
    ${command}
    exit_code=$?
    echo " > exit_code=${exit_code}"
    if [ ${exit_code} != 0 ]; then
        echo " > Failed to delete a stack. stack=${stack_name}, exit_code=${exit_code}"
        continue
    fi
    command="aws cloudformation wait stack-delete-complete --stack-name ${stack_name} --region ap-northeast-1"
    echo " > command=${command}"
    ${command}
    exit_code=$?
    echo " > exit_code=${exit_code}"
    if [ ${exit_code} == 0 ]; then
        echo " > Completed to delete a stack. stack=${stack_name}, exit_code=${exit_code}"
    else
        echo " > Failed to delete a stack. stack=${stack_name}, exit_code=${exit_code}"
        exit 1
    fi
done
