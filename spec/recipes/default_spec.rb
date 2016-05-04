#
# Cookbook Name:: mesos
# Spec:: default
#

require 'spec_helper'

describe 'et_mesos::default' do
  context 'when platform is neither `ubuntu` nor `centos`' do
    let :chef_run do
      ChefSpec::ServerRunner.new(platform: 'debian', version: '7.0').converge described_recipe
    end

    it 'exits the Chef run' do
      expect { chef_run }.to raise_error.with_message(/is not supported/)
    end
  end

  context 'when all attributes are default, on CentOS 6.6' do
    let :chef_run do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6')
      runner.converge(described_recipe)
    end

    it 'includes the `yum::default` recipe' do
      expect(chef_run).to include_recipe 'yum'
    end
  end

  context 'when all attributes are default, on Ubuntu 14.04' do
    let(:chef_run) { ChefSpec::ServerRunner.new.converge described_recipe }

    %w(
      apt
      java
      et_mesos::mesosphere
    ).each do |r|
      it "includes the #{r} recipe" do
        expect(chef_run).to include_recipe r
      end
    end
  end
end
