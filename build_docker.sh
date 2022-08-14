#!/bin/bash

AWS_ACCOUNT_ID=$1
AWS_REGION=${2:-ap-northeast-1}
AWS_ECR_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
echo ${AWS_ECR_URL}

aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ECR_URL}

docker build . -t superset
docker tag superset:latest "${AWS_ECR_URL}/superset:latest"
docker push "${AWS_ECR_URL}/superset:latest"
