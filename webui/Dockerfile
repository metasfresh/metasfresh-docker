FROM metasfresh/metasfresh-webui:5.101

COPY sources/certs /etc/ssl/certs
COPY sources/configs/config.js /opt/metasfresh-webui-frontend/dist/
COPY sources/configs/metasfresh_webui.conf /opt/
COPY sources/configs/metasfresh_webui_ssl.conf /opt/

RUN chown www-data:www-data -R /opt/

EXPOSE 80 443
ENTRYPOINT ["/start_webui.sh"]
