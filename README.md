# vm-formation (centos 7)

## creation d'un compte perso sur la VM avec droits de sudo root 

## prepa des envts de developpement (staff) a faire en sudo root
. installation docker (wget -qO- https://get.docker.com/ | sh), docker-compose (curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose ; chmod +x /usr/bin/docker-compose), git (sudo yum install git), java8 (sudo yum install java), puppet (rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm && yes | yum -y install puppet)
. demarrage docker (sudo service docker start)
. creation de comptes/groupes/sudos (en root)
sudo bash 
for trainee in {1..5}; do userlogin=traineegrp$trainee ; useradd $userlogin ; echo $userlogin | passwd --stdin $userlogin ; done  
visudo (ajouter ceci)  
  ALL ALL=(root) NOPASSWD: /bin/docker  
exit  
. creation d'alias docker pour faciliter les choses
sudo vi /etc/profile.d/dockercmds.sh
contenu:
alias dockerrmall='docker ps -a | awk '"'"'{print $1}'"'"' | grep -v CONTAINER | xargs docker rm'
alias dockerstopall='docker ps | awk '"'"'{print $1}'"'"' | grep -v CONTAINER | xargs docker stop'
. ajout des comptes dans le groupe docker (/etc/group) docker:x:GID:traineegrp,traineegrp1,traineegrp2,traineegrp3,traineegrp4,traineegrp5

## mise en place du backlog (manager/ba)
. crea de comptes github pour tout le monde
. crea d'une orga github avec les 3 amigos + staff
. fork des projets server et client 
. creation d'un backlog sur le fork du projet server via zenhub + invit de l'orga
=> panneau des feature teams

## mise en place du workspace de developpement (dev)
. recuperation du projet server : https://github.com/Finaxys/bluebank-atm-server.git en repo public
. analyse du projet
. build maven : creer des configurations de build pour : compilation et tests u, execution et generation des rapports BDD, execution des rapports de mutation testing

## mise en place de l'IC (dev/ops)
. Creation d'un compte docker.io (prendre le github)
docker login
. connexion a la VM par le compte traineegrp<ID>
. demarrage d'un conteneur docker jenkins : docker run -p 808{ID}:8080 -p 5000{ID}:50000 --name=traineegrp{ID}-jenkins jenkins, le lien http://{hostname}:8080
. description positionnee : THIS MESSAGE APPEARS IF THE CONTAINER IS PERSISTED
. Arrêt du conteneur (ctrl + c) puis redemarrage avec la meme commande : la description n'apparait plus sur la page
. description repositionnee : THIS MESSAGE APPEARS IF THE CONTAINER IS PERSISTED
. Arrêt du conteneur (ctrl + c) puis redemarrage avec l'option start : docker ps -a && docker start <id du conteneur> 
=> le message est conservé cette fois
. sur le meme principe, creation d'un conteneur sonar :  docker run -d --name traineegrp{ID}-sonarqube -p 900{ID}:9000 -p 909{ID}:9092 sonarqube ? NON
. Recup du package formation (git clone)+ creation des images ( docker-compose up)
. Modif de la description sur le jenkins : HELLO DOCKER-COMPOSE
. Stop des containers et re docker-compose up : la conf reste (restart le conteneur courant)
