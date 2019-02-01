#!/bin/bash

set -e

DB_HOST=db
APP_HOST=app

set_properties()
{
 local prop_file="$1"
 if [[ $(cat $prop_file | grep FOO | wc -l) -ge "1" ]]; then
	sed -Ei "s/FOO_DBMS/$DB_HOST/g" $prop_file
	sed -Ei "s/FOO_APP/$APP_HOST/g" $prop_file
 fi
}

wait_dbms()
{
 until nc -z $DB_HOST 5432
 do
   sleep 1
 done
}

 #2019-01-29 jb: added '-XX:HeapDumpPath=/opt/metasfresh/heapdump' to java opts
 #               gh issue: https://github.com/metasfresh/metasfresh-docker/issues/41
 #
 
 #2019-02-01 jb: changed memory parameter to make java aware its living in a container.
 #               this allows for flexible memory allocation in docker-compose.yml settings.
 #               Thanks to https://blog.csanchez.org/2017/05/31/running-a-jvm-in-a-container-without-getting-killed/
 #               
run_metasfresh()
{
 cd /opt/metasfresh-webui-api/ && java -Dsun.misc.URLClassPath.disableJarChecking=true \
 -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -XX:MaxRAMFraction=1 \
 -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/opt/metasfresh-webui-api/heapdump \
 -DPropertyFile=/opt/metasfresh-webui-api/metasfresh.properties \
 -Dcom.sun.management.jmxremote.port=1618 \
 -Dcom.sun.management.jmxremote.authenticate=false \
 -Dcom.sun.management.jmxremote.ssl=false \
 -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8789 \
 -jar metasfresh-webui-api.jar
}


set_properties /opt/metasfresh-webui-api/metasfresh.properties
set_properties /opt/metasfresh-webui-api/local_settings.properties

wait_dbms
run_metasfresh

exit 0 
