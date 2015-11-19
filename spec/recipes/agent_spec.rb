#
# Cookbook Name:: mesos
# Spec:: agent
#

require 'spec_helper'

describe 'et_mesos::agent' do
  deploy_dir = '/usr/local/var/mesos/deploy'

  context "when node['et_mesos']['agent']['master'] is not set" do
    let(:chef_run) { ChefSpec::ServerRunner.new.converge described_recipe }

    it 'exits the Chef run' do
      expect { chef_run }.to raise_error.with_message(
        "node['et_mesos']['agent']['master'] is required to configure mesos-agent."
      )
    end
  end

  context(
    "when node['et_mesos']['agent']['master'] is set, " \
    'but all other attributes are default, on Ubuntu 14.04'
  ) do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node|
        node.set['et_mesos']['agent']['master'] = 'test-master'
      end.converge described_recipe
    end

    it 'includes et_mesos::default' do
      expect(chef_run).to include_recipe 'et_mesos::default'
    end

    it 'does nothing to service[mesos-agent]' do
      resource = chef_run.service 'mesos-agent'
      expect(resource).to do_nothing
    end

    it 'creates the Mesos deploy dir' do
      expect(chef_run).to create_directory(deploy_dir).with(
        recursive: true
      )
    end

    describe 'agent env file' do
      it 'creates it' do
        expect(chef_run).to create_template "#{deploy_dir}/mesos-agent-env.sh"
      end

      it 'notifies service[mesos-agent] to reload configurations and restart' do
        conf = chef_run.template("#{deploy_dir}/mesos-agent-env.sh")
        expect(conf).to notify('service[mesos-agent]').to(:reload).delayed
        expect(conf).to notify('service[mesos-agent]').to(:restart).delayed
      end
    end

    describe 'mesos-agent upstart script' do
      it 'installs it to /etc/init' do
        expect(chef_run).to create_template '/etc/init/mesos-agent.conf'
      end

      it 'describe service name "mesos agent"' do
        expect(chef_run).to render_file('/etc/init/mesos-agent.conf')
          .with_content 'description "mesos agent"'
      end

      it 'contains start on stopped rc with runlevel 2,3,4,5' do
        expect(chef_run).to render_file('/etc/init/mesos-agent.conf')
          .with_content 'start on stopped rc RUNLEVEL=[2345]'
      end

      it 'contains respawn' do
        expect(chef_run).to render_file('/etc/init/mesos-agent.conf')
          .with_content 'respawn'
      end

      it 'sets the correct role' do
        expect(chef_run).to render_file('/etc/init/mesos-agent.conf')
          .with_content 'role=agent'
      end

      it 'notifies service[mesos-agent] to reload service configuration' do
        conf = chef_run.template('/etc/init/mesos-agent.conf')
        expect(conf).to notify('service[mesos-agent]').to(:reload).delayed
      end
    end
  end

  context "when node['et_mesos']['type'] == mesosphere, on Ubuntu 14.04" do
    let :chef_run do
      ChefSpec::ServerRunner.new do |node|
        node.set['et_mesos']['type'] = 'mesosphere'
        node.set['et_mesos']['agent']['master'] = 'test-master'
        node.set['et_mesos']['agent']['agent_key'] = 'agent_value'
        node.set['et_mesos']['agent']['attributes']['rackid'] = 'us-east-1b'
      end.converge(described_recipe)
    end

    it "has a agent env file with each key-value pair from node['et_mesos']['agent']" do
      expect(chef_run).to render_file("#{deploy_dir}/mesos-agent-env.sh")
        .with_content 'export MESOS_agent_key=agent_value'
    end

    it 'has a mesos-agent upstart script with a different command' do
      expect(chef_run).to render_file('/etc/init/mesos-agent.conf')
        .with_content 'exec /usr/bin/mesos-init-wrapper agent'
    end

    describe '/etc/mesos/zk' do
      it 'creates it' do
        expect(chef_run).to create_template '/etc/mesos/zk'
      end

      it 'contains configured zk string' do
        expect(chef_run).to render_file('/etc/mesos/zk').with_content 'test-master'
      end
    end

    describe '/etc/default/mesos' do
      it 'creates it' do
        expect(chef_run).to create_template '/etc/default/mesos'
      end

      it 'populates the log_dir correctly' do
        expect(chef_run).to render_file('/etc/default/mesos')
          .with_content 'LOGS=/var/log/mesos'
      end
    end

    describe '/etc/default/mesos-agent' do
      it 'creates it' do
        expect(chef_run).to create_template '/etc/default/mesos-agent'
      end

      it 'contains ISOLATION variable' do
        expect(chef_run).to render_file('/etc/default/mesos-agent')
          .with_content %r{^ISOLATION=cgroups/cpu,cgroups/mem$}
      end
    end

    it 'creates /etc/mesos-agent' do
      expect(chef_run).to create_directory('/etc/mesos-agent').with(
        recursive: true
      )
    end

    it 'removes the contents of /etc/mesos-agent dir' do
      expect(chef_run).to run_execute 'rm -rf /etc/mesos-agent/*'
    end

    describe 'configuration files in /etc/mesos-agent' do
      it "sets the content of the file matching a key in node['et_mesos']['agent'] " \
         'to its corresponding value' do
        expect(chef_run).to render_file('/etc/mesos-agent/work_dir')
          .with_content '/tmp/mesos'

        expect(chef_run).to render_file('/etc/mesos-agent/agent_key')
          .with_content 'agent_value'

        expect(chef_run).to create_directory '/etc/mesos-agent/attributes'

        expect(chef_run).to render_file('/etc/mesos-agent/attributes/rackid')
          .with_content 'us-east-1b'
      end
    end
  end
end
