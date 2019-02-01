#!/bin/bash

set -e
set -u

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

set_hosts()
{
 if [[ -z $(grep ${APP_HOST} /etc/hosts) ]]; then
        sed -i 's/'$(hostname)'/'$(hostname)' '${APP_HOST}'/' /etc/hosts
 fi
}
wait_dbms()
{
 until nc -z $DB_HOST 5432
 do
   sleep 1
 done
}

run_install()
{
 if [[ ! -f /opt/metasfresh/metasfresh_server.jar ]]; then
	cp -R /opt/metasfresh/dist/deploy/* /opt/metasfresh/
        chmod 700 /opt/metasfresh/metasfresh_server.jar
	chown root:root -R /opt/metasfresh
	chmod -R a+w /opt/metasfresh/reports/
 fi
}

run_db_update()
{
 sleep 10
 cd /opt/metasfresh/dist/install/ && java -jar ./lib/de.metas.migration.cli.jar $@
} 

run_metasfresh()
{

 #2018-03-22 jb: added '-Dcom.sun.net.ssl.enableECC=false' to java opts
 #               gh issue: https://github.com/metasfresh/metasfresh-docker/issues/31
 #               info: https://docs.oracle.com/cd/E26362_01/E40761/html/known-bugs-issues.html
 #                     https://stackoverflow.com/a/19379760

 #2019-01-29 jb: added '-XX:HeapDumpPath=/opt/metasfresh/heapdump' to java opts
 #               gh issue: https://github.com/metasfresh/metasfresh-docker/issues/41
 
 cd /opt/metasfresh/ && java \
 -Dsun.misc.URLClassPath.disableJarChecking=true \
 -Xmx1024M -XX:MaxPermSize=512M \
 -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/opt/metasfresh/heapdump \
 -DPropertyFile=/opt/metasfresh/metasfresh.properties \
 -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8788 \
 -Dcom.sun.net.ssl.enableECC=false \
 -jar metasfresh_server.jar
}

run_install

set_properties /opt/metasfresh/metasfresh.properties
set_properties /opt/metasfresh/local_settings.properties
set_properties /root/local_settings.properties

wait_dbms

run_db_update

run_metasfresh

exit 0 
