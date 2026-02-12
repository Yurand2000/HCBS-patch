#!/bin/bash

set -e

DIR="$(dirname $(realpath $0))/../.."
CONFIG=$1
COMMIT=$2

if [ ! -f "$CONFIG" ]; then
    echo "Config file not provided"
    echo "Usage: $0 <CONFIG_FILE>"
    exit 1
fi

if !(echo "$CONFIG" | grep ".config$" - > /dev/null); then
    echo "Config file must end with .config"
    echo "Usage: $0 <CONFIG_FILE>"
    exit 1
fi

CONFIG_NAME=$(basename "$CONFIG")
CONFIG=$(realpath "$CONFIG")

docker build \
    -t ubuntu_22_04_hcbs_build \
    -f "$DIR/containers/ubuntu/ubuntu_22_04.dockerfile" .

docker run --rm \
    --volume "$CONFIG:/config/$CONFIG_NAME:ro" \
    --volume "$DIR/build_debpkg_from_config.sh:/scripts/build_debpkg_from_config.sh" \
    --volume "$DIR/hcbs.config:/scripts/hcbs.config" \
	--volume "$DIR/build:/build:rw" \
    -e BUILD=/build \
    ubuntu_22_04_hcbs_build \
    sh /scripts/build_debpkg_from_config.sh /config/$CONFIG_NAME $COMMIT