#
# Cookbook Name:: et_mesos
# Recipe:: package
#

apt_repository 'mesosphere' do
  uri "http://repos.mesosphere.com/#{node['platform']}"
  components %w(main)
  keyserver 'keyserver.ubuntu.com'
  key 'E56151BF'
end

package 'mesos' do
  version node['et_mesos']['version']
end
