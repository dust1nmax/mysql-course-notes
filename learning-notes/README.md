# MySQL 学习记录

记录 MySQL 的学习过程：练习环境、每日笔记、练习 SQL。

## 练习环境

| 项 | 值 |
|---|---|
| 容器 | `mysql-learn`（Docker，MySQL 8.4） |
| 地址 | `127.0.0.1:3306` |
| 账号 | `root` / `******`（见本地） |
| 数据库 | `learn` |
| 数据卷 | `mysql-learn-data`（数据持久化） |

连接方式：

```bash
docker exec -it mysql-learn mysql -uroot -p learn
```

课程素材：[../MySQL课程-全集案例手册.md](../MySQL课程-全集案例手册.md)（黑马 MySQL 入门到精通，195 集案例手册）。

## 目录

- `logs/` —— 每日学习记录（一天一个文件，`YYYY-MM-DD.md`）
- `sql/` —— 练习用的 SQL 脚本

## 学习进度

| 日期 | 内容 | 记录 |
|---|---|---|
| 2026-11-26 | 环境搭建、DQL 基础（GROUP BY / COUNT / HAVING / LEFT JOIN） | [logs/2026-11-26.md](logs/2026-11-26.md) |
