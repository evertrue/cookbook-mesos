#
# Cookbook Name:: et_mesos
# Recipe:: install
#

%w(
  python
  build-essential
  maven
).each do |r|
  include_recipe r
end

case node['platform']
when 'centos'
  repo_url = value_for_platform(
    'centos' => {
      'default' => 'http://opensource.wandisco.com/centos/6/svn-1.8/RPMS/$basearch/',
      '~> 7.0' => 'http://opensource.wandisco.com/centos/7/svn-1.9/RPMS/$basearch/'
    }
  )

  yum_repository 'WANdiscoSVN' do
    description 'WANdiscoSVN Repo'
    baseurl repo_url
    gpgkey 'http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco'
  end

  pkgs = %w(
    zlib-devel
    libcurl-devel
    openssl-devel
    cyrus-sasl-devel
    cyrus-sasl-md5
    apr-devel
    subversion-devel
    apr-util-devel
  )
when 'ubuntu'
  pkgs = %w(
    unzip
    libtool
    python-boto
    libcurl4-nss-dev
    libsasl2-dev
    libapr1-dev
    libsvn-dev
  )
end

pkgs.each do |pkg|
  package pkg
end

mesos_version = node['et_mesos']['version']
prefix = node['et_mesos']['prefix']
node.default['et_mesos']['deploy_dir'] = "#{prefix}/var/mesos/deploy"
bin = "#{prefix}/sbin/mesos-master"
cmd = Mixlib::ShellOut.new("#{bin} --version |cut -f 2 -d ' '")

unless File.exist?(bin) && cmd.run_command && (cmd.stdout.chop == mesos_version)
  remote_file "#{Chef::Config[:file_cache_path]}/mesos-#{mesos_version}.zip" do
    source "https://github.com/apache/mesos/archive/#{mesos_version}.zip"
  end

  execute "extract mesos to #{node['et_mesos']['home']}" do
    cwd     node['et_mesos']['home']
    command "unzip -o #{Chef::Config[:file_cache_path]}/mesos-#{mesos_version}.zip -d ./" \
             " && mv mesos-#{mesos_version} mesos"
  end

  execute 'build mesos from source' do
    cwd     "#{node['et_mesos']['home']}/mesos"
    command "./bootstrap && mkdir -p build && cd build && ../configure --prefix=#{prefix} && make"
  end

  execute 'test mesos' do
    cwd     "#{node['et_mesos']['home']}/mesos/build"
    command 'make check'
    not_if  { node['et_mesos']['build']['skip_test'] }
  end

  execute "install mesos to #{prefix}" do
    cwd     "#{node['et_mesos']['home']}/mesos/build"
    command 'make install && ldconfig'
  end
end
