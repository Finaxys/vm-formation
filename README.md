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

## mise en place du backlog (manager/ba)
- crea de comptes github pour tout le monde  
- crea d'une orga github avec les 3 amigos + staff  
- fork des projets server et client  
- creation d'un backlog sur le fork du projet server via zenhub + invit de l'orga  
=> panneau des feature teams  
  
## mise en place du workspace de developpement (dev)  
- recuperation du projet server : https://github.com/Finaxys/bluebank-atm-server.git en repo public  
- analyse du projet  
- build maven : creer des configurations de build pour : compilation et tests u, execution et generation des rapports BDD, execution des rapports de mutation testing, demarrage du serveur et de la GUI (install de protoc + path, definition de PIPELINE_VERSION en SNAPSHOT, install de node + path...)  
  
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
- configuration du job 01-ATM-BUILD avec l'url git sur https://github.com/Finaxys/bluebank-atm-server.git (nom: bluebank-atm-server)  
- positionner le polling : toutes les deux minutes
- build echoue : pas de maven ? installer  
docker exec -ti traineegrp-jenkins java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 install-tool  
This command can be only invoked from a build executing inside Hudson  
- configurer un maven basé sur le home suivant : /var/jenkins_home/maven3 (installe via puppet)  
- configurer un java basé sur le home suivant : /usr/lib/jvm/java-8-openjdk-amd64 (installé via puppet)
- configurer le build maven comme ceci : clean install -Pall-tests jacoco:report org.pitest:pitest-maven:mutationCoverage
- sur sonarcube, installer les plugins suivants: checkstyle, PMD, findbugs, github et pitest  
- sur jenkins, installer les plugins sonar, htmlpublisher, jobConfigHistory, saferestart, pitmutation  
docker exec -ti traineegrp-jenkins java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 install-plugin sonar  
docker exec -ti traineegrp-jenkins java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 install-plugin htmlpublisher  
docker exec -ti traineegrp-jenkins java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 install-plugin jobConfigHistory
docker exec -ti traineegrp-jenkins java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 install-plugin saferestart  
docker exec -ti traineegrp-jenkins java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 install-plugin pitmutation -restart  
- configurer une instance sonarcube sur http://traineegrp-sonarqube:9000 sans authent avec l'option sonar.pitest.mode=reuseReport  
- modifier le job de DEV avec le runner sonar + publication des rapports junit (target/surefire-reports/*.xml), jgiven (html sur target/jgiven-reports/json/*.json) et pit mutation (conf par defaut) et relancer  
- la page jgiven ne s'ouvre pas ? telecharger le zip, l'extraire et regarder  
- apres analyse, ajouter les widgets integration tests et pitest reports dans sonarqube et comparer les resultats => rien sur pitest?  
- installer le plugin envinject sur jenkins  
docker exec -ti traineegrp-jenkins java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 install-plugin envinject -restart  
- Injecter une variable password NEXUS_CONNEXION correspondant au <user>:<pasword> utilisé pour se connecter à Nexus
- Remplacer le goal maven pour inclure le deploiement des binaires  
clean deploy -Pall-tests jacoco:report org.pitest:pitest-maven:mutationCoverage  -DaltDeploymentRepository=releases::default::http://${NEXUS_CONNEXION}@traineegrp-nexus:8081/content/repositories/releases  
- definir un environnement pour le build avec le properties content suivant : PIPELINE_VERSION=${BUILD_NUMBER}
- modifier la version du pom.xml en ATMSERVER-${env.PIPELINE_VERSION} et pusher ... le job doit marcher  
- Ajouter en post-task un publish git avec le tag en ATMSERVER-${PIPELINE_VERSION} create vers le repo bluebank-atm-server
- Echec : ajouter en additional behaviour le custom user/email pour autoriser le push des tags  
- installer le plugin parameterized plugin  
docker exec -ti traineegrp-jenkins java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 install-plugin  parameterized-trigger -restart	

## mise en place du pipeline (dev/ops)  
- creer un job 02-ATM-PACKAGE de type freestyle (garder l'URL  + creds git du serveur)
- mettre a jour le job 01-ATM-BUILD pour inclure 02-ATM-PACKAGE en parameterized downstream, avec le git passthrough + les params predefinis comme suit : PIPELINE_VERSION=${PIPELINE_VERSION}  
- installer les plugins : build pipeline , rebuild, mask-passwords  
docker exec -ti traineegrp-jenkins java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 install-plugin build-pipeline-plugin  
docker exec -ti traineegrp-jenkins java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 install-plugin  mask-passwords  
docker exec -ti traineegrp-jenkins java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 install-plugin rebuild -restart  
- creer une vue pipeline ATM-PIPELINE et ajouter le job 01-ATM-BUILD
- Editer le job 02-ATM-PACKAGE ui doit creer une image de l'ATM, la lancer, la versionner  
SCM : le meme  
etape 1 (shell) : wget --no-verbose http://traineegrp-nexus:8081/content/repositories/releases/org/bluebank/atm/bluebank-atm/ATMSERVER-${PIPELINE_VERSION}/bluebank-atm-ATMSERVER-${PIPELINE_VERSION}.war -O 02-PACKAGE-ATM/bluebank-atm-ATMSERVER.war
- mettre a jour le javascript pour utiliser le port 818${TRAINEEGREPID} en "dur" (node-client/scripts/main.js, fixe a 8180 par defaut) et le CheckATMConnectivity.scala (ports HTTP et l'autre)
etape 2 (shell) : sudo docker build --tag=traineegrp${TRAINEEGREPID}/atm:${PIPELINE_VERSION} 02-PACKAGE-ATM
etape 3 (shell) : sudo docker run --name traineegrp${TRAINEEGREPID}-atm-${PIPELINE_VERSION} -itd -p 888${TRAINEEGREPID}:80 -p 818${TRAINEEGREPID}:8180 > atm.containerid

## creation d'un scenario de test sur le conteneur
- verifier l'URL http://<VM>:<port_80_mappe>/accounts/b73cf3a6-8f29-4ef1-955a-94c7efae01af : doit correspondre a la carte 5555444433331111
- installer gatling en local (http://gatling.io/#/download) et lancer le recorder en mode proxy 8000
- configurer un navigateur sur ce proxy et ouvrir l'URL http://<VM>:<port_80_mappe>/accounts/b73cf3a6-8f29-4ef1-955a-94c7efae01af
- enregistrer la sequence (C:\dev\gatling-charts-highcharts-bundle-2.1.7\user-files\simulations\RecordedSimulation.scala) et la committer dans le projet  
- relancer la sequence comme suit :  
gatling.bat --simulations-folder C:\Users\sguclu\git\sguclu\bluebank-atm-server --simulation CheckATMConnectivity

## import du container dans la registry
- Creation d'un job qui va stopper/supprimer le container local et pusher vers github.io : 03-ATM-PUSH-REGISTRY  
- ajout des parametres de connexion DOCKER_LOGIN, DOCKER EMAIL (parametres string) et DOCKER_PASSWORD (variable injectee de type password) pour se connecter a la registry
sudo docker stop $CONTAINER_ID && sudo docker rm $CONTAINER_ID  
- Copie de l'image afin de pouvoir la pousser sur la registry  
sudo docker tag -f traineegrp${TRAINEEGRPID}/atm:${PIPELINE_VERSION} ${LOGIN_DOCKER}/atm:${PIPELINE_VERSION}
sudo docker tag -f ${LOGIN_DOCKER}/atm:${PIPELINE_VERSION} ${LOGIN_DOCKER}/atm:latest
sudo docker login --username=${LOGIN_DOCKER} --password=${PASSWORD_DOCKER} --email=${EMAIL_DOCKER}
sudo docker push ${LOGIN_DOCKER}/atm
  
## deploiement vers le cloud (tutum)
- creer un compte tutum (le compte docker)  
- TODO la suite

TODO : ajout du push  
  
- Ajouter une step shell dans pour passer l'ID du container vers le job suivant dans 02-ATM-PACKAGE
echo "CONTAINER_ID=`cat atm.containerid`" > atm.containerid
- Creer un downstream job manuel dans 02-ATM-PACKAGE vers le job 03-ATM-PUSH-REGISTRY (passer les parametres du build + SHA1 courant + fichier atm.containerid)
  
## mise en place de la metrologie (elastic)  

## creation d'une feature pour pousser le pipeline de bout en bout  
