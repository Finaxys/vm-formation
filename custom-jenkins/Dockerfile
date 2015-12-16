FROM jenkins

# PROTOBUF INSTALL WITH APT-GET
RUN sudo apt-get install -y protobuf-compiler

# GIT INSTALL
RUN sudo apt-get install -y git

# MAVEN INSTALL
RUN mkdir -p /home/user/maven3 && \
wget -qO- "http://archive.apache.org/dist/maven/maven-3/3.1.1/binaries/apache-maven-3.1.1-bin.tar.gz" | tar -zx --strip-components=1 -C /home/user/maven3
ENV M2_HOME /home/user/maven3
RUN echo "export M2_HOME=$M2_HOME" >> /home/user/.bashrc
ENV PATH $M2_HOME/bin:$PATH
RUN echo "export PATH=$PATH" >> /home/user/.bashrc
