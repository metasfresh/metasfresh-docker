ARG BASE_REGISTRY=metasfresh
FROM $BASE_REGISTRY/metasfresh-db:5.175

RUN localedef -i de_DE -c -f UTF-8 -A /usr/share/locale/locale.alias de_DE.UTF-8
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG=de_DE.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_MESSAGES=en_US.UTF-8

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["postgres"]
