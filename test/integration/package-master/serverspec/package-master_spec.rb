# encoding: utf-8

require 'spec_helper'

describe 'et_mesos::master' do
  it_behaves_like 'an installation from package'

  it_behaves_like 'all nodes'
  it_behaves_like 'a master node'

  context 'master upstart script' do
    if os[:release].to_i < 16
      describe file '/etc/init/mesos-master.conf' do
        describe '#content' do
          subject { super().content }
          it { is_expected.to include 'exec /usr/bin/mesos-init-wrapper master' }
        end
      end
    else
      describe file '/lib/systemd/system/mesos-master.service' do
        describe '#content' do
          subject { super().content }
          it { is_expected.to contain 'ExecStart=/usr/bin/mesos-init-wrapper master' }
        end
      end
    end
  end

  context 'configuration files in /etc' do
    describe 'zk configuration file' do
      let :zk_file do
        file('/etc/mesos/zk')
      end

      it 'creates it' do
        expect(zk_file).to be_a_file
      end

      it 'contains configured zk string' do
        expect(zk_file.content).to match(%r{^zk://localhost:2181/mesos$})
      end
    end

    describe 'general mesos configuration file' do
      let :mesos_file do
        file('/etc/default/mesos')
      end

      it 'creates it' do
        expect(mesos_file).to be_a_file
      end

      it 'contains LOGS variable' do
        expect(mesos_file.content).to match(%r{^LOGS=/var/log/mesos$})
      end

      it 'contains ULIMIT variable' do
        expect(mesos_file.content).to match(/^ULIMIT="-n 65535"$/)
      end
    end

    describe 'master specific configuration file' do
      let :master_file do
        file('/etc/default/mesos-master')
      end

      it 'creates it' do
        expect(master_file).to be_a_file
      end

      it 'contains PORT variable' do
        expect(master_file.content).to match(/^PORT=5050$/)
      end

      it 'contains ZK variable' do
        expect(master_file.content).to match(%r{^ZK=`cat /etc/mesos/zk`$})
      end
    end

    describe 'mesos-master directory' do
      it 'creates it' do
        expect(file('/etc/mesos-master')).to be_a_directory
      end
    end
  end
end
