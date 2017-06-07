#
# Cookbook Name:: et_mesos
# Recipe:: master
#

include_recipe 'et_mesos::default'

service 'mesos-master' do
  provider Chef::Provider::Service::Upstart if node['platform_version'].to_i < 16
  supports restart: true
  action %i(enable start)
end

deploy_dir = node['et_mesos']['deploy_dir']

directory deploy_dir do
  recursive true
end


fail 'node["et_mesos"]["zk"] is required to configure mesos-master.' unless node['et_mesos']['zk']

unless node['et_mesos']['master']['quorum']
  fail 'node["et_mesos"]["master"]["quorum"] is required to configure mesos-master.'
end

# configuration files for mesos-[start|stop]-cluster.sh
%w(masters slaves mesos-deploy-env.sh).each { |file| template "#{deploy_dir}/#{file}" }

# configuration files for mesos-daemon.sh
template "#{deploy_dir}/mesos-master-env.sh" do
  source 'mesos-env.sh.erb'
  variables role: 'master'
  notifies :restart, 'service[mesos-master]'
end

template '/etc/init/mesos-master.conf' do
  source 'upstart.conf.erb'
  variables init_state: 'start', role: 'master'
  notifies :restart, 'service[mesos-master]'
  only_if { node['platform_version'].to_i < 16 }
end

# config files for service scripts(mesos-init-wrapper) by mesosphere package.
#
# these template resources don't notify service resource because
# changes of configuration can be detected in mesos-master-env.sh
template '/etc/default/mesos-master' do
  source 'etc-default-mesos-master.erb'
  variables port: node['et_mesos']['master']['port']
end

directory '/etc/mesos-master'

# execute 'rm -rf /etc/mesos-master/*'
file Dir.glob('/etc/mesos-master/*') do
  action :delete
end

node['et_mesos']['master'].each do |key, val|
  next if %w(zk log_dir port).include? key
  next if val.nil?
  if val.respond_to? :to_path_hash
    val.to_path_hash.each do |path_h|
      attr_path = "/etc/mesos-master/#{key}"

      directory attr_path

      file "#{attr_path}/#{path_h['path']}" do
        content "#{path_h['content']}\n"
      end
    end
  else
    file "/etc/mesos-master/#{key}" do
      content "#{val}\n"
    end
  end
end
