#!/bin/bash

BASEDIR="$(dirname $(realpath $0))"

: "${BUILD:=$BASEDIR/build}"

mkdir -p "$BUILD/source"
mkdir -p "$BUILD/config"

if [ ! -d "$BUILD/source/ubuntu-noble" ]; then
    git clone --depth 1 git://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/noble $BUILD/source/ubuntu-noble
fi

cd $BUILD/source/ubuntu-noble

./debian/scripts/misc/annotations --arch amd64 --flavour low-latency --export \
    > $BUILD/config/ubuntu-noble-amd64.config