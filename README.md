# Mesos Cookbook [![Build Status](https://travis-ci.org/evertrue/et_mesos-cookbook.png?branch=master)](https://travis-ci.org/evertrue/et_mesos-cookbook)

Install Mesos (<http://mesos.apache.org/>) and configure mesos master and slave.
This cookbook also supports installation by both bulding from source and with [Mesosphere](http://mesosphere.io) package.
You can switch installation type using the `node[:et_mesos][:type]` attribute (`source` or `mesosphere`).

All credit to @everpeace for the basis for this cookbook, [everpeace/cookbook-mesos](https://github.com/everpeace/cookbook-mesos).

## Platform

Currently only supports `ubuntu` and `centos`. But `centos` support is  experimental.

If you would use `cgroups` isolator or `docker` containerizer, Ubuntu 14.04 is highly recommended. Note that `docker` containerizer is only supported by Mesos 0.20.0+.

## Installation Type

You have to specify intallation type (`source` or `mesosphere`) by setting `node[:et_mesos][:type]` variable.

Currently this cookbook defaults to build mesos from source, i.e.
`node[:et_mesos][:type]` is set to `source`.

## Recipes

### et_mesos::default

Install mesos using `source` recipe or `mesosphere` recipe, depending
on what the `node[:et_mesos][:type]` attribute is set to (`source` or `mesosphere`).

### et_mesos::source

Build and install Mesos from source (downloads from [GitHub](https://github.com/apache/mesos), configure, make, make install).

### et_mesos::mesosphere

Install Mesos using Mesosphere's `mesos` package.
You can also install `zookeeper` package by `node[:et_mesos][:mesosphere][:with_zookeeper]` if required because Mesosphere's Mesos package doesn't include ZooKeeper.

### et_mesos::master

Configure master and cluster deployment configuration files, and start
`mesos-master`.

* `node[:et_mesos][:deploy_dir]/masters`
* `node[:et_mesos][:deploy_dir]/slaves`
* `node[:et_mesos][:deploy_dir]/mesos-deploy-env.sh`
* `node[:et_mesos][:deploy_dir]/mesos-master-env.sh`

Furthermore, this recipe will also configure upstart configuration files.

* `/etc/mesos/zk`
* `/etc/defaults/mesos`
* `/etc/defaults/mesos-master`

#### How to configure `mesos-master`

You can configure `mesos-master` command line options using the `node[:et_mesos][:master]` attribute.

If you have a configuration as shown below:

```
node[:et_mesos][:master] = {
  port:    "5050",
  log_dir: "/var/log/mesos",
  zk:      "zk://localhost:2181/mesos",
  cluster: "MyCluster",
  quorum:  "1"
}
```

Then `mesos-master` will be invoked with command line options like this:

```
mesos-master --zk=zk://localhost:2181/mesos --port=5050 --log_dir=/var/log/mesos --cluster=MyCluster
```

See the [latest Mesos config docs](http://mesos.apache.org/documentation/latest/configuration/) for available options or the output of `mesos-master --help`.

### et_mesos::slave

Configure slave configuration files, and start `mesos-slave`.

* `node[:et_mesos][:deploy_dir]/mesos-slave-env.sh`

Furthermore, this recipe also configures upstart configuration files.

* `/etc/mesos/zk`
* `/etc/defaults/mesos`
* `/etc/defaults/mesos-slave`

#### How to configure `mesos-slave`

You can configure `mesos-slave` command line options by `node[:et_mesos][:slave]` hash.
If you have a configuration as shown below:

```
node[:et_mesos][:slave] = {
  master:         'zk://localhost:2181/mesos',
  log_dir:        '/var/log/mesos',
  containerizers: 'docker,mesos',
  isolation:      'cgroups/cpu,cgroups/mem',
  work_dir:       '/var/run/work'
}
```

Then `mesos-slave` will be invoked with command line options like this:

```
mesos-slave --master=zk://localhost:2181/mesos --log_dir=/var/log/mesos --containerizers=docker,mesos --isolation=cgroups/cpu,cgroups/mem --work_dir=/var/run/work
```

See the [latest Mesos config docs](http://mesos.apache.org/documentation/latest/configuration/) for available options or the output of `mesos-slave --help`.

## Usage

Wrap this cookbook, setting the `node[:et_mesos][:type]` attribute as appropriate for your installation, and `include_recipe 'et_mesos::master'` or `include_recipe 'et_mesos::slave'`, depending on what part of the cluster you need to provision.

The recommendation would be to have two wrapper cookbooks, one for the master(s), and another for your slave(s).

## Attributes

<table>
    <tr>
        <th>Key</th>
        <th>Type</th>
        <th>Description</th>
        <th>Default</th>
    </tr>
    <tr>
        <td><tt>[:et_mesos][:type]</tt></td>
        <td>String</td>
        <td>installation type(<tt>source</tt> or <tt>mesosphere</tt>)</td>
        <td><tt>source</tt></td>
    </tr>
    <tr>
        <td><tt>[:et_mesos][:version]</tt></td>
        <td>String</td>
        <td>Version(branch or tag name at <a href="http://github.com/apache/mesos">http://github.com/apache/mesos</a>).</td>
        <td><tt>0.22.1</tt></td>
    </tr>
    <tr>
        <td><tt>[:et_mesos][:prefix]</tt></td>
        <td>String</td>
        <td>Prefix value to be passed to configure script for building from source.
        <td><tt>/usr/local</tt></td>
    </tr>
    <tr>
        <td><tt>[:et_mesos][:home]</tt></td>
        <td>String</td>
        <td>Directory which mesos sources are extracted to(<tt>node[:et_mesos][:home]/mesos</tt>).</td>
        <td><tt>/opt</tt></td>
    </tr>
    <tr>
        <td><tt>[:et_mesos][:build][:skip_test]</tt></td>
        <td>Boolean</td>
        <td>Flag whether test will be performed on the build before installing.</td>
        <td><tt>true</tt></td>
    </tr>
    <tr>
        <td><tt>[:et_mesos][:mesosphere][:with_zookeeper]</tt></td>
        <td>String</td>
        <td>Flag for installing zookeeper package, only applies to <tt>[:et_mesos][:type] = mesosphere</tt>.</td>
        <td><tt>false</tt></td>
    </tr>
    <tr>
        <td><tt>[:et_mesos][:ssh_opt]</tt></td>
        <td>String</td>
        <td>ssh options to be used in <tt>mesos-[start|stop]-cluster</tt></td>
        <td><tt>-o StrictHostKeyChecking=no <br> -o ConnectTimeout=2</tt></td>
    </tr>
    <tr>
        <td><tt>[:et_mesos][:deploy_with_sudo]</tt></td>
        <td>String</td>
        <td>Flag whether sudo will be used in <tt>mesos-[start|stop]-cluster</tt></td>
        <td><tt>1</tt></td>
    </tr>
    <tr>
        <td><tt>[:et_mesos][:cluster_name]</tt></td>
        <td>String</td>
        <td>[OBSOLETE] Human readable name for the cluster, displayed at webui. </td>
        <td><tt>MyCluster</tt></td>
    </tr>
    <tr>
        <td><tt>[:et_mesos][:master_ips]</tt></td>
        <td>Array of String</td>
        <td>IP list of masters used in <tt>mesos-[start|stop]-cluster</tt></td>
        <td>[ ]</td>
    </tr>
    <tr>
        <td><tt>[:et_mesos][:slave_ips]</tt></td>
        <td>Array of String</td>
        <td>IP list of slaves used in <tt>mesos-[start|stop]-cluster</tt></td>
        <td>[ ]</td>
    </tr>
    <tr>
        <td><tt>[:et_mesos][:master][:zk]</tt></td>
        <td>String</td>
        <td>[REQUIRED(0.19.1+)] ZooKeeper URL (used for leader election amongst masters). May be one of:<br>
        zk://host1:port1,host2:port2,…path<br>
        zk://username:password@host1:port1,host2:port2,…/path<br>
        file://path/to/file (where file contains one of the above)</td>
        <td></td>
    </tr>
    <tr>
        <td><tt>[:et_mesos][:master][:work_dir]</tt></td>
        <td>String</td>
        <td>[REQUIRED(0.19.1+)] Where to store the persistent information stored in the Registry.</td>
        <td><tt>/tmp/mesos</tt></td>
    </tr>
    <tr>
        <td><tt>[:et_mesos][:master][:quorum]</tt></td>
        <td>String</td>
        <td>[REQUIRED(0.19.1+)] The size of the quorum of replicas when using “replicated_log” based registry. It is imperative to set this value to be a majority of masters, i.e., quorum > (number of masters) / 2.</td>
        <td></td>
    </tr>
    <tr>
        <td><tt>[:et_mesos][:master][:option_name]</tt></td>
        <td>String</td>
        <td>You can set arbitrary command line option for <tt>mesos-master</tt>, replace `option_name` with the key for the option to set. See the <a href="http://mesos.apache.org/documentation/latest/configuration/">latest Mesos config docs</a> for available options, or the output of `mesos-master --help`.</td>
        <td></td>
    </tr>
    <tr>
        <td><tt>[:et_mesos][:slave][:master]</tt></td>
        <td>String</td>
        <td>[REQUIRED] mesos master url.This should be ip:port for non-ZooKeeper based masters, otherwise a zk:// . when <tt>mesosphere</tt>, you should set zk:// address. </td>
        <td></td>
    </tr>
    <tr>
        <td><tt>[:et_mesos][:slave][:option_name]</tt></td>
        <td>String</td>
        <td>Like <tt>[:et_mesos][:master][:option_name]</tt> above, arbitrary options may be specified as a key for a slave by replacing `option_name` with your option’s key.</td>
        <td></td>
    </tr>
</table>

## Testing

There are a couple of test suites in place:

* `chefspec` for unit tests.
* `test-kitchen` with `serverspec` for integration tests (using `vagrant`).

These test both `source` and `mesosphere` type installations (using both the `master` and `slave` recipes).

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License

MIT License.  see [LICENSE.txt](LICENSE.txt)

(Please note that before 2015-02-06-18:00 PST, this project is opened under Apache License, Version 2.0. See also [README.md in old version](https://github.com/evertrue/et_mesos-cookbook/blob/b9e660382affaba7c3906367fbd135e0de49de02/README.md#license))
