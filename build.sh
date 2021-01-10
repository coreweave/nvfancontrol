#!/bin/bash
set -e

sudo apt-get -y install libxnvctrl-dev

cargo build --release --features=dynamic-xnvctrl
