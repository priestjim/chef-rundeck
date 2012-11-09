#
# Cookbook Name:: chef-rundeck
# Recipe:: default
#
# Copyright 2012, Panagiotis Papadomitsos <pj@ezgr.net>
#

case node['platform_family']

when 'debian'

	remote_file "#{Chef::Config['file_cache_path']}/rundeck-#{node['rundeck']['version']}.deb" do
		owner 'root'
		group 'root'
		mode '0644'
		source node['rundeck']['deb_url']
		checksum node['rundeck']['deb_checksum']
		action :create_if_missing
	end

	dpkg_package "#{Chef::Config['file_cache_path']}/rundeck-#{node['rundeck']['version']}.deb" do
		action :install
		notifies :delete, 'file[/etc/rundeck/realm.properties]'
	end

	# Erase the default realm.properties after package install, we manage that
	file "/etc/rundeck/realm.properties" do
		action :nothing
	end

	adminobj = data_bag_item(node['rundeck']['admin']['data_bag'], node['rundeck']['admin']['data_bag_id'])

	unless Chef::Config['solo']
		recipients = search(node['rundeck']['mail']['recipients_data_bag'],node['rundeck']['mail']['recipients_query']).
		map {|u| u[node['rundeck']['mail']['recipients_field']] }.
		join(',') rescue []
	else
		recipients = 'root'
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
		notifies :restart, "service[rundeckd]"
	end

	# Featuring Javascript optimizations
	cookbook_file "/etc/rundeck/profile" do
		source 'profile'
		owner 'rundeck'
		group 'rundeck'
		mode 00644
		action :create
		notifies :restart, "service[rundeckd]"		
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

	cookbook_file '/etc/logrotate.d/rundeck' do
		source 'rundeck.logrotate'
		owner 'root'
		group 'root'
		mode 00644
	end
	
	# SSH private key. Stored in the data bag item as an array
	unless adminobj['ssh_key'].nil? || adminobj['ssh_key'].empty?

		directory "/var/lib/rundeck/.ssh" do
			owner 'rundeck'
			group 'rundeck'
			mode 00755
			action :create
		end

		file "/var/lib/rundeck/.ssh/id_rsa" do
			action :create
			owner 'rundeck'
			group 'rundeck'
			mode 00600
			content adminobj['ssh_key'].join("\n")
		end

	end

	service 'rundeckd' do
		provider Chef::Provider::Service::Upstart if platform?('ubuntu') && node['platform_version'].to_f >= 12.04
		supports :status => true, :restart => true
		action [ :enable, :start ]
	end

when 'rhel'
	# TODO
end
