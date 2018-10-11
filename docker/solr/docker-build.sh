#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Version Number Not Passed"
    echo "Usage: docker-build.sh <version_number>"
    exit 1
fi

version="$1"


echo "Version Passed: $version"
echo "Building Image: solr:ack-7.5.0-$version"
docker build -t solr:ack-7.5.0-$version .
echo "Tag Image: solr:ack-7.5.0-$version to uknth/solr:ack-7.5.0-$version"
docker tag solr:ack-7.5.0-$version uknth/solr:ack-7.5.0-$version
echo "Push Image to Docker Hub"
docker push uknth/solr:ack-7.5.0-$version

echo "----------------------------------------------------"
echo " DOCKER IMAGE: uknth/solr:ack-7.5.0-$version"
echo "----------------------------------------------------"
