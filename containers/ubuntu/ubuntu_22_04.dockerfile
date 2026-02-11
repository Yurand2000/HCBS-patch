# Use the official Ubuntu image
FROM ubuntu:22.04

# Install required packages
RUN apt-get update && apt-get install -y \
    build-essential \
    libncurses-dev \
    bison \
    flex \
    libssl-dev \
    libelf-dev \
    git \
    linux-source \
    wget \
    lsb-core \
    kmod \
    libdw-dev:native \
    zstd

# Entry point
CMD ["/bin/bash"]
