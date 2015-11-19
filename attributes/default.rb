default['et_mesos']['type']             = 'source'
default['et_mesos']['version']          = '0.23.0'
default['et_mesos']['prefix']           = '/usr/local'
default['et_mesos']['home']             = '/opt'
default['et_mesos']['ssh_opts']         = '-o StrictHostKeyChecking=no ' \
                                          '-o ConnectTimeout=2'
default['et_mesos']['deploy_with_sudo'] = '1'
default['et_mesos']['deploy_dir']       = '/usr/etc/mesos'
default['et_mesos']['master_ips']       = []
default['et_mesos']['agent_ips']        = []

default['et_mesos']['mesosphere']['with_zookeeper'] = false

default['et_mesos']['build']['skip_test'] = true

default['et_mesos']['master']['log_dir']  = '/var/log/mesos'
default['et_mesos']['master']['work_dir'] = '/tmp/mesos'
default['et_mesos']['master']['port']     = '5050'

default['et_mesos']['agent']['log_dir']   = '/var/log/mesos'
default['et_mesos']['agent']['work_dir']  = '/tmp/mesos'
default['et_mesos']['agent']['isolation'] = 'cgroups/cpu,cgroups/mem'

default['et_mesos']['agent']['cgroups_hierarchy'] = value_for_platform(
  'centos' => {
    'default' => '/cgroup'
  },
  'default' => nil
)

set['java']['jdk_version'] = '7'
