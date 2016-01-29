# vm-formation (centos 7)  
https://github.com/Finaxys/bluebank-atm-server  
  
Rappels : deux VMs par groupe avec access internet  
- 8 Gb RAM pour la plate-forme continunous delivery (centos7)  
- 2 Gb RAM pour la partie "run on cloud" (ubuntu 14.04)  
  
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

## ALTERNATIVE 

- Installation ansible  
```  
sudo rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm  
sudo yum -y update  
sudo yum -y install ansible  
ansible --version  
```  

- Creation du playbook.yml https://github.com/Finaxys/vm-formation/blob/master/FACTORY_SETUP/playbook.yml  
  
- Creation du fichier host.ansible https://github.com/Finaxys/vm-formation/blob/master/FACTORY_SETUP/playbook.yml   
  
- Execution du playbook en mode test (enlever l'option -C pour faire en vrai)  
```
ansible-playbook -i host.ansible -C  playbook.yml
```
