#!/usr/bin/env bash

set -e

docker run \
  -e BUILD_NAME \
  -e UNITY_LICENSE_CONTENT \
  -e BUILD_TARGET \
  -e UNITY_USERNAME \
  -e UNITY_PASSWORD \
  -w /project/ \
  -v $(pwd):/project/ \
  $IMAGE_NAME \
  /bin/bash -c "/project/Tools/travis/ci/before_script.sh && /project/Tools/travis/ci/build.sh"
