#!/bin/bash
set +ex

# todo add any additional variables
echo "all:" > inventory.yml 
echo "  hosts:" >> inventory.yml 
echo "    \"$(cd ../infra && terraform output instance_public_ip)\"" >> inventory.yml
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.yml -e 'record_host_keys=True' -u ec2-user --private-key ../keys/ec2-key --extra-vars "db_endpoint=$(cd ../infra && terraform output db_endpoint) lb_endpoint=$(cd ../infra && terraform output lb_endpoint) instance_public_ip=$(cd ../infra && terraform output instance_public_ip) db_user=$(cd ../infra && terraform output db_user) db_pass=$(cd ../infra && terraform output db_pass)" ../ansible/playbook.yml