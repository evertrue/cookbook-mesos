default['et_mesos']['version']          = "0.28.2-2.0.27.#{node['platform']}#{node['platform_version'].sub '.', ''}"
default['et_mesos']['ssh_opts']         = '-o StrictHostKeyChecking=no ' \
                                          '-o ConnectTimeout=2'
default['et_mesos']['deploy_with_sudo'] = '1'
default['et_mesos']['deploy_dir']       = '/usr/etc/mesos'
default['et_mesos']['master_ips']       = []
default['et_mesos']['slave_ips']        = []
default['et_mesos']['ulimit']           = 65_535


default['et_mesos']['master']['log_dir']  = '/var/log/mesos'
default['et_mesos']['master']['work_dir'] = '/tmp/mesos'
default['et_mesos']['master']['port']     = '5050'

default['et_mesos']['slave']['log_dir']   = '/var/log/mesos'
default['et_mesos']['slave']['work_dir']  = '/tmp/mesos'
default['et_mesos']['slave']['isolation'] = 'cgroups/cpu,cgroups/mem'

default['et_mesos']['slave']['cgroups_hierarchy'] = value_for_platform(
  'centos' => {
    'default' => '/cgroup'
  },
  'default' => nil
)

default['java']['jdk_version'] = '7'
