#
# Cookbook Name:: rundeck
# Recipe:: default
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

include_recipe 'java'
include_recipe 'logrotate'

case node['platform_family']

when 'debian'

	include_recipe 'apt'

	remote_file "#{Chef::Config['file_cache_path']}/rundeck-#{node['rundeck']['deb_version']}.deb" do
		owner 'root'
		group 'root'
		mode 00644
		source node['rundeck']['deb_url']
		checksum node['rundeck']['deb_checksum']
		action :create
		notifies :install, "dpkg_package[#{Chef::Config['file_cache_path']}/rundeck-#{node['rundeck']['deb_version']}.deb]", :immediately
	end

	# Added --force-depends since Rundeck hard-depends on Java 6 but will run on Java 7 well enough
	dpkg_package "#{Chef::Config['file_cache_path']}/rundeck-#{node['rundeck']['deb_version']}.deb" do
		action :nothing
		options '--force-confdef --force-confold --force-depends'
		notifies :delete, 'file[/etc/rundeck/realm.properties]', :immediately
	end

when 'rhel'

	include_recipe 'yum'

	package 'java' # Needed for RPM dependency

	remote_file "#{Chef::Config['file_cache_path']}/rundeck-config-#{node['rundeck']['rpm_version']}.noarch.rpm" do
		owner 'root'
		group 'root'
		mode 00644
		source node['rundeck']['rpm_cfg_url']
		checksum node['rundeck']['rpm_cfg_checksum']
		action :create
	end

	remote_file "#{Chef::Config['file_cache_path']}/rundeck-#{node['rundeck']['rpm_version']}.noarch.rpm" do
		owner 'root'
		group 'root'
		mode 00644
		source node['rundeck']['rpm_url']
		checksum node['rundeck']['rpm_checksum']
		action :create
	end

	execute "install-rundeck-#{node['rundeck']['rpm_version']}" do
		command "yum -y localinstall #{Chef::Config['file_cache_path']}/rundeck-#{node['rundeck']['rpm_version']}.noarch.rpm #{Chef::Config['file_cache_path']}/rundeck-config-#{node['rundeck']['rpm_version']}.noarch.rpm"
		action :run
		not_if "rpm -q rundeck | grep #{node['rundeck']['rpm_version']}"
	end

end

# Erase the default realm.properties after package install, we manage that
file '/etc/rundeck/realm.properties' do
	action :nothing
end

adminobj = if node['rundeck']['admin']['encrypted_data_bag']
		Chef::EncryptedDataBagItem.load(node['rundeck']['admin']['data_bag'], node['rundeck']['admin']['data_bag_id'])
	else
		data_bag_item(node['rundeck']['admin']['data_bag'], node['rundeck']['admin']['data_bag_id'])
	end rescue { 'username' => node['rundeck']['admin']['username'], 'password' => node['rundeck']['admin']['password'], 'ssh_key'  => node['rundeck']['admin']['ssh_key'] }

recipients = if Chef::Config[:solo]
		'root'
	elsif node['rundeck']['partial_search']
		partial_search(
	    node['rundeck']['mail']['recipients_data_bag'],
	    node['rundeck']['mail']['recipients_query'],
			:keys => node['rundeck']['mail']['recipients_keys']
		).map {|u| u[node['rundeck']['mail']['recipients_keys'].keys.first] }.
		join(',')
	else
		search(node['rundeck']['mail']['recipients_data_bag'], node['rundeck']['mail']['recipients_query']).
		map {|u| eval("u#{node['rundeck']['mail']['recipients_field']}") }.
		join(',')
	end

# Resource instance declaration needed to instantiate the
# 'rundeck' user before the package is actually installed. See PR #2
user 'rundeck' do
	action :nothing
end

directory '/etc/rundeck' do
	action :create
	not_if { ::File.directory?('/etc/rundeck') }
end

# Configuration properties
template '/etc/rundeck/framework.properties' do
	source 'framework.properties.erb'
	owner 'rundeck'
	group 'rundeck'
	mode 00644
	variables({
		:admin_user => adminobj['username'],
		:admin_pass => adminobj['password'],
		:recipients => recipients
	})
	notifies :restart, 'service[rundeckd]'
end

template '/etc/rundeck/project.properties' do
	source 'project.properties.erb'
	owner 'rundeck'
	group 'rundeck'
	mode 00644
	variables({ :recipients => recipients })
	notifies :restart, 'service[rundeckd]'
end

template '/etc/rundeck/rundeck-config.groovy' do
	source 'rundeck-config.groovy.erb'
	owner 'rundeck'
	group 'rundeck'
	mode 00644
	notifies :restart, 'service[rundeckd]'
end

# Rundeck profile file
template '/etc/rundeck/profile' do
	source 'rundeck.profile.erb'
	owner 'rundeck'
	group 'rundeck'
	mode 00644
	action :create
	notifies :restart, 'service[rundeckd]'
end

# Stub files from the cookbook, override with chef-rewind
node['rundeck']['stub_config_files'].each do |cf|
	cookbook_file "/etc/rundeck/#{cf}" do
		source cf
		owner 'rundeck'
		group 'rundeck'
		mode 00644
		action :create
	end
end

cookbook_file '/etc/rundeck/realm.properties' do
	source 'realm.properties'
	owner 'rundeck'
	group 'rundeck'
	mode 00644
	action :create_if_missing
end

rundeck_user adminobj['username'] do
	password adminobj['password']
	encryption 'md5'
	roles %w{ user admin architect deploy build }
	action [:create, :update]
end

# Log rotation
logrotate_app 'rundeck' do
  path '/var/log/rundeck/*.log'
  enable true
  frequency 'daily'
  rotate 7
  cookbook 'logrotate'
  create '0644 rundeck adm'
  options [ 'missingok', 'delaycompress', 'notifempty', 'compress', 'sharedscripts', 'copytruncate' ]
end

# SSH private key. Stored in the data bag item as ssh_key
unless adminobj['ssh_key'].nil? || adminobj['ssh_key'].empty?

	directory '/var/lib/rundeck/.ssh' do
		owner 'rundeck'
		group 'rundeck'
		mode 00750
		action :create
	end

	file '/var/lib/rundeck/.ssh/id_rsa' do
		action :create
		owner 'rundeck'
		group 'rundeck'
		mode 00600
		content adminobj['ssh_key']
	end

end

# Disable upstart service, causes hangups
file '/etc/init/rundeckd.override' do
	action :create
	content 'manual'
	only_if { platform?('ubuntu') && node['platform_version'].to_f >= 12.04 }
end

service 'rundeckd' do
	supports :status => true, :restart => true
	action [ :enable, :start ]
end
