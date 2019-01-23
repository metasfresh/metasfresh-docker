#!/bin/bash

set -e
#set -x

DB_HOST=db
APP_HOST=app

echo_variable_values()
{
 echo "*************************************************************"
 echo "Display the variable values we run with"
 echo "*************************************************************"
 echo "Note: all these variables can be set using the -e parameter."
 echo ""
 echo "DB_HOST=${DB_HOST}"
 echo "APP_HOST=${APP_HOST}"
 echo ""
}

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

# thx to 
# https://blog.csanchez.org/2017/05/31/running-a-jvm-in-a-container-without-getting-killed/
MEMORY_PARAMS="-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -XX:MaxRAMFraction=1"

run_metasfresh()
{
 cd /opt/metasfresh-webui-api/ && java -Dsun.misc.URLClassPath.disableJarChecking=true \
 $MEMORY_PARAMS \
 -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/opt/metasfresh-webui-api/heapdump \
 -DPropertyFile=/opt/metasfresh-webui-api/metasfresh.properties \
 -Dcom.sun.management.jmxremote.port=1618 \
 -Dcom.sun.management.jmxremote.authenticate=false \
 -Dcom.sun.management.jmxremote.ssl=false \
 -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8789 \
 -jar metasfresh-webui-api.jar
}

echo_variable_values

set_properties /opt/metasfresh-webui-api/metasfresh.properties
set_properties /opt/metasfresh-webui-api/local_settings.properties

wait_dbms
run_metasfresh

exit 0 
