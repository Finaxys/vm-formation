FROM jenkins

# NEED TO BE ROOT FOR APT INSTALLS
USER root

# PROTOBUF INSTALL WITH APT-GET : DOES NOT WORK ON THE JENKINS BASE IMAGE
# RUN apt-get install -y protobuf-compiler

# PROTOBUF INSTALL "A LA MANO"
RUN apt-get install g++
RUN wget https://protobuf.googlecode.com/files/protobuf-2.4.1.tar.gz
RUN tar -xzvf protobuf-2.4.1.tar.gz
RUN cd protobuf-2.4.1 && ./configure --prefix=/ && make && make install

# GIT INSTALL
RUN apt-get install -y git

# GET BACK TO STANDARD USER
USER jenkins

# MAVEN INSTALL
RUN mkdir -p /home/jenkins/maven3 && \
wget -qO- "http://archive.apache.org/dist/maven/maven-3/3.1.1/binaries/apache-maven-3.1.1-bin.tar.gz" | tar -zx --strip-components=1 -C /home/jenkins/maven3
ENV M2_HOME /home/jenkins/maven3
RUN echo "export M2_HOME=$M2_HOME" >> /home/jenkins/.bashrc
ENV PATH $M2_HOME/bin:/usr/local/bin:$PATH
RUN echo "export PATH=$PATH" >> /home/jenkins/.bashrc
