# Mesos Cookbook [![Build Status](https://travis-ci.org/evertrue/et_mesos-cookbook.png?branch=master)](https://travis-ci.org/evertrue/et_mesos-cookbook)

Install Mesos (<http://mesos.apache.org/>) and configure mesos master and slave.
This cookbook installs Mesos using [Mesosphere](http://mesosphere.io) packages.

All credit to @everpeace for the basis for this cookbook, [everpeace/cookbook-mesos](https://github.com/everpeace/cookbook-mesos).

## Platform

Currently only supports `ubuntu` and `centos`. But `centos` support is  experimental.

If you would use `cgroups` isolator or `docker` containerizer, Ubuntu 14.04 is highly recommended. Note that `docker` containerizer is only supported by Mesos 0.20.0+.

## Recipes

### et_mesos::default

Install Java and Mesos, with platform-dependent switches in place.

### et_mesos::package

Install Mesos using Mesosphere's `mesos` package.

One should use the [`zookeeper` cookbook](https://supermarket.chef.io/cookbooks/zookeeper) to provision a well-configured ZooKeeper instance or cluster of instances. There is a caveat to this: the `mesos` package on Ubuntu installs the `zookeeper` package, so co-locating Mesos and ZooKeeper using that cookbook is tricky, at best. A separate ZK cluster is encouraged.

### et_mesos::master

Configure master and cluster deployment configuration files, and start
`mesos-master`.

* `node['et_mesos']['deploy_dir']/masters`
* `node['et_mesos']['deploy_dir']/slaves`
* `node['et_mesos']['deploy_dir']/mesos-deploy-env.sh`
* `node['et_mesos']['deploy_dir']/mesos-master-env.sh`

Furthermore, this recipe will also configure upstart configuration files.

* `/etc/mesos/zk`
* `/etc/defaults/mesos`
* `/etc/defaults/mesos-master`

#### How to configure `mesos-master`

You can configure `mesos-master` command line options using the `node['et_mesos']['master']` attribute.

If you have a configuration as shown below:

```
node['et_mesos']['master'] = {
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

* `node['et_mesos']['deploy_dir']/mesos-slave-env.sh`

Furthermore, this recipe also configures upstart configuration files.

* `/etc/mesos/zk`
* `/etc/defaults/mesos`
* `/etc/defaults/mesos-slave`

#### How to configure `mesos-slave`

You can configure `mesos-slave` command line options by `node['et_mesos']['slave']` hash.
If you have a configuration as shown below:

```
node['et_mesos']['slave'] = {
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

Wrap this cookbook and `include_recipe 'et_mesos::master'` or `include_recipe 'et_mesos::slave'`, depending on what part of the cluster you need to provision.

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
        <td><tt>['et_mesos']['version']</tt></td>
        <td>String</td>
        <td>Version(branch or tag name at <a href="http://github.com/apache/mesos">http://github.com/apache/mesos</a>).</td>
        <td><tt>0.22.1</tt></td>
    </tr>
    <tr>
        <td><tt>['et_mesos']['ssh_opt']</tt></td>
        <td>String</td>
        <td>ssh options to be used in <tt>mesos-[start|stop]-cluster</tt></td>
        <td><tt>-o StrictHostKeyChecking=no <br> -o ConnectTimeout=2</tt></td>
    </tr>
    <tr>
        <td><tt>['et_mesos']['deploy_with_sudo']</tt></td>
        <td>String</td>
        <td>Flag whether sudo will be used in <tt>mesos-[start|stop]-cluster</tt></td>
        <td><tt>1</tt></td>
    </tr>
    <tr>
        <td><tt>['et_mesos']['cluster_name']</tt></td>
        <td>String</td>
        <td>[OBSOLETE] Human readable name for the cluster, displayed at webui. </td>
        <td><tt>MyCluster</tt></td>
    </tr>
    <tr>
        <td><tt>['et_mesos']['master_ips']</tt></td>
        <td>Array of String</td>
        <td>IP list of masters used in <tt>mesos-[start|stop]-cluster</tt></td>
        <td>[ ]</td>
    </tr>
    <tr>
        <td><tt>['et_mesos']['slave_ips']</tt></td>
        <td>Array of String</td>
        <td>IP list of slaves used in <tt>mesos-[start|stop]-cluster</tt></td>
        <td>[ ]</td>
    </tr>
    <tr>
        <td><tt>['et_mesos']['zk']</tt></td>
        <td>String</td>
        <td>[REQUIRED(0.19.1+)] ZooKeeper URL (used for leader election amongst masters). May be one of:<br>
        zk://host1:port1,host2:port2,…path<br>
        zk://username:password@host1:port1,host2:port2,…/path<br>
        file://path/to/file (where file contains one of the above)</td>
        <td></td>
    </tr>
    <tr>
        <td><tt>['et_mesos']['master']['work_dir']</tt></td>
        <td>String</td>
        <td>[REQUIRED(0.19.1+)] Where to store the persistent information stored in the Registry.</td>
        <td><tt>/tmp/mesos</tt></td>
    </tr>
    <tr>
        <td><tt>['et_mesos']['master']['quorum']</tt></td>
        <td>String</td>
        <td>[REQUIRED(0.19.1+)] The size of the quorum of replicas when using “replicated_log” based registry. It is imperative to set this value to be a majority of masters, i.e., quorum > (number of masters) / 2.</td>
        <td></td>
    </tr>
    <tr>
        <td><tt>['et_mesos']['master']['option_name']</tt></td>
        <td>String</td>
        <td>You can set arbitrary command line option for <tt>mesos-master</tt>, replace `option_name` with the key for the option to set. See the <a href="http://mesos.apache.org/documentation/latest/configuration/">latest Mesos config docs</a> for available options, or the output of `mesos-master --help`.</td>
        <td></td>
    </tr>
    <tr>
        <td><tt>['et_mesos']['slave']['master']</tt></td>
        <td>String</td>
        <td>[REQUIRED] mesos master url.This should be a `zk://` style address.</td>
        <td></td>
    </tr>
    <tr>
        <td><tt>['et_mesos']['slave']['option_name']</tt></td>
        <td>String</td>
        <td>Like <tt>['et_mesos']['master']['option_name']</tt> above, arbitrary options may be specified as a key for a slave by replacing `option_name` with your option’s key.</td>
        <td></td>
    </tr>
</table>

## Testing

There are a couple of test suites in place:

* `chefspec` for unit tests.
* `test-kitchen` with `serverspec` for integration tests (using `kitchen-ec2`).

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
