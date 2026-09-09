#!/bin/bash
set -e

# Retrieve GitHub token from SSM
GITHUB_TOKEN=$(aws ssm get-parameter --name "${github_token_path}" --with-decryption --query "Parameter.Value" --output text)

# Clone and checkout
CLONE_DIR=$(mktemp -d)
git clone "https://$${GITHUB_TOKEN}@${git_host}" "$${CLONE_DIR}"
cd "$${CLONE_DIR}"
git checkout "${git_commit_sha}"
# Fetch the Sumo extension into the Docker build context (the build dir), not the
# clone root, so a subdirectory build context (docker_build_dir set for monorepo
# lambdas) still contains the tarball for the Dockerfile's
# `ADD sumologic-extension-amd64.tar.gz*`. docker_build_dir defaults to "." (repo
# root) for single-repo lambdas, so their build context is unchanged.
wget -P "$${CLONE_DIR}/${docker_build_dir}" https://github.com/SumoLogic/sumologic-lambda-extensions/releases/latest/download/sumologic-extension-amd64.tar.gz

# Authenticate to ECR for the image push below.
aws ecr get-login-password --region "${aws_region}" | \
  docker login --username AWS --password-stdin "${ecr_repo_url}"

# Build the shared internal-libs base image locally first, if this source provides
# one. Monorepo/at_lib lambdas ship `at_lib-base.Dockerfile` at the repo root; it
# bakes `at_lib/` in as layers. The lambda's own Dockerfile then does
# `FROM at-lib-base:<sha>` (a LOCAL tag, no registry), so shared libs need no
# git+https pin and no build-time GITHUB_TOKEN. Non-monorepo lambdas have no such
# file, so this is skipped and their build is unchanged.
if [ -f at_lib-base.Dockerfile ]; then
  docker build --platform linux/amd64 --provenance=false \
    -f at_lib-base.Dockerfile -t "at-lib-base:${git_commit_sha}" .
fi

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

# Push (already authenticated to the registry before the build)
docker push "${ecr_repo_url}:${git_commit_sha}"
docker push "${ecr_repo_url}:latest"

# Cleanup
rm -rf "$${CLONE_DIR}"
