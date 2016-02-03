## Installation de Mesos/Marathon/Jenkins via docker/docker-compose  
Cible : centos 7.2  
  
1. installation de docker  
```  
sudo -s -- << EOF  
yum update  
curl -sSL https://get.docker.com/ | sh  
service docker start  
docker run hello-world  
EOF  
```  
  
2. installation de docker-compose  
```  
sudo -s -- <<EOF  
curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose  
chmod +x /usr/bin/docker-compose  
EOF  
```  
  
2. Creation du fichier https://github.com/Finaxys/vm-formation/blob/master/MESOS-MARATHON-DOCKER-JENKINS/docker-compose.yml  
  
3. Lancement de la stack complète:  
```  
export HOST_IP=<IP_DU_HOST> ; export MESOS_RESOURCES="ports(*):[31000-32000]" ; docker-compose up -d  
GUI mesos :  http://<IP_DU_HOST>:5050/  
GUI marathon : http://<IP_DU_HOST>:8080/  
```  
  
4. installation de jenkins  
```  
curl -X PUT -H "Content-Type: application/json" http://localhost:8080/v2/apps/jenkins?force=true -d@jenkins.json  
GUI Jenkins : http://<IP_DU_HOST>:31000  
```  
  
ATTENTION : pour faire fonctionner le healthcheck, il a fallu mettre à jour le routage de la VM comme suit:
- autoriser le routage vers/depuis le network DOCKER  
```  
sudo iptables -A INPUT -i docker0 -j ACCEPT  
``` 
- reordonner les regles de routage de forwarding  
=> S'assurer que "-A FORWARD -i docker0 -o docker0 -j ACCEPT" est au-dessus de "-A FORWARD -j REJECT --reject-with icmp-host-prohibited"
- Mettre à jour la commande de démarrage du service Docker dans /usr/lib/systemd/system/docker.service comme ceci:  
```  
ExecStart=/usr/bin/docker daemon --exec-opt native.cgroupdriver=cgroupfs -H fd://  
```  
- Remplacer le healthcheck "COMMAND" par un check "HTTP"  

Pour mutualiser sur plusieurs hosts :  
docker machine + cluster swarm?  
docker networking entre hosts?  
autre?  
