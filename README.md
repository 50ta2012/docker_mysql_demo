###### tags: `MySQL`, `Docker`
# Docker MySQL 架設

作者：Berlin

日期：2022/08/30

Github 頁面：[50ta2012/docker_mysql_demo](https://github.com/50ta2012/docker_mysql_demo)

## 系統需求

* Docker v20.10.17+
* Docker Compose v2.6.0+

## 設定 root 和 user 的密碼

使用 openssl 產生密碼
```
openssl rand -base64 20
```

新增 root 密碼到 `./mysql/demo_db_root_password`
```
Your_Root_Password
```

新增資料庫 demo，設定 user 帳號、密碼和使用權限到 `./mysql/init.sql`
```sql
CREATE DATABASE demo;
CREATE USER 'josh'@'%' IDENTIFIED BY 'Your_User_Password';
GRANT ALL ON demo.* to 'josh'@'%';
```
> 如果使用 mysql docker 環境變數建立的 User 是超級帳號，權限太大。

## Docker Compose

Docker Compose 設定檔 `./docker-compose.yml`
```yaml
services:  
  demo_db:
    # 採用 MySQL 最新的映像檔
    image: mysql:latest
    # 容器名稱自訂
    container_name: demo_db
    # 映射本地的 port 13306 到容器的 port 3306 (MySQL 預設服務 port)
    ports:
      - 13306:3306
    # 掛載 demo_db_root_password 檔案到容器的 /run/secrets 目錄底下
    secrets:
      - demo_db_root_password
    # 容器環境變數
    environment:
      # 宣告 MySQL ROOT 使用 demo_db_root_password 檔案裡的密碼
      MYSQL_ROOT_PASSWORD_FILE: /run/secrets/demo_db_root_password
    # 容器掛載資料卷
    volumes:
      # 掛載 mysql 預設初始化的 SQL 檔，新建資料庫和使用者相關設定。
      - ./mysql/init.sql:/docker-entrypoint-initdb.d/init.sql
    # 重啟政策
    restart: always

secrets:
  # 建立一個參考 demo_db_root_password 檔案的 docker secret
  demo_db_root_password:
    file: ./mysql/demo_db_root_password
```

啟動
```
docker compose up -d
```

測試
```sql
### bash ###

# 登入
docker exec -it demo_db mysql -uroot -p

### mysql console ###

# db 列表
show databases;

+--------------------+
| Database           |
+--------------------+
| demo               |
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)


# db 使用者
select user from mysql.user;

+------------------+
| user             |
+------------------+
| josh             |
| root             |
| mysql.infoschema |
| mysql.session    |
| mysql.sys        |
| root             |
+------------------+
6 rows in set (0.00 sec)
```