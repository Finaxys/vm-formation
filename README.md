# vm-formation (centos 7)

Rappels : deux VMs par groupe avec access internet
- 8 Gb RAM pour la plate-forme continunous delivery (centos7)
- 2 Gb RAM pour la partie "run on cloud" (ubuntu 14.04)

## creation d'un compte perso sur la VM avec droits de sudo root 

## prepa des VMS continuous delivery (staff) a faire en sudo root
- installation docker, docker-compose, git, java 8  
wget -qO- https://get.docker.com/ | sh  
curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose ; chmod +x /usr/bin/docker-compose
sudo yum install -y git java

- demarrage et activation du service docker  
sudo service docker start 
sudo chkconfig docker on  
 
- modification de la commande de démarrage de docker a cause du bug https://github.com/docker/docker/issues/17653  
sudo vi /usr/lib/systemd/system/docker.service)  
ExecStart=/usr/bin/docker daemon --exec-opt native.cgroupdriver=cgroupfs -H fd://  

- creation du compte traineegrp et droits de sudo (en root)  
sudo bash
export PASSWORD=<password>
useradd traineegrp ; echo ${PASSWORD} | passwd --stdin traineegrp

visudo (ajouter ceci)  
  ALL ALL=(root) NOPASSWD: /bin/docker  
exit  

- creation des volumes pour le compte traineegrp
for service in jenkins nexus sonar elk; do mkdir -p /volumes/${service} ; done; done
mkdir -p /volumes/sonar/data 
mkdir -p /volumes/sonar/extensions
chown -R 1000:1000 /volumes/jenkins
chown -R 200:200 /volumes/nexus
- creation d'alias docker pour faciliter les choses  
sudo vi /etc/profile.d/dockercmds.sh  
contenu:  
alias dockerstopall='docker ps | grep -v CONTAINER | awk '"'"'{print $1}'"'"' | xargs docker stop'  
alias dockerrmall='docker ps -a | grep -v CONTAINER | awk '"'"'{print $1}'"'"' | xargs docker rm'  
alias dockerrmiall='docker images | grep -v "IMAGE ID" | awk '"'"'{print $3}'"'"' | xargs docker rmi'  
  
- ajout du compte traineegrp dans le groupe docker  
vi /etc/group  
docker:x:GID:traineegrp  
  
- creation du repertoire des volumes avec les bons droits
mkdir -p /volumes ; chgrp docker /volumes ; chmod 777 /volumes  
- configuration de routage pour les conteneurs  
sudo iptables -A DOCKER -p tcp -j ACCEPT
