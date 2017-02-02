FROM metasfresh/metasfresh-app:4.54.53

COPY sources/configs/* /opt/metasfresh/
COPY sources/start_app.sh /opt/metasfresh/
RUN chmod 700 /opt/metasfresh/start_app.sh

ENTRYPOINT ["/opt/metasfresh/start_app.sh"]
