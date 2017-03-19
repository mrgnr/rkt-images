# OnionBalance

This image runs [OnionBalance][onionbalance], a load balancing application for Tor hidden services.

## Usage

First, fetch the images:

```
$ sudo rkt fetch rkt.mrgnr.io/tor
$ sudo rkt fetch rkt.mrgnr.io/onionbalance
```

### Generating configuration

You can generate all the necessary configuration files for OnionBalance and your hidden services
using the [`onionbalance-config`][onionbalance-config] command. This will generate the OnionBalance
config file, the OnionBalance private key, a sample `torrc` for the OnionBalance tor process, and
`torrc` files and private keys for your backend hidden services.

```
$ sudo mkdir /config
$ sudo rkt run \
    --volume=localtime,kind=host,source=/etc/localtime \
    --volume=config,kind=host,source=/config \
    rkt.mrgnr.io/onionbalance \
    --exec onionbalance-config \
    -- \
    --output /etc/onionbalance \
    --tag my_hidden_service \
    -n 2 \
    --service-virtual-port 80 \
    --service-target 127.0.0.1:80
```

The above commands will create OnionBalance configuration for two backend hidden services using
virtual port 80 and targeting 127.0.0.1:80. Files are written to `/config` on the host:

```
$ sudo tree /config
/config
├── master
│   ├── config.yaml
│   ├── torrc-server
│   └── xxqw7pvk5oap7zvn.key
├── my_hidden_service1
│   ├── instance_torrc
│   └── rkssknjd2bb4hie7
│       └── private_key
└── my_hidden_service2
    ├── hoemd6me4lu57i7o
    │   └── private_key
    └── instance_torrc
```

### Configuring backend hidden services

Your backend hidden services can run on separate machines from OnionBalance. For high availabilty,
it's best to run your backend services accross multiple machines. Use the files in
`/config/my_hidden_service*` to configure your backend hidden services. See the the
[official documentation][configure-hidden-services] for more information.

### Configuring the host

On the host where OnionBalance will be run, create a configuration directory and copy files there:

```
$ sudo mkdir -p /etc/onionbalance
$ sudo cp /config/master/* /etc/onionbalance
```

OnionBalance communicates with a running tor process in order to publish service descriptors to the
Tor network. It's easiest to run the `rkt.mrgnr.io/tor` image in a pod alongside OnionBalance. The
`rkt.mrgnr.io/tor` image mounts its data directory from the host, so you'll need to set the proper
permissions on the host directory so that the tor process running in the container can access it.
Create a `tor` user on the host with uid 9001 and a tor data directory with the proper permissions:

```
$ sudo useradd -MU -u 9001 -s /sbin/nologin tor
$ sudo mkdir -p /var/lib/onionbalance-tor
$ sudo chown tor:tor /var/lib/onionbalance-tor
$ sudo chmod 2700 /var/lib/onionbalance-tor
```

### Running OnionBalance

The command below runs OnionBalance and Tor together in a pod. Tor reads its `torrc` file from
`/etc/onionbalance/torrc-server` mounted from the host. Likewise, the tor data directory is mounted
from `/var/lib/onionbalance-tor` on the host and the OnionBalance configuration directory is mounted
from `/etc/onionbalance/` on the host.

```
$ sudo rkt run \
    --volume=localtime,kind=host,source=/etc/localtime \
    --volume=config,kind=host,source=/etc/onionbalance/ \
    --volume=torrc,kind=host,source=/etc/onionbalance/torrc-server \
    --volume=data,kind=host,source=/var/lib/onionbalance-tor \
    --dns=8.8.8.8 --dns=8.8.4.4 \
    rkt.mrgnr.io/tor \
    rkt.mrgnr.io/onionbalance
```


[onionbalance]: https://github.com/DonnchaC/onionbalance
[onionbalance-config]: https://onionbalance.readthedocs.io/en/latest/onionbalance-config.html
[configure-hidden-services]: https://www.torproject.org/docs/tor-hidden-service.html.en
