#!/bin/bash

set -e

BASEDIR="$(dirname $(realpath $0))"
CONFIG=$1
COMMIT=${2:-edcc18778f465a95c7196d41c36066be40a13bad}

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

: "${BUILD:=$BASEDIR/build}"

BUILD=$(realpath $BUILD)

mkdir -p "$BUILD/source"
mkdir -p "$BUILD/build"

if [ ! -d "$BUILD/source/hcbs" ]; then
    git clone \
        --depth 1 \
        https://github.com/Yurand2000/HCBS-patch.git \
        "$BUILD/source/hcbs"
fi

(
    cd $BUILD/source/hcbs
    git fetch --depth 1 origin $COMMIT
    git checkout FETCH_HEAD
)

SOURCE_DIR="$BUILD/source/hcbs"
CONFIG_NAME=$(basename -s .config "$CONFIG")
BUILD_DIR="$BUILD/build/$CONFIG_NAME-$COMMIT/kernel"

mkdir -p "$BUILD_DIR"

cp "$CONFIG" "$BUILD_DIR/.config"
make -C "$SOURCE_DIR" O="$BUILD_DIR" olddefconfig
"$SOURCE_DIR/scripts/config" --file "$BUILD_DIR/.config" --disable SYSTEM_TRUSTED_KEYS
"$SOURCE_DIR/scripts/config" --file "$BUILD_DIR/.config" --disable SYSTEM_REVOCATION_KEYS
"$SOURCE_DIR/scripts/kconfig/merge_config.sh" -O "$BUILD_DIR" -m "$BUILD_DIR/.config" "$BASEDIR/hcbs.config"
make -C "$SOURCE_DIR" O="$BUILD_DIR" olddefconfig

make -C "$BUILD_DIR" -j $(nproc) bindeb-pkg \
    EXTRAVERSION="-hcbs" \
    DEBEMAIL="yurand2000@gmail.com" \
    DEBFULLNAME="Yuri Andriaccio"