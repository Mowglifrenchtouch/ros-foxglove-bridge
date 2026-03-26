docker buildx build \
  --platform linux/arm64 \
  --file foxglove_openmower/Dockerfile \
  --tag ghcr.io/pepeuch/mowgli-docker:v2-foxglove \
  --build-arg AMD64_MAX_JOBS=8 \
  --build-arg ARM64_MAX_JOBS=4 \
  --progress=plain \
  --load \
  . 2>&1 | tee build-foxglove.log
