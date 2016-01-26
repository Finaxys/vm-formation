FROM jenkins:1.625.3

# NEED TO BE ROOT FOR APT INSTALLS
USER root
 
# MODULES INSTALL : GIT, PROTOBUF, PUPPET, SUDO
RUN apt-get update && apt-get install -y git protobuf-compiler apt-transport-https sudo wget telnet vim

# DOCKER REPOS SETUP - YEAH, DOCKER IN DOCKER ;)
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-cache policy docker-engine

# INSTALL AND ACTIVATE DOCKER 
RUN apt-get install -y docker-engine && \
    adduser jenkins sudo && \
    echo "jenkins ALL=NOPASSWD:ALL" | (EDITOR="tee -a" visudo) && \ 
    usermod -aG docker jenkins

# GET BACK TO STANDARD USER
USER jenkins

# GATLING INSTALL "A LA MANO" DISABLED FOR NOW
RUN cd /tmp && \
 wget https://oss.sonatype.org/content/repositories/releases/io/gatling/highcharts/gatling-charts-highcharts-bundle/2.1.7/gatling-charts-highcharts-bundle-2.1.7-bundle.zip && \
  unzip gatling-charts-highcharts-bundle-2.1.7-bundle.zip
