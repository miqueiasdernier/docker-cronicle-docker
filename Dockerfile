FROM       opensuse/leap:latest
LABEL      maintainer="BlueT - Matthew Lien - 練喆明 <bluet@bluet.org>"

# Docker defaults
ENV        CRONICLE_VERSION=0.9.68
ENV        CRONICLE_base_app_url='http://localhost:3012'
ENV        CRONICLE_WebServer__http_port=3012
ENV        CRONICLE_WebServer__https_port=443
ENV        EDITOR=nano

RUN        zypper --non-interactive refresh && \
           zypper --non-interactive install nodejs npm git curl perl bash tar procps nano tini python3

RUN        mkdir -p /opt/cronicle \
                && cd /opt/cronicle \
                && curl -L https://github.com/jhuckaby/Cronicle/archive/v${CRONICLE_VERSION}.tar.gz | tar zxvf - --strip-components 1 \
                && npm install \
                && node bin/build.js dist \
                && rm -Rf /root/.npm

# Runtime user
# RUN        useradd -m -d /opt/cronicle cronicle
# RUN        usermod -aG docker cronicle
WORKDIR    /opt/cronicle/
ADD        docker/entrypoint.sh /entrypoint.sh

EXPOSE     3012

# data volume is also configured in entrypoint.sh
VOLUME     ["/opt/cronicle/data", "/opt/cronicle/logs", "/opt/cronicle/plugins"]

ENTRYPOINT ["/sbin/tini", "--"]
CMD        ["sh", "/entrypoint.sh"]