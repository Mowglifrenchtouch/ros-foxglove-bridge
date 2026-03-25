docker buildx build \
  --platform linux/arm64 \
  --file docker/foxglove/Dockerfile \
  --tag ghcr.io/pepeuch/mowgli-docker:v2-foxglove \
  --build-arg IMAGE=ghcr.io/cedbossneo/mowgli-docker:upstream \
  --progress=plain \
  --load \
  . 2>&1 | tee build-foxglove.log
