#! /bin/bash
echo "STARTING DOCKER SERVICE (DOCKER IN DOCKER)"
service docker start
echo "GIVING HAND TO DEFAULT ENDPOINT
/bin/tini -- /usr/local/bin/jenkins.sh
