#
# Cookbook Name:: chef-rundeck
# Provider:: user
#
# Copyright 2012, Panagiotis Papadomitsos <pj@ezgr.net>
#

action :create do

	new_resource.updated_by_last_action(true)

	# Check user existense in realm.properties
	if ::File.read(::File.join('etc','rundeck','realm.properties')).match(/^#{new_resource.name}: /)
		new_resource.updated_by_last_action(false)
		Chef::Log.info("Rundeck user #{new_resource.name} already exists. Please use :update action instead")
	else
		# Append the line to realm.properties
		::File.open(::File.join('etc','rundeck','realm.properties'), 'a') do |fp|
			fp.puts(create_auth_line(new_resource.name, new_resource.password, new_resource.encryption, new_resource.roles))
		end
		Chef::Log.info("Rundeck user #{new_resource.name} created")		
		ruby_block "notify-rundeckd-restart" do
			block do
				notifies :restart, "service[rundeckd]"		
			end
		end
	end

end

action :remove do

	new_resource.updated_by_last_action(true)
	
	# Check user existense in realm.properties
	unless ::File.read(::File.join('etc','rundeck','realm.properties')).match(/^#{new_resource.name}: /)
		new_resource.updated_by_last_action(false)
	else
		fp = ::File.open(::File.join('etc','rundeck','realm.properties'), 'r')
		newcontent = String.new
		while line = fp.readline
			newcontent << line unless fp.gets.match(/^#{new_resource.name}: /)
		end
		fp.close
		::File.open(::File.join('etc','rundeck','realm.properties'), 'w') do |fp|
			fp.puts(newcontent)
		end
		Chef::Log.info("Rundeck user #{new_resource.name} removed")
		ruby_block "notify-rundeckd-restart" do
			block do
				notifies :restart, "service[rundeckd]"		
			end
		end
	end

end

action :update do
	new_resource.updated_by_last_action(true)

	new_auth_line = create_auth_line(new_resource.name, new_resource.password, new_resource.encryption, new_resource.roles)

	unless ::File.read(::File.join('etc','rundeck','realm.properties')).match(/^#{new_auth_line}: $/)
		new_resource.updated_by_last_action(false)
		Chef::Log.info("Rundeck user #{new_resource.name} already up to date")		
	else
		fp = ::File.open(::File.join('etc','rundeck','realm.properties'), 'r')
		newcontent = String.new
		while line = fp.readline
			newcontent << fp.gets.match(/^#{new_resource.name}: /) ? new_auth_line : line
		end
		fp.close
		::File.open(::File.join('etc','rundeck','realm.properties'), 'w') do |fp|
			fp.puts(newcontent)
		end	
		Chef::Log.info("Rundeck user #{new_resource.name} updated")
		ruby_block "notify-rundeckd-restart" do
			block do
				notifies :restart, "service[rundeckd]"		
			end
		end
	end
	
end

def create_auth_line(username, password, encryption, roles)
	case encryption
	when 'crypt'
		pass = 'CRYPT:' + password.crypt('rb')
	when 'md5'
		require 'digest/md5'
		pass = 'MD5:' + Digest::MD5.hexdigest(password)
	when 'plain'
		pass = password
	end

	return "#{username}: #{pass},#{roles.join(',')}"
end