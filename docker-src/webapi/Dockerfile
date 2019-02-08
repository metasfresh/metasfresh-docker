FROM ubuntu:16.04

# to make sure that the cache is only used during one day, run docker build --build-arg CACHEBUST=$(date "+%Y-%m-%d")
# that way we should get the latest updates since the release of our base image 
# thx to https://github.com/moby/moby/issues/1996#issuecomment-185872769
ARG CACHEBUST=1

RUN apt update && apt -y full-upgrade
RUN apt autoclean && apt update

RUN apt -y install netcat \
    && apt -y install curl \
    && apt -y install openjdk-8-jdk-headless \
    && apt -y install postgresql-client-9.5 \
    && apt -y install unzip \
    && apt -y autoremove \
    && apt -y autoclean

COPY sources/configs/local_settings.properties /root/
RUN mkdir -p /opt/metasfresh-webui-api/metasfresh-webui-api \
    && mkdir -p /opt/metasfresh-webui-api/log \
    && mkdir -p /opt/metasfresh-webui-api/heapdump
RUN curl https://repo.metasfresh.com/content/repositories/mvn-release/de/metas/ui/web/metasfresh-webui-api/5.88.2-655+release/metasfresh-webui-api-5.88.2-655+release.jar \
    --output /opt/metasfresh-webui-api/metasfresh-webui-api.jar

# Explode the uber jar to make it easier to work with the docker image; 
# e.g. with the exploded uber jar, we can later copy or overwrite config files into the docker image that change the applications behavior.
# Note that the skript start_materialdispo_docker.sh is adapted to the exploded jar.
# Note2 that we need unzip; jar doesn't work, thx to https://stackoverflow.com/a/39653862/1012103
RUN cd /opt/metasfresh/metasfresh-webui-api \
 && (unzip -q /opt/metasfresh/metasfresh-webui-api/metasfresh-webui-api || echo "Ignore exit code $? because spring boot's uber jar starts with a shell script") \
 && rm /opt/metasfresh/metasfresh-webui-api/metasfresh-webui-api

COPY sources/configs/* /opt/metasfresh-webui-api/
COPY sources/start_webapi.sh /opt/metasfresh-webui-api/
RUN chmod 700 /opt/metasfresh-webui-api/start_webapi.sh

ENTRYPOINT ["/opt/metasfresh-webui-api/start_webapi.sh"]
