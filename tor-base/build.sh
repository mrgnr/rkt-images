#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script requires root privileges"
    exit 1
fi

TOR_VERSION=0.2.8.6

acbuild --debug begin
trap "{ acbuild --debug end && exit 1; }" EXIT

acbuild --debug set-name mrgnr.io/tor-base
acbuild --debug dep add quay.io/coreos/alpine-sh

# Install prerequisites for building tor
acbuild --debug run -- apk update
acbuild --debug run -- apk add bash gcc gpgme libc-dev libevent libevent-dev make openssl openssl-dev zlib zlib-dev

# Fetch tor source
# https://www.torproject.org/docs/signing-keys.html.en
acbuild --debug run -- gpg --keyserver keys.mozilla.org --recv-keys 0xB35BF85BF19489D04E28C33C21194EBB165733EA
acbuild --debug run -- wget https://www.torproject.org/dist/tor-$TOR_VERSION.tar.gz
acbuild --debug run -- wget https://www.torproject.org/dist/tor-$TOR_VERSION.tar.gz.asc
acbuild --debug run -- gpg --verify tor-$TOR_VERSION.tar.gz.asc

# Build and install tor
acbuild --debug run -- tar xzf tor-$TOR_VERSION.tar.gz
acbuild --debug run -- /bin/bash -c "cd tor-$TOR_VERSION && ./configure && make && make install"
acbuild --debug run -- rm -rf tor-$TOR_VERSION
acbuild --debug run -- rm tor-$TOR_VERSION.tar.gz tor-$TOR_VERSION.tar.gz.asc
acbuild --debug run -- rm -rf /var/cache/apk/*
acbuild --debug run -- adduser -D -g tor -s /sbin/nologin tor
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

acbuild --debug set-exec -- /bin/sh -c /bin/sh

acbuild --debug write --overwrite tor-base.aci
