FROM postgres:9.5

RUN apt update
RUN apt install -y curl

RUN localedef -i de_DE -c -f UTF-8 -A /usr/share/locale/locale.alias de_DE.UTF-8
ENV LANG=de_DE.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_MESSAGES=en_US.UTF-8

COPY sources/create_db.sh /docker-entrypoint-initdb.d/
COPY sources/metasfresh.pgdump /tmp/

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["postgres"]
EXPOSE 5432
