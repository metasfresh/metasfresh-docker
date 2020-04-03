FROM ubuntu:16.04


RUN apt update && apt -y full-upgrade
RUN apt autoclean && apt update

RUN apt -y install netcat \
    && apt -y install curl \
    && apt -y install openjdk-8-jdk-headless \
    && apt -y install postgresql-client-9.5 \
    && apt -y autoremove \
    && apt -y autoclean

COPY sources/configs/local_settings.properties /root/
RUN mkdir -p /opt/metasfresh-webui-api/metasfresh-webui-api \
    && mkdir -p /opt/metasfresh-webui-api/log \
    && mkdir -p /opt/metasfresh-webui-api/heapdump
RUN curl https://repo.metasfresh.com/repository/mvn-release/de/metas/ui/web/metasfresh-webui-api/5.144.2-895+release/metasfresh-webui-api-5.144.2-895+release.jar \
    --output /opt/metasfresh-webui-api/metasfresh-webui-api.jar \
    && chmod 750 /opt/metasfresh-webui-api/metasfresh-webui-api.jar

COPY sources/configs/* /opt/metasfresh-webui-api/
COPY sources/start_webapi.sh /opt/metasfresh-webui-api/
RUN chmod 700 /opt/metasfresh-webui-api/start_webapi.sh

ENTRYPOINT ["/opt/metasfresh-webui-api/start_webapi.sh"]
