#
# Cookbook Name:: mesos
# Spec:: default
#

require 'spec_helper'

describe 'et_mesos::default' do
  context 'when platform_family is not `debian`' do
    let :chef_run do
      ChefSpec::ServerRunner.new(platform: 'centos', version: '6.0').converge described_recipe
    end

    it 'exits the Chef run' do
      expect { chef_run }.to raise_error.with_message(/is not supported/)
    end
  end

  context 'when all attributes are default' do
    let(:chef_run) { ChefSpec::ServerRunner.new.converge described_recipe }

    %w(
      apt
      java
      et_mesos::package
    ).each do |r|
      it "includes the #{r} recipe" do
        expect(chef_run).to include_recipe r
      end
    end
  end
end
