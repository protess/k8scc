kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep dash-admin | awk '{print $1}')
