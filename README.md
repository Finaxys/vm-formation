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
for trainee in {1..5}; do userlogin=traineegrp$trainee ; useradd $userlogin ; echo $userlogin | passwd --stdin $userlogin ; done  
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

## mise en place du backlog (manager/ba)
- crea de comptes github pour tout le monde  
- crea d'une orga github avec les 3 amigos + staff  
- fork des projets server et client  
- creation d'un backlog sur le fork du projet server via zenhub + invit de l'orga  
=> panneau des feature teams  
  
## mise en place du workspace de developpement (dev)  
- recuperation du projet server : https://github.com/Finaxys/bluebank-atm-server.git en repo public  
- analyse du projet  
- build maven : creer des configurations de build pour : compilation et tests u, execution et generation des rapports BDD, execution des rapports de mutation testing  
  
## mise en place de l'IC (dev/ops)  
- Creation d'un compte docker.io (prendre le github)  
docker login  
- connexion a la VM par le compte traineegrp<ID>  
- demarrage d'un conteneur docker jenkins : docker run -p 808{ID}:8080 -p 5000{ID}:50000 --name=traineegrp{ID}-jenkins jenkins, le lien http://{hostname}:8080  
- description positionnee : THIS MESSAGE APPEARS IF THE CONTAINER IS PERSISTED  
- Arrêt du conteneur (ctrl + c) puis redemarrage avec la meme commande : la description n'apparait plus sur la page  
- description repositionnee : THIS MESSAGE APPEARS IF THE CONTAINER IS PERSISTED  
- Arrêt du conteneur (ctrl + c) puis redemarrage avec l'option start : docker ps -a && docker start <id du conteneur>  
=> le message est conservé cette fois  
- sur le meme principe, creation d'un conteneur sonar :  docker run -d --name traineegrp{ID}-sonarqube -p 900{ID}:9000 -p 909{ID}:9092 sonarqube ? NON  
- Recup du package formation (git clone)+ creation des images (docker-compose up)  
- Modif de la description sur le jenkins : HELLO DOCKER-COMPOSE  
- Stop des containers et re docker-compose up : la conf reste (restart le conteneur courant)  
- creation d'un job freestyle : pas de client git?  
docker exec -ti traineegrp-jenkins java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 install-plugin git -restart  
- configuration du job build ATM server sur https://github.com/Finaxys/bluebank-atm-server.git  
- build echoue : pas de maven ? installer  
docker exec -ti traineegrp-jenkins java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 install-tool  
This command can be only invoked from a build executing inside Hudson  
- configurer un maven basé sur le home suivant : /var/jenkins_home/maven3 (installe via puppet)  
- configurer un java basé sur le home suivant : /usr/lib/jvm/java-8-openjdk-amd64 (installé via puppet)
- configurer le build maven comme ceci : clean install -Pall-tests jacoco:report org.pitest:pitest-maven:mutationCoverage
- sur sonarcube, installer les plugins suivants: checkstyle, PMD, findbugs, github et pitest  
- sur jenkins, installer les plugins sonar, pitmutation et htmlpublisher  
docker exec -ti traineegrp-jenkins java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 install-plugin sonar  
docker exec -ti traineegrp-jenkins java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 install-plugin htmlpublisher  
docker exec -ti traineegrp-jenkins java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 install-plugin pitmutation -restart  
-  configurer une instance sonarcube sur http://traineegrp-sonarqube:9000 sans authent  
-  modifier le job de DEV avec le runner sonar + publication des rapports junit (target/surefire-reports/*.xml), jgiven (html sur target/jgiven-reports) et pit mutation (conf par defaut) et relancer  
-  apres analyse, ajouter les widgets integration tests et pitest reports dans sonarqube et comparer les resultats
-  rien sur pitest? ajouter dans jenkins l'option sur la configuration sonarqube (analysis properties) et relancer l'analyse  
sonar.pitest.mode=reuseReport  
  
