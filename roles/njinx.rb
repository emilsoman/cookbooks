name "nginx"
description "Role for all nginx loadbalancer servers"
run_list("recipe[apt]", "recipe[git]", "recipe[load_balancer_nginx]")
