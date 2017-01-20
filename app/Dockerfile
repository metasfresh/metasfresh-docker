FROM ubuntu:16.04
RUN apt update && apt -y full-upgrade
RUN apt -y install netcat \
    && apt -y install openjdk-8-jdk-headless \
    && apt -y autoremove \
    && apt -y autoclean

ADD sources/metasfresh_51_50.tar.gz /

COPY sources/start_app.sh /opt/metasfresh/
RUN chmod 700 /opt/metasfresh/start_app.sh


ENTRYPOINT ["/opt/metasfresh/start_app.sh"]
EXPOSE 8282
