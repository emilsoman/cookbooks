puts "Available nodes in data bag = #{data_bag('nodes').inspect}"
if node['cloud_environment_id'].nil?
  environment_id = data_bag_item('nodes', Chef::Config[:node_name])['environment_id']
  node.set['cloud_environment_id'] = environment_id
end
puts "Cloud Environment ID of node #{Chef::Config[:node_name]} = #{node.cloud_environment_id.inspect}"


node_details = data_bag_item('nodes', Chef::Config[:node_name])
project = data_bag_item('projects', node_details['project_id'])
project_name = project["name"]
secret_key = project["deploy_key"]
repo = project["repo"]

package "apt"

execute "apt update" do
  command "sudo apt-get update"
end

package "libsqlite3-dev"
package "nodejs"
package "libmysqlclient-dev"

application "app_rails" do
  owner 'ubuntu'
  group 'admin'
  path "/deploy/#{project_name}"
  repository repo
  revision "HEAD"
  environment_name "development"
  deploy_key secret_key
  rails do
    gems ["bundler"]
  end

  nginx_load_balancer do
    application_server_role 'app'
    application_port 8080
  end

end
ruby_block do
  block do
    node_details = data_bag_item('nodes', Chef::Config[:node_name])
    project = data_bag_item('projects', node_details['project_id'])
    project["environments"][node_details["environment_id"]]["environment_deployed"] = "true"
    puts "ENVIRONMENT DEPLOYED!!"
    project.save
  end
end
