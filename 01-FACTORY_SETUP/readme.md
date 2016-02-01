# FORMATION CD  
Rappel : deux VMs par groupe avec access internet  
- 8 Gb RAM pour la plate-forme continunous delivery (centos7)  
- 2 Gb RAM pour la partie "run on cloud" (ubuntu 14.04)  

Code : https://github.com/Finaxys/bluebank-atm-server  
  
## CONFIGURATION MANUELLE

## Creation d'un compte perso sur la VM avec droits de sudo root  
  
## Prepa des VMS continuous delivery (staff) a faire en sudo root  
- Installation docker, docker-compose, git, java 8  
```  
wget -qO- https://get.docker.com/ | sh  
curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose  
chmod +x /usr/bin/docker-compose  
sudo yum install -y git java  
```  
- Demarrage et activation du service docker  
```  
sudo service docker start  
sudo chkconfig docker on  
```  
- Modification de la commande de démarrage de docker a cause du bug https://github.com/docker/docker/issues/17653  
```  
sudo vi /usr/lib/systemd/system/docker.service)  
```  
ExecStart=/usr/bin/docker daemon --exec-opt native.cgroupdriver=cgroupfs -H fd://  
  
- Creation du compte traineegrp et droits de sudo (en root)  
```  
sudo bash  
export PASSWORD=<password>  
useradd traineegrp ; echo ${PASSWORD} | passwd --stdin traineegrp  
```  
  
- Edition du sudoer 
```  
visudo  
```  
- Ajouter ceci  
```  
ALL ALL=(root) NOPASSWD: /bin/docker  
```  
  
- Creation des volumes pour le compte traineegrp  
```  
for service in jenkins nexus sonar elk; do mkdir -p /volumes/${service} ; done; done  
mkdir -p /volumes/sonar/data  
mkdir -p /volumes/sonar/extensions  
chown -R 1000:1000 /volumes/jenkins  
chown -R 200:200 /volumes/nexus  
```  
- Creation d'alias docker pour faciliter les choses  
```  
sudo vi /etc/profile.d/dockercmds.sh  
```  
- Contenu:  
```  
alias dockerstopall='docker ps | grep -v CONTAINER | awk '"'"'{print $1}'"'"' | xargs docker stop'  
alias dockerrmall='docker ps -a | grep -v CONTAINER | awk '"'"'{print $1}'"'"' | xargs docker rm'  
alias dockerrmiall='docker images | grep -v "IMAGE ID" | awk '"'"'{print $3}'"'"' | xargs docker rmi'  
```  

- Ajout du compte traineegrp dans le groupe docker  
```  
vi /etc/group  
docker:x:GID:traineegrp  
```  

- Configuration de routage pour les conteneurs  
```  
sudo iptables -A DOCKER -p tcp -j ACCEPT  
```  

## CONFIGURATION AUTOMATIQUE 

- Installation ansible et git (inutile avec l'image wittman/centos-7.2-ansible qui contient deja ansible et git?) 
```  
sudo rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm  
sudo yum -y update  
sudo yum -y install ansible git 
ansible --version  
```  

- Recuperation du repo https://github.com/Finaxys/vm-formation/
```  
git clone https://github.com/Finaxys/vm-formation
```  
Execution du playbook ansible qui va tout configurer
```  
ansible-playbook -i vm-formation/01-FACTORY_SETUP/01-setup-VM/host.ansible vm-formation/01-FACTORY_SETUP/01-setup-VM/playbook.yml  
```  

La VM a maintenant un moteur docker configuré et utilisable par le compte traineegrp.  
Le montage de la software factory peut se faire maintenant comme ceci:  
```  
cd 
```  
