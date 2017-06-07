name             'et_mesos'
maintainer       'EverTrue'
maintainer_email 'devops@evertrue.com'
license          'MIT'
description      'Installs/Configures mesos'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '7.0.0'
issues_url       'https://github.com/evertrue/et_mesos-cookbook/issues' if respond_to?(:issues_url)
source_url       'https://github.com/evertrue/et_mesos-cookbook/' if respond_to?(:source_url)

supports         'ubuntu', '>= 14.04'

recipe           'et_mesos::default', 'install mesos.'
recipe           'et_mesos::package', 'install mesos from mesosphere package.'
recipe           'et_mesos::master',  'configure the machine as master.'
recipe           'et_mesos::slave',   'configure the machine as slave.'

depends          'java',            '~> 1.35'
depends          'ulimit',          '>= 0.3'
depends          'yum',             '>= 3.7'

suggests         'docker'
suggests         'zookeeper'
