# encoding: utf-8

require 'spec_helper'

describe 'et_mesos::agent' do
  it_behaves_like 'an installation from source'

  it_behaves_like 'a agent node'

  context 'agent upstart script' do
    describe file '/etc/init/mesos-agent.conf' do
      describe '#content' do
        subject { super().content }
        it { is_expected.to include 'role=agent' }
      end
    end
  end
end
