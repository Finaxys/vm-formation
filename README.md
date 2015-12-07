# vm-formation

1. crea compte perso sur la VM
2. installation docker (sudo yum install docker) et java8 (sudo yum install java)
3. demarrage docker (sudo service docker start)
4. definition d'alias docker (alias docker='sudo docker')
5. installation conteneur che (docker run --privileged -it -p 8080:8080 -p 49152-49162:49152-49162 codenvy/che)
