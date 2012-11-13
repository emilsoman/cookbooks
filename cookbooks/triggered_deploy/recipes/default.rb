#
# Cookbook Name:: triggered_deploy
# Recipe:: default
#
# Copyright 2012, Emil Soman
#
# License - MIT
#

Chef::Log.info("Node name s equal to: #{Chef::Config[:node_name]}")
puts "_________________"
puts data_bag('nodes').inspect
puts "_________________"

Chef::Log.info("Printing : #{data_bag('nodes').inspect}")
project_id = data_bag_item('nodes', Chef::Config[:node_name])["project_id"]
puts "project id = #{project_id}"
puts "data bags for projects = #{data_bag('projects')}"
project_name = data_bag_item('projects', project_id)['name']
puts "project name = #{project_name}"
application "rails_app" do
  path "/deploy/#{project_name}"
  repository "git@github.com:emilsoman/rails_test_app.git"
  revision "HEAD"
  action :deploy
end
