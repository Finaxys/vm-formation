# vm-formation

## creation envt de developpement
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
  
# mise en place du workspace de developpement
1. recuperation du projet server : https://github.com/Finaxys/bluebank-atm-server.git en repo public
2. TODO etapes de dev

# mise en place de l'IC
1. connexion a la VM par le compte traineegrp<ID>
2. demarrage d'un conteneur docker jenkins : docker run -p 808<ID>:8080 -p 5000<ID>:50000 jenkins
3. creation d'un item (job) puis arret/demarrage du conteneur : plus rien
4. demarrage avec l'option de volume : docker run -p 808<ID>:8080 -p 5000<ID>:50000 -v /home/traineegrp<ID>:/var/jenkins_home jenkins 
NE MARCHE PAS : a  corriger
