#!/bin/bash

#title           :remove_docker_stopped_images.sh
#description     :This script will remove all unused docker-images from the system.
#                 When issueing with "--force" it will also remove images which are
#                 in use. This will NOT remove the containers.
#                 Note: This script is very barebones and will produce errors
#                       by design.
#
#author          :julian.bischof@metasfresh.com
#date            :2017-04-03
#usage           :./remove_docker_stopped_images.sh [--force]
#==============================================================================


docker rm $(docker ps -q -f status=exited) 2>&1 >/dev/null
docker rmi $1 `docker images | awk '{ print $3; }'` 2>&1 >/dev/null


exit 0
