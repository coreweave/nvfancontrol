#!/bin/bash
# Build the binary inside Docker container.
set -e

docker build -t builder-nvfancontrol -f - . <<EOF
FROM ubuntu:18.04

RUN apt-get -y update && \
    apt-get -y install curl build-essential \
    libx11-dev libxext-dev libxnvctrl-dev

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /repo

ADD . /repo

RUN cargo build --release --features=dynamic-xnvctrl
EOF

CID=$(docker create builder-nvfancontrol)

mkdir -p build/
docker cp $CID:/repo/target/release/nvfancontrol build/

docker rm $CID

echo "Build artifacts:"
ls -al build/
