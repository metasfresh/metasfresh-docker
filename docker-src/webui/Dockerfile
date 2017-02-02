FROM ubuntu:16.04
RUN apt update && apt -y full-upgrade
RUN apt -y install apache2 \
    && apt -y autoremove \
    && apt -y autoclean

RUN a2enmod proxy proxy_http proxy_html proxy_wstunnel rewrite
RUN a2dissite 000-default.conf default-ssl.conf

RUN mkdir -p /opt/metasfresh-webui-frontend

COPY sources/dist /opt/metasfresh-webui-frontend/dist
COPY sources/configs/config.js /opt/metasfresh-webui-frontend/dist/

#add apache config
COPY sources/configs/metasfresh_webui.conf /etc/apache2/sites-available/
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

EXPOSE 80
ENTRYPOINT ["apache2ctl", "-D", "FOREGROUND"]
