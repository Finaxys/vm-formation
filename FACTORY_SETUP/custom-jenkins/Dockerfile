FROM jenkins:1.625.3

# NEED TO BE ROOT FOR APT INSTALLS
USER root

# GIT INSTALL
RUN apt-get update && apt-get install -y git
# PROTOBUF INSTALL WITH APT-GET
RUN apt-get install -y protobuf-compiler
# PUPPET WITH JENKINS SPECIFIC MODULE INSTALL 
ENV JENKINS_HOME /var/lib/jenkins
RUN apt-get install -y puppet
# RUN puppet module install rtyler-jenkins : original module points to /var/lib/jenkins whereas docker image uses /var/jenkins! => hacked in postconfig/puppet_modules
RUN puppet module install puppetlabs-stdlib -v 4.6.0
RUN puppet module install puppetlabs-apt -v 2.2.1
RUN puppet module install puppetlabs-java -v 1.4.3
RUN puppet module install darin-zypprepo -v 1.0.2
RUN puppet module install nanliu-staging -v 1.0.3
RUN puppet module install camptocamp-archive -v 0.8.0
COPY ./postconfig /tmp/
RUN puppet apply /tmp/jenkinsconfig/manifests/init.pp --modulepath=/tmp/puppet_modules:/etc/puppet/modules

# PROTOBUF INSTALL "A LA MANO"
#RUN apt-get --help
#RUN wget https://protobuf.googlecode.com/files/protobuf-2.4.1.tar.gz
#RUN tar -xzvf protobuf-2.4.1.tar.gz
#RUN cd protobuf-2.4.1 && ./configure --prefix=/ && make && make install

# GET BACK TO STANDARD USER
USER jenkins

# MAVEN INSTALL
RUN mkdir -p //var/jenkins_home/maven3 && \
wget -qO- "http://archive.apache.org/dist/maven/maven-3/3.1.1/binaries/apache-maven-3.1.1-bin.tar.gz" | tar -zx --strip-components=1 -C /var/jenkins_home/maven3
ENV M2_HOME /var/jenkins_home/maven3
RUN echo "export M2_HOME=$M2_HOME" >> /var/jenkins_home/.bashrc
ENV PATH $M2_HOME/bin:/usr/local/bin:$PATH
RUN echo "export PATH=$PATH" >> /var/jenkins_home/.bashrc

