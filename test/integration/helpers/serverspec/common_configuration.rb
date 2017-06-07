shared_examples_for 'all nodes' do
  describe 'general mesos configuration file' do
    let :mesos_file do
      file('/etc/default/mesos')
    end

    it 'creates it' do
      expect(mesos_file).to be_a_file
    end

    it 'contains LOGS variable' do
      expect(mesos_file.content).to match %r{^LOGS=/var/log/mesos$}
    end

    it 'contains ULIMIT variable' do
      expect(mesos_file.content).to match(/^ULIMIT="-n 65535"$/)
    end
  end
end
