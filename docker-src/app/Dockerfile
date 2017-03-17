FROM ubuntu:16.04


RUN apt update && apt -y full-upgrade

RUN apt -y install netcat \
    && apt -y install curl \
    && apt -y install openjdk-8-jdk-headless \
    && apt -y install postgresql-client-9.5 \
    && apt -y autoremove \
    && apt -y autoclean

RUN mkdir -p /opt/metasfresh
RUN curl https://repo.metasfresh.com/service/local/repositories/mvn-release/content/de/metas/endcustomer/mf15/de.metas.endcustomer.mf15.dist/2.77/de.metas.endcustomer.mf15.dist-2.77-dist.tar.gz \ 
  | tar -xzC /opt/metasfresh/ 

COPY sources/configs/* /opt/metasfresh/
COPY sources/configs/local_settings.properties /root/
COPY sources/start_app.sh /opt/metasfresh/
RUN chmod 700 /opt/metasfresh/start_app.sh

ENTRYPOINT ["/opt/metasfresh/start_app.sh"]

EXPOSE 61616
