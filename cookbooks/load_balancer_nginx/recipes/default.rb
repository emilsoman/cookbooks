app_instances_deployed = false


node_details = data_bag_item('nodes', Chef::Config[:node_name])
project = data_bag_item('projects', node_details['project_id'])
app_instances_deployed = project["environments"][node_details["environment_id"]]["app_instances_deployed"]
deployed_app_instances_count = app_instances_deployed.split(",").count
app_instances_count = project["environments"][node_details["environment_id"]]["app_instance_count"]

puts "app_instances_deployed = #{app_instances_deployed} ------- app_instances_count = #{app_instances_count}"


if deployed_app_instances_count = app_instances_count
  include_recipe "load_balancer_nginx::deploy"
end
