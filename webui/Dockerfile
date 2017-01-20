FROM ubuntu:16.04
RUN apt update && apt -y full-upgrade
RUN apt -y install apache2 \
    && apt -y install nodejs \
    && apt -y install npm \
    && apt -y install git \
    && apt -y autoremove \
    && apt -y autoclean

RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN a2enmod proxy_http proxy_html rewrite
RUN a2dissite 000-default.conf default-ssl.conf
RUN npm install webpack -g

ADD sources/metasfresh_webui.tar.gz /

COPY sources/metasfresh_webui.conf /etc/apache2/sites-available/
RUN a2ensite metasfresh_webui.conf

RUN chmod 700 /opt/metasfresh-webui-frontend/scripts/update_metasfresh-webui-frontend.sh
RUN /opt/metasfresh-webui-frontend/scripts/update_metasfresh-webui-frontend.sh

COPY sources/index.html /opt/metasfresh-webui-frontend/dist/

ENV APACHE_RUN_USER    www-data
ENV APACHE_RUN_GROUP   www-data
ENV APACHE_PID_FILE    /var/run/apache2.pid
ENV APACHE_RUN_DIR     /var/run/apache2
ENV APACHE_LOCK_DIR    /var/lock/apache2
ENV APACHE_LOG_DIR     /var/log/apache2

RUN chown www-data:www-data -R /opt/metasfresh-webui-frontend/

EXPOSE 80
ENTRYPOINT ["/usr/sbin/apache2", "-D", "FOREGROUND"]
