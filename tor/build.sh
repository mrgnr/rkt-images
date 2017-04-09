#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script requires root privileges"
    exit 1
fi

REPO_DOMAIN=rkt.mrgnr.io
COMMIT=$(git rev-parse --verify HEAD)
TOR_VERSION=0.2.9.10

acbuild --debug begin
trap "{ acbuild --debug end && exit 1; }" EXIT

acbuild --debug set-name $REPO_DOMAIN/tor
acbuild --debug label add commit $COMMIT
acbuild --debug label add version $TOR_VERSION
acbuild --debug dep add $REPO_DOMAIN/tor-base:$TOR_VERSION

acbuild --debug copy -- ./tor-service-defaults-torrc /usr/share/tor/tor-service-defaults-torrc
acbuild --debug run -- chown -R tor:tor /usr/share/tor/tor-service-defaults-torrc

acbuild --debug port add https tcp 443  # useful for bridges
acbuild --debug port add dnsport tcp 5353
acbuild --debug port add orport tcp 9001
acbuild --debug port add dirport tcp 9030
acbuild --debug port add transport tcp 9040
acbuild --debug port add socksport tcp 9050
acbuild --debug mount add data /var/lib/tor/
acbuild --debug mount add torrc /etc/tor/torrc --read-only
acbuild --debug mount add localtime /etc/localtime --read-only
acbuild --debug set-user tor
acbuild --debug set-group tor
acbuild --debug isolator add "os/linux/capabilities-retain-set" capabilities.json
acbuild --debug set-exec -- /usr/local/bin/tor --defaults-torrc /usr/share/tor/tor-service-defaults-torrc -f /etc/tor/torrc

acbuild --debug write --overwrite tor.aci
