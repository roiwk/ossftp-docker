# OSSFTP Docker 镜像

基于阿里云 OSSFTP 的轻量级 Docker 镜像，支持通过环境变量动态配置访问账号，适用于快速部署基于 FTP 协议的 OSS 文件访问服务。

> 镜像版本号与阿里云官方 OSSFTP 工具版本基本保持一致，但会额外多一位补丁号用于识别构建差异。例如：
>
> - 官方工具版本：`1.2.0` 文档[ossftp](https://help.aliyun.com/zh/oss/developer-reference/installation-9)
> - Docker 镜像版本：`1.2.0.1`（即 `roiwk/ossftp:1.2.0.1`） 当前镜像：[`roiwk/ossftp`](https://hub.docker.com/r/roiwk/ossftp)

---

## 特别限制

* 【官方文档说明】ossftp在同一时间只允许一台客户端连接，新发起的连接请求会导致已经连接的客户端断开。

## 🚀 使用方式

### ✅ 建议网络模式：`--network host`

为了兼容 FTP 的被动模式端口动态连接行为，**强烈建议使用 Host 网络模式** 启动容器：

```bash
docker run --name ossftp --network host roiwk/ossftp:latest
````

### ⚠️ 安全提示

* Host 模式会将容器端口暴露在宿主机网络上，**等同于本地服务**；
* 不建议直接用于公网或生产环境，推荐用于 **内网环境、受控服务器、开发测试场景**；
* FTP协议是明文传输的，为了防止您的密码泄漏，建议将ossftp和客户端运行在同一台机器上，通过127.0.0.1:2048 访问。

---

## ⚙️ 配置方式

你可以选择以下两种方式配置 OSSFTP 行为：

---

### 🧩 方式一：使用环境变量自动生成配置（推荐）

容器启动时会自动生成 `config.json`，支持单账号或多账号配置方式：

#### ✅ 单账号配置示例：

```bash
docker run --name ossftp --network host \
  -e ACCOUNT_ACCESS_ID="yourAccessKeyID" \
  -e ACCOUNT_ACCESS_SECRET="yourAccessKeySecret" \
  -e ACCOUNT_BUCKET_NAME="examplebucket" \
  -e ACCOUNT_HOME_DIR="folder1/" \
  -e ACCOUNT_LOGIN_USERNAME="user1" \
  -e ACCOUNT_LOGIN_PASSWORD="pass1" \
  -e BUCKET_ENDPOINTS="oss-cn-hangzhou.aliyuncs.com" \
  -e LOG_LEVEL="DEBUG" \
  roiwk/ossftp:latest
```

#### ✅ 多账号配置示例（使用 JSON）：

```bash
docker run --name ossftp --network host \
  -e ACCOUNTS_JSON='[
    {
      "access_id": "xxx",
      "access_secret": "yyy",
      "bucket_name": "bucket1",
      "home_dir": "folder1/",
      "login_username": "user1",
      "login_password": "pass1"
    },
    {
      "access_id": "aaa",
      "access_secret": "bbb",
      "bucket_name": "bucket2",
      "home_dir": "",
      "login_username": "user2",
      "login_password": "pass2"
    }
  ]' \
  roiwk/ossftp:latest
```

---

### 🧩 方式二：挂载自定义 `config.json` 文件

如果你希望手动编写完整配置文件，可使用 `-v` 参数挂载本地配置：

#### 示例：

```bash
docker run --name ossftp --network host \
  -v $(pwd)/config.json:/srv/ossftp/config.json \
  roiwk/ossftp:latest
```

> 挂载时容器不会使用环境变量生成配置，请自行编写完整有效的 `config.json` 文件。

---

## 🌐 支持的环境变量（方式一可用）

### 账户配置（单用户）

| 变量名                   | 描述                    |
| ------------------------ | ----------------------- |
| `ACCOUNT_ACCESS_ID`      | 阿里云 AccessKey ID     |
| `ACCOUNT_ACCESS_SECRET`  | 阿里云 AccessKey Secret |
| `ACCOUNT_BUCKET_NAME`    | Bucket 名称             |
| `ACCOUNT_HOME_DIR`       | 访问目录前缀，可为空    |
| `ACCOUNT_LOGIN_USERNAME` | 自定义 FTP 登录用户名   |
| `ACCOUNT_LOGIN_PASSWORD` | 登录密码                |

### 多用户模式（推荐）

| 变量名          | 描述                                   |
| --------------- | -------------------------------------- |
| `ACCOUNTS_JSON` | 一个数组格式的完整账号配置 JSON 字符串 |

### 其他参数

| 变量名             | 映射字段                          | 默认值   |
| ------------------ | --------------------------------- | -------- |
| `BUCKET_ENDPOINTS` | `modules.ossftp.bucket_endpoints` | `""`     |
| `LOG_LEVEL`        | `modules.ossftp.log_level`        | `"INFO"` |

---

## 🧾 示例配置文件结构（用于挂载）

```json
{
  "modules": {
    "accounts": [
      {
        "access_id": "xxx",
        "access_secret": "yyy",
        "bucket_name": "examplebucket",
        "home_dir": "folder1/",
        "login_username": "user1",
        "login_password": "pass1"
      }
    ],
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

---

## 暴露端口说明

| 端口范围          | 用途               |
| ------------- | ---------------- |
| `2048`        | FTP 服务端口         |
| `8192`        | 控制/配置端口          |
| `51000-53000` | FTP 被动模式端口（建议映射） |

---

## 🌐 支持的环境变量

### 账户配置（单用户模式）

| 环境变量名                    | 用途               |
| ------------------------ | ---------------- |
| `ACCOUNT_ACCESS_ID`      | AccessKey ID     |
| `ACCOUNT_ACCESS_SECRET`  | AccessKey Secret |
| `ACCOUNT_BUCKET_NAME`    | Bucket 名称        |
| `ACCOUNT_HOME_DIR`       | 可访问目录路径（可为空）     |
| `ACCOUNT_LOGIN_USERNAME` | 登录用户名            |
| `ACCOUNT_LOGIN_PASSWORD` | 登录密码             |

### 多账户模式（推荐）

| 环境变量名           | 说明                   |
| --------------- | -------------------- |
| `ACCOUNTS_JSON` | 包含多个账户对象的 JSON 数组字符串 |

### 其他配置

| 环境变量名              | 对应配置字段                            | 默认值      |
| ------------------ | --------------------------------- | -------- |
| `BUCKET_ENDPOINTS` | `modules.ossftp.bucket_endpoints` | `""`（空）  |
| `LOG_LEVEL`        | `modules.ossftp.log_level`        | `"INFO"` |



## TODO / Roadmap

* [ ] 添加 `docker-compose.yml` 示例

---

## License

本项目基于 [MIT License](LICENSE)，阿里云 OSSFTP 工具版权归阿里云所有。
