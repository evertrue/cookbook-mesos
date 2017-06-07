#
# Cookbook Name:: mesos
# Spec:: package
#

require 'spec_helper'

describe 'et_mesos::package' do
  context 'when all attributes are default, on Ubuntu 14.04' do
    let(:chef_run) { ChefSpec::ServerRunner.new.converge described_recipe }

    it 'adds the mesosphere apt repository' do
      expect(chef_run).to add_apt_repository('mesosphere').with(
        uri: 'http://repos.mesosphere.com/ubuntu',
        components: %w(trusty main),
        keyserver: 'keyserver.ubuntu.com',
        key: 'E56151BF'
      )
    end

    it 'installs the default version of the mesos package' do
      expect(chef_run).to install_package('mesos').with(
        version: '0.28.1-2.0.20.ubuntu1404'
      )
    end
  end

  context "when node['et_mesos']['version'] == 0.19.0-1.0.ubuntu1404, on Ubuntu 14.04" do
    let :chef_run do
      ChefSpec::ServerRunner.new do |node|
        node.set['et_mesos']['version'] = '0.19.0-1.0.ubuntu1404'
      end.converge described_recipe
    end

    it 'installs the specified version of the mesos package' do
      expect(chef_run).to install_package('mesos').with(
        version: '0.19.0-1.0.ubuntu1404'
      )
    end
  end
end
