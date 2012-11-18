db_resolved = false

node_details = data_bag_item('nodes', Chef::Config[:node_name])
project = data_bag_item('projects', node_details['project_id'])
db_instance_present = project["environments"][node_details["environment_id"]]["db_instance_present"]

puts "Db instance present = #{db_instance_present}"

if db_instance_present.to_s == true
  rds_ip_address = project["environments"][node_details["environment_id"]]["rds_ip_address"]
  puts "Rds ip address = #{rds_ip_address}"
  if rds_ip_address.nil?
    if project["environments"][node_details["environment_id"]]["db_deployed"].to_s == "true"
      puts "DB instance deployed = #{project["environments"][node_details["environment_id"]]["db_deployed"].to_s}"
      #If db instance was deployed by db_mysql recipe, continue
      db_resolved = true
    end
  else
    node.set["rds_ip_address"] = rds_ip_address
    #If rds ip address is found , continue
    db_resolved = true
  end
else
  #If the stack is not using a DB, continue
  db_resolved = true
end

if db_resolved
  include_recipe "app_rails::deploy"
end
