FROM metasfresh/metasfresh-app:5.22

COPY sources/configs/* /opt/metasfresh/
COPY sources/start_app.sh /opt/metasfresh/
RUN chmod 700 /opt/metasfresh/start_app.sh

ENTRYPOINT ["/opt/metasfresh/start_app.sh"]
