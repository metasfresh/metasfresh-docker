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

# For Instances with Java8. Should have no effect on other java versions due to absolute paths used. 
# Need to remove this file or we get "java.awt.AWTError: Assistive Technology not found: org.GNOME.Accessibility.AtkWrapper" when running jasper reports
remove_accessibility-properties(){
	rm -fv /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/accessibility.properties
	rm -fv /etc/java-8-openjdk/accessibility.properties
}

run_metasfresh()
{

 #2018-03-22 jb: added '-Dcom.sun.net.ssl.enableECC=false' to java opts
 #		 gh issue: https://github.com/metasfresh/metasfresh-docker/issues/31
 #		 info: https://docs.oracle.com/cd/E26362_01/E40761/html/known-bugs-issues.html
 #		       https://stackoverflow.com/a/19379760

 #2019-01-29 jb: added '-XX:HeapDumpPath=/opt/metasfresh/heapdump' to java opts
 #               gh issue: https://github.com/metasfresh/metasfresh-docker/issues/41
 
 #2022-04-23 ts: added '-Dloader.path=/opt/metasfresh/external-lib':
 # Allow loading jars from /opt/metasfresh/external-lib.
 # This assumes that the app uses PropertiesLauncher (can be verified by opening the jar e.g. with 7-zip and checking META-INF/MANIFEST.MF)
 # Also see https://docs.spring.io/spring-boot/docs/current/reference/html/executable-jar.html#executable-jar-property-launcher-features
  
 cd /opt/metasfresh/ && java \
 -Dsun.misc.URLClassPath.disableJarChecking=true \
 -Xmx1024M \
 -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/opt/metasfresh/heapdump \
 -DPropertyFile=/opt/metasfresh/metasfresh.properties \
 -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8788 \
 -Dloader.path=/opt/metasfresh/external-lib \
 -Dcom.sun.net.ssl.enableECC=false \
 -jar metasfresh_server.jar
}

run_install

set_properties /opt/metasfresh/metasfresh.properties
set_properties /opt/metasfresh/local_settings.properties
set_properties /root/local_settings.properties

wait_dbms

run_db_update

remove_accessibility-properties

run_metasfresh

exit 0 
