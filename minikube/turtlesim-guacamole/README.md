## Turtlesim Guacamole-val

Kubernetes környezet előkészítése:
```sh
# Weavenet CNI manifest letöltése (csak egyszer kell minden új kubernetes verziónál)
minikube start
KUBEVER=$(kubectl version | base64 | tr -d '\n')
wget https://reweave.azurewebsites.net/k8s/net?k8s-version=$KUBEVER -O weavenet.yaml # ezzel nem működik, a weave-npc blokkol minden kapcsolatot valamiért
wget "https://reweave.azurewebsites.net/k8s/net?k8s-version=$KUBEVER&disable-npc=true" -O weavenet-nonpc.yaml
minikube delete

# Indítás Weavenet CNI-vel
minikube start --cni weavenet-nonpc.yaml

# open dashboard (opcionális)
minikube dashboard # külön ablakban vagy háttérben
```

Turtlesim elindítása:
```sh
cd ros2
kubectl apply -f namespace.yml
kubectl apply -f turtlesim.yml
cd ..
```

Guacamole elindítása:
```sh
# guacamole/init mappa (létrehozása és) csatolása a Kubernetes környezetbe:
mkdir -p guacamole/guacamole/init
minikube mount "$(pwd)/guacamole/guacamole:/guacamole" # külön ablakban vagy háttérben

cd guacamole
kubectl apply -f namespace.yml
kubectl apply -f guacamole.yml
cd ..
```

Draw square elérése: `kubectl attach -it -n ros2 <draw-square-pod-name>`
Turtlesim (Guacamole) elérése: `minikube service -n guacamole --all` -> `http://192.168.49.2:30654/guacamole/` (a `/guacamole/` hozzáírása szükséges)
Felhasználónév: `guacadmin`, jelszó: `guacadmin`

Settings -> Connections -> Új connection hozzáadása a guacamole felületen:
- Edit connection:
    - Name: `Turtlesim`
    - Protocol: `VNC`
- Parameters:
    - Hostname: `10.244.0.17` (`ros2-turtlesim-<...>` pod IP címe)
    - Port: `5900`
    - Password: `password123`
Save.

Jobb felül a user menüben: Home -> majd katt a Turtlesim-re (csatlakozás)



Egész törlése:
```sh
cd guacamole
kubectl delete -f guacamole.yml
kubectl delete -f namespace.yml
rm -R guacamole
cd ..

cd ros2
kubectl delete -f turtlesim.yml
kubectl delete -f namespace.yml
cd ..

minikube delete
```



Tcpdump mérések parancsai:
```sh
# host
sudo tcpdump -i veth0bbef79 -w tcpdump-host_veth0bbef79.pcap &
sudo tcpdump -i br-ceee13dfea39 -w tcpdump-host_br-ceee13dfea39.pcap &

# minikube
mkdir minikube-tcpdumps-mount
cp start-capture-minikube.sh minikube-tcpdumps-mount/
minikube mount minikube-tcpdumps-mount:/home/docker/tcpdumps # külön terminálban
minikube ssh
cp tcpdumps/start-capture-minikube.sh .
sudo ./start-capture-minikube.sh
mv tcpdump-minikube_* tcpdumps/

# guac-postgres
kubectl exec -it -n guacamole guac-5dbdb4c486-lcfkw -c guac-postgres -- /bin/bash
apt update
apt install net-tools tcpdump
tcpdump -i eth0 -w tcpdump-guac-postgres_eth0.pcap
kubectl cp guacamole/guac-5dbdb4c486-lcfkw:/tcpdump-guac-postgres_eth0.pcap tcpdump-guac-postgres_eth0.pcap -c guac-postgres

# guac-guacd
kubectl exec -it -n guacamole guac-5dbdb4c486-lcfkw -c guac-guacd -- /bin/sh # /bin/bash nincs
# nincs bash, nincs apt, nincs yum, nincs dnf, nincs tcpdump... -> nem sikerült a capture

# guac-guacamole
kubectl exec -it -n guacamole guac-5dbdb4c486-lcfkw -c guac-guacamole -- /bin/bash
apt update
apt install net-tools tcpdump
tcpdump -i eth0 -w tcpdump-guac-guacamole_eth0.pcap
kubectl cp guacamole/guac-5dbdb4c486-lcfkw:/opt/guacamole/tcpdump-guac-guacamole_eth0.pcap tcpdump-guac-guacamole_eth0.pcap -c guac-guacamole

# turtlesim-draw-square
kubectl exec -it -n ros2 ros2-turtlesim-draw-square-6754f9d6c7-6v7c8 -- /bin/bash
tcpdump -i eth0 -w tcpdump-turtlesim-draw-square_eth0.pcap
kubectl cp ros2/ros2-turtlesim-draw-square-6754f9d6c7-6v7c8:/tcpdump-turtlesim-draw-square_eth0.pcap tcpdump-turtlesim-draw-square_eth0.pcap

# turtlesim
kubectl exec -it -n ros2 ros2-turtlesim-965856f96-vmhrx -- /bin/bash
tcpdump -i eth0 -w tcpdump-turtlesim_eth0.pcap
kubectl cp ros2/ros2-turtlesim-965856f96-vmhrx:/tcpdump-turtlesim_eth0.pcap tcpdump-turtlesim_eth0.pcap
```
