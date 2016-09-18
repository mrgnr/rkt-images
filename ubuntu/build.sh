#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script requires root privileges"
    exit 1
fi

REPO_DOMAIN=rkt.mrgnr.io
COMMIT=$(git rev-parse --verify HEAD)
UBUNTU_VERSION=16.04

acbuild --debug begin ./ubuntu-base-16.04-core-amd64.tar.gz
trap 'exit_code=$? && acbuild --debug end && exit $exit_code;' EXIT

acbuild --debug set-name $REPO_DOMAIN/ubuntu
acbuild --debug label add commit $COMMIT
acbuild --debug label add version $UBUNTU_VERSION
acbuild --debug set-exec -- /bin/bash

acbuild --debug write --overwrite ubuntu.aci
