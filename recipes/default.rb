#
# Cookbook Name:: chef-rundeck
# Recipe:: default
#
# Copyright 2012, Panagiotis Papadomitsos <pj@ezgr.net>
#

case node['platform_family']

when 'debian'

	remote_file "#{Chef::Config['file_cache_path']}/rundeck-#{node['rundeck']['version']}.deb" do
		owner "root"
		group "root"
		mode "0644"
		source node['rundeck']['deb_url']
		checksum node['rundeck']['deb_checksum']
	end

	dpkg_package "#{Chef::Config['file_cache_path']}/rundeck-#{node['rundeck']['version']}.deb" do
		action :upgrade
	end

	adminobj = data_bag_item(node['rundeck']['admin']['data_bag'],node['rundeck']['admin']['data_bag_id'])

	# Configuration properties
	template "/etc/rundeck/framework.properties" do
		source "framework.properties.erb"
		owner 'rundeck'
		group 'rundeck'
		mode 00644
		variables({
			:admin_user => adminobj['username'],
			:admin_pass => adminobj['password']	
		})
	end
	
	service "rundeckd" do
		provider Chef::Provider::Service::Upstart
		supports :status => true, :restart => true
		action [ :enable, :start ]
	end

end
