FROM python:2-alpine

ENV OSSFTP_VERSION=$OSSFTP_VERSION

RUN set -xe && \
    apk add --no-cache unzip jq

WORKDIR /srv

# 拷贝本地 zip 安装包（从 GitHub 仓库根目录）
COPY ossftp-1.2.0-linux-mac.zip .

# 解压并安装
RUN unzip -o ossftp-1.2.0-linux-mac.zip -d /srv && \
    rm -f ossftp-1.2.0-linux-mac.zip && \
    mv "ossftp-1.2.0-linux-mac" ossftp

# 拷贝配置文件与启动脚本
COPY config.template.json /srv/ossftp/config.template.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 2048 8192

WORKDIR /srv/ossftp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["python", "launcher/start.py"]

