#
# Cookbook Name:: chef-rundeck
# Resource:: user
#
# Copyright 2012, Panagiotis Papadomitsos <pj@ezgr.net>
#

actions :create, :remove, :update

default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :password, :kind_of => String, :required => true
attribute :roles, :kind_of => Array, :default => [ 'admin' ]
attribute :encryption, :regex => /^(crypt|md5|plain)$/, :default => 'md5'
