# encoding: utf-8
require 'serverspec'

set :backend, :exec

require 'package_installation'
require 'master_configuration'
require 'slave_configuration'
