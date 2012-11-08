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
	
	rundeck_user adminobj['username'] do
		password adminobj['password']
		encryption 'md5'
		roles %w{ user admin architect deploy build }
	end

	if node['rundeck']['proxy']['enable']

		include_recipe 'nginx'

		template "#{node['nginx']['dir']}/sites-available/rundeck" do
			source 'nginx_proxy.erb'
			owner 'root'
			group 'root'
			mode 00644
			if(::File.symlink?("#{node['nginx']['dir']}/sites-enabled/rundeck"))
				notifies :reload, 'service[nginx]', :immediately
			end
		end

		nginx_site 'rundeck'

	end

	cookbook_file '/etc/logrotate.d/rundeck' do
		source 'rundeck.logrotate'
		owner 'root'
		group 'root'
		mode 00644
	end
	
	service 'rundeckd' do
		provider Chef::Provider::Service::Upstart if platform?('ubuntu') && node['platform_version'].to_f >= 12.04
		supports :status => true, :restart => true
		action [ :enable, :start ]
	end

end
