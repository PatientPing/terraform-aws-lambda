#!/bin/bash
set -e

# Retrieve GitHub token from SSM
GITHUB_TOKEN=$(aws ssm get-parameter --name "${github_token_path}" --with-decryption --query "Parameter.Value" --output text)

# Clone and checkout
CLONE_DIR=$(mktemp -d)
git clone "https://$${GITHUB_TOKEN}@${git_host}" "$${CLONE_DIR}"
cd "$${CLONE_DIR}"
git checkout "${git_commit_sha}"
wget https://github.com/SumoLogic/sumologic-lambda-extensions/releases/latest/download/sumologic-extension-amd64.tar.gz
# Build
docker build \
  --platform linux/amd64 \
  --provenance=false \
  -t "${ecr_repo_url}:${git_commit_sha}" \
  --build-arg "GITHUB_TOKEN=$${GITHUB_TOKEN}" \
  --build-arg "GITHUB_SHA=${git_commit_sha}" \
  ${extra_build_args} \
  "$${CLONE_DIR}/${docker_build_dir}"

# Tag latest
docker tag \
  "${ecr_repo_url}:${git_commit_sha}" \
  "${ecr_repo_url}:latest"

# Push
aws ecr get-login-password --region "${aws_region}" | \
  docker login --username AWS --password-stdin "${ecr_repo_url}"
docker push "${ecr_repo_url}:${git_commit_sha}"
docker push "${ecr_repo_url}:latest"

# Cleanup
rm -rf "$${CLONE_DIR}"
