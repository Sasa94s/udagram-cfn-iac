#!/bin/bash

mkdir -p ./key_temp
ssh-keygen -t rsa -N '' -f ./key_temp/id_rsa
aws ssm put-parameter --name udagramBastionKey --type SecureString --value "$(cat ./key_temp/id_rsa.pub)" --region "$1" --overwrite
rm -rf ./key_temp
