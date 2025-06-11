#
#
# ansible-playbook -i nimbus.hosts deploy_apps.yaml --limit apps --check
ansible-playbook -i nimbus.hosts setup-ssh-access-nimbus.yaml
ansible-playbook -i nimbus.hosts deploy_apps.yaml --check
ansible-playbook -i nimbus.hosts deploy_apps.yaml 
