#!/usr/bin/env bash
set -e

ARCHIVE=ubuntu-base-16.04-core-amd64.tar.gz
BASE_URL=http://cdimage.ubuntu.com/ubuntu-base/releases/16.04.1/release

# Download Ubuntu 16.04 rootfs
stat SHA256SUMS || wget $BASE_URL/SHA256SUMS
stat SHA256SUMS.gpg || wget $BASE_URL/SHA256SUMS.gpg
stat $ARCHIVE || wget $BASE_URL/$ARCHIVE

# Verify integrity of downloaded rootfs
ERROR="Error: The integrity of the downloaded rootfs could not be verified!"
trap 'exit_code=$? && ([ $exit_code -eq 0 ] || echo $ERROR) && exit $exit_code;' EXIT
gpg --keyserver hkp://keyserver.ubuntu.com \
    --recv-keys 0xC5986B4F1257FFA86632CBA746181433FBB75451 0x843938DF228D22F7B3742BC0D94AA3F0EFE21092
gpg --verify SHA256SUMS.gpg SHA256SUMS
sha256sum -c SHA256SUMS 2>/dev/null | grep "$ARCHIVE: OK"
