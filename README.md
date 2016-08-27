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

The build script will produce a `.aci` file which you can import with rkt:

```
$ sudo rkt --insecure-options=image fetch ./tor-base.aci

$ sudo rkt image list
ID                  NAME                    IMPORT TIME     LAST USED       SIZE    LATEST
sha512-4d873d5b1f86	rkt.mrgnr.io/tor-base   14 minutes ago  14 minutes ago  295MiB  true
```

Note the use of the `--insecure-options=image` flag, which is used to disable image signature
verifcation. You should only use this flag for development purposes. If you distribute your images,
be sure to properly [sign and verify](https://coreos.com/rkt/docs/latest/signing-and-verification-guide.html)
them.

## Using pre-built images

You can download pre-built images for this repo from [https://rkt.mrgnr.io](https://rkt.mrgnr.io).
First, run `rkt trust` to trust images from `rkt.mrgnr.io` that are signed using
[my key](https://keybase.io/mrgnr/key.asc).

```
$ sudo rkt trust --prefix rkt.mrgnr.io https://keybase.io/mrgnr/key.asc
```

Verify that the output contains the same fingerprints as below:

```
gpg key fingerprint is: 3C59 695D 35AF 3F3F 8D07  A9F7 272B CF46 796C A791
    Subkey fingerprint: 77EE D522 FAE0 9A31 41B2  FE18 3F98 A921 D31E 62D9
```

Now you can fetch images and signatures will be verified automatically:

```
$ sudo rkt fetch rkt.mrgnr.io/tor
```
