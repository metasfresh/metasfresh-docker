FROM metasfresh/metasfresh-webapi:5.2

COPY sources/configs/* /opt/metasfresh-webui-api/
COPY sources/start_webapi.sh /opt/metasfresh-webui-api/
RUN chmod 700 /opt/metasfresh-webui-api/start_webapi.sh

ENTRYPOINT ["/opt/metasfresh-webui-api/start_webapi.sh"]
