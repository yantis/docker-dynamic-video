docker build -t yantis/dynamic-video .

xhost +si:localuser:$(whoami) >/dev/null
docker run \
  --privileged \
  --rm \
  -ti \
  -e DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -u docker \
  yantis/dynamic-video /bin/bash -c "sudo initalize-graphics >/dev/null 2>/dev/null; nvidia-smi;"
