## Deployment-ek elindítása

```sh
# a node0 (master node) gépre belépve ssh-val:
cd turtlesim-guacamole/

cd ros2
kubectl apply -f namespace.yml
kubectl apply -f turtlesim.yml
cd ..

cd guacamole
kubectl apply -f namespace.yml
kubectl apply -f guacamole.yml
cd ..
```

```sh
kubectl attach -it -n ros2 ros2-turtlesim-draw-square-58f897d556-l282t # külön ablakban

kubectl get services -n guacamole

ssh -i <kulcs> kube@<node0-external-ip> -L 8080:<CLUSTER-IP>>:8080 # külön ablakban (host gépről)
```
http://127.0.0.1:8080/guacamole/

Felhasználónév: `guacadmin`, jelszó: `guacadmin`

Settings -> Connections -> Új connection hozzáadása a guacamole felületen:
- Edit connection:
    - Name: `Turtlesim`
    - Protocol: `VNC`
- Parameters:
    - Hostname: `10.44.0.1` (`ros2-turtlesim-<...>` pod IP címe)
    - Port: `5900`
    - Password: `password123`

Save.

Jobb felül a user menüben: Home -> majd katt a Turtlesim-re (csatlakozás)


## Egész törlése:
```sh
cd guacamole
kubectl delete -f guacamole.yml
kubectl delete -f namespace.yml
cd ..

cd ros2
kubectl delete -f turtlesim.yml
kubectl delete -f namespace.yml
cd ..
```

