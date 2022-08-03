#!/bin/bash

# if the environment parameter for "WEBAPI_URL" is set in docker-compose.yml, replace all placeholder variables with that parameter
# otherwise, a manual edit of './webui/sources/configs/config.js' and './webui/sources/configs/mobile/config.js' is required
#
if [[ ! -z $WEBAPI_URL ]]; then
    find /opt/metasfresh-webui-frontend/dist/ -type f -name 'config.js' -exec sed -i 's,http\:\/\/MYDOCKERHOST\:PORT,'$WEBAPI_URL',g' {} +
fi

if [[ -f "/etc/apache2/certs/fullchain.pem" ]] && [[ -f "/etc/apache2/certs/privkey.pem" ]]; then
	sed -i 's/\bhttp\b/https/g' /opt/metasfresh-webui-frontend/dist/config.js
	a2ensite metasfresh_webui_ssl.conf
	echo "[METASFRESH] Activated SSL!"
else 
	sed -i 's/\https\b/http/g' /opt/metasfresh-webui-frontend/dist/config.js
	a2ensite metasfresh_webui.conf
	a2dissite metasfresh_webui_ssl.conf
	echo "[METASFRESH] Runnning Non-SSL!"
fi

/usr/sbin/apache2ctl -DFOREGROUND	
