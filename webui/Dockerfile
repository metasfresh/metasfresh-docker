<<<<<<< HEAD
FROM metasfresh/metasfresh-webui:4.53.52.unstable

COPY sources/configs/config.js /opt/metasfresh-webui-frontend/dist/

#add apache config
COPY sources/configs/metasfresh_webui.conf /etc/apache2/sites-available/
RUN a2ensite metasfresh_webui.conf

#set environment
ENV APACHE_RUN_USER    www-data
ENV APACHE_RUN_GROUP   www-data
ENV APACHE_PID_FILE    /var/run/apache2.pid
ENV APACHE_RUN_DIR     /var/run/apache2
ENV APACHE_LOCK_DIR    /var/lock/apache2
ENV APACHE_LOG_DIR     /var/log/apache2

RUN chown www-data:www-data -R /opt/metasfresh-webui-frontend/
=======
FROM metasfresh/metasfresh-webui:latest
>>>>>>> a8c581c4189df595832c3cef88e37cb3690e797e

EXPOSE 80
ENTRYPOINT ["/usr/sbin/apache2", "-D", "FOREGROUND"]
