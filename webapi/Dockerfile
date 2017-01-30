<<<<<<< HEAD
FROM metasfresh/metasfresh-webapi:4.53.52.unstable

COPY sources/configs/* /opt/metasfresh-webui-api/
COPY sources/start_webapi.sh /opt/metasfresh-webui-api/
RUN chmod 700 /opt/metasfresh-webui-api/start_webapi.sh
=======
FROM metasfresh/metasfresh-webapi:latest
>>>>>>> a8c581c4189df595832c3cef88e37cb3690e797e

ENTRYPOINT ["/opt/metasfresh-webui-api/start_webapi.sh"]
