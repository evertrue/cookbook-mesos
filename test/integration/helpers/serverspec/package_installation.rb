# encoding: utf-8

shared_examples_for 'an installation from package' do
  it 'installs mesos package' do
    expect(package('mesos')).to be_installed
  end
end
