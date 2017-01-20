#!/bin/bash

set -e
set -u

DB_HOST=${DB_HOST:-db}
APP_HOST=${APP_HOST:-app}

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
 java -jar /opt/metasfresh/dist/install/lib/de.metas.migration.cli.jar $@
} 

run_metasfresh()
{
 cd /opt/metasfresh/ && java -jar metasfresh_server.jar
}

run_install

set_properties /opt/metasfresh/metasfresh.properties
set_properties /opt/metasfresh/local_settings.properties

wait_dbms

run_db_update

run_metasfresh

exit 0 
