#! /bin/bash
echo "STARTING DOCKER SERVICE (DOCKER IN DOCKER)"
sudo service docker start
echo "GIVING HAND TO DEFAULT ENDPOINT"
/bin/tini -- /usr/local/bin/jenkins.sh $*
