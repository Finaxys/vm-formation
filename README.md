# vm-formation (centos 7)

## prepa des envts de developpement (staff)
1. crea compte perso sur la VM
2. installation docker (sudo yum install docker), git (sudo yum install git) et java8 (sudo yum install java)
3. demarrage docker (sudo service docker start)
4. definition d'alias docker (alias docker='sudo docker')
5. creation de comptes/groupes/sudos (en root)
sudo bash 
for trainee in {1..5}; do userlogin=traineegrp$trainee ; useradd $userlogin ; echo $userlogin | passwd --stdin $userlogin ; done  
visudo (ajouter ceci)  
  ALL ALL=(root) NOPASSWD: /bin/docker  
exit  
useradd che 
6. ajout des comptes dans le groupe dockerroot (/etc/group) dockerroot:x:GID:traineegrp,traineegrp1,traineegrp2,traineegrp3,traineegrp4,traineegrp5
7. ajout de l'option -G dockerroot dans /etc/sysconfig/docker

## mise en place du backlog (manager/ba)
1. crea de comptes github pour tout le monde
2. crea d'une orga avec les 3 amigos + staff
3. fork des projets server et client 
4. creation d'un backlog sur le projet server sur zenhub + invit de l'orga

## mise en place du workspace de developpement (dev)
1. recuperation du projet server : https://github.com/Finaxys/bluebank-atm-server.git en repo public
2. analyse du projet
3. build maven : creer des configurations de build pour : compilation et tests u, execution et generation des rapports BDD, execution des rapports de mutation testing

## mise en place de l'IC (dev/ops)
1. connexion a la VM par le compte traineegrp<ID>
2. demarrage d'un conteneur docker jenkins : docker run -p 808{ID}:8080 -p 5000{ID}:50000 jenkins, le lien http://{hostname}:8080
3. description positionnee : THIS MESSAGE APPEARS IF THE CONTAINER IS PERSISTED
5. Arrêt du conteneur (ctrl + c) puis redemarrage avec la meme commande : la description n'apparait plus sur la page
6. description repositionnee : THIS MESSAGE APPEARS IF THE CONTAINER IS PERSISTED
7. Arrêt du conteneur (ctrl + c) puis redemarrage avec l'option start : docker ps -a && docker start <id du conteneur> 
=> le message est conservé cette fois
8. sur le meme principe, creation d'un conteneur sonar
9. 
