name             'et_mesos'
maintainer       'EverTrue'
maintainer_email 'devops@evertrue.com'
license          'MIT'
description      'Installs/Configures mesos'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '4.0.1'
issues_url       'https://github.com/evertrue/et_mesos-cookbook/issues' if respond_to?(:issues_url)
source_url       'https://github.com/evertrue/et_mesos-cookbook/' if respond_to?(:source_url)

supports         'ubuntu', '>= 14.04'
supports         'centos', '>= 6.5'

recipe           'et_mesos::default', 'install mesos.'
recipe           'et_mesos::mesosphere', 'install mesos from mesosphere package.'
recipe           'et_mesos::source', 'install mesos from source(default recipe).'
recipe           'et_mesos::master',  'configure the machine as master.'
recipe           'et_mesos::slave',   'configure the machine as slave.'

depends          'java',            '~> 1.35'
depends          'python',          '~> 1.4'
depends          'build-essential', '~> 2.2'
depends          'maven',           '~> 1.3'
depends          'ulimit',          '~> 0.3'
depends          'apt',             '~> 2.8'
depends          'yum',             '~> 3.7'

suggests         'docker'
suggests         'zookeeper'

attribute       'et_mesos/type',
  recipes:      ['et_mesos::source', 'et_mesos::mesosphere', 'et_mesos::master', 'et_mesos::slave'],
  display_name: 'installation type',
  description:  "Value should be 'source' | 'mesosphere'.",
  default:      'source'

attribute       'et_mesos/version',
  recipes:      ['et_mesos::source', 'et_mesos::mesosphere'],
  display_name: 'Version to be installed.',
  description:  "branch name or tag name at http://github.com/apache/mesos, or mesos's version name",
  default:      '0.23.0'

attribute       'et_mesos/mesosphere/with_zookeeper',
  recipes:      ['et_mesos::mesosphere'],
  display_name: 'switch for installing zookeeper packages',
  description:  "if true, zookeeper packages will be installed with mesosphere's mesos package",
  default:      'false'

attribute       'et_mesos/prefix',
  recipes:      ['et_mesos::source', 'et_mesos::master', 'et_mesos::slave'],
  display_name: 'Prefix value to be passed to configure script',
  description:  'prefix value to be passed to configure script',
  default:      '/usr/local'

attribute       'et_mesos/home',
  recipes:      ['et_mesos::source'],
  display_name: 'mesos home directory',
  description:  'directory which mesos sources are extracted to.',
  default:      '/opt'

attribute       'et_mesos/build/skip_test',
  recipes:      ['et_mesos::source'],
  display_name: 'Flag whether test will be performed.',
  description:  'if true, test will be skipped.',
  default:      'true'

attribute       'et_mesos/ssh_opts',
  recipes:      ['et_mesos::master'],
  display_name: 'ssh options',
  description:  'passed to be mesos-deploy-env.sh',
  default:      '-o StrictHostKeyChecking=no -o ConnectTimeout=2'

attribute       'et_mesos/deploy_with_sudo',
  recipes:      ['et_mesos::master'],
  display_name: 'Flag whether sudo will be used in mesos deploy scripts',
  description:  'Flag whether sudo will be used in mesos deploy scripts',
  default:      '1'

attribute       'et_mesos/master_ips',
  recipes:      ['et_mesos::master'],
  display_name: 'IP list of masters',
  description:  'used in mesos-start/stop-cluster scripts.'

attribute       'et_mesos/slave_ips',
  recipes:      ['et_mesos::master'],
  display_name: 'IP list of slaves',
  description:  'used in mesos-start/stop-cluster scripts.'
