FROM nginx

RUN apt update && apt -y full-upgrade

RUN rm -rf /usr/share/nginx/html/*
RUN mkdir -p /opt/metasfresh-webui-frontend
RUN ln -s /usr/share/nginx/html /opt/metasfresh-webui-frontend/dist

COPY sources/configs/metasfresh_webui.conf  /opt/
COPY sources/configs/metasfresh_webui_ssl.conf /opt/
COPY sources/dist /usr/share/nginx/html
COPY sources/configs/config.js /opt/metasfresh-webui-frontend/dist/

COPY sources/start_webui.sh /
RUN chmod +x /start_webui.sh

ENTRYPOINT ["/start_webui.sh"]
