#
# Cookbook Name:: et_mesos
# Recipe:: mesosphere
#

include_recipe 'et_mesos::zookeeper' if node['et_mesos']['mesosphere']['with_zookeeper']

case node['platform']
when 'centos'
  repo_url = value_for_platform(
    'centos' => {
      'default' => 'http://repos.mesosphere.io/el/6',
      '~> 7.0' => 'http://repos.mesosphere.io/el/7'
    }
  )

  repos = {
    'mesosphere' => {
      'description' => 'Mesosphere Packages - $basearch',
      'url' => '$basearch'
    },
    'mesosphere-noarch' => {
      'description' => 'Mesosphere Packages - noarch',
      'url' => 'noarch'
    },
    'mesosphere-source' => {
      'description' => 'Mesosphere Packages - $basearch - Source',
      'url' => 'SRPMS'
    }
  }

  repos.each do |repo, details|
    yum_repository repo do
      description details['description']
      baseurl "#{repo_url}/#{details['url']}/"
      gpgkey 'http://repos.mesosphere.io/el/RPM-GPG-KEY-mesosphere'
    end
  end
when 'ubuntu'
  apt_repository 'mesosphere' do
    uri "http://repos.mesosphere.com/#{node['platform']}"
    components [node['lsb']['codename'], 'main']
    keyserver 'keyserver.ubuntu.com'
    key 'E56151BF'
  end
end

package 'mesos' do
  version node['et_mesos']['version']
end
