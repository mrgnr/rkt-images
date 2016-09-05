#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script requires root privileges"
    exit 1
fi

REPO_DOMAIN=rkt.mrgnr.io
COMMIT=$(git rev-parse --verify HEAD)

acbuild --debug begin
trap "{ acbuild --debug end && exit 1; }" EXIT

acbuild --debug set-name $REPO_DOMAIN/tools
acbuild --debug label add commit $COMMIT
acbuild --debug label add version latest
acbuild --debug dep add quay.io/coreos/alpine-sh

acbuild --debug run -- apk update
acbuild --debug run -- apk add bash curl htop net-tools nload nmap python py-pip strace tcpdump \
    tcptraceroute the_silver_searcher tree
acbuild --debug run -- pip install httpie

acbuild --debug set-exec -- /bin/sh -c /bin/bash

acbuild --debug write --overwrite tools.aci
