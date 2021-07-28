#!/bin/bash

if [ $# != 3 ]; then
    echo "Usage: $(basename $0) <template-name> <project-id> <env-id>"
    echo "<template-name>: template name = yaml file name with out .yml. it is used stack name."
    echo "<project-id>: project id (ex. common)"
    echo "<env-id>: environment id (ex. test00, dev00, prd00)"
    exit 1
fi

template_name=$1
project_id=$2
env_id=$3

stack_name=${project_id}-${env_id}-${template_name}
echo "Delete a stack. stack=${stack_name}"

command="aws cloudformation delete-stack --stack-name ${stack_name} --region ap-northeast-1"
echo " > command=${command}"
${command}
exit_code=$?
echo " > exit_code=${exit_code}"
if [ ${exit_code} != 0 ]; then
    echo " > Failed to delete a stack. stack=${stack_name}, exit_code=${exit_code}"
    exit 1
fi

command="aws cloudformation wait stack-delete-complete --stack-name ${stack_name} --region ap-northeast-1"
echo " > command=${command}"
${command}
exit_code=$?
echo " > exit_code=${exit_code}"
if [ ${exit_code} != 0 ]; then
    echo " > Failed to delete a stack. stack=${stack_name}, exit_code=${exit_code}"
    exit 1
fi
echo " > Completed to delete a stack. stack=${stack_name}, exit_code=${exit_code}"
exit 0
