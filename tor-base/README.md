# Tor Base

This is a base image for applications that use [Tor][tor-project]. The build script for this image
downloads the Tor [source code][tor-source], builds Tor, and installs it.

Note that Tor requires very specific ownership and permissions for certain directories, including
`/var/lib/tor`, `/var/run/tor`, and `/var/log/tor`. In this image, these directories are owned by
the user `tor` with uid 9001. If these directories are mounted from the host, they must have the
permissions given in the build file and owned by a user on the host with uid 9001.

## Usage

Fetch the image:

```
$ sudo rkt fetch rkt.mrgnr.io/tor-base
```

To use this image as the base for another image, specify `tor-base` in your
[`acbuild begin`][acbuild-begin] command:

```
acbuild begin rkt.mrgnr.io/tor-base
```

You can also add `tor-base` as a [dependency][acbuild-dependency] of another image:

```
acbuild dep add rkt.mrgnr.io/tor-base
```

You can run a shell using `tor-base` with:

```
$ sudo rkt run --interactive rkt.mrgnr.io/tor-base
```


[tor-project]: https://www.torproject.org/
[tor-source]: https://www.torproject.org/download
[acbuild-begin]: https://github.com/containers/build/blob/master/Documentation/subcommands/begin.md
[acbuild-dependency]: https://github.com/containers/build/blob/master/Documentation/subcommands/dependency.md
