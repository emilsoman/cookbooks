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
 
puts "Available nodes in data bag = #{data_bag('nodes').inspect}"
if node['cloud_environment_id'].nil?
  environment_id = data_bag_item('nodes', Chef::Config[:node_name])['environment_id']
  node.set['cloud_environment_id'] = environment_id
end
puts "Cloud Environment ID of node #{Chef::Config[:node_name]} = #{node.cloud_environment_id.inspect}"
=begin
project_name = ""
projects = data_bag('projects')
projects.each do |project|
  data_bag_content = data_bag_item('projects', project)
  if data_bag_content['environment_id'] == node.cloud_environment_id
    project_name = data_bag_content['name']
  end
end
=end

package "mysql-client" 
package "libmysqlclient-dev"
package "ruby-mysql"

node['mysql']['server_root_password'] = "root"

include_recipe "mysql::server"
include_recipe "mysql::server_ec2"

sleep 10

username = "root"
password = "root"
mysql_database 'oracle_rules' do
   connection ({:host => "localhost", :username => username, :password => password})
   action :create
end 
