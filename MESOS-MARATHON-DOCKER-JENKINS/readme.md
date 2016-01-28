## Installation de Mesos/Marathon/Jenkins via docker/docker-compose
Cible : centos 7.2

1. installation de docker
sudo -s -- << EOF
yum update
curl -sSL https://get.docker.com/ | sh
service docker start
docker run hello-world
EOF

2. installation de docker-compose
sudo -s -- <<EOF
curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose  
chmod +x /usr/bin/docker-compose
EOF

2. Creation du fichier docker-compose.yml

3. Lancement de la stack complète:
export HOST_IP=<IP_DU_HOST> ; export MESOS_RESOURCES="ports(*):[31000-32000]" ; docker-compose up -d
GUI de http://178.33.83.136:5050/ et http://178.33.83.136:8080/), pour cela j'ai utilisé les noms réseau fournis par les links Docker et j'ai mis le master en écoute sur 0.0.0.0 + le mode privilégié pour rattacher les conteneurs à la VM, et tout ceci sans networking host.

4. installation de jenkins 
J'ai repris ta commande telle quelle :  curl -X PUT -H "Content-Type: application/json" http://localhost:8080/v2/apps/jenkins?force=true -d@jenkins.json

5. Le jenkins est bien accessible sur http://178.33.83.136:31000, redémarre quand je stoppe/kill le container et garde toutes les données vives, c'est fantastique.

Merci d'avoir pris le temps de dégrossir le sujet, avec cela nous allons pouvoir bien avancer pour la suite. Si tu veux refaire ce genre de choses mais avec trois serveurs/VMs différentes, il te faudra un docker machine sur chacune et cluster swarm (qui va lui-même créer un cluster de docker engines). Après faire un cluster qui va gérer un autre cluster ça semble assez risqué. Laurent tu corrigeras au besoin?
