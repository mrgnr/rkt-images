#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script requires root privileges"
    exit 1
fi

REPO_DOMAIN=rkt.mrgnr.io
COMMIT=$(git rev-parse --verify HEAD)
TOR_VERSION=0.2.9.9

acbuild --debug begin
trap "{ acbuild --debug end && exit 1; }" EXIT

acbuild --debug set-name $REPO_DOMAIN/tor-base
acbuild --debug label add commit $COMMIT
acbuild --debug label add version $TOR_VERSION
acbuild --debug dep add quay.io/coreos/alpine-sh

# Install prerequisites for building tor
acbuild --debug run -- apk update
acbuild --debug run -- apk add bash gcc gpgme libc-dev libevent libevent-dev make openssl openssl-dev zlib zlib-dev

# Fetch tor source
# https://www.torproject.org/docs/signing-keys.html.en
acbuild --debug run -- gpg --keyserver keys.mozilla.org --recv-keys 0x2133BC600AB133E1D826D173FE43009C4607B1FB
acbuild --debug run -- wget https://www.torproject.org/dist/tor-$TOR_VERSION.tar.gz
acbuild --debug run -- wget https://www.torproject.org/dist/tor-$TOR_VERSION.tar.gz.asc
acbuild --debug run -- gpg --verify tor-$TOR_VERSION.tar.gz.asc

# Build and install tor
acbuild --debug run -- tar xzf tor-$TOR_VERSION.tar.gz
acbuild --debug run -- /bin/bash -c "cd tor-$TOR_VERSION && ./configure && make && make install"
acbuild --debug run -- rm -rf tor-$TOR_VERSION
acbuild --debug run -- rm tor-$TOR_VERSION.tar.gz tor-$TOR_VERSION.tar.gz.asc
acbuild --debug run -- rm -rf /var/cache/apk/*
acbuild --debug run -- adduser -u 9001 -D -g tor -s /sbin/nologin tor
acbuild --debug run -- mkdir -p /etc/tor
acbuild --debug run -- mkdir -p /usr/share/tor
acbuild --debug run -- mkdir -p /var/lib/tor
acbuild --debug run -- mkdir -p /var/run/tor
acbuild --debug run -- mkdir -p /var/log/tor
acbuild --debug run -- touch /var/log/tor/log
acbuild --debug run -- touch /etc/tor/torrc
acbuild --debug run -- chown -R tor:tor /etc/tor
acbuild --debug run -- chown -R tor:tor /usr/share/tor
acbuild --debug run -- chown -R tor:tor /var/lib/tor
acbuild --debug run -- chown -R tor:tor /var/run/tor
acbuild --debug run -- chown -R tor:tor /var/log/tor
acbuild --debug run -- chmod -R 2700 /var/lib/tor
acbuild --debug run -- chmod -R 2750 /var/run/tor
acbuild --debug run -- chmod -R 2750 /var/log/tor

acbuild --debug set-user tor
acbuild --debug set-group tor
acbuild --debug set-exec -- /bin/sh -c /bin/sh

acbuild --debug write --overwrite tor-base.aci
