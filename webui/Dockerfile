FROM metasfresh/metasfresh-webui:5.144

COPY sources/configs/config.js /opt/metasfresh-webui-frontend/dist/

#add apache config
COPY sources/configs/metasfresh_webui.conf /etc/apache2/sites-available/
RUN mkdir -p /etc/apache2/certs/
COPY sources/certs /etc/apache2/certs

RUN a2ensite metasfresh_webui.conf

#set environment
RUN . /etc/apache2/envvars

ENV APACHE_RUN_USER    www-data
ENV APACHE_RUN_GROUP   www-data
ENV APACHE_PID_FILE    /var/run/apache2.pid
ENV APACHE_RUN_DIR     /var/run/apache2
ENV APACHE_LOCK_DIR    /var/lock/apache2
ENV APACHE_LOG_DIR     /var/log/apache2

RUN chown www-data:www-data -R /opt/metasfresh-webui-frontend/


EXPOSE 80 443
ENTRYPOINT ["/start_webui.sh"]
