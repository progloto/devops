#
# vault password is '1'
# use --ask-vault-pass option
# or the --vault-password-file option
# check with dry run
#ansible-playbook setup-ssh-access-nimbus.yaml -i nimbus.hosts --check --diff
# apply, optional --start-at-task
#ansible-playbook setup-ssh-access.yaml --vault-password-file ./vault-nimbus  --limit online2 -i 99d.hosts
ansible-playbook setup-ssh-access-nimbus.yaml -i nimbus.hosts
