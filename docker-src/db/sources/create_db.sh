#!/bin/bash

set -e

METASFRESH_DBNAME=metasfresh
METASFRESH_APPHOST=app
METASFRESH_USERNAME=metasfresh
METASFRESH_PASSWORD=metasfresh
DB_SYSPASS=System

create_initial() 
{
 echo "[METASFRESH] Creating role, database and permissions ..."
 psql -v ON_ERROR_STOP=1 -U "postgres" <<- EOSQL
	CREATE ROLE $METASFRESH_USERNAME LOGIN ENCRYPTED PASSWORD '$METASFRESH_PASSWORD' SUPERUSER INHERIT CREATEDB NOCREATEROLE;
	CREATE DATABASE $METASFRESH_DBNAME WITH OWNER = $METASFRESH_USERNAME;
	GRANT ALL PRIVILEGES ON DATABASE $METASFRESH_DBNAME to $METASFRESH_USERNAME;
EOSQL
 echo "[METASFRESH] ... done!"
}

apply_conf()
{
 echo "[METASFRESH] Applying host-specific scripts to database ... "
 psql -v ON_ERROR_STOP=1 -U "$METASFRESH_USERNAME" -d "$METASFRESH_DBNAME" <<- EOSQL
	DELETE FROM AD_SysConfig WHERE Name='de.metas.payment.sepa.api.impl.SEPADocumentBL.marshalXMLCreditFile.defaultPath';
	UPDATE AD_User SET Password='$DB_SYSPASS' WHERE AD_User_ID=100 AND Name='SuperUser';
	UPDATE ad_client SET StoreAttachmentsOnFileSystem='N', StoreArchiveOnFileSystem='N', WindowsAttachmentPath=null, WindowsArchivePath=null;
	UPDATE AD_SysConfig SET Value='http://$METASFRESH_APPHOST:8282/adempiereJasper/ReportServlet' WHERE Name='de.metas.adempiere.report.jasper.JRServerServlet';
-- required as of task 06275
	UPDATE AD_SysConfig SET Value='http://$METASFRESH_APPHOST:8282/adempiereJasper/BarcodeServlet' WHERE Name='de.metas.adempiere.report.barcode.BarcodeServlet';

	UPDATE AD_SysConfig SET Value='http://$METASFRESH_APPHOST:8282/printing-client-webapp-1.5/printing-client.jar' WHERE Name='de.metas.printing.client.archive';
	UPDATE AD_SysConfig SET Value='http://$METASFRESH_APPHOST:8182/printing' WHERE Name='de.metas.printing.client.endpoint.RestHttpPrintConnectionEndpoint.ServerUrl';
	UPDATE AD_SysConfig SET Value='tcp://$METASFRESH_APPHOST:61616' WHERE name='de.metas.jms.URL';
	UPDATE AD_OrgInfo SET reportprefix='file:////opt/metasfresh/reports' WHERE reportprefix='file:////opt/metasfresh/jboss/server/adempiere/deploy/reports.war';
	UPDATE AD_SysConfig SET Value='Y' WHERE NAME='de.metas.event.jms.UseEmbeddedBroker';
EOSQL
 echo "[METASFRESH] ... done!"
}

import_dump()
{
 echo "[METASFRESH] Populating database with data. This may take a while ... "
 pg_restore -Fc -U "$METASFRESH_USERNAME" -d "$METASFRESH_DBNAME" /tmp/metasfresh.pgdump
 echo "[METASFRESH] ... done!"
}

create_initial
import_dump
apply_conf


