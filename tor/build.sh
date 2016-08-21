#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script requires root privileges"
    exit 1
fi

acbuild --debug begin ../tor-base/tor-base.aci
trap "{ acbuild --debug end && exit 1; }" EXIT

acbuild --debug set-name mrgnr.io/tor

acbuild --debug copy -- ./tor-service-defaults-torrc /usr/share/tor/tor-service-defaults-torrc
acbuild --debug run -- chown -R tor:tor /usr/share/tor/tor-service-defaults-torrc

acbuild --debug port add https tcp 443  # useful for bridges
acbuild --debug port add dnsport tcp 5353
acbuild --debug port add orport tcp 9001
acbuild --debug port add dirport tcp 9030
acbuild --debug port add transport tcp 9040
acbuild --debug port add socksport tcp 9050
acbuild --debug mount add torrc /etc/tor/torrc --read-only
acbuild --debug set-exec -- /usr/local/bin/tor --defaults-torrc /usr/share/tor/tor-service-defaults-torrc -f /etc/tor/torrc

acbuild --debug write --overwrite tor.aci
