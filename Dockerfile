FROM python:2-alpine

# 设置版本号为环境变量
ARG OSSFTP_VERSION=1.2.0
ENV OSSFTP_VERSION=${OSSFTP_VERSION}
ENV OSSFTP_URL=https://gosspublic.alicdn.com/ossftp/ossftp-${OSSFTP_VERSION}-linux-mac.zip

# 安装依赖并下载指定版本的 zip 包
RUN set -xe && \
    apk add --no-cache unzip curl jq

# 下载ossftp
RUN  cd /srv && \
    curl -fSL "$OSSFTP_URL" -o ossftp.zip && \
    unzip -o "ossftp.zip" -d /srv && \
    rm -rf "ossftp.zip" && \
    mv "ossftp" ossftp

# 复制配置模板和脚本
COPY config.template.json /srv/ossftp/config.template.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 2048 8192

WORKDIR /srv/ossftp

ENTRYPOINT ["/entrypoint.sh"]
CMD [ "python", "launcher/start.py" ]
