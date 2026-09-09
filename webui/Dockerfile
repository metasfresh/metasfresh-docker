ARG BASE_REGISTRY=metasfresh
ARG MF_VERSION=5.175

FROM ${BASE_REGISTRY}/metasfresh-webui:${MF_VERSION} AS bundle

# nginx:stable (Debian, not alpine) for GNU sed in the entrypoint.
FROM nginx:stable
RUN rm -f /etc/nginx/conf.d/default.conf

# openssl is used by the entrypoint to validate mounted certs.
RUN apt-get update \
    && apt-get install -y --no-install-recommends openssl \
    && rm -rf /var/lib/apt/lists/*

COPY conf.d/     /etc/nginx/conf.d/
COPY snippets/   /etc/nginx/snippets/
COPY docker-entrypoint.d/10-metasfresh.sh /docker-entrypoint.d/10-metasfresh.sh
RUN chmod +x /docker-entrypoint.d/10-metasfresh.sh

COPY --from=bundle /opt/metasfresh-webui-frontend/dist/ /opt/metasfresh-webui-frontend/dist/
COPY sources/configs/config.js        /opt/metasfresh-webui-frontend/dist/
COPY sources/configs/mobile/config.js /opt/metasfresh-webui-frontend/dist/mobile/

EXPOSE 80 443
