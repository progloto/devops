# show or change current kubernetes cluster 
alias kx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config get-contexts ; } ; f'
# show or change current namespace in kubetrnetes cluster
alias kn='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'

