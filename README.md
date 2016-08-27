# rkt images

## Building images

To build rkt images, you need to install the [`acbuild`](https://github.com/appc/acbuild) command
line tool. To automate the installation of both `acbuild` and `rkt` using
[Ansible](https://github.com/ansible/ansible), you can use my
[`rkt` role](https://github.com/mrgnr/roles/tree/master/rkt).

Each directory in this repo contains a `build.sh` script that can be used to build an image, e.g:

```
$ cd tor-base && sudo ./build
```

The build script will produce a `.aci` file which you can import with rkt, e.g.:

```
$ sudo rkt --insecure-options=image fetch ./tor-base.aci

$ sudo rkt image list
ID                  NAME                    SIZE    IMPORT TIME     LAST USED
sha512-9143900eeb0b rkt.mrgnr.io/tor-base   605MiB  22 seconds ago  11 seconds ago
```

Note the use of the `--insecure-options=image` flag, which is used to disable image signature
verifcation. You should only use this flag for development purposes. If you distribute your images,
be sure to properly [sign and verify](https://coreos.com/rkt/docs/latest/signing-and-verification-guide.html)
them.
