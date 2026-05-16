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


## Tcpdump mérések

### Hoszt gépen

```sh
sudo tcpdump -i wlp4s0 -w tcpdump_host_wlp4s0.pcap
```

### Master és worker node-okon

1. `start-capture-all.sh` szkript másolása a node-ra (pl. scp-vel)
2. SSH belépés a node root felhasználójába (a tcpdump miatt fontos a root jogosultság)
3. Interfészek neveinek beírása a szkriptben a megfelelő helyre
4. Szkript futtatása: `./start-capture-all.sh`
5. Capture fájlok visszamásolása a hosztra (pl. scp-vel)

**node0** monitorozott interfészei:
```
datapath
eno1
enp5s0f0
lo
vethwe-bridge
vethwe-datapath
vethwepl076e5f5
vethwepld418e4b
vxlan-6784
weave
```

**node1** monitorozott interfészei:
```
datapath
eno1
enp5s0f0
lo
vethwe-bridge
vethwe-datapath
vethweplfe2aaa0
vxlan-6784
weave
```

**node2** monitorozott interfészei:
```
datapath
eno1
enp5s0f0
lo
vethwe-bridge
vethwe-datapath
vethweplc5f41b6
vethweplddb20ad
vxlan-6784
weave
```

**node3** monitorozott interfészei:
```
datapath
eno1
enp5s0f0
lo
vethwe-bridge
vethwe-datapath
vethwepl3962b1c
vxlan-6784
weave
```

### Pod-okon:

```sh
# turtlesim
kubectl exec -it -n ros2 ros2-turtlesim-6487b6dd4f-crgvj -- /bin/bash
tcpdump -i eth0 -w tcpdump_turtlesim_eth0.pcap
kubectl cp ros2/ros2-turtlesim-6487b6dd4f-crgvj:/tcpdump_turtlesim_eth0.pcap tcpdump_turtlesim_eth0.pcap

# turtlesim-draw-square
kubectl exec -it -n ros2 ros2-turtlesim-draw-square-58f897d556-6hlfm -- /bin/bash
tcpdump -i eth0 -w tcpdump_turtlesim-draw-square_eth0.pcap
kubectl cp ros2/ros2-turtlesim-draw-square-58f897d556-6hlfm:/tcpdump_turtlesim-draw-square_eth0.pcap tcpdump_turtlesim-draw-square_eth0.pcap

# guac-guacamole (guacamole pod)
kubectl exec -it -n guacamole guac-7dff9f674d-znzlj -c guac-guacamole -- /bin/bash
apt update
apt install net-tools tcpdump
tcpdump -i eth0 -w tcpdump_guac-guacamole_eth0.pcap
kubectl cp guacamole/guac-7dff9f674d-znzlj:/opt/guacamole/tcpdump_guac-guacamole_eth0.pcap tcpdump_guac-guacamole_eth0.pcap -c guac-guacamole

# guac-guacamole (guacamole pod)
# nincs bash, nincs apt, nincs semmilyen csomagkezelő, nincs tcpdump -> ebben a container-ben nem tudtam mérni

# guac-postgres (guacamole pod)
kubectl get pods -A -owide
kubectl exec -it -n guacamole guac-7dff9f674d-znzlj -c guac-postgres -- /bin/bash
apt update
apt install net-tools tcpdump
tcpdump -i eth0 -w tcpdump_guac-postgres_eth0.pcap
kubectl cp guacamole/guac-7dff9f674d-znzlj:/tcpdump_guac-postgres_eth0.pcap tcpdump_guac-postgres_eth0.pcap -c guac-postgres
```
