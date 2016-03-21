#
# Cookbook Name:: et_mesos
# Recipe:: agent
#

include_recipe 'et_mesos::default'

service 'mesos-agent' do
  provider Chef::Provider::Service::Upstart
  supports restart: true, reload: true
  action :nothing
end

deploy_dir = node['et_mesos']['deploy_dir']

directory deploy_dir do
  recursive true
end

unless node['et_mesos']['agent']['master']
  fail "node['et_mesos']['agent']['master'] is required to configure mesos-agent."
end

# configuration files for mesos-daemon.sh provided by both source and mesosphere
template "#{deploy_dir}/mesos-agent-env.sh" do
  source 'mesos-agent-env.sh.erb'
  notifies :reload,  'service[mesos-agent]', :delayed
  notifies :restart, 'service[mesos-agent]', :delayed
end

template '/etc/init/mesos-agent.conf' do
  source "upstart.conf.for.#{node['et_mesos']['type']}.erb"
  variables init_state: 'start', role: 'agent'
  notifies :reload, 'service[mesos-agent]'
end

# configuration files for service scripts(mesos-init-wrapper) by mesosphere package.
if node['et_mesos']['type'] == 'mesosphere'
  template '/etc/mesos/zk' do
    source 'etc-mesos-zk.erb'
    variables zk: node['et_mesos']['agent']['master']
  end

  template '/etc/default/mesos' do
    source 'etc-default-mesos.erb'
    variables log_dir: node['et_mesos']['agent']['log_dir']
  end

  template '/etc/default/mesos-agent' do
    source 'etc-default-mesos-agent.erb'
    variables isolation: node['et_mesos']['agent']['isolation']
  end

  directory '/etc/mesos-agent' do
    recursive true
  end

  # TODO: Refactor this or add a guard to provide idempotency - jeffbyrnes
  execute 'rm -rf /etc/mesos-agent/*'

  node['et_mesos']['agent'].each do |key, val|
    next if %w(master_url master isolation log_dir).include?(key)
    next if val.nil?
    if val.respond_to? :to_path_hash
      val.to_path_hash.each do |path_h|
        attr_path = "/etc/mesos-agent/#{key}"

        directory attr_path

        file "#{attr_path}/#{path_h[:path]}" do
          content "#{path_h[:content]}\n"
        end
      end
    else
      file "/etc/mesos-agent/#{key}" do
        content "#{val}\n"
      end
    end
  end
end
