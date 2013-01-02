name "app"
description "Role for all app servers"
run_list("recipe[apt]", "recipe[git]")
