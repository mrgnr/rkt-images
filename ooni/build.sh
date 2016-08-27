#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script requires root privileges"
    exit 1
fi

REPO_DOMAIN=rkt.mrgnr.io

acbuild --debug begin
trap "{ acbuild --debug end && exit 1; }" EXIT

acbuild --debug set-name $REPO_DOMAIN/ooni
acbuild --debug dep add $REPO_DOMAIN/tor-base

acbuild --debug run -- apk update
acbuild --debug run -- apk add bash build-base geoip geoip-dev libdnet libdnet-dev libffi \
    libffi-dev libpcap libpcap-dev openssl openssl-dev py-pip python python-dev tcpdump
acbuild --debug run -- mv /usr/sbin/tcpdump /usr/bin  # workaround for unknown issue.. maybe need to set net_admin capability?
acbuild --debug run -- pip install ooniprobe

acbuild --debug set-exec -- /usr/bin/ooniprobe

acbuild --debug write --overwrite ooni.aci
