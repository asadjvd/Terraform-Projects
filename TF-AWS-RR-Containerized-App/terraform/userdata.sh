#!/bin/bash

set -e

# Terraform Variables (Rendered)
region="${region}"
frontend="${frontend}"
backend="${backend}"
frontend_repo_name="${frontend_repo_name}"
backend_repo_name="${backend_repo_name}"
backend_url="${backend_url}"
frontend_url="${frontend_url}"

# Variable Declaration
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Packages Installation
echo "Installing Packages..."

sudo dnf update -y
sudo dnf install docker git unzip awscli -y

sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -aG docker ec2-user

# LOGIN TO ECR
echo "Logging into ECR..."

aws ecr get-login-password --region "$region" | \
docker login --username AWS --password-stdin \
"$AWS_ACCOUNT_ID.dkr.ecr.$region.amazonaws.com"

# Download Applications
echo "Download Applications..."

curl -L -o "${backend}.zip" "$backend_url"
curl -L -o "${frontend}.zip" "$frontend_url"

unzip "${backend}.zip"
unzip "${frontend}.zip"

# Build Frontend Image
echo "Building frontend image..."

cd "$frontend"

docker build -t "$frontend_repo_name" .

docker tag "$frontend_repo_name":latest \
"$AWS_ACCOUNT_ID.dkr.ecr.$region.amazonaws.com/$frontend_repo_name:latest"

# Push Frontend Image
echo "Pushing frontend image..."

docker push \
"$AWS_ACCOUNT_ID.dkr.ecr.$region.amazonaws.com/$frontend_repo_name:latest"

cd ..

# Build Backend Image
echo "Building backend image..."

cd "$backend"

docker build -t "$backend_repo_name" .

docker tag "$backend_repo_name":latest \
"$AWS_ACCOUNT_ID.dkr.ecr.$region.amazonaws.com/$backend_repo_name:latest"

# Push Backend Image
echo "Pushing backend image..."

docker push \
"$AWS_ACCOUNT_ID.dkr.ecr.$region.amazonaws.com/$backend_repo_name:latest"

echo "Docker images pushed successfully!"
