#!/bin/bash

echo "*** UNSAFE XHOST USAGE ***"
xhost +

docker run -it --rm \
  -e DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $HOME:/home \
  kicad
