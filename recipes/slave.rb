#
# Cookbook Name:: et_mesos
# Recipe:: slave
#

include_recipe 'et_mesos::default'

service 'mesos-slave' do
  provider Chef::Provider::Service::Upstart if node['platform_version'].to_i < 16
  supports restart: true
  action %i(enable start)
end

deploy_dir = node['et_mesos']['deploy_dir']

directory deploy_dir do
  recursive true
end

fail 'node["et_mesos"]["zk"] is required to configure mesos-slave.' unless node['et_mesos']['zk']

# configuration files for mesos-daemon.sh provided by both source and mesosphere
template "#{deploy_dir}/mesos-slave-env.sh" do
  source 'mesos-env.sh.erb'
  variables role: 'slave'
  notifies :restart, 'service[mesos-slave]', :delayed
end

template '/etc/init/mesos-slave.conf' do
  source 'upstart.conf.erb'
  variables init_state: 'start', role: 'slave'
  notifies :restart, 'service[mesos-slave]'
  only_if { node['platform_version'].to_i < 16 }
end

# configuration files for service scripts(mesos-init-wrapper) by mesosphere package.
template '/etc/default/mesos-slave' do
  source 'etc-default-mesos-slave.erb'
  variables isolation: node['et_mesos']['slave']['isolation']
end

directory '/etc/mesos-slave' do
  recursive true
end

# TODO: Refactor this or add a guard to provide idempotency - jeffbyrnes
execute 'rm -rf /etc/mesos-slave/*'

node['et_mesos']['slave'].each do |key, val|
  next if %w(master_url master isolation log_dir).include?(key)
  next if val.nil?
  if val.respond_to? :to_path_hash
    val.to_path_hash.each do |path_h|
      attr_path = "/etc/mesos-slave/#{key}"

      directory attr_path

      file "#{attr_path}/#{path_h[:path]}" do
        content "#{path_h[:content]}\n"
      end
    end
  else
    file "/etc/mesos-slave/#{key}" do
      content "#{val}\n"
    end
  end
end
