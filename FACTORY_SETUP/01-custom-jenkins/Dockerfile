FROM jenkins:1.625.3

# NEED TO BE ROOT FOR APT INSTALLS
USER root
 
# MODULES INSTALL : GIT, PROTOBUF, PUPPET, SUDO
RUN apt-get update && apt-get install -y git protobuf-compiler puppet apt-transport-https sudo

# DOCKER REPOS SETUP - YEAH, DOCKER IN DOCKER ;)
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-cache policy docker-engine

# INSTALL AND ACTIVATE DOCKER 
RUN apt-get install -y docker-engine && \
    adduser jenkins sudo && \
    echo "jenkins ALL=NOPASSWD:ALL" | (EDITOR="tee -a" visudo) && \ 
    echo "alias docker='sudo docker'" >> /var/jenkins_home/.bashrc && \
    usermod -aG docker jenkins

# PUPPET MODULES INSTALL : rtyler-jenkins original module points to /var/lib/jenkins whereas docker image uses /var/jenkins_home! => hacked in postconfig/puppet_modules
COPY ./postconfig /tmp/
RUN puppet module install puppetlabs-stdlib -v 4.6.0 ;\
    puppet module install puppetlabs-apt -v 2.2.1 ;\
    puppet module install puppetlabs-java -v 1.4.3 ;

# puppet post-configuration : install java8
RUN puppet apply /tmp/jenkinsconfig/manifests/init.pp --modulepath=/tmp/puppet_modules:/etc/puppet/modules

# GET BACK TO STANDARD USER
USER jenkins

# MAVEN INSTALL "A LA MANO"
ENV PATH $M2_HOME/bin:/usr/local/bin:$PATH
ENV M2_HOME /var/jenkins_home/maven3
RUN mkdir -p //var/jenkins_home/maven3 && \
    wget -qO- "http://archive.apache.org/dist/maven/maven-3/3.1.1/binaries/apache-maven-3.1.1-bin.tar.gz" | tar -zx --strip-components=1 -C /var/jenkins_home/maven3 && \
    echo "export M2_HOME=$M2_HOME" >> /var/jenkins_home/.bashrc && \
    echo "export PATH=$PATH" >> /var/jenkins_home/.bashrc
