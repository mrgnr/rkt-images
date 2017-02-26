#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script requires root privileges"
    exit 1
fi

REPO_DOMAIN=rkt.mrgnr.io
COMMIT=$(git rev-parse --verify HEAD)
ONIONBALANCE_VERSION=0.1.7

acbuild --debug begin
trap "{ acbuild --debug end && exit 1; }" EXIT

acbuild --debug set-name $REPO_DOMAIN/onionbalance
acbuild --debug label add commit $COMMIT
acbuild --debug label add version $ONIONBALANCE_VERSION
acbuild --debug dep add quay.io/coreos/alpine-sh

# Install prerequisites
acbuild --debug run -- apk update
acbuild --debug run -- apk add bash ca-certificates gcc gpgme musl-dev openssl openssl-dev py-pip python python-dev

# Fetch OnionBalance source
# https://onionbalance.readthedocs.io/en/latest/installation.html#installation
acbuild --debug run -- update-ca-certificates
acbuild --debug run -- gpg --keyserver keys.mozilla.org --recv-keys 0x7EFBDDE8FD2111AEA7BE1AA63B0D706A7FBFED86
acbuild --debug run -- wget https://github.com/DonnchaC/onionbalance/releases/download/$ONIONBALANCE_VERSION/onionbalance-$ONIONBALANCE_VERSION.tar.gz
acbuild --debug run -- wget https://github.com/DonnchaC/onionbalance/releases/download/$ONIONBALANCE_VERSION/onionbalance-$ONIONBALANCE_VERSION.tar.gz.sig
acbuild --debug run -- gpg --verify onionbalance-$ONIONBALANCE_VERSION.tar.gz.sig

# Install OnionBalance
acbuild --debug run -- pip install setuptools
acbuild --debug run -- mkdir -p onionbalance
acbuild --debug run -- tar xzf onionbalance-$ONIONBALANCE_VERSION.tar.gz -C onionbalance
acbuild --debug run -- /bin/bash -c "cd onionbalance && python setup.py install"
acbuild --debug run -- rm -rf onionbalance
acbuild --debug run -- rm onionbalance-$ONIONBALANCE_VERSION.tar.gz onionbalance-$ONIONBALANCE_VERSION.tar.gz.sig
acbuild --debug run -- rm -rf /var/cache/apk/*

acbuild --debug mount add config /etc/onionbalance/
acbuild --debug mount add localtime /etc/localtime --read-only
acbuild --debug set-exec -- /bin/sh -c /bin/sh

acbuild --debug write --overwrite onionbalance.aci
