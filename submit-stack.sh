#!/bin/bash

BASE=templates
stacks=$(<stacks.lst)
while IFS= read -r stack; do
    stack_names=$(<"${BASE}/${stack}/names.lst")
    while IFS= read -r stack_name; do
      yaml_files=$(find "$BASE/$stack" -name "*.y*ml")
      while IFS= read -r yaml_file; do
        echo "Located template-body: $yaml_file"
        params_files=$(find "$BASE/$stack" -name "$stack_name*.json")
        while IFS= read -r param_file; do
          echo "Located Parameters: $param_file"
          if [ "$1" == "create" ]; then
            echo "Creating CloudFormation Stack [$stack_name] on [$2] region..."
            aws cloudformation create-stack \
            --stack-name "$stack_name" \
            --template-body "file://$yaml_file" \
            --parameters "file://$param_file" \
            --region "$2" \
            --capabilities CAPABILITY_NAMED_IAM

            aws cloudformation wait stack-create-complete \
            --stack-name "$stack_name" \
            --region "$2"

          else
            echo "Updating CloudFormation Stack [$stack_name] on [$2] region..."
            aws cloudformation update-stack \
            --stack-name "$stack_name" \
            --template-body "file://$yaml_file" \
            --parameters "file://$param_file" \
            --region "$2" \
            --capabilities CAPABILITY_NAMED_IAM

            aws cloudformation wait stack-update-complete \
            --stack-name "$stack_name" \
            --region "$2"

          fi
        done <<< "$params_files"
      done <<< "$yaml_files"
    done <<< "$stack_names"
done <<< "$stacks"
