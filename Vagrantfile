# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)
#
# Copyright 2013, Panagiotis Papadomitsos
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

Vagrant.configure('2') do |config|

  config.berkshelf.enabled = true
  config.vbguest.no_install = true

  config.vm.provider :virtualbox do |v|
    v.memory = 1024
    v.gui = true
  end

  config.vm.box = 'ubuntu'
  config.vm.hostname = 'rundeck'
  config.vm.network :private_network, ip: '172.16.6.2'
  config.vm.network :forwarded_port, guest: 4440, host: 4440

  config.vm.provision :chef_solo do |chef|
    chef.arguments = '-Fdoc'
    chef.json = {
      'java' => {
        'install_flavor' => 'oracle',
        'oracle' => {
          'accept_oracle_download_terms' => true
        },
        'jdk_version' => '7',
        'remove_deprecated_packages' => false
      }
    }
    chef.run_list = [
      'recipe[apt]',
      'recipe[openresty]',
      'recipe[python]',
      'recipe[supervisor]',
      'recipe[logrotate]',
      'recipe[java]',
      'recipe[rundeck]',
      'recipe[rundeck::chef]',
      'recipe[rundeck::proxy]'
    ]

  end
end
