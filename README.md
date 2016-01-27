# vm-formation (centos 7)

## creation d'un compte perso sur la VM avec droits de sudo root 

## prepa des envts de developpement (staff) a faire en sudo root
- installation docker (wget -qO- https://get.docker.com/ | sh)
- installation docker-compose (curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose ; chmod +x /usr/bin/docker-compose)  
- installation git (sudo yum install git), java8 (sudo yum install java)  
- installation puppet (rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm && yes | yum -y install puppet)  
- demarrage docker (sudo service docker start) 
- modification de la commande de démarrage de docker a cause du bug https://github.com/docker/docker/issues/17653 (sudo vi /usr/lib/systemd/system/docker.service) 
  ExecStart=/usr/bin/docker daemon --exec-opt native.cgroupdriver=cgroupfs -H fd://
- activation du service docker (sudo chkconfig docker on)
- creation de comptes/groupes/sudos (en root)  
sudo bash  
for trainee in {1..5}; do userlogin=traineegrp$trainee ; useradd $userlogin ; echo $userlogin | passwd --stdin $userlogin ; echo "export TRAINEEGRPID=$trainee" >> /home/${userlogin}/.bashrc;  done
visudo (ajouter ceci)  
  ALL ALL=(root) NOPASSWD: /bin/docker  
exit  
- creation des volumes pour les trainees
for trainee in {1..5}; do for service in jenkins nexus sonar elk; do mkdir -p /volumes/${service}/traineegrp${trainee}-${service}/ ; done; done
chown -R 1000:1000 /volumes/jenkins
chown -R 200:200 /volumes/nexus
- creation d'alias docker pour faciliter les choses  
sudo vi /etc/profile.d/dockercmds.sh  
contenu:  
alias dockerstopall='docker ps | grep -v CONTAINER | awk '"'"'{print $1}'"'"' | xargs docker stop'  
alias dockerrmall='docker ps -a | grep -v CONTAINER | awk '"'"'{print $1}'"'"' | xargs docker rm'  
alias dockerrmiall='docker images | grep -v "IMAGE ID" | awk '"'"'{print $3}'"'"' | xargs docker rmi'  
- ajout des comptes dans le groupe docker (/etc/group)   docker:x:GID:traineegrp,traineegrp1,traineegrp2,traineegrp3,traineegrp4,traineegrp5  
- creation du repertoire des volumes avec les bons droits
mkdir -p /volumes ; chgrp docker /volumes ; chmod 777 /volumes  
- configuration de routage pour les conteneurs  
sudo iptables -A DOCKER -p tcp -j ACCEPT

## mise en place de la metrologie (elastic) sur jenkins
- installer le plugin elastic sur jenkins  
docker exec -ti traineegrp${TRAINEEGRPID}-jenkins java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 install-plugin logstash -restart  
- declarer le serveur ELK dans la configuration du jenkins master  (ELASTICSEARCH, http://traineegrp-elk, 9200, pas user/password, jenkins/object)   
- installer head  
docker exec -ti traineegrp${TRAINEEGRPID}-elk /usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head
- dans chaque job activer logstash et lancer le pipeline : les données de build doivent remonter dans elastic  
ATTENTION : certaines informations sensibles (password etc) ne sont pas obfusquées ... d'ou l'interet d'un filtrage prealable
- dans Kibana creer un index pattern jenkins base sur @timestamp
- choisir via le time picker une plage week to date : les donnees doivent apparaitre  
- entrer la requete : message:"*Finished: SUCCESS*"  AND _exists_:data.buildVariables.PIPELINE_VERSION  
- choisir les colonnes data.projectName et data.buildVariables.PIPELINE_VERSION : le rendu permet d'avoir un historique des etapes reussies pour chaque version livree  
- Sauver la recherche en tant que PHASE_PER_VERSION  
- Remplacer la requete par : message:"*Finished: SUCCESS*"  OR  message:"*Finished: FAILURE*"  
- choisir les colonnes data.projectName,  data.buildVariables.PIPELINE_VERSION, data.buildDuration et message : le rendu permet d'avoir le temps d'execution de toutes les phases reussies ou non pour chaque version  
- Sauver cette nouvelle recherche en tant que DURATION_PER_VERSION  
- Creer une visualisation de type Vertical Bar associee a DURATION_PER_VERSION :  
- sur l'axe Y choisir un sum sur data.buildDuration  
- en X, subagregation sur le term PIPELINE_VERSION, Order TOP size 100, sum of data.buildDuration  
- en split bars choisir le term correspondant a data.projectName, Order TOP size 100, Order by Custom Metric Count  

- sauver la visu en DURATION_PER_VERSION  

- Creer un dashboard avec la visu DURATIONS_PER_VERSION a gauche, et la request PHASE_PER_VERSION a droite  
