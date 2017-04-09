#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script requires root privileges"
    exit 1
fi

REPO_DOMAIN=rkt.mrgnr.io
COMMIT=$(git rev-parse --verify HEAD)
NGINX_VERSION=1.8.1
NGINX_VERSION_SUFFIX=-r1

acbuild --debug begin
trap "{ acbuild --debug end && exit 1; }" EXIT

acbuild --debug set-name $REPO_DOMAIN/nginx
acbuild --debug label add commit $COMMIT
acbuild --debug label add version $NGINX_VERSION
acbuild --debug dep add quay.io/coreos/alpine-sh

acbuild --debug run -- apk update
acbuild --debug run -- apk add bash ca-certificates nginx=$NGINX_VERSION$NGINX_VERSION_SUFFIX

acbuild --debug port add http tcp 80
acbuild --debug port add https tcp 443
acbuild --debug isolator add "os/linux/capabilities-retain-set" capabilities.json
acbuild --debug set-exec -- /usr/sbin/nginx -g "daemon off;"

acbuild --debug write --overwrite nginx.aci
