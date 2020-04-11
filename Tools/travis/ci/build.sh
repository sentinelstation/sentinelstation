#!/usr/bin/env bash

set -e
set -x

unitywait(){
    sleep 60
    while ps -C Unity >/dev/null; do
        echo "Building..."
        sleep 120
    done
}

echo "Building for $BUILD_TARGET"

export BUILD_PATH=./Builds/$BUILD_TARGET/
mkdir -p $BUILD_PATH

${UNITY_EXECUTABLE:-xvfb-run --auto-servernum --server-args='-screen 0 640x480x24' /opt/Unity/Editor/Unity} -projectPath $(pwd)/UnityProject -quit -batchmode -buildTarget $BUILD_TARGET -customBuildTarget $BUILD_TARGET -customBuildName $BUILD_NAME -customBuildPath $BUILD_PATH -executeMethod BuildCommand.PerformBuild & unitywait

UNITY_EXIT_CODE=$?

if [ $UNITY_EXIT_CODE -eq 0 ]; then
  echo "Run succeeded, no failures occurred";
elif [ $UNITY_EXIT_CODE -eq 2 ]; then
  echo "Run succeeded, some tests failed";
elif [ $UNITY_EXIT_CODE -eq 3 ]; then
  echo "Run failure (other failure)";
else
  echo "Unexpected exit code $UNITY_EXIT_CODE";
fi

ls -la $BUILD_PATH
[ -n "$(ls -A $BUILD_PATH)" ] # fail job if build folder is empty
