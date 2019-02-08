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
    && apt -y autoremove \
    && apt -y autoclean

RUN mkdir -p /opt/metasfresh
RUN curl https://repo.metasfresh.com/content/repositories/mvn-release-releases/de/metas/dist/metasfresh-dist-dist/5.88.2-894+release/metasfresh-dist-dist-5.88.2-894+release-dist.tar.gz \
  | tar -xzC /opt/metasfresh/ 
RUN mkdir -p /opt/metasfresh/heapdump

# Explode the uber jar to make it easier to work with the docker image; 
# e.g. with the exploded uber jar, we can later copy or overwrite config files into the docker image that change the applications behavior.
# Note that the skript start_materialdispo_docker.sh is adapted to the exploded jar.
# Note2 that we need unzip; jar doesn't work, thx to https://stackoverflow.com/a/39653862/1012103
RUN cd /opt/metasfresh \
 && (unzip -q /opt/metasfresh/metasfresh_server.jar || echo "Ignore exit code $? because spring boot's uber jar starts with a shell script") \
 && rm /opt/metasfresh/metasfresh_server.jar

COPY sources/configs/* /opt/metasfresh/
COPY sources/configs/local_settings.properties /root/
COPY sources/start_app.sh /opt/metasfresh/
RUN chmod 700 /opt/metasfresh/start_app.sh

ENTRYPOINT ["/opt/metasfresh/start_app.sh"]

EXPOSE 61616
