# encoding: utf-8

shared_examples_for 'an installation from mesosphere' do |opt|
  if opt[:with_zookeeper]
    context 'with zookeeper' do
      describe service('zookeeper') do
        it { should be_running }
      end
    end
  end

  it 'installs mesos package' do
    expect(package('mesos')).to be_installed
  end

  describe command('apt-mark showhold mesos'), if: %w(debian ubuntu).include?(os[:family]) do
    it 'places a hold on the mesos package' do
      expect(subject.stdout).to contain('mesos')
    end
  end
end
