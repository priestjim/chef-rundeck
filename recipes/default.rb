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

	remote_file "#{Chef::Config['file_cache_path']}/rundeck-#{node['rundeck']['deb_version']}.deb" do
		owner 'root'
		group 'root'
		mode 00644
		source node['rundeck']['deb_url']
		checksum node['rundeck']['deb_checksum']
		action :create
		notifies :install, "dpkg_package[#{Chef::Config['file_cache_path']}/rundeck-#{node['rundeck']['deb_version']}.deb]"
	end

	dpkg_package "#{Chef::Config['file_cache_path']}/rundeck-#{node['rundeck']['deb_version']}.deb" do
		action :nothing
		notifies :delete, 'file[/etc/rundeck/realm.properties]'
	end

when 'rhel'

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

if Chef::Config[:solo]
	adminobj = data_bag_item(node['rundeck']['admin']['data_bag'], node['rundeck']['admin']['data_bag_id']) rescue {
		'username' => node['rundeck']['admin']['username'],
		'password' => node['rundeck']['admin']['password'],
		'ssh_key'  => node['rundeck']['admin']['ssh_key']
	}
elsif node['rundeck']['admin']['encrypted_data_bag']
	adminobj = Chef::EncryptedDataBagItem.load(node['rundeck']['admin']['data_bag'], node['rundeck']['admin']['data_bag_id'])
else
	adminobj = data_bag_item(node['rundeck']['admin']['data_bag'], node['rundeck']['admin']['data_bag_id'])
end

unless Chef::Config[:solo]
	recipients = search(node['rundeck']['mail']['recipients_data_bag'], node['rundeck']['mail']['recipients_query']).
	map {|u| eval("u#{node['rundeck']['mail']['recipients_field']}") }.
	join(',') rescue []
else
	recipients = 'root'
end

user 'rundeck'

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

template '/etc/rundeck/rundeck-config.properties' do
	source 'rundeck-config.properties.erb'
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
%w{ log4j.properties jaas-loginmodule.conf apitoken.aclpolicy admin.aclpolicy }.each do |cf|
	cookbook_file "/etc/rundeck/#{cf}" do
		source cf
		owner 'rundeck'
		group 'rundeck'
		mode 00644
		action :create
	end
end

cookbook_file "/etc/rundeck/realm.properties" do
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
	action :create
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

service 'rundeckd' do
	provider(Chef::Provider::Service::Upstart) if platform?('ubuntu') && node['platform_version'].to_f >= 12.04
	supports :status => true, :restart => true
	action [ :enable, :start ]
end
