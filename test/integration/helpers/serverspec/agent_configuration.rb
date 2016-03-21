# encoding: utf-8

shared_examples_for 'a agent node' do
  describe 'deploy env template' do
    let :deploy_env_file do
      file '/usr/etc/mesos/mesos-deploy-env.sh'
    end

    it 'creates it in deploy directory' do
      expect(deploy_env_file).to be_a_file
    end

    it 'contains SSH_OPTS variable' do
      expect(deploy_env_file.content).to(
        match(/^export SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=2"$/)
      )
    end

    it 'contains DEPLOY_WITH_SUDO variable' do
      expect(deploy_env_file.content).to match(/^export DEPLOY_WITH_SUDO="1"$/)
    end
  end

  describe 'agent env template' do
    let :agent_env_file do
      file '/usr/etc/mesos/mesos-agent-env.sh'
    end

    it 'exists in deploy directory' do
      expect(agent_env_file).to be_a_file
    end

    it 'contains log_dir variable' do
      expect(agent_env_file.content).to match %r{^export MESOS_log_dir=/var/log/mesos$}
    end

    it 'contains work_dir variable' do
      expect(agent_env_file.content).to match %r{^export MESOS_work_dir=/tmp/mesos$}
    end

    it 'contains isolation variable' do
      expect(agent_env_file.content).to match %r{^export MESOS_isolation=cgroups/cpu,cgroups/mem$}
    end

    it 'contains rackid variable' do
      expect(agent_env_file.content).to match(/^export MESOS_attributes_rackid=us-east-1b$/)
    end
  end

  context 'agent upstart script' do
    describe file '/etc/init/mesos-agent.conf' do
      it { is_expected.to be_file }
    end
  end

  describe service('mesos-agent') do
    it { should be_enabled } if %w(ubuntu debian).include? os[:family]
    # service mesos-master is required in order which the below was passed.
    it { should be_running }
  end
end
