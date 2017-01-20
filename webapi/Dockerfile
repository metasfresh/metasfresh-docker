FROM ubuntu:16.04
RUN apt update && apt -y full-upgrade
RUN apt -y install netcat \
    && apt -y install openjdk-8-jdk-headless \
    && apt -y autoremove \
    && apt -y autoclean

ADD sources/metasfresh_webapi.tar.gz /

COPY sources/start_webapi.sh /opt/metasfresh-webui-api/
RUN chmod 700 /opt/metasfresh-webui-api/start_webapi.sh

ENTRYPOINT ["/opt/metasfresh-webui-api/start_webapi.sh"]
