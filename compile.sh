#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="ghcr.io/pepeuch/mowgli-docker"
IMAGE_TAG="v2-foxglove"
PLATFORM="linux/arm64"
DOCKERFILE="docker/foxglove/Dockerfile"
LOG_FILE="build-foxglove.log"
CACHE_DIR=".buildx-cache"
CACHE_DIR_NEW=".buildx-cache-new"

mkdir -p "${CACHE_DIR}"

echo "=== Build Foxglove image ==="
echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "Platform: ${PLATFORM}"
echo "Dockerfile: ${DOCKERFILE}"
echo "Log: ${LOG_FILE}"

docker buildx build \
  --platform "${PLATFORM}" \
  --file "${DOCKERFILE}" \
  --tag "${IMAGE_NAME}:${IMAGE_TAG}" \
  --build-arg IMAGE=ghcr.io/cedbossneo/mowgli-docker:upstream \
  --progress=plain \
  --cache-from type=local,src="${CACHE_DIR}" \
  --cache-to type=local,dest="${CACHE_DIR_NEW}",mode=max \
  --push \
  . 2>&1 | tee "${LOG_FILE}"

rm -rf "${CACHE_DIR}"
mv "${CACHE_DIR_NEW}" "${CACHE_DIR}"

echo
echo "=== Build finished ==="
echo "Logs saved to ${LOG_FILE}"
