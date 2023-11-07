#!/bin/bash

#title           :upgrade_postgres.sh
#description     :
#author          :max.rieck@metasfresh.com
#date            :2022-11-29
#usage           :nohup bash ./upgrade_postgres.sh
#logs            :tail -f nohup.out
#
#                Prerequisites: Enough storage space to store a second db-volume
#
#                unknown data-types aren't supported anymore, they should be altered before upgrade
#                SELECT *
#                FROM information_schema.columns
#                WHERE data_type ILIKE 'unknown';
#
#                before starting set POSTGRES_PASSWORD in docker-compose-before-upgrade-postgres.yml
#                before starting set POSTGRES_PASSWORD in docker-compose-upgrade-postgres.yml
#                before starting set POSTGRES_PASSWORD in docker-compose-after-upgrade-postgres.yml
#
#                ATTENTION:
#                this script generates and executes SQL to alternate Tables with oids
#======================================================================================================

start=$(date +%s)

instance=$(basename "${PWD%/*}")

echo "stopping metasfresh instance $instance"
docker-compose -p "$instance" stop

while [ "$(docker inspect -f '{{.State.Running}}' "${instance}"_db_1)" == "true" ] ; do
  sleep 2
  echo "waiting for $instance to stop..."
done

echo "waiting for $instance to stop... done"
echo ""

echo "docker-compose up -f docker-compose-before-upgrade-postgres.yml -p ${instance}-before-upgrade-postgres"

if ! docker-compose -f docker-compose-before-upgrade-postgres.yml -p "${instance}"-before-upgrade-postgres up -d; then
    end=$(date +%s)
    runtime=$((end-start))
    echo "script failed after ${runtime}s"
    exit 1
fi

echo "starting postgres beforedb for handling tables with oids"

while [ "$(docker inspect -f '{{.State.Health.Status}}' "${instance}"-before-upgrade-postgres-beforedb-1)" != "healthy" ]; do
  echo "waiting for db..."
  sleep 5
done

echo "waiting for db... done"
echo ""

echo "alter known oid-tables to without oids"
docker exec -i "${instance}"-before-upgrade-postgres-beforedb-1 psql -U metasfresh -d metasfresh -tAc "
ALTER TABLE de_metas_acct.accounting_docs_to_repost SET WITHOUT OIDS;
ALTER TABLE public.c_invoice_candidate_recompute SET WITHOUT OIDS;
ALTER TABLE public.fact_acct_log SET WITHOUT OIDS;
"

docker exec -i "${instance}"-before-upgrade-postgres-beforedb-1 psql -U metasfresh -d metasfresh -tAc "
SELECT quote_ident(nspname) || '.' || quote_ident(relname)
FROM pg_catalog.pg_class c
         LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE 1=1
  AND c.relkind = 'r'
  AND c.relhasoids = true
  AND n.nspname <> 'pg_catalog'
order by n.nspname, c.relname;
" >tables_with_oids.txt

rm handle_tables_with_oids.sql 2> /dev/null

while read -ru 3 p; do
  nextOID=$(docker exec -i "${instance}"-before-upgrade-postgres-beforedb-1 pg_controldata -D /var/lib/postgresql/data | grep OID)
  nextOID=${nextOID#"Latest checkpoint's NextOID:"}
  nextOID=${nextOID// /}

  echo "

ALTER TABLE $p DISABLE TRIGGER ALL;
ALTER TABLE $p ADD newoid bigint NOT NULL;
UPDATE $p SET newoid = oid;
ALTER TABLE $p SET WITHOUT OIDS;
ALTER TABLE $p RENAME newoid TO oid;
CREATE SEQUENCE IF NOT EXISTS oid_seq;
ALTER TABLE $p ALTER oid SET DEFAULT nextval('oid_seq');
SELECT setval('oid_seq', $nextOID);
ALTER TABLE $p ENABLE TRIGGER ALL;

  " >> handle_tables_with_oids.sql
done 3< tables_with_oids.txt

oidsql=$(cat handle_tables_with_oids.sql)
docker exec -i "${instance}"-before-upgrade-postgres-beforedb-1 psql -U metasfresh -d metasfresh -c "$oidsql"

echo "docker stop ${instance}-before-upgrade-postgres-beforedb-1"
docker stop "${instance}"-before-upgrade-postgres-beforedb-1

while [ "$(docker inspect -f '{{.State.Running}}' "${instance}"-before-upgrade-postgres-beforedb-1)" == "true" ]; do
  sleep 2
  echo "waiting for ${instance}-before-upgrade-postgres-beforedb-1 to stop..."
done

echo "waiting for ${instance}-before-upgrade-postgres-beforedb-1 to stop... done"

echo "docker rm ${instance}-before-upgrade-postgres-beforedb-1"
docker rm "${instance}"-before-upgrade-postgres-beforedb-1

echo "docker-compose up -f docker-compose-upgrade-postgres.yml -p ${instance}-upgrade-postgres"
docker-compose -f docker-compose-upgrade-postgres.yml -p "${instance}"-upgrade-postgres up

docker exec -i -u postgres "${instance}"-upgrade-postgres-upgradedb-1 cp ./update_extensions.sql /var/lib/postgresql/15/data/update_extensions.sql

upgradelogs=$(docker logs "${instance}"-upgrade-postgres-upgradedb-1 --tail 100)
grep -wq "Upgrade Complete" <<< "$upgradelogs"
upgradeComplete=$?

echo "docker stop ${instance}-upgrade-postgres-upgradedb-1"
docker stop "${instance}"-upgrade-postgres-upgradedb-1

while [ "$(docker inspect -f '{{.State.Running}}' "${instance}"-upgrade-postgres-upgradedb-1)" == "true" ]; do
  sleep 2
  echo "waiting for ${instance}-upgrade-postgres-upgradedb-1 to stop..."
done
echo "waiting for ${instance}-upgrade-postgres-upgradedb-1 to stop... done"
echo ""

echo "docker rm ${instance}-upgrade-postgres-upgradedb-1"
docker rm "${instance}"-upgrade-postgres-upgradedb-1

if [ $upgradeComplete -ne 0 ]; then
    echo "upgrade failed removing newdb volume..."
    rm -r ./../volumes/newdb
    end=$(date +%s)
    runtime=$((end-start))
    echo "script failed after ${runtime}s"
    exit 1
fi

echo "copying config files..."
cp ./../volumes/db/data/pg_hba.conf ./../volumes/newdb/data/pg_hba.conf
cp ./../volumes/db/data/postgresql.conf ./../volumes/newdb/data/postgresql.conf
cp ./../volumes/db/data/postgresql.auto.conf ./../volumes/newdb/data/postgresql.auto.conf
echo "copying config files... done"
echo ""

docker-compose -f docker-compose-after-upgrade-postgres.yml -p "${instance}"-after-upgrade-postgres up -d

echo "starting postgres afterdb for update extensions, vacuumdb and reindex"

while [ "$(docker inspect -f '{{.State.Health.Status}}' "${instance}"-after-upgrade-postgres-afterdb-1)" != "healthy" ]; do
  echo "waiting for db..."
  sleep 5
done

echo "waiting for db... done"
echo ""

echo "update extensions"
docker exec -i -u postgres "${instance}"-after-upgrade-postgres-afterdb-1 psql -U metasfresh -d metasfresh -f "/var/lib/postgresql/data/update_extensions.sql"
rm ./../volumes/newdb/data/update_extensions.sql
echo ""

start_vacuumdb=$(date +%s)
echo "vacuumdb -d metasfresh --analyze-in-stages -v"
docker exec -i -u postgres "${instance}"-after-upgrade-postgres-afterdb-1 vacuumdb -d metasfresh --analyze-in-stages -v
end_vacuumdb=$(date +%s)
runtime_vacuumdb=$((end_vacuumdb-start_vacuumdb))
echo "vacuumdb took ${runtime_vacuumdb}s"
echo ""

start_reindex=$(date +%s)
echo "REINDEX each table of metasfresh database"
docker exec -i -u postgres "${instance}"-after-upgrade-postgres-afterdb-1 psql -U metasfresh -d metasfresh -tAc "
SELECT 'REINDEX (VERBOSE, CONCURRENTLY) TABLE ' || quote_ident(nspname) || '.' || quote_ident(relname) || ' /*' || pg_size_pretty(pg_total_relation_size(C.oid)) || '*/;'
FROM pg_class C
LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
WHERE nspname <> 'pg_catalog'
  AND C.relkind = 'r'
  AND nspname !~ '^pg_toast'
ORDER BY pg_total_relation_size(C.oid) ASC;
" > tables_to_reindex.txt

#ignore table if needed
#grep -v "tablename" tables_to_reindex.txt > tmpfile && mv tmpfile tables_to_reindex.txt

while read -ru 3 p; do
  echo "$p"
  docker exec -i -u postgres "${instance}"-after-upgrade-postgres-afterdb-1 psql -U metasfresh -d metasfresh -c "$p"
  echo ""
done 3< tables_to_reindex.txt

end_reindex=$(date +%s)
runtime_reindex=$((end_reindex-start_reindex))
echo "REINDEX took ${runtime_reindex}s"
echo ""

echo "docker stop afterdb"
docker stop "${instance}"-after-upgrade-postgres-afterdb-1

while [ "$(docker inspect -f '{{.State.Running}}' "${instance}"-after-upgrade-postgres-afterdb-1)" == "true" ]; do
  sleep 2
  echo "waiting for ${instance}-after-upgrade-postgres-afterdb-1 to stop..."
done

echo "waiting for ${instance}-after-upgrade-postgres-afterdb-1 to stop... done"

echo "docker rm afterdb"
docker rm "${instance}"-after-upgrade-postgres-afterdb-1

mv ./../volumes/db ./../volumes/olddb
mv ./../volumes/newdb ./../volumes/db

echo ""
echo "upgrade done! You can now change db image and restart the instance"
echo ""

end=$(date +%s)
runtime=$((end-start))
echo "script finished in ${runtime}s"
