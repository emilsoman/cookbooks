#
# Cookbook Name:: db_mysql
# Recipe:: default
#
# Copyright 2012, Emil Soman
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
if node['cloud_environment_id'].nil?
  environment_id = data_bag_item('nodes', Chef::Config[:node_name])['environment_id']
  node.set['cloud_environment_id'] = environment_id
end
node_details = data_bag_item('nodes', Chef::Config[:node_name])
project = data_bag_item('projects', node_details['project_id'])
project_name = project["name"]

node.set['mysql']['server_root_password'] = "root"
node.set['mysql']['server_debian_password'] = "root"
node.set['mysql']['allow_remote_root'] = true

include_recipe "mysql::server"

execute "apt-get update" do
  ignore_failure true
  action :nothing
end.run_action(:run)

node.set['build_essential']['compiletime'] = true
include_recipe "build-essential"

%w{build-essential mysql-client libmysqlclient-dev}.each do |p|
  package p do
    action :nothing
  end.run_action(:install)
end

chef_gem 'mysql' do
  action :nothing
end.run_action(:install)

mysql_database project_name do
  connection ({:host => 'localhost', :username => 'root', :password => 'root'})
  action :create
end

ruby_block "set_database_deployed_true" do
  block do
    node.set["db_deployed"] = true
  end
end
