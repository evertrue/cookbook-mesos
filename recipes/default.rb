#
# Cookbook Name:: et_mesos
# Recipe:: default
#

# Avoid running on unsupported systems
unless node['platform_family'] == 'debian'
  fail "#{node['platform_family']} is not supported on #{cookbook_name} cookbook"
end

include_recipe 'apt'
include_recipe 'java'
include_recipe 'et_mesos::package'

template '/etc/default/mesos' do
  source 'etc-default-mesos.erb'
  variables(
    log_dir: node['et_mesos']['log_dir'],
    ulimit: node['et_mesos']['ulimit']
  )
end

file('/etc/mesos/zk') { content "#{node['et_mesos']['zk']}\n" }
