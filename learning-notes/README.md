# MySQL 学习笔记

> 换设备后：照着「快速恢复」把环境跑起来，然后把本文件丢给 AI，就能直接接续，不用重复交代背景。

## 这是什么

- 黑马 MySQL 课程（BV1Kr4y1i7ru，195 集）的个人学习记录
- 配套课程手册：[../MySQL课程-全集案例手册.md](../MySQL课程-全集案例手册.md)
- `logs/`：每天一个 `YYYY-MM-DD.md`，记录当天知识点和练习
- `sql/`：练习用的 SQL 脚本
- ⚠️ 本仓库是**公开**的，任何密码/密钥一律用占位符，不要提交明文

## 练习环境

| 项 | 值 |
|---|---|
| 容器 | `mysql-learn` |
| 镜像 | `mysql:8.4` |
| 地址 | `127.0.0.1:3306` |
| 账号 | `root` / 本地自设（不进仓库） |
| 数据库 | `learn` |
| 数据卷 | `mysql-learn-data`（数据持久化） |

## 快速恢复（新设备）

```bash
# 0. 前置：装好 Docker Desktop 和 git，并启动 Docker
git clone https://github.com/dust1nmax/mysql-course-notes.git
cd mysql-course-notes

# 1. 建学习容器（密码自己定，记在本地，别提交）
docker run -d --name mysql-learn \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD='<你的密码>' \
  -e MYSQL_DATABASE=learn \
  -v mysql-learn-data:/var/lib/mysql \
  mysql:8.4

# 2. 连进去
docker exec -it mysql-learn mysql -uroot -p learn

# 3. 导入示例库（生成后才有，见「待办」）
# docker exec -i mysql-learn mysql -uroot -p'<密码>' learn < learning-notes/sql/itcast.sql
```

日常起停：

```bash
docker start mysql-learn     # 开始学习
docker stop mysql-learn      # 结束
```

## 每天的学习流程

1. 启动容器，照手册对应分 P 看课、敲 SQL
2. 新建 `logs/YYYY-MM-DD.md` 记录：知识点表 + 练习 SQL + 待办
3. 练习脚本存到 `sql/`
4. 提交推送：

```bash
git add . && git commit -m "notes: $(date +%F)" && git push
```

## 记录规范

```markdown
# YYYY-MM-DD

## 今日知识点
| 主题 | 要点 |
|---|---|
| GROUP BY | 一行话讲清它干什么 |

## 练习 SQL
```sql
-- 可复现的语句
```

## 待办
- [ ] 事项
```

- 知识点只写「一句话要点 + 坑」，不抄大段定义
- SQL 保持能直接跑，涉及密码用占位符
- 当天结束更新下方进度表

## 学习进度

| 日期 | 内容 | 记录 |
|---|---|---|
| 2026-11-26 | 环境搭建、DQL 基础（GROUP BY / COUNT / HAVING / LEFT JOIN） | [logs/2026-11-26.md](logs/2026-11-26.md) |

## 待办

- [ ] 按课程附录生成 `sql/itcast.sql`（`emp` 20 行 + `dept` + `salgrade`），导入后 P15–P50 的案例即可直接跑

## 给 AI 的接续说明

- **背景**：Go 开发者，中文交流；在学 MySQL（黑马 195 集课程），边看边练
- **偏好**：先给用法和可跑示例、多用表格；少讲理论，不展开其他语言
- **环境**：Docker 容器 `mysql-learn`（MySQL 8.4，库 `learn`，`127.0.0.1:3306`），SQL 用 `docker exec` 执行
- **记录**：`logs/` 每日一篇；当天学完更新本文件进度表，并 commit + push
- **安全**：仓库公开，输出/写入任何密码都用占位符
- **手册特点**：附录只有示例表结构（emp/dept/salgrade 等），**没有建表语句和 INSERT 数据**，`emp` 相关案例需要先建库
- **下一步**：生成并导入 `sql/itcast.sql`
