#!/bin/bash

set -e
set -x

cd /home/terraform
terraform apply -auto-approve -input=false -json
cp backend main.tf
terraform init -migrate-state -force-copy
terraform apply -auto-approve -input=false -json
