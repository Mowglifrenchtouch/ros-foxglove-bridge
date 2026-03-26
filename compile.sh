#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="ghcr.io/mowglifrenchtouch/foxglove-bridge"
IMAGE_TAG="v2"
PLATFORM="linux/amd64,linux/arm64"
DOCKERFILE="foxglove_openmower/Dockerfile"
LOG_FILE="build-foxglove.log"
CACHE_DIR=".buildx-cache"
CACHE_DIR_NEW=".buildx-cache-new"

mkdir -p "${CACHE_DIR}"
rm -rf "${CACHE_DIR_NEW}"
mkdir -p "${CACHE_DIR_NEW}"

echo "=== Build Foxglove image ==="
echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "Platform: ${PLATFORM}"
echo "Dockerfile: ${DOCKERFILE}"
echo "Log: ${LOG_FILE}"

docker buildx build \
  --platform "${PLATFORM}" \
  --build-arg AMD64_MAX_JOBS=8 \
  --build-arg ARM64_MAX_JOBS=4 \
  --file "${DOCKERFILE}" \
  --tag "${IMAGE_NAME}:${IMAGE_TAG}" \
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
