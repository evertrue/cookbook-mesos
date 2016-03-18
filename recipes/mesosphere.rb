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

  yum_package "mesos >= #{node['et_mesos']['version']}"
when 'ubuntu'
  apt_repository 'mesosphere' do
    uri "http://repos.mesosphere.com/#{node['platform']}"
    components [node['lsb']['codename'], 'main']
    keyserver 'keyserver.ubuntu.com'
    key 'E56151BF'
  end

  target_mesos_version = "#{node['et_mesos']['version']}-" \
            "1.0.#{node['platform']}#{node['platform_version'].sub '.', ''}"

  execute 'un-hold mesos package' do
    command 'apt-mark -qq unhold mesos'
    only_if do
      cmd = Mixlib::ShellOut.new('apt-cache policy mesos')
      cmd.run_command
      cmd.stdout[/Installed: (.*)$/, 1] != target_mesos_version
    end
    only_if 'apt-mark showhold mesos | grep mesos'
  end

  package 'mesos' do
    version target_mesos_version
  end

  execute 'hold mesos package' do
    command 'apt-mark -qq hold mesos'
    not_if 'apt-mark showhold mesos | grep mesos'
  end
end
