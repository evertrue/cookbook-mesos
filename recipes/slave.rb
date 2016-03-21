#
# Cookbook Name:: et_mesos
# Recipe:: slave
#

include_recipe 'et_mesos::default'

service 'mesos-slave' do
  provider Chef::Provider::Service::Upstart
  supports restart: true, reload: true
  action :nothing
end

deploy_dir = node['et_mesos']['deploy_dir']

directory deploy_dir do
  recursive true
end

unless node['et_mesos']['slave']['master']
  raise "node['et_mesos']['slave']['master'] is required to configure mesos-slave."
end

# configuration files for mesos-daemon.sh provided by both source and mesosphere
template "#{deploy_dir}/mesos-slave-env.sh" do
  source 'mesos-slave-env.sh.erb'
  notifies :reload,  'service[mesos-slave]', :delayed
  notifies :restart, 'service[mesos-slave]', :delayed
end

template '/etc/init/mesos-slave.conf' do
  source "upstart.conf.for.#{node['et_mesos']['type']}.erb"
  variables init_state: 'start', role: 'slave'
  notifies :reload, 'service[mesos-slave]'
end

# configuration files for service scripts(mesos-init-wrapper) by mesosphere package.
if node['et_mesos']['type'] == 'mesosphere'
  template '/etc/mesos/zk' do
    source 'etc-mesos-zk.erb'
    variables zk: node['et_mesos']['slave']['master']
  end

  template '/etc/default/mesos' do
    source 'etc-default-mesos.erb'
    variables log_dir: node['et_mesos']['slave']['log_dir']
  end

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
end
