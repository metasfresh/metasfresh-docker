FROM ubuntu:20.04


RUN apt update && apt -y full-upgrade
RUN apt autoclean && apt update

RUN apt -y install netcat \
    && apt -y install curl \
    && apt -y install openjdk-17-jdk-headless \
    && apt -y install postgresql-client-12 \
    && apt -y autoremove \
    && apt -y autoclean

RUN mkdir -p /opt/metasfresh
RUN curl https://repo.metasfresh.com/repository/mvn-master_java14-releases/de/metas/dist/metasfresh-dist-dist/5.176.2-63+masterjava14/metasfresh-dist-dist-5.176.2-63+masterjava14-dist.tar.gz \
  | tar -xzC /opt/metasfresh/ 
RUN mkdir -p /opt/metasfresh/heapdump

COPY sources/configs/* /opt/metasfresh/
COPY sources/configs/local_settings.properties /root/
COPY sources/start_app.sh /opt/metasfresh/
RUN chmod 700 /opt/metasfresh/start_app.sh

ENTRYPOINT ["/opt/metasfresh/start_app.sh"]

EXPOSE 61616
