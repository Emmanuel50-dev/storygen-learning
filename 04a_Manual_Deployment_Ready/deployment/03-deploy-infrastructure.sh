#!/bin/bash
set -e

source deployment/load-env.sh

cd terraform_code

terraform init

terraform apply -auto-approve -var="project_id=$PROJECT_ID" -var="region=$REGION"

cd ..
