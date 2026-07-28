#!/bin/bash

set -e
set -x

PYTHON_VERSION=$1

WHEEL_PATH=$(ls dist/*.whl)

# Dot the Python version for identifying the base Docker image.
PYTHON_DOCKER_IMAGE_PART="${PYTHON_VERSION:0:1}.${PYTHON_VERSION:1:2}"

DOCKER_IMAGE="winamd64/python:${PYTHON_DOCKER_IMAGE_PART}-windowsservercore"
MNT_FOLDER="C:/mnt"
CONTAINER_ID=$(docker run -it -v "$(cygpath -w "$PWD"):$MNT_FOLDER" -d "$DOCKER_IMAGE")

function exec_inside_container() {
    docker exec "$CONTAINER_ID" powershell -Command "$1"
}

exec_inside_container "python -m venv C:/venv"
exec_inside_container "C:/venv/Scripts/python -m pip install $MNT_FOLDER/$WHEEL_PATH"
exec_inside_container "C:/venv/Scripts/python -c 'import sklearn; sklearn.show_versions()'"
# Running the estimator checks is a good enough check to make sure we bundled
# correctly the shared libraries on Windows, while still being reasonably fast
# to run.
exec_inside_container "C:/venv/Scripts/python -m sklearn.utils.tests.test_estimator_checks"
