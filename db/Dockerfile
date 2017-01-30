<<<<<<< HEAD
FROM metasfresh/metasfresh-db:4.53.52.unstable

RUN localedef -i de_DE -c -f UTF-8 -A /usr/share/locale/locale.alias de_DE.UTF-8
ENV LANG=de_DE.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_MESSAGES=en_US.UTF-8
=======
FROM metasfresh/metasfresh-db:latest
>>>>>>> a8c581c4189df595832c3cef88e37cb3690e797e

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["postgres"]
