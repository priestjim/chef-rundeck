#
# Cookbook Name:: rundeck
# Recipe:: chef
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

include_recipe 'supervisor'

adminobj = if node['rundeck']['admin']['encrypted_data_bag']
		Chef::EncryptedDataBagItem.load(node['rundeck']['admin']['data_bag'], node['rundeck']['admin']['data_bag_id'])
	else
		data_bag_item(node['rundeck']['admin']['data_bag'], node['rundeck']['admin']['data_bag_id'])
	end rescue {'client_key' => node['rundeck']['chef']['client_key'], 'client_name' => node['rundeck']['chef']['client_name']	}

if adminobj['client_key'].nil? || adminobj['client_key'].empty? || adminobj['client_name'].nil? || adminobj['client_name'].empty?
	Chef::Log.info('Could not locate a valid client/PEM key pair for chef-rundeck. Please define one!')
	return true
end

# Install the chef-rundeck gem on the Chef omnibus package. Useful workaround instead of installing RVM, a system Ruby etc
# and it offers minimal system pollution

chef_gem 'chef-rundeck'

# Create the knife.rb for chef-rundeck to read
directory '/var/lib/rundeck/.chef' do
	owner 'rundeck'
	group 'rundeck'
	mode 00755
	action :create
end

template '/var/lib/rundeck/.chef/knife.rb' do
	source 'knife.rb.erb'
	owner 'rundeck'
	group 'rundeck'
	mode 00644
	variables({
		:user => adminobj['client_name'],
		:ssl_verify_mode => node['rundeck']['chef']['ssl_verify_mode'],
		:chef_server_url => node['rundeck']['chef']['server_url']
	})
	notifies :restart, 'supervisor_service[chef-rundeck]'
end

file "/var/lib/rundeck/.chef/#{adminobj['client_name']}.pem" do
	action :create
	owner 'rundeck'
	group 'rundeck'
	mode 00644
	content adminobj['client_key']
end

chef_rundeck_args = [
	'-a', node['rundeck']['chef']['server_url'],
	'-k', "/var/lib/rundeck/.chef/#{adminobj['client_name']}.pem",
	'-c', '/var/lib/rundeck/.chef/knife.rb',
	'-u', node['rundeck']['ssh']['user'],
	'-t', node['rundeck']['chef']['cache_timeout'],
	'-w', node['rundeck']['chef']['server_url'],
	'-p', node['rundeck']['chef']['port']
]

chef_rundeck_args << '--partial-search true' if node['rundeck']['chef']['partial_search']

# Create a Supervisor service that runs chef-rundeck
supervisor_service 'chef-rundeck' do
	command "/opt/chef/embedded/bin/ruby /opt/chef/embedded/bin/chef-rundeck #{chef_rundeck_args.join(' ')}"
	numprocs 1
	directory '/var/lib/rundeck'
	autostart true
	autorestart :unexpected
	startsecs 15
	stopwaitsecs 15
	stdout_logfile 'NONE'
	stopsignal :TERM
	user 'rundeck'
	redirect_stderr true
	action :enable
	environment({'HOME' => '/var/lib/rundeck'})
end
