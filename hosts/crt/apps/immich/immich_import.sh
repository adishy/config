IMMICH_API_KEY=""
docker run -it --rm \
  --network host \
  -v /mnt/external/pictures:/import:ro \
  ghcr.io/immich-app/immich-cli:latest \
  upload \
  -u http://192.168.0.123:2283/api \
  -k $IMMICH_API_KEY \
  --recursive \
  /import
