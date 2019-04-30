#!/bin/bash


webapi_client_host=${WEBUI_API_CLIENT_HOST:-webapi}
webapi_client_port=${WEBUI_API_CLIENT_PORT:-8080}

webapi_proxypass_host=${WEBUI_API_PROXYPASS_HOST:-webapi}
webapi_proxypass_port=${WEBUI_API_PROXYPASS_PORT:-8080}

msv3_proxypass_host=${MSV3_API_PROXYPASS_HOST:-msv3}
msv3_proxypass_port=${MSV3_API_PROXYPASS_PORT:-8080}


#Using the env-variable in docker-compose.yml to populate config.js
if [[ ! -z $WEBAPI_URL ]]; then
    sed -i 's,http\:\/\/MYDOCKERHOST\:PORT,'$WEBAPI_URL',g' /opt/metasfresh-webui-frontend/dist/config.js
fi

if [[ -f "/etc/ssl/certs/cert.pem" ]] && [[ -f "/etc/ssl/certs/privkey.pem" ]]; then
	sed -i 's/\bhttp\b/https/g' /opt/metasfresh-webui-frontend/dist/config.js
	cat /opt/metasfresh_webui_ssl.conf > /etc/nginx/conf.d/default.conf
	SSL_ACTIVE="SSL"
else 
	sed -i 's/\https\b/http/g' /opt/metasfresh-webui-frontend/dist/config.js
	cat /opt/metasfresh_webui.conf > /etc/nginx/conf.d/default.conf
	SSL_ACTIVE="NON-SSL"
fi

sed -i 's/WEBUI_API_PROXYPASS_HOST/'${webapi_proxypass_host}'/g' /etc/nginx/conf.d/default.conf
sed -i 's/WEBUI_API_PROXYPASS_PORT/'${webapi_proxypass_port}'/g' /etc/nginx/conf.d/default.conf
sed -i 's/MSV3_API_PROXYPASS_HOST/'${msv3_proxypass_host}'/g' /etc/nginx/conf.d/default.conf
sed -i 's/MSV3_API_PROXYPASS_PORT/'${msv3_proxypass_port}'/g' /etc/nginx/conf.d/default.conf


echo "*************************************************************"
echo "Display the variable values we run with"
echo "*************************************************************"
echo ""
echo "WEBUI_API_PROXYPASS_HOST=$webapi_proxypass_host"
echo "WEBUI_API_PROXYPASS_PORT=$webapi_proxypass_port"
echo ""
echo "MSV3_API_PROXYPASS_HOST=$msv3_proxypass_host"
echo "MSV3_API_PROXYPASS_PORT=$msv3_proxypass_port"
echo ""
echo "SSL_ACTIVE=$SSL_ACTIVE"


echo "Start nginx -g 'daemon off;'"
nginx -g 'daemon off;'
