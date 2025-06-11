#
# vault password is '1'
# use --ask-vault-pass option
# or the --vault-password-file option
# check with dry run
ansible-playbook setup-ssh-access.yaml --vault-password-file ./vault --check --diff --limit online2 -i 99d.hosts
# apply, optional --start-at-task
ansible-playbook setup-ssh-access.yaml --vault-password-file ./vault  --limit online2 -i 99d.hosts
