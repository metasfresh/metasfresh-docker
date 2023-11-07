#thx to https://github.com/tianon/docker-postgres-upgrade/tree/master/9.6-to-15

FROM postgres:15.1

RUN sed -i 's/$/ 9.5/' /etc/apt/sources.list.d/pgdg.list

RUN apt-get update && apt-get install -y --no-install-recommends \
		postgresql-9.5=9.5.25-6.pgdg110+1 \
		postgresql-contrib-9.5=9.5.25-6.pgdg110+1 \
	&& rm -rf /var/lib/apt/lists/*

RUN localedef -i de_DE -c -f UTF-8 -A /usr/share/locale/locale.alias de_DE.UTF-8
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG=de_DE.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_MESSAGES=en_US.UTF-8

ENV PGBINOLD /usr/lib/postgresql/9.5/bin
ENV PGBINNEW /usr/lib/postgresql/15/bin

ENV PGDATAOLD /var/lib/postgresql/9.5/data
ENV PGDATANEW /var/lib/postgresql/15/data

RUN mkdir -p "$PGDATAOLD" "$PGDATANEW" \
	&& chown -R postgres:postgres /var/lib/postgresql

WORKDIR /var/lib/postgresql

COPY docker-upgrade /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-upgrade

ENTRYPOINT ["/usr/local/bin/docker-upgrade"]

# recommended: --link
CMD ["pg_upgrade"]