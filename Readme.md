# OSSFTP Docker 镜像

基于阿里云 OSSFTP 的轻量级 Docker 镜像，支持通过环境变量动态配置访问账号，适用于快速部署基于 FTP 协议的 OSS 文件访问服务。

> 镜像版本与阿里云 OSSFTP 工具版本保持一致。当前镜像：[`roiwk/ossftp`](https://hub.docker.com/r/roiwk/ossftp)

---

## 🚀 启动容器

使用已构建好的公共镜像：

```bash
docker pull roiwk/ossftp:1.2.0
```

### 方法一：使用默认配置

```bash
docker run -p 2048:2048 -p 8192:8192 roiwk/ossftp:1.2.0
```

> 默认使用 `config.template.json` 中定义的账户信息

---

### 方法二：单账户配置（使用多个环境变量）

```bash
docker run -p 2048:2048 -p 8192:8192 \
  -e ACCOUNT_ACCESS_ID="yourAccessKeyID" \
  -e ACCOUNT_ACCESS_SECRET="yourAccessKeySecret" \
  -e ACCOUNT_BUCKET_NAME="examplebucket" \
  -e ACCOUNT_HOME_DIR="folder1/" \
  -e ACCOUNT_LOGIN_USERNAME="user1" \
  -e ACCOUNT_LOGIN_PASSWORD="pass1" \
  roiwk/ossftp:1.2.0
```

---

### 方法三：多账户配置（使用 JSON 字符串）

```bash
docker run -p 2048:2048 -p 8192:8192 \
  -e ACCOUNTS_JSON='[
    {
      "access_id": "yourAccessKeyID",
      "access_secret": "yourAccessKeySecret",
      "bucket_name": "examplebucket",
      "home_dir": "folder1/",
      "login_username": "user1",
      "login_password": "pass1"
    },
    {
      "access_id": "yourAccessKeyID2",
      "access_secret": "yourAccessKeySecret2",
      "bucket_name": "examplebucket2",
      "home_dir": "",
      "login_username": "user2",
      "login_password": "pass2"
    }
  ]' \
  roiwk/ossftp:1.2.0
```

---

## ⚙️ 配置项说明（config.template.json）

```json
{
  "modules": {
    "accounts": [],
    "launcher": {
      "auto_start": 0,
      "control_port": 8192,
      "language": "cn",
      "popup_webui": 1,
      "show_systray": 1
    },
    "ossftp": {
      "address": "127.0.0.1",
      "bucket_endpoints": "",
      "log_level": "INFO",
      "passive_ports_start": 51000,
      "passive_ports_end": 53000,
      "port": 2048
    }
  }
}
```

默认将配置模板复制为 `config.json`，启动时根据环境变量自动覆盖 `modules.accounts` 字段。

---

## 暴露端口说明

| 端口范围          | 用途               |
| ------------- | ---------------- |
| `2048`        | FTP 服务端口         |
| `8192`        | 控制/配置端口          |
| `51000-53000` | FTP 被动模式端口（建议映射） |

---

## TODO / Roadmap

* [ ] 添加 `docker-compose.yml` 示例
* [ ] 支持 `.env` 文件注入
* [ ] 自动检测并校验账户配置合法性

---

## License

本项目基于 [MIT License](LICENSE)，阿里云 OSSFTP 工具版权归阿里云所有。

