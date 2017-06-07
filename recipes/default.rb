#
# Cookbook Name:: et_mesos
# Recipe:: default
#

# Avoid running on unsupported systems
unless %w(ubuntu centos).include? node['platform']
  raise "#{node['platform']} is not supported on #{cookbook_name} cookbook"
end

case node['platform']
when 'centos'
  include_recipe 'yum'
when 'ubuntu'
  include_recipe 'apt'
end

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
