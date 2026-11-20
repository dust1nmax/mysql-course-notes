# 黑马 MySQL 全集案例手册（逐集版）

> 视频：BV1Kr4y1i7ru ｜ 195 个分 P
> 说明：B 站该视频没有公开字幕，本手册按官方分 P 结构逐集整理「讲解要点 + 课堂案例/演示」。SQL 与演示数据依据课程讲义的标准素材整理，个别演示数值可能与你看到的版本略有出入。
> 配套：`MySQL数据库入门到精通-全集总结.md`（知识体系速览版）
>
> **模板说明**：每个实例代码块上方都有一行 `模板：...`，是可套用的通用骨架。`[]` 表示可选，`...` 表示可续写，`｜` 分隔同类命令的不同写法；把中文占位符（表名、列、条件）换成自己的即可。

## 模板总览

按语法类型速查，详细实例见各分 P 小节。

| 类别 | 模板骨架 |
|---|---|
| 库操作 | `CREATE DATABASE [IF NOT EXISTS] 库名 [DEFAULT CHARSET utf8mb4];` / `DROP DATABASE [IF EXISTS] 库名;` / `USE 库名;` |
| 建表 | `CREATE TABLE 表名 (字段 类型 [约束] [COMMENT '注释'], ...) [COMMENT '表注释'];` |
| 改表 | `ALTER TABLE 表名 ADD\|MODIFY\|CHANGE\|DROP\|RENAME ...;` |
| 插入 | `INSERT INTO 表名 [(字段...)] VALUES (值...)[, (...)];` |
| 更新 | `UPDATE 表名 SET 列1 = 值1 [, 列2 = 值2] [WHERE 条件];` |
| 删除 | `DELETE FROM 表名 [WHERE 条件];` |
| 单表查询 | `SELECT [DISTINCT] 列 FROM 表 [WHERE 条件] [GROUP BY 列] [HAVING 组条件] [ORDER BY 列] [LIMIT m, n];` |
| 连接查询 | `SELECT 列 FROM 表1 别名1 [INNER\|LEFT\|RIGHT] JOIN 表2 别名2 ON 关联条件;` |
| 子查询 | `SELECT 列 FROM 表 WHERE 列 IN\|ANY\|ALL (SELECT 列 FROM 表 WHERE 条件);` |
| 事务 | `START TRANSACTION; ... COMMIT;` / `ROLLBACK;` |
| 索引 | `CREATE [UNIQUE] INDEX 索引名 ON 表 (列[(前缀长度)]);` / `DROP INDEX 索引名 ON 表;` |
| 执行计划 | `EXPLAIN SELECT ...;`（看 type / key / key_len / rows / Extra） |
| 视图 | `CREATE [OR REPLACE] VIEW 视图名 AS SELECT ... [WITH CHECK OPTION];` |
| 存储过程 | `DELIMITER $$ CREATE PROCEDURE 名([参数]) BEGIN ... END$$ DELIMITER ; CALL 名(...);` |
| 触发器 | `CREATE TRIGGER 名 AFTER INSERT\|UPDATE\|DELETE ON 表 FOR EACH ROW BEGIN ...; END;` |
| 锁 | `LOCK TABLES 表 READ\|WRITE; ... UNLOCK TABLES;` / `SELECT ... FOR UPDATE;` |
| 用户权限 | `CREATE USER '用户'@'主机' IDENTIFIED BY '密码';` / `GRANT 权限 ON 库.表 TO '用户'@'主机';` |
| 主从复制 | `CHANGE REPLICATION SOURCE TO SOURCE_HOST='...', ...; START REPLICA;` |
| MyCat 分片 | `<table name="逻辑表" dataNode="dn1,dn2" rule="规则名"/>` + `<tableRule>` |

## 目录

- [基础篇 P1–P57](#基础篇-p1p57)
- [进阶篇 P58–P152](#进阶篇-p58p152)
- [运维篇 P153–P195](#运维篇-p153p195)
- [附录：课程用到的示例表结构](#附录课程用到的示例表结构)

---

# 基础篇 P1–P57

## P1 课程介绍

- MySQL 课程分三篇：基础（SQL）、进阶（索引/优化/锁/InnoDB）、运维（日志/复制/分库分表）。
- 学习方式：跟敲 + 每章小结 + 练习。
- 案例：无，纯介绍。

## P2 基础-课程内容-数据库相关概念

| 术语 | 全称 | 说明 |
|---|---|---|
| DB | DataBase | 数据库，存储数据的仓库，数据是有组织地存储的 |
| DBMS | Database Management System | 数据库管理系统，操纵和管理数据库的大型软件 |
| SQL | Structured Query Language | 结构化查询语言，操作关系型数据库的编程语言 |

- 常见关系型数据库：MySQL、Oracle、SQL Server、PostgreSQL。
- MySQL 版本：社区版 / 商业版；5.7 与 8.0。
- 案例：对比「文件存数据」与「数据库存数据」的缺点（冗余、难共享、无并发控制、无安全控制）。

## P3 基础-概述-MySQL安装及启动

- 安装 MySQL 8.0（msi 安装包，选择 Server only / Custom）。
- 启动与停止服务：
  ```bash
  net start mysql80
  net stop mysql80
  # 命令行客户端
  mysql -u root -p
  mysql -h 127.0.0.1 -P 3306 -u root -p
  ```
- 配置环境变量，使 `mysql` 命令可在任意目录使用。
- 案例：安装完成后用命令行客户端连接本地 MySQL，执行第一条 SQL。

## P4 基础-概述-数据模型

- 客户端 → DBMS → 数据库 → 表（二维表：行=记录，列=字段）。
- 案例：用「一个数据库 → 多张表 → 表里多行记录」画出关系型数据模型。

## P5 基础-SQL-通用语法及分类

| 分类 | 全称 | 作用 |
|---|---|---|
| DDL | Data Definition Language | 定义数据库对象（库、表、字段） |
| DML | Data Manipulation Language | 增删改表中的数据 |
| DQL | Data Query Language | 查询表中数据 |
| DCL | Data Control Language | 创建用户、控制访问权限 |

- 语法规则：可单行/多行、分号结尾、不区分大小写（建议关键字大写）、字符串用单引号。
- 注释三种写法：
  ```sql
  -- 单行注释（-- 后必须有空格）
  # 单行注释（MySQL 特有）
  /* 多行注释 */
  ```
- 案例：一段包含三种注释、大小写混写的 SQL，演示规范写法。

## P6 基础-SQL-DDL-数据库操作

演示全集：

> 模板：`SHOW DATABASES ｜ CREATE DATABASE [IF NOT EXISTS] 库名 [DEFAULT CHARSET utf8mb4] ｜ DROP DATABASE [IF EXISTS] 库名 ｜ USE 库名`

```sql
SHOW DATABASES;                                   -- 查询所有数据库
SELECT DATABASE();                                -- 查询当前数据库
CREATE DATABASE itcast;                           -- 创建
CREATE DATABASE IF NOT EXISTS itcast DEFAULT CHARSET utf8mb4;
DROP DATABASE itcast;                             -- 删除
DROP DATABASE IF EXISTS itcast;
USE itcast;                                       -- 使用
```

## P7 基础-SQL-DDL-表操作-创建&查询

演示：

> 模板：`SHOW TABLES ｜ DESC 表名 ｜ SHOW CREATE TABLE 表名`

```sql
USE itcast;
SHOW TABLES;                                      -- 查询当前库所有表

CREATE TABLE tb_user (
  id       INT,
  username VARCHAR(20),
  password VARCHAR(32),
  name     VARCHAR(10),
  gender   CHAR(1),
  birthday DATE
);

DESC tb_user;                                     -- 查询表结构
SHOW CREATE TABLE tb_user;                        -- 查询建表语句
```

## P8 基础-SQL-DDL-数据类型及案例

| 类型 | 大小 | 说明 |
|---|---|---|
| TINYINT | 1 byte | 小整数值 |
| SMALLINT | 2 bytes | 大整数值 |
| MEDIUMINT | 3 bytes | 大整数值 |
| INT / INTEGER | 4 bytes | 大整数值 |
| BIGINT | 8 bytes | 极大整数值 |
| FLOAT | 4 bytes | 单精度浮点 |
| DOUBLE | 8 bytes | 双精度浮点 |
| DECIMAL | — | 精确小数（金额必用） |
| CHAR(n) | 定长 | 定长字符串，性能好但可能浪费空间 |
| VARCHAR(n) | 变长 | 变长字符串，最常用 |
| TEXT | — | 长文本 |
| DATE | 3 bytes | 日期，YYYY-MM-DD |
| TIME | 3 bytes | 时间，HH:MM:SS |
| DATETIME | 8 bytes | 日期时间，YYYY-MM-DD HH:MM:SS |
| TIMESTAMP | 4 bytes | 时间戳，支持到 2038 年 |

- 要点：`UNSIGNED` 无符号；金额用 `DECIMAL`；定长用 `CHAR`，变长用 `VARCHAR`；`TIMESTAMP` 到 2038 年。

**案例：设计一张员工信息表**，要求：

1. 编号（纯数字）
2. 员工工号（字符串，不超过 10 位）
3. 员工姓名（字符串，不超过 10 位）
4. 性别（男/女，存一个汉字）
5. 年龄（不能为负）
6. 身份证号（18 位，可能含 X）
7. 入职时间（年月日）

> 模板：`CREATE TABLE 表名 (字段 类型 [约束] [COMMENT '注释'], ...) [COMMENT '表注释'];`

```sql
CREATE TABLE emp (
  id        INT           COMMENT '编号',
  workno    VARCHAR(10)   COMMENT '工号',
  name      VARCHAR(10)   COMMENT '姓名',
  gender    CHAR(1)       COMMENT '性别',
  age       TINYINT UNSIGNED COMMENT '年龄',
  idcard    CHAR(18)      COMMENT '身份证号',
  entrydate DATE          COMMENT '入职时间'
) COMMENT '员工表';
```

## P9 基础-SQL-DDL-表操作-修改&删除

演示（接着 P8 的 emp 表）：

> 模板：`ALTER TABLE 表名 ADD 列 类型 ｜ MODIFY 列 新类型 ｜ CHANGE 旧列 新列 类型 ｜ DROP 列 ｜ RENAME TO 新表名`

```sql
-- 1. 为 emp 表增加新字段“昵称” nickname，varchar(20)
ALTER TABLE emp ADD nickname VARCHAR(20) COMMENT '昵称';

-- 2. 将 nickname 字段修改为 username，类型 varchar(30)
ALTER TABLE emp CHANGE nickname username VARCHAR(30) COMMENT '用户名';

-- 3. 将 emp 表的字段 username 删除
ALTER TABLE emp DROP username;

-- 4. 将表名 emp 修改为 employee
ALTER TABLE emp RENAME TO employee;

-- 5. 删除表
DROP TABLE IF EXISTS tb_user;

-- 6. 清空表（结构保留）
TRUNCATE TABLE employee;
```

## P10 基础-SQL-DDL小结

- 库：`CREATE / DROP / USE / SHOW DATABASES / SELECT DATABASE()`
- 表：`CREATE / ALTER(ADD, MODIFY, CHANGE, DROP, RENAME) / DROP / TRUNCATE`
- 案例：不看笔记，独立写出建库 → 建表 → 改字段 → 删字段 → 删表全流程。

## P11 基础-SQL-图形化界面工具DataGrip

- 连接 MySQL、新建数据库、执行 SQL、查看表结构与数据。
- 案例：在 DataGrip 中连接 itcast 库，打开 employee 表查看数据。

## P12 基础-SQL-DML-插入

> 模板：`INSERT INTO 表名 [(字段1, 字段2, ...)] VALUES (值1, 值2, ...) [, (...)];`

```sql
-- 1. 指定字段插入
INSERT INTO employee (id, workno, name, gender, age, idcard, entrydate)
VALUES (1, '1', 'Itcast', '男', 10, '123456789012345678', '2000-01-01');

-- 2. 全字段插入
INSERT INTO employee
VALUES (2, '2', '张无忌', '男', 18, '123456789012345670', '2005-09-01');

-- 3. 批量插入
INSERT INTO employee
VALUES (3, '3', '韦一笑', '男', 38, '123456789017345678', '2005-08-01'),
       (4, '4', '赵敏',  '女', 18, '123456789012345678', '2009-05-01');
```

要点：字符串和日期加引号；插入数据长度不能超字段限制；批量插入建议 500–1000 条一批。

## P13 基础-SQL-DML-更新和删除

> 模板：`UPDATE 表名 SET 列1 = 值1 [, 列2 = 值2] [WHERE 条件]; ｜ DELETE FROM 表名 [WHERE 条件];`

```sql
-- 1. id 为 1 的记录，name 改为 itheima
UPDATE employee SET name = 'itheima' WHERE id = 1;

-- 2. id 为 1 的记录，name 改为小昭，gender 改为女
UPDATE employee SET name = '小昭', gender = '女' WHERE id = 1;

-- 3. 所有员工入职日期改为 2008-01-01（无 WHERE，改全表）
UPDATE employee SET entrydate = '2008-01-01';

-- 4. 删除 gender 为女的员工
DELETE FROM employee WHERE gender = '女';

-- 5. 删除所有员工
DELETE FROM employee;
```

要点：UPDATE/DELETE 不带 WHERE 会作用于全表；DELETE 不能只删某列值（用 UPDATE 置 NULL）。

## P14 基础-SQL-DML小结

| 对比项 | DELETE | TRUNCATE |
|---|---|---|
| 类型 | DML | DDL |
| 删除方式 | 逐行删除 | 清空整表 |
| WHERE 条件 | 支持 | 不支持 |
| 自增重置 | 不重置 | 重置 |
| 事务回滚 | 可回滚 | 不可回滚 |
| 速度 | 慢 | 快 |

- `INSERT` / `UPDATE` / `DELETE` 三组语法与注意事项；

## P15 基础-SQL-DQL-基础查询

课程 emp 表字段：`id, workno, name, gender, age, idcard, workaddress, entrydate`（约 20 行演示数据，含张无忌、赵敏、韦一笑、常遇春、小昭、灭绝等）。

```sql
SELECT 字段列表 FROM 表名列表;
SELECT * FROM emp;
SELECT name, age FROM emp;
SELECT name AS 姓名, age AS 年龄 FROM emp;   -- AS 可省略
SELECT DISTINCT workaddress FROM emp;        -- 去重
```

## P16 基础-SQL-DQL-条件查询

> 模板：`SELECT 列 FROM 表 WHERE 列 比较符 值 [AND|OR ...] [BETWEEN a AND b] [IN (...)] [LIKE '模式'] [IS [NOT] NULL];`

```sql
-- 1. 年龄等于 20
SELECT * FROM emp WHERE age = 20;
-- 2. 年龄小于 20
SELECT * FROM emp WHERE age < 20;
-- 3. 年龄小于等于 20
SELECT * FROM emp WHERE age <= 20;
-- 4. 没有身份证号
SELECT * FROM emp WHERE idcard IS NULL;
-- 5. 有身份证号
SELECT * FROM emp WHERE idcard IS NOT NULL;
-- 6. 年龄不等于 20
SELECT * FROM emp WHERE age != 20;
-- 7. 年龄在 15（含）到 20（含）之间
SELECT * FROM emp WHERE age BETWEEN 15 AND 20;
-- 8. 性别为女且年龄小于 25
SELECT * FROM emp WHERE gender = '女' AND age < 25;
-- 9. 年龄等于 18 或 20 或 40
SELECT * FROM emp WHERE age IN (18, 20, 40);
-- 10. 姓名为两个字
SELECT * FROM emp WHERE name LIKE '__';
-- 11. 身份证号最后一位是 X
SELECT * FROM emp WHERE idcard LIKE '%X';
```

## P17 基础-SQL-DQL-聚合函数

| 函数 | 功能 |
|---|---|
| `COUNT` | 统计数量（一般选用 `*`） |
| `MAX` | 最大值 |
| `MIN` | 最小值 |
| `AVG` | 平均值 |
| `SUM` | 求和 |

> 模板：`SELECT 聚合函数(列) FROM 表 [WHERE 条件];  -- COUNT / MAX / MIN / AVG / SUM`

```sql
SELECT COUNT(*) FROM emp;                         -- 统计员工数量
SELECT AVG(age) FROM emp;                         -- 平均年龄
SELECT MAX(age) FROM emp;                         -- 最大年龄
SELECT MIN(age) FROM emp;                         -- 最小年龄
SELECT SUM(age) FROM emp WHERE workaddress = '西安';  -- 西安员工年龄之和
```

要点：聚合函数作用于某一列，`NULL` 不参与计算。

## P18 基础-SQL-DQL-分组查询

> 模板：`SELECT 分组列, 聚合函数(列) FROM 表 [WHERE 行条件] GROUP BY 分组列 [HAVING 组条件];`

```sql
-- 1. 按性别分组，统计男女员工数量
SELECT gender, COUNT(*) FROM emp GROUP BY gender;
-- 2. 按性别分组，统计男女平均年龄
SELECT gender, AVG(age) FROM emp GROUP BY gender;
-- 3. 年龄小于 45 的员工，按工作地址分组，取员工数 >= 3 的地址
SELECT workaddress, COUNT(*)
FROM emp
WHERE age < 45
GROUP BY workaddress
HAVING COUNT(*) >= 3;
```

要点：`WHERE` 在分组前过滤行，`HAVING` 在分组后过滤组；分组后 SELECT 只能写分组字段和聚合函数。

## P19 基础-SQL-DQL-排序查询

> 模板：`SELECT 列 FROM 表 [WHERE 条件] ORDER BY 列1 [ASC|DESC] [, 列2 [ASC|DESC]];`

```sql
-- 1. 按年龄升序
SELECT * FROM emp ORDER BY age ASC;
-- 2. 按入职时间降序
SELECT * FROM emp ORDER BY entrydate DESC;
-- 3. 年龄升序，年龄相同按入职时间降序
SELECT * FROM emp ORDER BY age ASC, entrydate DESC;
```

## P20 基础-SQL-DQL-分页查询

> 模板：`SELECT 列 FROM 表 [WHERE 条件] [ORDER BY 列] LIMIT 起始索引, 查询条数;`

```sql
-- 1. 第 1 页，每页 10 条
SELECT * FROM emp LIMIT 0, 10;
-- 2. 第 2 页，每页 10 条
SELECT * FROM emp LIMIT 10, 10;
-- 起始索引 = (页码 - 1) × 每页条数
```

## P21 基础-SQL-DQL-案例练习

DQL 综合 5 题：

> 模板：`SELECT [DISTINCT] 列 FROM 表 WHERE 条件 GROUP BY 分组列 HAVING 组条件 ORDER BY 列 LIMIT m, n;`

```sql
-- 1. 查询年龄为 20、21、22、23 岁的女性员工
SELECT * FROM emp WHERE gender = '女' AND age IN (20, 21, 22, 23);

-- 2. 性别为男且年龄 20–40（含）、姓名为三个字
SELECT * FROM emp WHERE gender = '男' AND age BETWEEN 20 AND 40 AND name LIKE '___';

-- 3. 年龄小于 60 的男、女员工人数
SELECT gender, COUNT(*) FROM emp WHERE age < 60 GROUP BY gender;

-- 4. 年龄 <= 35 的员工姓名和年龄，按年龄升序、入职时间降序
SELECT name, age FROM emp WHERE age <= 35 ORDER BY age ASC, entrydate DESC;

-- 5. 性别为男且年龄 20–40，前 5 个员工，按年龄升序、入职时间升序
SELECT * FROM emp
WHERE gender = '男' AND age BETWEEN 20 AND 40
ORDER BY age ASC, entrydate ASC
LIMIT 5;
```

## P22 基础-SQL-DQL-执行顺序

| 关键字 | 作用 | 执行顺序 |
|---|---|---|
| FROM | 确定数据源 | 1 |
| WHERE | 过滤行 | 2 |
| GROUP BY | 分组 | 3 |
| HAVING | 过滤分组 | 4 |
| SELECT | 取列、聚合 | 5 |
| ORDER BY | 排序（可用 SELECT 别名） | 6 |
| LIMIT | 分页 | 7 |

- 案例：`ORDER BY` 中可以使用 SELECT 的别名，`WHERE` 中不能：
  ```sql
  SELECT name, age AS a FROM emp ORDER BY a;    -- 可以
  SELECT name, age AS a FROM emp WHERE a > 20;  -- 报错
  ```

## P23 基础-SQL-DQL小结

| 子句 | 作用 | 要点 |
|---|---|---|
| WHERE | 过滤行 | 不能使用 SELECT 别名 |
| GROUP BY / HAVING | 分组与组过滤 | SELECT 只能取分组列和聚合函数 |
| ORDER BY | 排序 | 多字段排序注意先后顺序 |
| LIMIT | 分页 | `LIMIT 起始索引, 条数`，索引从 0 开始 |

执行顺序：`FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT`

- 案例：用一条 SQL 完成「筛选 + 分组 + 排序 + 分页」。

## P24 基础-SQL-DCL-用户管理

> 模板：`CREATE USER '用户'@'主机' IDENTIFIED BY '密码'; ｜ ALTER USER '用户'@'主机' ... BY '新密码'; ｜ DROP USER '用户'@'主机';`

```sql
-- 1. 创建用户 itcast，只能本地访问，密码 123456
CREATE USER 'itcast'@'localhost' IDENTIFIED BY '123456';
-- 2. 创建用户 heima，任意主机访问，密码 123456
CREATE USER 'heima'@'%' IDENTIFIED BY '123456';
-- 3. 修改 heima 的密码为 1234
ALTER USER 'heima'@'%' IDENTIFIED WITH mysql_native_password BY '1234';
-- 4. 删除 itcast@localhost
DROP USER 'itcast'@'localhost';
```

## P25 基础-SQL-DCL-权限控制

| 权限 | 说明 |
|---|---|---|
| ALL / ALL PRIVILEGES | 所有权限 |
| SELECT / INSERT / UPDATE / DELETE | 数据操作权限 |
| ALTER / DROP / CREATE | 结构变更权限 |
| GRANT OPTION | 允许将自己的权限授予他人 |

常用权限：`ALL, SELECT, INSERT, UPDATE, DELETE, ALTER, DROP, CREATE ...`

> 模板：`GRANT 权限 ON 库.表 TO '用户'@'主机'; ｜ REVOKE 权限 ON 库.表 FROM '用户'@'主机'; ｜ SHOW GRANTS FOR '用户'@'主机';`

```sql
-- 1. 查看 heima 的权限
SHOW GRANTS FOR 'heima'@'%';
-- 2. 授予 itcast 库所有表的所有权限
GRANT ALL ON itcast.* TO 'heima'@'%';
-- 3. 授予 itcast 库 tb_user 表的查询权限
GRANT SELECT ON itcast.tb_user TO 'heima'@'%';
-- 4. 撤销 itcast 库所有权限
REVOKE ALL ON itcast.* FROM 'heima'@'%';
```

## P26 基础-SQL-DCL小结

| 操作 | 命令 |
|---|---|
| 创建用户 | `CREATE USER '用户'@'主机' IDENTIFIED BY '密码';` |
| 修改密码 | `ALTER USER '用户'@'主机' IDENTIFIED WITH mysql_native_password BY '新密码';` |
| 删除用户 | `DROP USER '用户'@'主机';` |
| 授权 | `GRANT 权限 ON 库.表 TO '用户'@'主机';` |
| 撤销权限 | `REVOKE 权限 ON 库.表 FROM '用户'@'主机';` |
| 查看权限 | `SHOW GRANTS FOR '用户'@'主机';` |

- 案例：新建一个只读账号，验证它可以 SELECT、执行 INSERT 时报错。

## P27 基础-函数-字符串函数

MySQL 内置了很多字符串函数，常用的几个如下：

| 函数 | 功能 |
|---|---|
| `CONCAT(S1, S2, ... Sn)` | 字符串拼接，将 S1、S2 … Sn 拼接成一个字符串 |
| `LOWER(str)` | 将字符串 str 全部转为小写 |
| `UPPER(str)` | 将字符串 str 全部转为大写 |
| `LPAD(str, n, pad)` | 左填充，用字符串 pad 对 str 的左边进行填充，达到 n 个字符串长度 |
| `RPAD(str, n, pad)` | 右填充，用字符串 pad 对 str 的右边进行填充，达到 n 个字符串长度 |
| `TRIM(str)` | 去掉字符串头部和尾部的空格 |
| `SUBSTRING(str, start, len)` | 返回从字符串 str 从 start 位置起的 len 个长度的字符串 |

**案例**：企业员工工号统一为 5 位，不足 5 位前面补 0（1 号员工 → 00001）：

> 模板：`UPDATE 表 SET 列 = 字符串函数(列 [, 参数]) [WHERE 条件];`

```sql
UPDATE emp SET workno = LPAD(workno, 5, '0');
```

## P28 基础-函数-数值函数

| 函数 | 功能 |
|---|---|
| `CEIL(x)` | 向上取整 |
| `FLOOR(x)` | 向下取整 |
| `MOD(x, y)` | 返回 x / y 的模 |
| `RAND()` | 返回 0~1 内的随机数 |
| `ROUND(x, y)` | 求参数 x 的四舍五入值，保留 y 位小数 |

**案例**：生成一个六位数的随机验证码：

> 模板：`SELECT 数值函数(参数 [, 参数]);`

```sql
SELECT LPAD(ROUND(RAND() * 1000000, 0), 6, '0');
```

## P29 基础-函数-日期函数

| 函数 | 功能 |
|---|---|
| `CURDATE()` | 返回当前日期 |
| `CURTIME()` | 返回当前时间 |
| `NOW()` | 返回当前日期和时间 |
| `YEAR(date)` | 获取指定 date 的年份 |
| `MONTH(date)` | 获取指定 date 的月份 |
| `DAY(date)` | 获取指定 date 的日期 |
| `DATE_ADD(date, INTERVAL expr type)` | 返回一个日期/时间值加上一个时间间隔 expr 后的时间值 |
| `DATEDIFF(date1, date2)` | 返回起始时间 date1 和结束时间 date2 之间的天数 |

**案例**：查询所有员工的入职天数，并按入职天数倒序：

> 模板：`SELECT 日期函数(列) FROM 表 [WHERE 条件] [ORDER BY 列];`

```sql
SELECT name, DATEDIFF(CURDATE(), entrydate) AS entrydays
FROM emp
ORDER BY entrydays DESC;
```

## P30 基础-函数-流程函数

| 函数 | 功能 |
|---|---|
| `IF(value, t, f)` | 如果 value 为 true，则返回 t，否则返回 f |
| `IFNULL(value1, value2)` | 如果 value1 不为空，返回 value1，否则返回 value2 |
| `CASE WHEN [val1] THEN [res1] ... ELSE [default] END` | 如果 val1 为 true，返回 res1，… 否则返回 default 默认值 |
| `CASE [expr] WHEN [val1] THEN [res1] ... ELSE [default] END` | 如果 expr 的值等于 val1，返回 res1，… 否则返回 default 默认值 |

**案例 1**：工作地址 北京/上海 → 一线城市，其他 → 二线城市：

> 模板：`SELECT CASE 表达式 WHEN 值 THEN 结果 ... [ELSE 结果] END AS 别名 FROM 表;`

```sql
SELECT name,
       (CASE workaddress WHEN '北京' THEN '一线城市'
                         WHEN '上海' THEN '一线城市'
                         ELSE '二线城市' END) AS '工作地址'
FROM emp;
```

**案例 2**：统计班级成绩，>=85 优秀、>=60 及格、否则不及格：

> 模板：`SELECT CASE WHEN 条件 THEN 结果 ... [ELSE 结果] END AS 别名 FROM 表;`

```sql
SELECT id, name,
       (CASE WHEN math >= 85 THEN '优秀' WHEN math >= 60 THEN '及格' ELSE '不及格' END) AS 数学,
       (CASE WHEN english >= 85 THEN '优秀' WHEN english >= 60 THEN '及格' ELSE '不及格' END) AS 英语,
       (CASE WHEN chinese >= 85 THEN '优秀' WHEN chinese >= 60 THEN '及格' ELSE '不及格' END) AS 语文
FROM score;
```

## P31 基础-函数-小结

| 类别 | 常用函数 |
|---|---|
| 字符串 | `CONCAT`、`LOWER`、`UPPER`、`LPAD`、`RPAD`、`TRIM`、`SUBSTRING` |
| 数值 | `CEIL`、`FLOOR`、`MOD`、`RAND`、`ROUND` |
| 日期 | `CURDATE`、`CURTIME`、`NOW`、`YEAR`、`MONTH`、`DAY`、`DATE_ADD`、`DATEDIFF` |
| 流程 | `IF`、`IFNULL`、`CASE ... END` |

- 案例：用函数组合完成实际需求，如 `CONCAT(name, '(', job, ')')`、`DATE_ADD(entrydate, INTERVAL 1 YEAR)`。

## P32 基础-约束-概述

约束是作用于表中字段上的规则，用于限制存储在表中的数据。

| 约束 | 描述 | 关键字 |
|---|---|---|
| 非空约束 | 限制该字段的数据不能为 null | `NOT NULL` |
| 唯一约束 | 保证该字段的所有数据都是唯一、不重复的 | `UNIQUE` |
| 主键约束 | 主键是一行数据的唯一标识，要求非空且唯一 | `PRIMARY KEY` |
| 默认约束 | 保存数据时，如果未指定该字段的值，则采用默认值 | `DEFAULT` |
| 检查约束（8.0.16 之后） | 保证字段值满足某一个条件 | `CHECK` |
| 外键约束 | 让两张表的数据之间建立连接，保证数据的一致性和完整性 | `FOREIGN KEY` |

- 案例：先建一张没有任何约束的 `user` 表，插入 NULL、重复值、负数年龄，演示数据混乱，引出约束的必要性。

## P33 基础-约束-演示

> 模板：`CREATE TABLE 表名 (字段 类型 [NOT NULL|UNIQUE|PRIMARY KEY|DEFAULT 值|CHECK (条件)|AUTO_INCREMENT], ...);`

```sql
CREATE TABLE user (
  id     INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
  name   VARCHAR(10) NOT NULL COMMENT '姓名',
  age    TINYINT UNSIGNED CHECK (age > 0) COMMENT '年龄',
  status CHAR(1) DEFAULT '1' COMMENT '状态',
  gender CHAR(1) COMMENT '性别'
) COMMENT '用户表';
```

演示过程（课堂逐步加约束）：

> 模板：`INSERT INTO 表 (字段...) VALUES (...);  -- 故意违反约束，验证是否被拦截`

```sql
-- 非空约束：name 为 NULL 插入失败
INSERT INTO user (name, age, status, gender) VALUES (NULL, 19, '1', '男');

-- 检查约束：age 为 -1 插入失败
INSERT INTO user (name, age, status, gender) VALUES ('张三', -1, '1', '男');

-- 唯一约束
ALTER TABLE user ADD CONSTRAINT unique_name UNIQUE (name);
INSERT INTO user (name, age, status, gender) VALUES ('张三', 20, '1', '男');
INSERT INTO user (name, age, status, gender) VALUES ('张三', 21, '1', '男');  -- 失败

-- 默认约束：不传 status 时取默认值 '1'
INSERT INTO user (name, age, gender) VALUES ('李四', 20, '男');

-- 主键自增：显式插入 id / 插入 NULL 自动生成
INSERT INTO user (id, name, age, status, gender) VALUES (10, '王五', 22, '1', '男');
INSERT INTO user (id, name, age, status, gender) VALUES (NULL, '赵六', 23, '1', '男');
```

## P34 基础-约束-外键约束

> 模板：`CREATE TABLE 主表 (id 类型 PRIMARY KEY, ...); CREATE TABLE 从表 (..., 外键列 类型, [CONSTRAINT 外键名] FOREIGN KEY (外键列) REFERENCES 主表 (主键));`

```sql
-- 主表
CREATE TABLE dept (
  id   INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL
);

-- 从表：dept_id 关联 dept.id
CREATE TABLE emp (
  id      INT PRIMARY KEY AUTO_INCREMENT,
  name    VARCHAR(50) NOT NULL,
  age     INT CHECK (age > 0),
  gender  CHAR(1) DEFAULT '1',
  dept_id INT,
  CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id) REFERENCES dept (id)
);
```

演示：

> 模板：`INSERT INTO 从表 (字段..., 外键列) VALUES (..., 主表中存在的 id);`

```sql
INSERT INTO dept (name) VALUES ('研发部'), ('市场部'), ('财务部'), ('销售部');
INSERT INTO emp (name, age, gender, dept_id) VALUES ('张三', 20, '1', 1);  -- 成功
INSERT INTO emp (name, age, gender, dept_id) VALUES ('李四', 21, '1', 6);  -- 失败：dept 无 id=6
DELETE FROM dept WHERE id = 1;                                              -- 失败：被子表引用
```

外键的增删：

> 模板：`ALTER TABLE 表 ADD CONSTRAINT 外键名 FOREIGN KEY (外键列) REFERENCES 主表 (主键列); ｜ ALTER TABLE 表 DROP FOREIGN KEY 外键名;`

```sql
ALTER TABLE emp ADD CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id) REFERENCES dept (id);
ALTER TABLE emp DROP FOREIGN KEY fk_emp_dept;
```

## P35 基础-约束-外键删除更新行为

> 模板：`FOREIGN KEY (外键列) REFERENCES 主表 (主键列) ON UPDATE 行为 ON DELETE 行为;  -- 行为：CASCADE / SET NULL / RESTRICT / NO ACTION`

```sql
-- 级联：主表更新/删除时，子表跟着改/删
ALTER TABLE emp ADD CONSTRAINT fk_emp_dept
  FOREIGN KEY (dept_id) REFERENCES dept (id)
  ON UPDATE CASCADE ON DELETE CASCADE;

-- 置空：主表删除后，子表外键置 NULL
ALTER TABLE emp ADD CONSTRAINT fk_emp_dept
  FOREIGN KEY (dept_id) REFERENCES dept (id)
  ON UPDATE CASCADE ON DELETE SET NULL;
```

演示：`UPDATE dept SET id = 10 WHERE id = 1;` → 子表 `dept_id` 随之变为 10（CASCADE）；`DELETE FROM dept WHERE id = 10;` → 子表记录被删除或置空，取决于行为。

## P36 基础-约束-小结

| 外键行为 | 说明 |
|---|---|
| NO ACTION / RESTRICT | 主表变更被拒绝（默认行为） |
| CASCADE | 级联更新 / 删除子表数据 |
| SET NULL | 子表外键置 NULL（外键列需允许 NULL） |
| SET DEFAULT | 置默认值（InnoDB 不支持） |

**案例**：用「部门-员工」表逐一验证四种外键行为。

> 模板：`FOREIGN KEY (外键列) REFERENCES 主表 (主键列) ON UPDATE 行为 ON DELETE 行为;`

```sql
-- 建表时指定：更新级联、删除置空
CREATE TABLE emp (
  id      INT PRIMARY KEY AUTO_INCREMENT,
  name    VARCHAR(50) NOT NULL,
  dept_id INT,
  CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id) REFERENCES dept (id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

INSERT INTO dept (name) VALUES ('研发部'), ('市场部');
INSERT INTO emp (name, dept_id) VALUES ('张三', 1), ('李四', 2);

-- 1. CASCADE：主表主键 1 改成 10，子表 dept_id 跟着变
UPDATE dept SET id = 10 WHERE id = 1;
SELECT * FROM emp WHERE name = '张三';     -- dept_id = 10

-- 2. SET NULL：删除主表记录，子表外键置 NULL
DELETE FROM dept WHERE id = 10;
SELECT * FROM emp WHERE name = '张三';     -- dept_id = NULL

-- 3. RESTRICT（默认）：被引用的记录不允许删除
ALTER TABLE emp DROP FOREIGN KEY fk_emp_dept;
ALTER TABLE emp ADD CONSTRAINT fk_emp_dept
  FOREIGN KEY (dept_id) REFERENCES dept (id);
DELETE FROM dept WHERE id = 2;             -- 报错：Cannot delete or update a parent row
```

- SET DEFAULT 只有部分引擎支持，InnoDB 指定后会建表失败。

## P37 基础-多表查询-多表关系介绍

| 关系 | 示例 | 实现方式 |
|---|---|---|
| 一对一 | 用户 ↔ 用户详情 | 任意一方加外键，并给外键加 UNIQUE |
| 一对多 | 部门 ↔ 员工 | 多的一方加外键，指向一的一方的主键 |
| 多对多 | 学生 ↔ 课程 | 建中间表，两个外键分别指向两张表 |

**案例 1：一对多（部门 ↔ 员工）**——外键加在多的一方

> 模板：`CREATE TABLE 多的一方 (..., 外键列 类型, CONSTRAINT 外键名 FOREIGN KEY (外键列) REFERENCES 一的一方 (主键));`

```sql
CREATE TABLE tb_dept (
  id   INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL
);

CREATE TABLE tb_emp (
  id      INT PRIMARY KEY AUTO_INCREMENT,
  name    VARCHAR(50) NOT NULL,
  age     INT,
  dept_id INT,
  CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id) REFERENCES tb_dept (id)
);
```

**案例 2：多对多（学生 ↔ 课程）**——建中间表，两个外键分别指向两张表

> 模板：`CREATE TABLE 中间表 (id 主键, 表1外键, 表2外键, 业务字段, 两个外键各自 REFERENCES);`

```sql
CREATE TABLE tb_student (
  id   INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  no   VARCHAR(10) NOT NULL
);

CREATE TABLE tb_course (
  id   INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL
);

CREATE TABLE tb_student_course (
  id         INT PRIMARY KEY AUTO_INCREMENT,
  student_id INT NOT NULL,
  course_id  INT NOT NULL,
  score      DECIMAL(4, 1),
  CONSTRAINT fk_sc_student FOREIGN KEY (student_id) REFERENCES tb_student (id),
  CONSTRAINT fk_sc_course  FOREIGN KEY (course_id)  REFERENCES tb_course (id)
);
```

**案例 3：一对一（用户 ↔ 用户详情）**——外键 + UNIQUE，保证一条用户只对应一条详情

> 模板：`CREATE TABLE 从表 (id 主键, user_id 类型 UNIQUE, ..., FOREIGN KEY (user_id) REFERENCES 主表 (id));`

```sql
CREATE TABLE tb_user (
  id    INT PRIMARY KEY AUTO_INCREMENT,
  name  VARCHAR(20) NOT NULL,
  age   INT,
  phone VARCHAR(11)
);

CREATE TABLE tb_user_detail (
  id       INT PRIMARY KEY AUTO_INCREMENT,
  user_id  INT UNIQUE,
  birthday DATE,
  address  VARCHAR(50),
  CONSTRAINT fk_detail_user FOREIGN KEY (user_id) REFERENCES tb_user (id)
);
```

## P38 基础-多表查询-概述

- 笛卡尔积演示：
  ```sql
  SELECT * FROM emp, dept;   -- 行数 = 两表行数相乘，结果无意义
  ```
- 消除无效笛卡尔积：加连接条件 `WHERE emp.dept_id = dept.id`。
- 分类：内连接、外连接、自连接、联合查询、子查询。

## P39 基础-多表查询-内连接

> 模板：`SELECT 列 FROM 表1 别名1 [INNER] JOIN 表2 别名2 ON 关联条件 [WHERE 条件];`

```sql
-- 1. 查询每个员工的姓名及部门名称（隐式内连接）
SELECT emp.name, dept.name FROM emp, dept WHERE emp.dept_id = dept.id;
-- 起别名
SELECT e.name, d.name FROM emp e, dept d WHERE e.dept_id = d.id;

-- 2. 显式内连接
SELECT e.name, d.name FROM emp e INNER JOIN dept d ON e.dept_id = d.id;
```

## P40 基础-多表查询-外连接

> 模板：`SELECT 列 FROM 表1 LEFT|RIGHT [OUTER] JOIN 表2 ON 关联条件;`

```sql
-- 1. 查询 emp 表所有数据及对应部门信息（左外连接）
SELECT e.*, d.name FROM emp e LEFT OUTER JOIN dept d ON e.dept_id = d.id;

-- 2. 查询 dept 表所有数据及对应员工信息（右外连接）
SELECT d.*, e.name FROM emp e RIGHT OUTER JOIN dept d ON e.dept_id = d.id;
```

要点：左外保留左表全部行，右外保留右表全部行，无匹配填 NULL。

## P41 基础-多表查询-自连接

> 模板：`SELECT a.列, b.列 FROM 表 a [LEFT] JOIN 表 b ON a.关联列 = b.关联列;`

```sql
-- 1. 查询员工及其直属领导的名字
SELECT a.name AS 员工, b.name AS 领导
FROM emp a, emp b
WHERE a.managerid = b.id;

-- 2. 查询所有员工及领导，没有领导的员工也要查出来
SELECT a.name AS 员工, b.name AS 领导
FROM emp a
LEFT JOIN emp b ON a.managerid = b.id;
```

## P42 基础-多表查询-联合查询union

> 模板：`SELECT ... FROM 表1 WHERE 条件1 UNION [ALL] SELECT ... FROM 表2 WHERE 条件2;`

```sql
-- 将薪资低于 5000 的员工和年龄大于 50 岁的员工全部查询出来
SELECT * FROM emp WHERE salary < 5000
UNION
SELECT * FROM emp WHERE age > 50;

-- UNION ALL 保留重复行，UNION 自动去重
```

要点：列数、列类型需一致。

## P43 基础-多表查询-子查询介绍

| 分类 | 返回结果 | 常用运算符 |
|---|---|---|
| 标量子查询 | 单个值 | =、<>、>、>=、<、<= |
| 列子查询 | 一列（多行） | IN、NOT IN、ANY、SOME、ALL |
| 行子查询 | 一行（多列） | =、<>、IN、NOT IN |
| 表子查询 | 多行多列 | IN，或放在 FROM 后当临时表 |

- 案例：`SELECT * FROM emp WHERE salary > (SELECT AVG(salary) FROM emp);` —— 先看内层返回什么，再决定外部用什么运算符。

## P44 基础-多表查询-标量子查询

> 模板：`SELECT 列 FROM 表 WHERE 列 比较符 (SELECT 单值 FROM 表 WHERE 条件);`

```sql
-- 1. 查询“销售部”的所有员工
SELECT * FROM emp WHERE dept_id = (SELECT id FROM dept WHERE name = '销售部');

-- 2. 查询“方东白”入职之后的员工
SELECT * FROM emp WHERE entrydate > (SELECT entrydate FROM emp WHERE name = '方东白');
```

## P45 基础-多表查询-列子查询

> 模板：`SELECT 列 FROM 表 WHERE 列 IN|ANY|ALL (SELECT 单列 FROM 表 WHERE 条件);`

```sql
-- 1. 查询“销售部”和“市场部”的所有员工
SELECT * FROM emp
WHERE dept_id IN (SELECT id FROM dept WHERE name = '销售部' OR name = '市场部');

-- 2. 查询比研发部所有人工资都高的员工
SELECT * FROM emp
WHERE salary > ALL (SELECT salary FROM emp
                    WHERE dept_id = (SELECT id FROM dept WHERE name = '研发部'));

-- 3. 查询比研发部任意一人工资高的员工
SELECT * FROM emp
WHERE salary > ANY (SELECT salary FROM emp
                    WHERE dept_id = (SELECT id FROM dept WHERE name = '研发部'));
```

## P46 基础-多表查询-行子查询

> 模板：`SELECT 列 FROM 表 WHERE (列1, 列2) = (SELECT 列1, 列2 FROM 表 WHERE 条件);`

```sql
-- 查询与“张无忌”的薪资及直属领导相同的员工
SELECT * FROM emp
WHERE (salary, managerid) = (SELECT salary, managerid FROM emp WHERE name = '张无忌');
```

## P47 基础-多表查询-表子查询

> 模板：`SELECT ... FROM (SELECT ... FROM 表 WHERE 条件) 别名 [LEFT JOIN 表2 ON ...];`

```sql
-- 1. 查询与“鹿杖客”“宋远桥”职位和薪资都相同的员工
SELECT * FROM emp
WHERE (job, salary) IN (SELECT job, salary FROM emp WHERE name IN ('鹿杖客', '宋远桥'));

-- 2. 查询入职日期在 2006-01-01 之后的员工及其部门信息
SELECT e.*, d.*
FROM (SELECT * FROM emp WHERE entrydate > '2006-01-01') e
LEFT JOIN dept d ON e.dept_id = d.id;
```

## P48 基础-多表查询-练习1

课程用 `emp`、`dept`、`salgrade` 演练，12 道综合题，本集完成前 6 题：

> 模板：`SELECT 列 FROM 表1 别名1, 表2 别名2 [, 表3 别名3] WHERE 关联条件 AND 过滤条件;`

```sql
-- 1. 查询员工的姓名、年龄、职位、部门信息（隐式内连接）
SELECT e.name, e.age, e.job, d.name
FROM emp e, dept d WHERE e.dept_id = d.id;

-- 2. 查询年龄小于 30 岁的员工姓名、年龄、职位、部门信息（显式内连接）
SELECT e.name, e.age, e.job, d.name
FROM emp e INNER JOIN dept d ON e.dept_id = d.id
WHERE e.age < 30;

-- 3. 查询拥有员工的部门 ID、部门名称（去重）
SELECT DISTINCT d.id, d.name
FROM emp e, dept d WHERE e.dept_id = d.id;

-- 4. 查询年龄大于 40 的员工及其部门名称，没有部门的也要展示
SELECT e.*, d.name
FROM emp e LEFT JOIN dept d ON e.dept_id = d.id
WHERE e.age > 40;

-- 5. 查询所有员工的工资等级（salgrade: grade, losal, hisal）
SELECT e.*, s.grade
FROM emp e, salgrade s
WHERE e.salary >= s.losal AND e.salary <= s.hisal;

-- 6. 查询“研发部”所有员工的信息及工资等级
SELECT e.*, s.grade
FROM emp e, dept d, salgrade s
WHERE e.dept_id = d.id AND d.name = '研发部'
  AND (e.salary BETWEEN s.losal AND s.hisal);
```

## P49 基础-多表查询-练习2

本集完成后 6 题，重点是子查询、按部门聚合与学生选课三表查询：

> 模板：`SELECT 列 FROM 表 WHERE 列 比较符 (SELECT 聚合函数(列) FROM 表 [WHERE 条件]);`

```sql
-- 7. 查询“研发部”员工的平均工资
SELECT AVG(e.salary)
FROM emp e, dept d
WHERE e.dept_id = d.id AND d.name = '研发部';

-- 8. 查询工资比“灭绝”高的员工信息
SELECT * FROM emp
WHERE salary > (SELECT salary FROM emp WHERE name = '灭绝');

-- 9. 查询比平均薪资高的员工信息
SELECT * FROM emp WHERE salary > (SELECT AVG(salary) FROM emp);

-- 10. 查询低于本部门平均工资的员工信息
SELECT * FROM emp e1
WHERE e1.salary < (SELECT AVG(e2.salary) FROM emp e2 WHERE e2.dept_id = e1.dept_id);

-- 11. 查询所有部门信息，并统计每个部门的员工人数
SELECT d.id, d.name, IFNULL(COUNT(e.id), 0) AS 人数
FROM dept d LEFT JOIN emp e ON d.id = e.dept_id
GROUP BY d.id, d.name;

-- 12. 查询所有学生的选课情况：学生名称、学号、课程名称
SELECT s.name AS 学生姓名, s.no AS 学号, c.name AS 课程名称
FROM student s, student_course sc, course c
WHERE s.id = sc.studentid AND sc.courseid = c.id;
```

## P50 基础-多表查询-小结

| 查询方式 | 写法特征 | 适用场景 |
|---|---|---|
| 内连接 | `JOIN ... ON` 或逗号 + WHERE | 只要两表匹配的行 |
| 左/右外连接 | `LEFT / RIGHT JOIN` | 保留一侧全部行，无匹配补 NULL |
| 自连接 | 同一张表起两个别名 | 层级数据（员工-领导） |
| 联合查询 | `UNION [ALL]` | 多条查询结果合并 |
| 子查询 | 标量 / 列 / 行 / 表 | 分步筛选、与聚合结果比较 |

- 口诀：有「全都要」用外连接，层级数据用自连接，聚合前的多步筛选用子查询。

## P51 基础-事务-简介

**案例：银行转账**

> 模板：`START TRANSACTION; UPDATE 表 SET 列 = 列 - 值 WHERE 条件; UPDATE 表 SET 列 = 列 + 值 WHERE 条件; COMMIT;  -- 异常时 ROLLBACK`

```sql
-- 张三给李四转 1000 元
UPDATE account SET money = money - 1000 WHERE name = '张三';
UPDATE account SET money = money + 1000 WHERE name = '李四';
-- 若第一条成功后系统异常，张三少了钱但李四没收到 → 引出事务
```

## P52 基础-事务-操作演示

> 模板：`SET @@autocommit = 0; ｜ START TRANSACTION ... COMMIT / ROLLBACK; ｜ SELECT @@autocommit;`

```sql
SELECT @@autocommit;          -- 1：自动提交
SET @@autocommit = 0;         -- 改为手动提交

-- 方式一：关闭自动提交
UPDATE account SET money = money - 1000 WHERE name = '张三';
UPDATE account SET money = money + 1000 WHERE name = '李四';
COMMIT;                       -- 或 ROLLBACK 回滚

-- 方式二：显式开启事务
START TRANSACTION;            -- 或 BEGIN
UPDATE account SET money = money - 1000 WHERE name = '张三';
UPDATE account SET money = money + 1000 WHERE name = '李四';
COMMIT;
```

演示：手动开启事务后，在另一个窗口查询看不到更新（未提交）；执行 ROLLBACK 后数据恢复。

## P53 基础-事务-四大特性ACID

| 特性 | 含义 | 案例 |
|---|---|---|
| 原子性 Atomicity | 事务是不可分割的最小操作单元，要么全部成功，要么全部失败 | 转账两条 UPDATE 要么都生效要么都不生效 |
| 一致性 Consistency | 事务完成时，必须使所有数据都保持一致状态 | 转账前后两人存款总额不变 |
| 隔离性 Isolation | 数据库提供的隔离机制，保证事务在不受外部并发操作影响的独立环境下运行 | 两个转账事务互不干扰 |
| 持久性 Durability | 事务一旦提交或回滚，对数据的改变就是永久的 | 提交后宕机，重启数据仍在 |

- 案例：仍用转账说明四个特性。

## P54 基础-事务-并发事务问题

| 问题 | 现象 | 案例 |
|---|---|---|
| 脏读 | 读到另一事务未提交的数据 | 事务 B 读到事务 A 尚未提交的转账结果，A 回滚后 B 读到的就是脏数据 |
| 不可重复读 | 同一事务两次读同一行结果不同 | 事务 A 两次查张三余额，中间事务 B 提交了更新 |
| 幻读 | 同一事务两次查「行数」不同 | 事务 A 按条件查 3 行，事务 B 插入 1 行并提交，A 再查变 4 行 |

## P55 基础-事务-并发事务演示及隔离级别

| 隔离级别 | 脏读 | 不可重复读 | 幻读 |
|---|---|---|---|
| READ UNCOMMITTED | 可能 | 可能 | 可能 |
| READ COMMITTED | 不可能 | 可能 | 可能 |
| REPEATABLE READ（MySQL 默认） | 不可能 | 不可能 | 可能（InnoDB 用间隙锁基本解决） |
| SERIALIZABLE | 不可能 | 不可能 | 不可能 |

演示（开两个命令行窗口，逐步切换隔离级别观察）：

> 模板：`SET [SESSION|GLOBAL] TRANSACTION ISOLATION LEVEL 级别; ｜ SELECT @@TRANSACTION_ISOLATION;`

```sql
-- 查看当前隔离级别
SELECT @@TRANSACTION_ISOLATION;

-- 设置隔离级别
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;   -- MySQL 默认
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

- 演示脏读：`READ UNCOMMITTED` 下，A 未提交，B 能读到 A 的更新；切到 `READ COMMITTED` 后读不到。
- 演示不可重复读：`READ COMMITTED` 下同一事务两次查询结果不同；切到 `REPEATABLE READ` 后一致。
- 演示幻读：`REPEATABLE READ` 下快照读结果一致，`SELECT ... FOR UPDATE`（当前读）仍可能看到新插入的行。

## P56 基础-事务-小结

| 要点 | 内容 |
|---|---|
| ACID | 原子性、一致性、隔离性、持久性 |
| 并发问题 | 脏读、不可重复读、幻读 |
| 隔离级别 | READ UNCOMMITTED / READ COMMITTED / REPEATABLE READ（默认）/ SERIALIZABLE |
| 常用命令 | `START TRANSACTION`、`COMMIT`、`ROLLBACK`、`SET @@autocommit` |

- 案例：给出业务场景（如秒杀扣库存）判断该用哪种隔离级别。

## P57 基础篇总结

- 全篇回看：建库建表 → 增删改查 → 函数约束 → 多表查询 → 事务；
- 案例：独立完成「部门-员工-工资等级」数据库的建表、初始化数据与十道综合查询。

---

# 进阶篇 P58–P152

## P58 进阶-课程介绍（进阶 01）

- 内容：存储引擎、索引、SQL 优化、视图、存储过程、触发器、锁、InnoDB 架构、MVCC、MySQL 管理。

## P59 进阶-存储引擎-MySQL体系结构（进阶 02）

| 层次 | 主要组件 | 职责 |
|---|---|---|
| 连接层 | 连接池、认证 | 处理客户端连接、权限校验 |
| 服务层 | SQL 接口、解析器、优化器、缓存 | 解析、优化、执行 SQL |
| 引擎层 | 可插拔存储引擎 | 数据的存取与事务、锁 |
| 存储层 | 文件系统 | 数据、日志落盘 |

- 案例：一条 SQL 从连接进入，经解析、优化，交给 InnoDB 执行，再从磁盘读页到 Buffer Pool 的完整路径。

## P60 进阶-存储引擎-简介（进阶 03）

| 引擎 | 特点 |
|---|---|---|
| InnoDB | 支持事务、外键、行级锁，MySQL 5.5 之后的默认引擎 |
| MyISAM | 不支持事务和外键，表级锁，访问速度快 |
| Memory | 数据存内存，hash 索引，重启后数据丢失 |

> 模板：`SHOW ENGINES; ｜ CREATE TABLE 表 (...) ENGINE = InnoDB|MyISAM|Memory;`

```sql
SHOW ENGINES;                    -- 查看支持的引擎及默认引擎
CREATE TABLE t (...) ENGINE = InnoDB;
```

- 案例：建三张同样的表分别用 InnoDB / MyISAM / Memory，观察数据目录下生成的文件差异（`.ibd` / `.myd+.myi` / 无文件）。

## P61 进阶-存储引擎-InnoDB介绍（进阶 04）

| 特性 | 说明 |
|---|---|---|
| 事务 | 支持 ACID |
| 外键 | 支持 |
| 锁 | 行级锁 |
| MVCC | 支持，读写互不阻塞 |
| 存储文件 | `xxx.ibd`（表结构 + 数据 + 索引） |

- 案例：`SHOW VARIABLES LIKE 'innodb_file_per_table';` 观察独立表空间配置。

## P62 进阶-存储引擎-MyISAM和Memory（进阶 05）

- MyISAM：不支持事务/外键，表级锁，`.myd` 数据 + `.myi` 索引，适合读多写少。
- Memory：数据在内存，hash 索引，重启丢失，适合临时表/缓存。
- 案例：Memory 表插入数据后重启 MySQL，数据消失；MyISAM 表测试并发写被表锁阻塞。

## P63 进阶-存储引擎-选择（进阶 06）

| 场景 | 推荐引擎 | 理由 |
|---|---|---|
| 订单、账户等业务表 | InnoDB | 需要事务与行锁 |
| 日志统计、只读报表 | MyISAM | 无事务需求、查询快 |
| 临时中间结果、缓存 | Memory | 内存级速度，允许丢失 |

- 案例：给出「电商订单表」「日志统计表」「会话临时表」三个场景选引擎。

## P64 进阶-存储引擎-小结（进阶 07）

| 特性 | InnoDB | MyISAM | Memory |
|---|---|---|---|
| 事务安全 | 支持 | 不支持 | 不支持 |
| 锁机制 | 行锁 | 表锁 | 表锁 |
| 外键 | 支持 | 不支持 | 不支持 |
| 存储文件 | `xxx.ibd` | `xxx.MYD` / `xxx.MYI` | `xxx.sdi` |
| 适用场景 | 事务、并发写 | 读多写少 | 临时数据、缓存 |

## P65 进阶-MySQL安装(linux版本)（进阶 08）

- CentOS 上安装 MySQL 8.0：卸载 mariadb → 上传解压 → 创建 mysql 用户 → 初始化 `mysqld --initialize` → 配置 `my.cnf` → 启动 → 修改临时密码。
- 案例：拿到 `grep 'temporary password' /var/log/mysqld.log` 的临时密码登录并改密。

## P66 进阶-索引-概述（进阶 09）

| 维度 | 说明 |
|---|---|
| 优势 | 提高检索效率、降低 IO 成本；借助索引列排序，降低排序成本 |
| 劣势 | 占用磁盘空间；降低 INSERT / UPDATE / DELETE 的速度 |
| 本质 | 排好序的数据结构（InnoDB 为 B+ 树） |

- 索引是帮助 MySQL 高效获取数据的数据结构（B+ 树）。
- 案例：`tb_sku` 表（千万级数据）：
  ```sql
  SELECT * FROM tb_sku WHERE sn = '100000003145001';   -- 无索引：约 20 秒
  CREATE INDEX idx_sku_sn ON tb_sku (sn);
  SELECT * FROM tb_sku WHERE sn = '100000003145001';   -- 有索引：毫秒级
  ```

## P67 进阶-索引-结构-介绍（进阶 10）

| 结构 | 特点 | 适用性 |
|---|---|---|
| 二叉树 / 红黑树 | 每个节点最多 2 个子节点，层级高 | 数据量大时 IO 次数多，不适合 |
| B 树 | 多路平衡，节点同时存 key 和 data | 范围查询需中序遍历，跨层 IO 多 |
| B+ 树 | 非叶子只存索引，叶子存数据并双向链表相连 | InnoDB 默认，范围查询和排序高效 |
| Hash | 等值查询 O(1) | 不支持范围和排序，Memory 引擎使用 |

- 讨论：为什么不用二叉树、红黑树、B 树？引出多路平衡 + 磁盘 IO 的权衡。
- 案例：同样 1000 万数据，二叉树高度 ~24 层、B+ 树 3–4 层，对比 IO 次数。

## P68 进阶-索引-结构-Btree（进阶 11）

- B 树：每个节点存 key + data，多路平衡；范围查询需要中序遍历，跨层 IO 多。
- 案例：画出 5 阶 B 树插入 1–20 的过程，观察节点分裂。

## P69 进阶-索引-结构-B+tree（进阶 12）

- 非叶子节点只存索引，叶子节点存数据并用双向链表连接；
- 优势：树更矮、范围查询和排序高效。
- 案例：`WHERE id BETWEEN 10 AND 100` 在 B+ 树上沿叶子链表顺序扫描。

## P70 进阶-索引-结构-hash（进阶 13）

- Hash 索引：等值查询 O(1)，不支持范围查询、排序、模糊匹配；Memory 引擎使用，InnoDB 支持自适应 hash。
- 案例：`SELECT * FROM t WHERE id = 1`（hash 快）vs `WHERE id > 1`（hash 无能为力）。

## P71 进阶-索引-结构-思考题（进阶 14）

- 思考：为什么 InnoDB 选择 B+ 树？为什么主键建议自增？
- 案例：`BIGINT` 主键与 `VARCHAR(36)` UUID 主键在同一数据量下的树高与页数对比。

## P72 进阶-索引-分类（进阶 15）

| 分类维度 | 类型 | 说明 |
|---|---|---|
| 数据结构 | B+Tree、Hash、Full-text | 默认 B+Tree |
| 存储形式 | 聚簇索引、二级索引 | 聚簇索引叶子存整行；二级索引叶子存主键值 |
| 字段个数 | 单列索引、联合索引 | 联合索引遵循最左前缀法则 |

- 案例：`SELECT * FROM tb_user WHERE name = 'Arm';` 走二级索引 → 拿到主键 → 回表取整行。

## P73 进阶-索引-思考题（进阶 16）

- 思考：一张表能有多少个聚簇索引？二级索引存什么？为什么二级索引查询要回表？
- 案例：`EXPLAIN` 对比主键查询与二级索引查询的 `Extra` 列。

## P74 进阶-索引-语法（进阶 17）

> 模板：`CREATE [UNIQUE|FULLTEXT] INDEX 索引名 ON 表 (列[(前缀长度)] [ASC|DESC], ...); ｜ DROP INDEX 索引名 ON 表;`

```sql
-- 1. name 可重复 → 普通索引
CREATE INDEX idx_user_name ON tb_user (name);
-- 2. phone 非空唯一 → 唯一索引
CREATE UNIQUE INDEX idx_user_phone ON tb_user (phone);
-- 3. profession、age、status 联合索引
CREATE INDEX idx_user_pro_age_sta ON tb_user (profession, age, status);
-- 4. email 建索引
CREATE INDEX idx_user_email ON tb_user (email);

SHOW INDEX FROM tb_user;
DROP INDEX idx_user_email ON tb_user;
```

## P75 进阶-索引-性能分析-查看执行频次（进阶 18）

> 模板：`SHOW [GLOBAL|SESSION] STATUS LIKE 'Com_______';  -- 统计各类 SQL 执行次数`

```sql
SHOW [GLOBAL|SESSION] STATUS LIKE 'Com_______';   -- Com_select/insert/update/delete
```

- 案例：读多写少的库应重点优化 SELECT；观察 `Com_select` 远大于 `Com_insert` 判断以读为主。

## P76 进阶-索引-性能分析-慢查询日志（进阶 19）

> 模板：`[mysqld] slow_query_log = 1 ｜ long_query_time = 秒 ｜ slow_query_log_file = 路径`

```ini
# my.cnf
slow_query_log = 1
long_query_time = 2
slow_query_log_file = /var/lib/mysql/slow.log
```

> 模板：`SHOW VARIABLES LIKE 'slow_query_log%'; ｜ SET GLOBAL slow_query_log = 1; ｜ SET GLOBAL long_query_time = 秒;`

```sql
SHOW VARIABLES LIKE 'slow_query_log%';
SHOW VARIABLES LIKE 'long_query_time';
SET GLOBAL slow_query_log = 1;
SET GLOBAL long_query_time = 2;
```

- 案例：`SELECT * FROM tb_sku WHERE sn = '100000003145008';` 记录进慢日志，用 `mysqldumpslow` 分析。

## P77 进阶-索引-性能分析-show profiles（进阶 20）

> 模板：`SET profiling = 1; ｜ SHOW PROFILES; ｜ SHOW PROFILE [CPU] FOR QUERY 查询ID;`

```sql
SELECT @@have_profiling;
SET profiling = 1;
SHOW PROFILES;
SHOW PROFILE FOR QUERY 1;
SHOW PROFILE CPU FOR QUERY 1;
```

- 案例：对比同一查询加索引前后的 `Duration` 与各阶段耗时。

## P78 进阶-索引-性能分析-explain（进阶 21）

> 模板：`EXPLAIN SELECT ...;  -- 关注 type / key / key_len / rows / Extra`

```sql
EXPLAIN SELECT * FROM tb_user WHERE id = 1;
```

重点列案例：

| 场景 | type | Extra |
|---|---|---|
| 主键等值 | `const` | NULL |
| 唯一索引等值 | `const` | NULL |
| 普通索引等值 | `ref` | NULL |
| 范围查询 | `range` | Using index condition |
| 全表扫描 | `ALL` | Using where |

- 案例：`EXPLAIN SELECT * FROM tb_user WHERE profession = '软件工程' AND age = 31 AND status = '0';` 观察 `key_len` 判断用到了联合索引的几列。

## P79 进阶-索引-使用规则-验证索引效率（进阶 22）

> 模板：`SELECT ... FROM 表 WHERE 索引列 = 值;  -- 对比建索引前后的耗时`

```sql
-- 未建索引
SELECT * FROM tb_sku WHERE sn = '100000003145001';   -- 20s
-- 建索引后再查
CREATE INDEX idx_sku_sn ON tb_sku (sn);
SELECT * FROM tb_sku WHERE sn = '100000003145001';   -- 0.01s
```

## P80 进阶-索引-使用规则-最左前缀法则（进阶 23）

联合索引 `idx_user_pro_age_sta (profession, age, status)`：

> 模板：`SELECT * FROM 表 WHERE 联合索引第1列 = 值 [AND 第2列 = 值 [AND 第3列 = 值]];  -- 不能跳过最左列`

```sql
-- 走全部 3 列
SELECT * FROM tb_user WHERE profession = '软件工程' AND age = 31 AND status = '0';
-- 走前 2 列
SELECT * FROM tb_user WHERE profession = '软件工程' AND age = 31;
-- 只走第 1 列
SELECT * FROM tb_user WHERE profession = '软件工程';
-- 跳过 profession，age/status 失效
SELECT * FROM tb_user WHERE age = 31 AND status = '0';
-- 只有 status，失效
SELECT * FROM tb_user WHERE status = '0';
-- 顺序打乱不影响（优化器会调整），但不能缺最左列
SELECT * FROM tb_user WHERE age = 31 AND profession = '软件工程';
```

## P81 进阶-索引-使用规则-索引失效情况一（进阶 24）

| 失效场景 | 示例 | 原因 |
|---|---|---|
| 范围查询后的列 | `WHERE a = 1 AND b > 2 AND c = 3` | 范围条件右侧的索引列无法继续定位 |
| 索引列参与运算 | `WHERE id + 1 = 10` | 索引存的是列的原值 |
| 索引列使用函数 | `WHERE SUBSTRING(phone, 10, 2) = '15'` | 同上，需逐行计算 |
| 字符串不加引号 | `WHERE phone = 17799990015` | 隐式类型转换相当于对列做函数 |
| 头部模糊匹配 | `WHERE name LIKE '%工程'` | 无法利用索引的有序前缀 |

> 模板：`反例：WHERE 函数(索引列) = 值 ｜ 字符串索引列 = 数字 ｜ 索引列 LIKE '%关键词'`

```sql
-- 1. 范围查询（>, <）右侧的列失效：age 走了范围，status 无法用索引
SELECT * FROM tb_user WHERE profession = '软件工程' AND age > 30 AND status = '0';
-- 用 >= 且带等号可保留后续列？—— 课程结论：范围查询右侧列失效，尽量把范围条件放最后

-- 2. 索引列上做运算 / 函数：失效
SELECT * FROM tb_user WHERE SUBSTRING(phone, 10, 2) = '15';
SELECT * FROM tb_user WHERE id + 1 = 10;

-- 3. 字符串不加引号：隐式类型转换，失效
SELECT * FROM tb_user WHERE phone = 17799990015;

-- 4. 头部模糊匹配：失效
SELECT * FROM tb_user WHERE profession LIKE '软件%';   -- 有效
SELECT * FROM tb_user WHERE profession LIKE '%工程';   -- 失效
SELECT * FROM tb_user WHERE profession LIKE '%工%';    -- 失效
```

## P82 进阶-索引-使用规则-索引失效情况二（进阶 25）

| 失效场景 | 示例 | 说明 |
|---|---|---|
| OR 连接无索引列 | `WHERE id = 10 OR age = 23` | OR 两侧都要能走索引 |
| 数据分布影响 | `WHERE gender = '1'`（几乎全表） | 优化器判断全表扫描更快 |

> 模板：`反例：WHERE 索引列 = 值 OR 无索引列 = 值  -- OR 两侧都要有索引`

```sql
-- 1. OR 连接的条件中有一侧没有索引 → 整体失效
SELECT * FROM tb_user WHERE id = 10 OR age = 23;
-- 给 age 建索引后恢复
CREATE INDEX idx_user_age ON tb_user (age);

-- 2. 数据分布影响：MySQL 评估走索引比全表扫更慢时，主动不走索引
SELECT * FROM tb_user WHERE gender = '1';   -- 几乎全表，走全表扫描
SELECT * FROM tb_user WHERE gender = '2';   -- 少量，可能走索引
```

## P83 进阶-索引-使用规则-SQL提示（进阶 26）

> 模板：`SELECT ... FROM 表 USE|IGNORE|FORCE INDEX (索引名) WHERE 条件;`

```sql
-- 建议使用指定索引
SELECT * FROM tb_user USE INDEX (idx_user_pro_age_sta) WHERE profession = '软件工程';
-- 忽略某索引
SELECT * FROM tb_user IGNORE INDEX (idx_user_pro_age_sta) WHERE profession = '软件工程';
-- 强制使用
SELECT * FROM tb_user FORCE INDEX (idx_user_pro_age_sta) WHERE profession = '软件工程';
```

- 案例：优化器选错索引导致慢查询，用 `FORCE INDEX` 纠正并用 `EXPLAIN` 验证。

## P84 进阶-索引-使用规则-覆盖索引&回表查询（进阶 27）

> 模板：`SELECT 索引覆盖的列 FROM 表 WHERE 索引条件;  -- Extra = Using index，无需回表`

```sql
-- 需要回表：SELECT * 要取整行
SELECT * FROM tb_user WHERE profession = '软件工程' AND age = 31 AND status = '0';
-- 覆盖索引：查询列全部在联合索引中，Extra = Using index，无需回表
SELECT id, profession, age, status
FROM tb_user
WHERE profession = '软件工程' AND age = 31 AND status = '0';

-- 案例：为 name、gender 建联合索引，让这条查询变成覆盖索引
CREATE INDEX idx_user_name_gender ON tb_user (name, gender);
SELECT id, name, gender FROM tb_user WHERE name = 'Arm';
```

## P85 进阶-索引-使用规则-前缀索引（进阶 28）

> 模板：`CREATE INDEX 索引名 ON 表 (列(前缀长度));  -- 长字符串用前缀索引`

```sql
-- email 很长，取前 5 位建前缀索引
CREATE INDEX idx_email_pre ON tb_user (email(5));
-- 选择性 = 不重复索引值数 / 总行数，越接近 1 越好
SELECT COUNT(DISTINCT SUBSTRING(email, 1, 5)) / COUNT(*) FROM tb_user;
```

- 案例：对比 `email` 全字段索引与前缀索引的索引大小、查询效率、区分度。

## P86 进阶-索引-使用规则-单列&联合索引（进阶 29）

> 模板：`CREATE INDEX 索引名 ON 表 (列1, 列2);  -- 多条件等值查询优先联合索引`

```sql
-- 已有 phone 单列索引和 profession 单列索引
SELECT * FROM tb_user WHERE phone = '17799990010' AND profession = '软件工程';
-- EXPLAIN 只会选其中一个 → 另一个条件回表过滤
-- 建联合索引后一次命中
CREATE INDEX idx_user_phone_pro ON tb_user (phone, profession);
```

## P87 进阶-索引-设计原则（进阶 30）

| 原则 | 说明 |
|---|---|---|
| 数据量 | 数据量大且查询频繁的表才建索引 |
| 查询字段 | 常作为 WHERE、ORDER BY、GROUP BY 条件的字段建索引 |
| 区分度 | 区分度高的列优先，尽量建联合索引 |
| 长字符串 | 用前缀索引，节省空间 |
| 空值 | 索引列尽量 NOT NULL |
| 数量 | 控制索引数量，避免拖慢写入 |
| 覆盖 | 用覆盖索引减少回表 |

- 案例：给 `tb_user` 的查询需求逐条设计索引并写出理由。

## P88 进阶-索引-小结（进阶 31）

| 环节 | 关键内容 |
|---|---|
| 结构 | B+Tree（默认）、Hash |
| 分类 | 聚簇 / 二级、单列 / 联合 |
| 语法 | `CREATE INDEX`、`DROP INDEX`、`SHOW INDEX` |
| 分析 | 执行频次、慢查询日志、show profiles、`EXPLAIN` |
| 使用规则 | 最左前缀、避免失效、SQL 提示、覆盖索引、前缀索引 |
| 设计原则 | 高频查询字段、区分度高、控制数量、尽量 NOT NULL |

## P89 进阶-SQL优化-插入数据（进阶 32）

> 模板：`INSERT INTO 表 VALUES (...),(...); ｜ START TRANSACTION ... COMMIT; ｜ LOAD DATA LOCAL INFILE '文件' INTO TABLE 表 ...;`

```sql
-- 1. 批量插入，每批 500–1000 条
INSERT INTO tb_user VALUES (1,'a'), (2,'b'), ...;

-- 2. 手动控制事务
START TRANSACTION;
INSERT INTO tb_user VALUES (...);
COMMIT;

-- 3. 主键顺序插入（避免页分裂）
-- 4. 大批量数据用 load
LOAD DATA LOCAL INFILE '/root/sql1.log'
INTO TABLE tb_user
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';
```

- 案例：100 万条数据分别用「单条插入 / 批量插入 / 手动事务 / load」对比耗时。

## P90 进阶-SQL优化-主键优化（进阶 33）

- 页分裂：乱序插入导致页频繁分裂、产生碎片；页合并：删除后相邻页合并。
- 案例：`AUTO_INCREMENT` 顺序插入 vs UUID 随机主键，观察 `SHOW ENGINE INNODB STATUS` 中页分裂次数与表空间大小。
- 主键设计建议：尽量短、顺序插入、避免修改主键。

## P91 进阶-SQL优化-order by优化（进阶 34）

> 模板：`SELECT 列 FROM 表 ORDER BY 索引列 [ASC|DESC];  -- 目标：Extra 出现 Using index 而非 Using filesort`

```sql
-- Using filesort：需要额外排序
SELECT * FROM tb_user ORDER BY age;
-- Using index：索引本身有序，无需额外排序
CREATE INDEX idx_user_age ON tb_user (age);
SELECT id, age FROM tb_user ORDER BY age;

-- 多字段排序：需要联合索引且顺序一致
CREATE INDEX idx_user_age_phone ON tb_user (age, phone);
SELECT * FROM tb_user ORDER BY age ASC, phone DESC;
```

- 案例：单字段排序 + 覆盖索引消除 `filesort`；多字段排序要求索引顺序与排序方向匹配。

## P92 进阶-SQL优化-group by优化（进阶 35）

> 模板：`SELECT 分组列, COUNT(*) FROM 表 GROUP BY 分组列;  -- 分组字段建索引，避免 Using temporary`

```sql
-- 无索引：Using temporary + Using filesort
SELECT profession, COUNT(*) FROM tb_user GROUP BY profession;
-- 建索引后：Using index
CREATE INDEX idx_user_pro ON tb_user (profession);
```

- 案例：分组字段顺序要与联合索引一致，否则仍会临时表。

## P93 进阶-SQL优化-limit优化（进阶 36）

> 模板：`SELECT * FROM 表 t, (SELECT 主键 FROM 表 ORDER BY 主键 LIMIT 偏移, 条数) a WHERE t.主键 = a.主键;`

```sql
-- 大偏移量：扫描 200 万行后丢弃，慢
SELECT * FROM tb_sku LIMIT 2000000, 10;
-- 优化：覆盖索引 + 关联
SELECT s.* FROM tb_sku s,
     (SELECT id FROM tb_sku ORDER BY id LIMIT 2000000, 10) a
WHERE s.id = a.id;
```

## P94 进阶-SQL优化-count优化（进阶 37）

> 模板：`SELECT COUNT(*)|COUNT(1)|COUNT(列) FROM 表;  -- 优先级：COUNT(*) ≈ COUNT(1) > COUNT(主键) > COUNT(字段)`

```sql
SELECT COUNT(*) FROM tb_user;      -- InnoDB 做了优化，推荐
SELECT COUNT(1) FROM tb_user;
SELECT COUNT(id) FROM tb_user;
SELECT COUNT(name) FROM tb_user;   -- 字段可能为 NULL，不计数，且需读字段
```

- 案例：百万行表分别测四种 count 的耗时；结论 `COUNT(*) ≈ COUNT(1) > COUNT(主键) > COUNT(字段)`。

## P95 进阶-SQL优化-update优化（进阶 38）

> 模板：`UPDATE 表 SET 列 = 值 WHERE 索引列 = 值;  -- 无索引条件会升级为表锁`

```sql
-- 按索引字段更新：行锁
UPDATE tb_user SET name = 'A' WHERE id = 1;
-- 按非索引字段更新：行锁升级为表锁，阻塞其他行
UPDATE tb_user SET name = 'B' WHERE name = '张三';
```

- 案例：两个会话同时按 `name` 更新不同行，观察互相阻塞；给 `name` 建索引后并发正常。

## P96 进阶-SQL优化-小结（进阶 39）

| 优化项 | 手段 |
|---|---|
| 插入数据 | 批量插入、手动事务、主键顺序插入、`LOAD DATA` |
| 主键 | 尽量短、自增顺序插入，避免 UUID |
| ORDER BY | 利用索引有序，消除 `Using filesort` |
| GROUP BY | 分组字段建索引，消除 `Using temporary` |
| LIMIT | 覆盖索引 + 子查询解决大偏移 |
| COUNT | 优先 `COUNT(*)`，尽量走二级索引 |
| UPDATE | 按索引字段更新，避免行锁升级为表锁 |

## P97 进阶-视图-介绍及基本语法（进阶 40）

> 模板：`CREATE [OR REPLACE] VIEW 视图名 AS SELECT ... [WITH [CASCADED|LOCAL] CHECK OPTION]; ｜ DROP VIEW [IF EXISTS] 视图名;`

```sql
CREATE VIEW emp_v1 AS
SELECT id, name, job, entrydate FROM emp;

CREATE OR REPLACE VIEW emp_v1 AS
SELECT id, name, job, entrydate, salary FROM emp;

ALTER VIEW emp_v1 AS SELECT id, name FROM emp;

SHOW CREATE VIEW emp_v1;
DROP VIEW IF EXISTS emp_v1;
```

- 案例：视图只存定义不存数据，修改基表后查询视图立即反映。

## P98 进阶-视图-检查选项(cascaded)（进阶 41）

> 模板：`CREATE VIEW 视图名 AS SELECT ... WHERE 条件 WITH CASCADED CHECK OPTION;`

```sql
CREATE OR REPLACE VIEW stu_v_1 AS
SELECT id, name FROM student WHERE id <= 10
WITH CASCADED CHECK OPTION;

INSERT INTO stu_v_1 VALUES (6, 'Tom');     -- 成功
INSERT INTO stu_v_1 VALUES (17, 'Tom22');  -- 失败：不满足 id <= 10
```

- 案例：两个有依赖关系的视图，`CASCADED` 会检查所有视图条件。

## P99 进阶-视图-检查选项(local)（进阶 42）

> 模板：`CREATE VIEW 视图名 AS SELECT ... WHERE 条件 WITH LOCAL CHECK OPTION;`

```sql
CREATE OR REPLACE VIEW stu_v_2 AS
SELECT id, name FROM stu_v_1 WHERE id >= 10
WITH LOCAL CHECK OPTION;
```

- 案例：`LOCAL` 只检查当前视图条件，插入 id=17 时通过（因为 stu_v_2 条件 id>=10 满足）。

## P100 进阶-视图-更新及作用（进阶 43）

| 视图情况 | 可否更新 | 原因 |
|---|---|---|
| 与基表行一一对应 | 可以 | 能定位到具体基表行 |
| 含聚合函数、GROUP BY | 不可以 | 一行无法映射到基表行 |
| 含 DISTINCT、UNION | 不可以 | 结果不唯一或来自多表 |
| FROM 中含子查询 | 一般不可以 | 无法确定更新目标 |

作用：简化复杂查询、控制数据访问、数据脱敏。

> 模板：`UPDATE 视图名 SET 列 = 值 WHERE 条件;  -- 视图须与基表行一一对应`

```sql
UPDATE stu_v_1 SET name = 'Tom2' WHERE id = 6;
```

## P101 进阶-视图-案例（进阶 44）

**案例 1**：屏蔽敏感字段——开发只能看到 `tb_user` 的基本字段：

> 模板：`CREATE VIEW 视图名 AS SELECT 需要暴露的列 FROM 表 [WHERE 条件];`

```sql
CREATE VIEW tb_user_view AS
SELECT id, name, profession, age, gender, status, createtime FROM tb_user;
```

**案例 2**：三表联查封装成视图——查询每个学生选的课程：

> 模板：`CREATE VIEW 视图名 AS SELECT ... FROM 表1, 表2, 表3 WHERE 表1.列 = 表2.列 AND 表2.列 = 表3.列;`

```sql
CREATE VIEW tb_stu_course_view AS
SELECT s.name AS student_name, s.no AS student_no, c.name AS course_name
FROM student s, student_course sc, course c
WHERE s.id = sc.studentid AND c.id = sc.courseid;
```

## P102 进阶-存储过程-介绍（进阶 45）

| 特点 | 说明 |
|---|---|
| 封装复用 | SQL 集合保存在数据库中，可重复调用 |
| 减少网络交互 | 一次 `CALL` 执行多条 SQL |
| 可传参 | 支持 IN / OUT / INOUT |
| 缺点 | 调试困难、可移植性差、版本管理不便 |

- 案例：把「统计学生总数 + 查询最高分」两条 SQL 封装成一个过程 `p1`，一次 `CALL` 完成。

## P103 进阶-存储过程-基本语法（进阶 46）

> 模板：`DELIMITER $$ CREATE PROCEDURE 过程名([参数列表]) BEGIN SQL 语句; END$$ DELIMITER ; ｜ CALL 过程名(参数); ｜ DROP PROCEDURE 过程名;`

```sql
DELIMITER $$
CREATE PROCEDURE p1()
BEGIN
  SELECT COUNT(*) FROM student;
END$$
DELIMITER ;

CALL p1();
DROP PROCEDURE IF EXISTS p1;
```

- 案例：`DELIMITER $$` 的作用是避免过程体内的分号提前结束语句。

## P104 进阶-存储过程-变量-系统变量（进阶 47）

| 变量类型 | 作用域 | 定义 / 引用方式 |
|---|---|---|
| 系统变量 | GLOBAL（全局）/ SESSION（会话） | `@@global.变量名`、`@@session.变量名` |
| 用户定义变量 | 当前会话 | `@变量名` |
| 局部变量 | 存储过程 `BEGIN…END` 内 | `DECLARE 变量名 类型 [DEFAULT 值]` |

> 模板：`SELECT @@[GLOBAL|SESSION.]变量名; ｜ SET [GLOBAL|SESSION] 变量名 = 值;`

```sql
SHOW [GLOBAL|SESSION] VARIABLES LIKE 'autocommit';
SELECT @@autocommit;
SELECT @@session.autocommit;
SELECT @@global.autocommit;
SET @@session.autocommit = 0;
SET GLOBAL autocommit = 1;
```

## P105 进阶-存储过程-变量-用户定义变量（进阶 48）

> 模板：`SET @变量名 = 值; ｜ SELECT @变量名; ｜ SELECT ... INTO @变量名 FROM 表;`

```sql
SET @myname = 'itcast';
SET @myage := 10;
SELECT @myname, @myage;

SELECT COUNT(*) INTO @count FROM student;
SELECT @count;
```

- 案例：用户变量会话级有效，断开连接即失效。

## P106 进阶-存储过程-变量-局部变量（进阶 49）

> 模板：`DECLARE 变量名 类型 [DEFAULT 值];  -- 必须在 BEGIN 内首部声明`

```sql
CREATE PROCEDURE p2()
BEGIN
  DECLARE stu_count INT DEFAULT 0;
  SELECT COUNT(*) INTO stu_count FROM student;
  SELECT stu_count;
END;
```

- 案例：局部变量只在 `BEGIN...END` 内有效，且必须在块首声明。

## P107 进阶-存储过程-if判断（进阶 50）

**案例**：根据分数变量判定等级。

> 模板：`IF 条件 THEN ... ELSEIF 条件 THEN ... ELSE ... END IF;`

```sql
CREATE PROCEDURE p3()
BEGIN
  DECLARE score INT DEFAULT 58;
  DECLARE result VARCHAR(10);
  IF score >= 85 THEN
    SET result := '优秀';
  ELSEIF score >= 60 THEN
    SET result := '及格';
  ELSE
    SET result := '不及格';
  END IF;
  SELECT result;
END;
```

## P108 进阶-存储过程-参数(IN,OUT,INOUT)（进阶 51）

| 参数类型 | 含义 | 示例 |
|---|---|---|
| IN | 入参，调用时传入 | `CALL p4(80, @result)` |
| OUT | 出参，过程内赋值后返回 | `OUT result VARCHAR(10)` |
| INOUT | 既传入又返回 | `INOUT score DOUBLE` |

> 模板：`CREATE PROCEDURE 名(IN 入参 类型, OUT 出参 类型, INOUT 双向 类型) BEGIN ... END; ｜ CALL 名(值, @变量, @变量);`

```sql
-- 1. 带 IN 参数、OUT 返回
CREATE PROCEDURE p4(IN score INT, OUT result VARCHAR(10))
BEGIN
  IF score >= 85 THEN SET result := '优秀';
  ELSEIF score >= 60 THEN SET result := '及格';
  ELSE SET result := '不及格';
  END IF;
END;

SET @result := '';
CALL p4(68, @result);
SELECT @result;

-- 2. INOUT：200 分制换算为百分制
CREATE PROCEDURE p5(INOUT score DOUBLE)
BEGIN
  SET score := score * 0.5;
END;

SET @score := 198;
CALL p5(@score);
SELECT @score;
```

## P109 进阶-存储过程-case（进阶 52）

**案例**：根据传入月份判定季度。

> 模板：`CASE [表达式] WHEN 值 THEN 结果 ... [ELSE 结果] END CASE;`

```sql
CREATE PROCEDURE p6(IN month INT)
BEGIN
  DECLARE result VARCHAR(10);
  CASE
    WHEN month >= 1 AND month <= 3 THEN SET result := '第一季度';
    WHEN month >= 4 AND month <= 6 THEN SET result := '第二季度';
    WHEN month >= 7 AND month <= 9 THEN SET result := '第三季度';
    WHEN month >= 10 AND month <= 12 THEN SET result := '第四季度';
    ELSE SET result := '非法参数';
  END CASE;
  SELECT CONCAT('您输入的月份为: ', month, ', 所属的季度为: ', result);
END;

CALL p6(11);
```

## P110 进阶-存储过程-循环-while（进阶 53）

**案例**：计算 1 累加到 n。

> 模板：`WHILE 条件 DO ... END WHILE;`

```sql
CREATE PROCEDURE p7(IN n INT)
BEGIN
  DECLARE total INT DEFAULT 0;
  WHILE n > 0 DO
    SET total := total + n;
    SET n := n - 1;
  END WHILE;
  SELECT total;
END;

CALL p7(100);
```

## P111 进阶-存储过程-循环-repeat（进阶 54）

**案例**：同样计算 1 累加到 n，用 `REPEAT`（先执行后判断）。

> 模板：`REPEAT ... UNTIL 条件 END REPEAT;  -- 至少执行一次`

```sql
CREATE PROCEDURE p8(IN n INT)
BEGIN
  DECLARE total INT DEFAULT 0;
  REPEAT
    SET total := total + n;
    SET n := n - 1;
    UNTIL n <= 0
  END REPEAT;
  SELECT total;
END;
```

## P112 进阶-存储过程-循环-loop（进阶 55）

| 循环 | 语法结构 | 特点 |
|---|---|---|
| WHILE | `WHILE 条件 DO ... END WHILE;` | 先判断后执行 |
| REPEAT | `REPEAT ... UNTIL 条件 END REPEAT;` | 先执行后判断，至少执行一次 |
| LOOP | `标签: LOOP ... LEAVE 标签; END LOOP 标签;` | 需配合 LEAVE 退出 |

**案例**：同样需求，用 `LOOP` + `LEAVE`。

> 模板：`标签: LOOP ... LEAVE 标签; END LOOP 标签;`

```sql
CREATE PROCEDURE p9(IN n INT)
BEGIN
  DECLARE total INT DEFAULT 0;
  sum: LOOP
    IF n <= 0 THEN
      LEAVE sum;
    END IF;
    SET total := total + n;
    SET n := n - 1;
  END LOOP sum;
  SELECT total;
END;
```

## P113 进阶-存储过程-游标-cursor（进阶 56）

**案例**：根据传入年龄 `uage`，把 `tb_user` 中年龄 ≤ uage 的姓名、专业插入新表 `tb_user_pro(id, name, profession)`。

> 模板：`DECLARE 游标 CURSOR FOR SELECT ...; ｜ OPEN 游标; FETCH 游标 INTO 变量...; CLOSE 游标;`

```sql
CREATE TABLE tb_user_pro (
  id         INT PRIMARY KEY AUTO_INCREMENT,
  name       VARCHAR(36) NOT NULL,
  profession VARCHAR(20) NOT NULL
);

CREATE PROCEDURE p10(IN uage INT)
BEGIN
  DECLARE uname VARCHAR(36);
  DECLARE upro   VARCHAR(20);
  DECLARE u_cursor CURSOR FOR
    SELECT name, profession FROM tb_user WHERE age <= uage;
  DECLARE EXIT HANDLER FOR NOT FOUND CLOSE u_cursor;

  DROP TABLE IF EXISTS tb_user_pro;
  CREATE TABLE tb_user_pro (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(36) NOT NULL,
    profession VARCHAR(20) NOT NULL
  );

  OPEN u_cursor;
  WHILE TRUE DO
    FETCH u_cursor INTO uname, upro;
    INSERT INTO tb_user_pro (name, profession) VALUES (uname, upro);
  END WHILE;
  CLOSE u_cursor;
END;

CALL p10(40);
SELECT * FROM tb_user_pro;
```

## P114 进阶-存储过程-条件处理程序-handler（进阶 57）

| 处理类型 | 行为 | 常用条件 |
|---|---|---|
| CONTINUE | 捕获后继续执行后续语句 | `FOR SQLEXCEPTION` |
| EXIT | 捕获后终止当前 `BEGIN…END` | `FOR SQLSTATE '02000'`、`FOR NOT FOUND` |

> 模板：`DECLARE EXIT|CONTINUE HANDLER FOR NOT FOUND|SQLSTATE '02000'|SQLEXCEPTION 处理语句;`

```sql
-- 游标取完会报 02000 / NOT FOUND，用 handler 捕获并关闭游标
DECLARE EXIT HANDLER FOR SQLSTATE '02000' CLOSE u_cursor;
-- 或
DECLARE EXIT HANDLER FOR NOT FOUND CLOSE u_cursor;

-- 其他：捕获所有异常继续执行
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET @info = 'error';
```

- 案例：不加 handler 时调用 p10 报错，加上后正常结束。

## P115 进阶-存储函数（进阶 58）

| 对比项 | 存储函数 FUNCTION | 存储过程 PROCEDURE |
|---|---|---|
| 返回值 | 必须有且只有一个 | 可以没有，或通过 OUT 返回多个 |
| 调用方式 | 在 SQL 中直接调用 | `CALL` 调用 |
| 参数 | 只有 IN | IN / OUT / INOUT |
| 适用 | 计算并返回一个值 | 执行一段业务逻辑 |

> 模板：`CREATE FUNCTION 函数名(参数 类型) RETURNS 类型 [DETERMINISTIC] BEGIN ... RETURN 值; END;`

```sql
-- 计算 1 到 n 的累加和
CREATE FUNCTION fun1(n INT)
RETURNS INT DETERMINISTIC
BEGIN
  DECLARE total INT DEFAULT 0;
  WHILE n > 0 DO
    SET total := total + n;
    SET n := n - 1;
  END WHILE;
  RETURN total;
END;

SELECT fun1(50);
DROP FUNCTION IF EXISTS fun1;
```

- 案例：存储函数必须有返回值，且一般用于 SELECT 中；存储过程用 CALL 调用。

## P116 进阶-触发器-介绍（进阶 59）

| 触发时机 | 支持的事件 | OLD / NEW |
|---|---|---|
| BEFORE | INSERT / UPDATE / DELETE | INSERT 只有 NEW，DELETE 只有 OLD，UPDATE 两者都有 |
| AFTER | INSERT / UPDATE / DELETE | 同上 |

- 触发器：在 INSERT/UPDATE/DELETE 前后自动执行的逻辑；
- 案例：记录 `tb_user` 的增删改日志到 `user_logs` 表。

> 模板：`CREATE TABLE 日志表 (id INT AUTO_INCREMENT PRIMARY KEY, operation VARCHAR(20), operate_time DATETIME, operate_id INT, operate_params VARCHAR(500));`

```sql
CREATE TABLE user_logs (
  id             INT(11) NOT NULL AUTO_INCREMENT,
  operation      VARCHAR(20) NOT NULL COMMENT '操作类型 insert/update/delete',
  operate_time   DATETIME NOT NULL COMMENT '操作时间',
  operate_id     INT(11) NOT NULL COMMENT '操作的ID',
  operate_params VARCHAR(500) COMMENT '操作参数',
  PRIMARY KEY (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8;
```

## P117 进阶-触发器-案例1(insert类型)（进阶 60）

> 模板：`CREATE TRIGGER 触发器名 AFTER INSERT ON 表 FOR EACH ROW BEGIN INSERT INTO 日志表 (...) VALUES (..., NEW.字段, ...); END;`

```sql
CREATE TRIGGER tb_user_insert_trigger
AFTER INSERT ON tb_user FOR EACH ROW
BEGIN
  INSERT INTO user_logs (id, operation, operate_time, operate_id, operate_params)
  VALUES (NULL, 'insert', NOW(), NEW.id,
          CONCAT('插入的数据内容为: id=', NEW.id, ', name=', NEW.name,
                 ', phone=', NEW.phone, ', profession=', NEW.profession));
END;

INSERT INTO tb_user (id, username, password, name, gender, phone, profession, age, status, email, createtime)
VALUES (NULL, 'heima', '123456', '黑马', '1', '17799990020', '软件工程', 32, '0', 'heima@itcast.cn', NOW());
```

## P118 进阶-触发器-案例2(update类型)（进阶 61）

> 模板：`CREATE TRIGGER 触发器名 AFTER UPDATE ON 表 FOR EACH ROW BEGIN ... OLD.字段 / NEW.字段 ...; END;`

```sql
CREATE TRIGGER tb_user_update_trigger
AFTER UPDATE ON tb_user FOR EACH ROW
BEGIN
  INSERT INTO user_logs (id, operation, operate_time, operate_id, operate_params)
  VALUES (NULL, 'update', NOW(), NEW.id,
          CONCAT('更新之前的数据: id=', OLD.id, ', name=', OLD.name, ', phone=', OLD.phone,
                 ' | 更新之后的数据: id=', NEW.id, ', name=', NEW.name, ', phone=', NEW.phone));
END;

UPDATE tb_user SET profession = '会计' WHERE id = 23;
```

## P119 进阶-触发器-案例3(delete类型)（进阶 62）

> 模板：`CREATE TRIGGER 触发器名 AFTER DELETE ON 表 FOR EACH ROW BEGIN ... OLD.字段 ...; END;`

```sql
CREATE TRIGGER tb_user_delete_trigger
AFTER DELETE ON tb_user FOR EACH ROW
BEGIN
  INSERT INTO user_logs (id, operation, operate_time, operate_id, operate_params)
  VALUES (NULL, 'delete', NOW(), OLD.id,
          CONCAT('删除的数据内容为: id=', OLD.id, ', name=', OLD.name, ', phone=', OLD.phone));
END;

DELETE FROM tb_user WHERE id = 24;
SELECT * FROM user_logs;
```

## P120 进阶-视图&存储过程&触发器-小结（进阶 63）

| 对象 | 作用 | 注意事项 |
|---|---|---|
| 视图 | 封装查询、控制字段访问、数据脱敏 | 含聚合、DISTINCT、UNION 等时不可更新 |
| 存储过程 | 封装业务逻辑，可传参、可返回 | 调试困难，注意 `DELIMITER` 与参数方向 |
| 触发器 | 在增删改前后自动执行 | 隐式执行，排查成本高，避免复杂逻辑 |

- 案例：回顾三个案例的适用场景与副作用（触发器难调试）。

## P121 进阶-锁-介绍（进阶 64）

| 分类 | 说明 |
|---|---|
| 全局锁 | 锁定数据库中的所有表 |
| 表级锁 | 每次操作锁住整张表（表锁、元数据锁、意向锁） |
| 行级锁 | 每次操作锁住对应的行数据（行锁、间隙锁、临键锁） |

- 案例：同一张表，两个会话分别执行 `UPDATE ... WHERE id = 1` 和 `UPDATE ... WHERE id = 2`，观察是否互相阻塞，引出锁粒度。

## P122 进阶-锁-全局锁-介绍（进阶 65）

> 模板：`FLUSH TABLES WITH READ LOCK; ... UNLOCK TABLES;`

```sql
FLUSH TABLES WITH READ LOCK;   -- 加全局读锁，整个库只读
UNLOCK TABLES;
```

- 案例：加全局锁后，其他会话的 INSERT/UPDATE 全部阻塞，只能 SELECT。

## P123 进阶-锁-全局锁-一致性数据备份（进阶 66）

| 方式 | 命令 | 是否阻塞写入 | 说明 |
|---|---|---|---|
| 加全局锁 | `FLUSH TABLES WITH READ LOCK` + `mysqldump` | 阻塞 | 简单可靠，影响业务 |
| 单事务备份 | `mysqldump --single-transaction` | 不阻塞 | 基于 MVCC 快照，仅适用于 InnoDB |

> 模板：`mysqldump [--single-transaction] -u用户 -p 库名 > 备份.sql`

```bash
# 加锁备份（阻塞写入）
mysqldump -uroot -p1234 --all-databases > backup.sql
# InnoDB 推荐：一致性快照，不阻塞
mysqldump --single-transaction -uroot -p1234 itcast > itcast.sql
```

- 案例：`--single-transaction` 基于 MVCC 快照，备份期间仍可写入，备份结果一致。

## P124 进阶-锁-表级锁-表锁（进阶 67）

| 锁类型 | 持有会话可做 | 其他会话可做 |
|---|---|---|
| READ 读锁 | 读 | 读；写阻塞 |
| WRITE 写锁 | 读、写 | 读、写都阻塞 |

> 模板：`LOCK TABLES 表 READ|WRITE; ... UNLOCK TABLES;`

```sql
-- 读锁：本会话可读不可写，其他会话可读、写阻塞
LOCK TABLES tb_user READ;
SELECT * FROM tb_user;
INSERT INTO tb_user (...) VALUES (...);   -- 失败
UNLOCK TABLES;

-- 写锁：本会话可读可写，其他会话读写都阻塞
LOCK TABLES tb_user WRITE;
UNLOCK TABLES;
```

## P125 进阶-锁-表级锁-元数据锁（进阶 68）

| 锁类型 | 触发语句 | 效果 |
|---|---|---|
| MDL 读锁 | SELECT、DML | 与 MDL 写锁互斥，会阻塞 DDL |
| MDL 写锁 | ALTER、DROP 等 DDL | 阻塞后续的 DML |

- MDL 自动加：DML 加 MDL 读锁，DDL 加 MDL 写锁，读写互斥、写写互斥。
- 案例：会话 A 开启事务执行 `SELECT`（持有 MDL 读锁不释放），会话 B 执行 `ALTER TABLE` 被阻塞；A 提交后 B 才继续。

> 模板：`SHOW PROCESSLIST;  -- 观察 Waiting for table metadata lock`

```sql
SHOW PROCESSLIST;      -- 观察 Waiting for table metadata lock
```

## P126 进阶-锁-表级锁-意向锁（进阶 69）

| 意向锁 | 含义 | 加锁时机 |
|---|---|---|
| IS 意向共享锁 | 表中有行被加了共享锁 | 执行 `SELECT ... LOCK IN SHARE MODE` |
| IX 意向排他锁 | 表中有行被加了排他锁 | 执行 `UPDATE`、`DELETE`、`SELECT ... FOR UPDATE` |

- 意向共享锁 IS、意向排他锁 IX：加行锁前先给表加意向锁，用于快速判断表中是否有行锁。
- 兼容性：IS/IX 之间兼容，与表锁的读/写互斥。

## P127 进阶-锁-表级锁-意向锁-测试（进阶 70）

> 模板：`BEGIN; SELECT ... FOR UPDATE / LOCK IN SHARE MODE;  -- 配 performance_schema.data_locks 查看意向锁`

```sql
-- 会话 A：给某行加共享锁
BEGIN;
SELECT * FROM tb_user WHERE id = 1 LOCK IN SHARE MODE;  -- 表上出现 IS
-- 会话 B：尝试加表锁，被阻塞
LOCK TABLES tb_user READ;
```

- 案例：`SELECT * FROM performance_schema.data_locks;` 查看 IS/IX 锁记录。

## P128 进阶-锁-行级锁-介绍（进阶 71）

| 锁类型 | 说明 | 触发条件 |
|---|---|---|
| 行锁 Record Lock | 锁住单行记录 | 按索引等值更新 / 删除 |
| 间隙锁 Gap Lock | 锁住索引项之间的间隙 | 范围条件、记录不存在 |
| 临键锁 Next-Key Lock | 行锁 + 间隙锁，左开右闭 | RR 隔离级别默认 |

- InnoDB 行锁基于索引实现；无索引时退化为表锁。

## P129 进阶-锁-行级锁-行锁（进阶 72）

> 模板：`BEGIN; UPDATE 表 SET 列 = 值 WHERE 索引列 = 值;  -- 有索引=行锁，无索引=表锁`

```sql
-- 会话 A
BEGIN;
UPDATE tb_user SET name = 'A' WHERE id = 1;    -- 锁住 id=1 这一行
-- 会话 B：更新 id=2 不受影响；更新 id=1 阻塞
UPDATE tb_user SET name = 'B' WHERE id = 2;

-- 无索引字段更新 → 表锁
UPDATE tb_user SET name = 'C' WHERE name = '张三';   -- 锁全表
```

## P130 进阶-锁-行级锁-间隙锁&临键锁1（进阶 73）

- 间隙锁：锁住索引项之间的空隙，防止其他事务在间隙中插入（防幻读）。
- 临键锁 = 行锁 + 间隙锁，左开右闭区间；RR 隔离级别默认使用。

> 模板：`SELECT * FROM 表 WHERE 索引列 = 值 FOR UPDATE;  -- 锁住 (前一值, 后一值) 间隙`

```sql
-- 表中有 id = 1, 4, 7, 10
BEGIN;
SELECT * FROM tb_user WHERE id = 5 FOR UPDATE;   -- 锁住 (4, 7) 间隙
-- 其他会话插入 id = 6 被阻塞，插入 id = 2 视间隙范围而定
```

## P131 进阶-锁-行级锁-间隙锁&临键锁2（进阶 74）

> 模板：`SELECT ... FOR UPDATE;  -- 唯一索引等值且存在→行锁；不存在→间隙锁；范围查询→临键锁`

```sql
-- 唯一索引等值查询且记录存在 → 临键锁退化为行锁
SELECT * FROM tb_user WHERE id = 4 FOR UPDATE;
-- 记录不存在 → 间隙锁
SELECT * FROM tb_user WHERE id = 5 FOR UPDATE;
-- 非唯一索引/范围查询 → 临键锁
SELECT * FROM tb_user WHERE id > 4 FOR UPDATE;
-- 无索引 → 锁全表所有记录 + 间隙
```

- 案例：`data_locks` 表对比 `LOCK_MODE` 为 `X` / `X,GAP` / `X,REC_NOT_GAP` 的差异。

## P132 进阶-锁-小结（进阶 75）

| 锁 | 粒度 | 典型命令 / 触发方式 |
|---|---|---|
| 全局锁 | 整个库 | `FLUSH TABLES WITH READ LOCK;` |
| 表锁 | 整张表 | `LOCK TABLES 表 READ/WRITE;` |
| 元数据锁 | 表结构 | DML 加读锁、DDL 加写锁，自动加 |
| 意向锁 | 表级标记 | 加行锁时自动加 IS / IX |
| 行锁 | 单行 | `UPDATE ... WHERE 索引列 = 值` |
| 间隙锁 / 临键锁 | 索引区间 | 范围条件、RR 隔离级别默认 |

- 案例：给出三条更新语句，判断各自会加什么锁、是否会互相阻塞。

## P133 进阶-InnoDB引擎-逻辑存储结构（进阶 76）

| 层级 | 说明 | 大小 |
|---|---|---|
| 表空间 Tablespace | 最高逻辑单位，可包含多个段 | — |
| 段 Segment | 分为数据段、索引段、回滚段 | — |
| 区 Extent | 连续页的集合，分配空间的基本单位 | 1 MB = 64 页 |
| 页 Page | InnoDB 磁盘管理的最小单位 | 16 KB |
| 行 Row | 数据按行存储 | — |

- 案例：`SHOW TABLE STATUS LIKE 'tb_user';` 估算表占用空间与页数。

## P134 进阶-InnoDB引擎-架构-内存结构1（进阶 77）

| 内存组件 | 作用 |
|---|---|---|
| Buffer Pool | 缓存数据页和索引页，读写先操作内存中的页 |
| Change Buffer | 缓存非唯一二级索引的写操作，减少随机 IO |
| Adaptive Hash Index | 为热点页自动建立 hash 索引 |
| Log Buffer | 缓存 redo log，按策略刷盘 |

  ```sql
  SHOW VARIABLES LIKE 'innodb_buffer_pool_size';   -- 默认 128M，建议物理内存 50%–70%
  ```
- 案例：修改一行数据后不立即刷盘，观察 `SHOW ENGINE INNODB STATUS` 中的脏页数量。

## P135 进阶-InnoDB引擎-架构-内存结构2（进阶 78）

**Change Buffer（写缓冲）**

非唯一二级索引的写操作先写入 Change Buffer，等该页被读入 Buffer Pool 时再合并，减少随机读。

```sql
SHOW VARIABLES LIKE 'innodb_change_buffer_max_size';   -- 占 Buffer Pool 的比例，默认 25%
```

**Adaptive Hash Index（自适应 hash 索引）**

InnoDB 监控索引页的访问频率，为热点页自动建立 hash 索引，等值查询可绕过 B+ 树；由 `innodb_adaptive_hash_index` 控制开关。

**Log Buffer（日志缓冲）**

redo log 先写入 Log Buffer，再按 `innodb_flush_log_at_trx_commit` 策略刷盘：

| 取值 | 刷盘行为 | 宕机影响 |
|---|---|---|
| 0 | 每秒刷盘一次 | 最多丢 1 秒事务 |
| 1 | 每次提交都刷盘（默认） | 不丢事务，性能最低 |
| 2 | 每次提交写入 OS cache，由系统刷盘 | 主机宕机可能丢数据，MySQL 崩溃不丢 |

> 模板：`SET [GLOBAL|SESSION] innodb_flush_log_at_trx_commit = 0 | 1 | 2;`

## P136 进阶-InnoDB引擎-架构-磁盘结构（进阶 79）

| 磁盘结构 | 作用 |
|---|---|---|
| 系统表空间 | 存 change buffer、双写缓冲、undo 等，文件 `ibdata1` |
| 独立表空间 | 每张表一个 `xxx.ibd`，存表结构、数据、索引 |
| 通用表空间 | 多张表共享一个表空间 |
| Undo 表空间 | 存 undo log |
| 临时表空间 | 存临时数据 |
| Doublewrite Buffer | 双写缓冲，防止页损坏 |
| Redo Log | 重做日志，用于崩溃恢复 |

- Doublewrite Buffer（双写缓冲，防页损坏）、Redo Log（`ib_logfile*`）。
- 案例：`SHOW VARIABLES LIKE 'innodb_undo_tablespaces';`、查看数据目录文件列表。

## P137 进阶-InnoDB引擎-架构-后台线程（进阶 80）

| 后台线程 | 作用 |
|---|---|---|
| Master Thread | 核心调度线程，负责刷新缓冲池等 |
| IO Thread | 负责读写数据页 |
| Purge Thread | 回收已提交事务的 undo 页 |
| Page Cleaner Thread | 刷新脏页 |

- 案例：`SHOW ENGINE INNODB STATUS\G` 中查看各线程与 IO 统计。

## P138 进阶-InnoDB引擎-事务原理-概述（进阶 81）

| 特性 | 保证机制 |
|---|---|---|
| 原子性 Atomicity | undo log（回滚） |
| 一致性 Consistency | redo log + undo log + 约束 |
| 隔离性 Isolation | 锁 + MVCC |
| 持久性 Durability | redo log（WAL） |

- 案例：提交事务后宕机，重启后 redo 重放恢复；执行 ROLLBACK 时 undo 回滚。

## P139 进阶-InnoDB引擎-事务原理-redolog（进阶 82）

| 对比项 | redo log | undo log |
|---|---|---|
| 日志类型 | 物理日志 | 逻辑日志 |
| 记录内容 | 数据页做了什么修改 | 修改前的值 |
| 作用 | 保证持久性、崩溃恢复 | 保证原子性、支撑 MVCC |
| 写入方式 | 循环写 | 追加写，purge 后清理 |

> 模板：`SHOW VARIABLES LIKE 'innodb_log_file_size'; ｜ SHOW ENGINE INNODB STATUS\G`

```sql
SHOW VARIABLES LIKE 'innodb_log_file_size';
SHOW ENGINE INNODB STATUS\G     -- 查看 Log sequence number
```

- 案例：大事务导致 redo log 写满，触发频繁刷脏页、性能下降。

## P140 进阶-InnoDB引擎-事务原理-undolog（进阶 83）

- 逻辑日志，记录数据修改前的值；用于回滚和 MVCC 版本链。
- 分类：insert undo（提交后可删）、update undo（供 MVCC 使用，purge 后清理）。

## P141 进阶-InnoDB引擎-MVCC-基本概念（进阶 84）

| 读类型 | 触发语句 | 读到的数据 |
|---|---|---|
| 快照读 | 普通 `SELECT` | ReadView 可见的历史版本 |
| 当前读 | `SELECT ... FOR UPDATE`、`UPDATE`、`DELETE` | 最新版本，并加锁 |

- MVCC = 隐藏字段 + undo 版本链 + ReadView。

## P142 进阶-InnoDB引擎-MVCC-隐藏字段（进阶 85）

| 隐藏字段 | 含义 |
|---|---|
| `DB_TRX_ID` | 最近一次修改该行的事务 ID |
| `DB_ROLL_PTR` | 回滚指针，指向 undo log 中的上一个版本 |
| `DB_ROW_ID` | 表无主键时自动生成的行 ID |

- 案例：用 `SELECT * FROM tb_user` 看不到这三列，但它们在行记录中真实存在。

## P143 进阶-InnoDB引擎-MVCC-undolog版本链（进阶 86）

- 每次 UPDATE 生成一条 undo 记录，`DB_ROLL_PTR` 串成链表，形成历史版本链。
- 案例：同一行连续更新 3 次，版本链：当前版本 → v3 → v2 → v1，回滚指针逐级指向旧版本。

## P144 进阶-InnoDB引擎-MVCC-readview介绍（进阶 87）

ReadView 四个字段：

| 字段 | 含义 |
|---|---|
| `m_ids` | 生成快照时活跃（未提交）的事务 ID 列表 |
| `min_trx_id` | `m_ids` 中最小事务 ID |
| `max_trx_id` | 下一个将分配的事务 ID（当前最大 + 1） |
| `creator_trx_id` | 创建该 ReadView 的事务 ID |

可见性判断（沿版本链）：
1. `DB_TRX_ID == creator_trx_id` → 可见（自己改的）；
2. `DB_TRX_ID < min_trx_id` → 可见（已提交）；
3. `DB_TRX_ID >= max_trx_id` → 不可见（快照后开启的）；
4. 在 `m_ids` 中 → 不可见（仍活跃）；否则可见。

## P145 进阶-InnoDB引擎-MVCC-原理分析(RC级别)（进阶 88）

- RC：**每次快照读都生成新的 ReadView**，所以能读到其他事务已提交的最新数据。
- 案例：事务 A 两次查询 `id=1`，期间事务 B 提交更新；RC 下第二次查询能看到 B 的新值 → 不可重复读。

## P146 进阶-InnoDB引擎-MVCC-原理分析(RR级别)（进阶 89）

| 对比项 | RC（读已提交） | RR（可重复读） |
|---|---|---|
| ReadView 生成时机 | 每次快照读都生成 | 只在第一次快照读生成 |
| 能否读到其他事务新提交的值 | 能 | 不能，整个事务复用同一快照 |
| 现象 | 不可重复读 | 可重复读；当前读仍可能幻读 |
| 幻读处理 | 靠加锁 | 快照读靠 MVCC，当前读靠临键锁 |

- RR：**只在第一次快照读时生成 ReadView，整个事务复用**，所以可重复读。
- 案例：同一场景在 RR 下两次查询结果一致；但执行 `SELECT ... FOR UPDATE`（当前读）能看到最新提交 → 幻读现象，靠临键锁解决。

## P147 进阶-InnoDB引擎-小结（进阶 90）

| 模块 | 内容 |
|---|---|
| 逻辑结构 | 表空间 → 段 → 区 → 页 → 行 |
| 内存结构 | Buffer Pool、Change Buffer、Adaptive Hash Index、Log Buffer |
| 磁盘结构 | 各类表空间、Doublewrite Buffer、Redo Log |
| 后台线程 | Master、IO、Purge、Page Cleaner |
| 事务原理 | redo log 保证持久性，undo log 保证原子性与 MVCC |
| MVCC | 隐藏字段、undo 版本链、ReadView，RC 与 RR 的生成时机不同 |

## P148 进阶-MySQL管理-系统数据库介绍（进阶 91）

| 库 | 作用 |
|---|---|
| `mysql` | 用户、权限、系统表 |
| `information_schema` | 元数据（表、列、索引、权限） |
| `performance_schema` | 性能监控（锁、等待事件、SQL 统计） |
| `sys` | 基于 performance_schema 的易用视图 |

- 案例：`SELECT * FROM information_schema.tables WHERE table_schema = 'itcast';`

## P149 进阶-MySQL管理-常用工具1（进阶 92）

| 工具 | 作用 |
|---|---|---|
| mysql | 客户端，执行 SQL，`-e` 可批量执行 |
| mysqladmin | 查看状态、关闭服务、修改密码 |
| mysqlbinlog | 解析二进制日志为可读 SQL |
| mysqlshow | 快速查看库、表、列 |

> 模板：`mysql -u用户 -p [-h主机] [-P端口] [-e "SQL"] ｜ mysqladmin -u用户 -p status|shutdown ｜ mysqlbinlog 文件 > 输出.sql ｜ mysqlshow -u用户 -p [库]`

```bash
mysql -u root -p -e "show databases;"        # 批量执行
mysqladmin -u root -p status                 # 运行状态
mysqladmin -u root -p shutdown               # 关闭
mysqlbinlog binlog.000001 > 1.sql            # 解析二进制日志
mysqlshow -u root -p                         # 快速查看库表
mysqlshow -u root -p itcast                  # 查看库中的表
```

## P150 进阶-MySQL管理-常用工具2（进阶 93）

| 操作 | 命令 | 特点 |
|---|---|---|
| 逻辑备份 | `mysqldump -u用户 -p 库名 > 文件.sql` | 可读 SQL，跨版本，速度慢 |
| 全库备份 | `mysqldump --all-databases` | 含系统库 |
| 只导结构 | `mysqldump --no-data 库名` | 不含数据 |
| 导入恢复 | `source 文件.sql;` 或 `mysql < 文件.sql` | 逐条执行 SQL |

> 模板：`mysqldump -u用户 -p [--all-databases|库名 [表名]] [--no-data] > 文件.sql ｜ source 文件.sql;`

```bash
# 逻辑备份
mysqldump -u root -p itcast > itcast.sql
mysqldump -u root -p --all-databases > all.sql
# 导入
mysqlimport -u root -p itcast /path/file.txt
# 或在客户端内
source /root/itcast.sql;
```

- 案例：备份 itcast 库 → 删除库 → 用 `source` 恢复，验证数据完整。

## P151 进阶-MySQL管理-小结（进阶 94）

| 系统库 | 用途 |
|---|---|
| `mysql` | 用户、权限、系统表 |
| `information_schema` | 元数据（表、列、索引、权限） |
| `performance_schema` | 性能监控（锁等待、等待事件） |
| `sys` | 基于 performance_schema 的易用视图 |

- 案例：只备份某张表 `mysqldump itcast tb_user`；只导出表结构 `mysqldump --no-data itcast`。

## P152 进阶篇总结（进阶 95）

- 回顾：索引（结构与规则）→ 优化 → 视图/过程/触发器 → 锁 → InnoDB/MVCC → 管理；案例：一条慢 SQL 从 `EXPLAIN` 到加索引、再到验证锁行为的完整排查。

---

# 运维篇 P153–P195

## P153 运维-课程介绍（运维 01）

- 内容：日志、主从复制、分库分表（MyCat）、读写分离。

## P154 运维-日志-错误日志（运维 02）

| 日志 | 作用 | 默认 |
|---|---|---|
| 错误日志 | 记录启动、运行、停止时的错误信息 | 开启 |
| 二进制日志 binlog | 记录所有 DDL / DML，用于复制与恢复 | 8.0 默认开启 |
| 查询日志 | 记录所有查询语句 | 关闭 |
| 慢查询日志 | 记录超过 `long_query_time` 的 SQL | 关闭 |

> 模板：`[mysqld] log_error = 日志路径`

```ini
log_error = /var/log/mysqld.log
```

> 模板：`tail -f 错误日志路径`

```bash
tail -f /var/log/mysqld.log       # 启动失败、权限问题等排查
```

- 案例：故意写错 `my.cnf` 参数导致启动失败，在错误日志里定位原因。

## P155 运维-日志-二进制日志（运维 03）

> 模板：`[mysqld] log_bin = 前缀 ｜ binlog_format = ROW|STATEMENT|MIXED`

```ini
log_bin = mysql-bin
binlog_format = ROW
```

> 模板：`SHOW BINARY LOGS; ｜ SHOW MASTER STATUS; ｜ PURGE BINARY LOGS BEFORE '时间';`

```sql
SHOW BINARY LOGS;
SHOW MASTER STATUS;
FLUSH LOGS;
PURGE BINARY LOGS BEFORE '2026-01-01 00:00:00';
```

> 模板：`mysqlbinlog [--no-defaults] [-v] binlog文件 > 输出.sql`

```bash
mysqlbinlog --no-defaults -v binlog.000001 > binlog.sql   # 解析为可读 SQL
```

- 案例：误删数据后用 binlog 恢复：找到删除前的 `position`，重放到该点。
- 格式对比：`STATEMENT`（日志小、部分函数不安全）、`ROW`（精确、推荐）、`MIXED`。

## P156 运维-日志-查询日志（运维 04）

> 模板：`[mysqld] general_log = 1 ｜ general_log_file = 路径`

```ini
general_log = 1
general_log_file = /var/lib/mysql/general.log
```

- 案例：临时打开查询日志，观察应用实际发出的 SQL（排查 ORM 生成语句）。

## P157 运维-日志-慢查询日志（运维 05）

> 模板：`[mysqld] slow_query_log = 1 ｜ long_query_time = 秒 ｜ slow_query_log_file = 路径`

```ini
slow_query_log = 1
long_query_time = 2
slow_query_log_file = /var/lib/mysql/slow.log
```

> 模板：`mysqldumpslow -s t|c|r 慢日志路径`

```bash
mysqldumpslow -s t /var/lib/mysql/slow.log     # 按耗时排序
```

- 案例：`SELECT * FROM tb_sku WHERE sn = '100000003145008';` 记录慢日志 → 加索引后不再出现。

## P158 运维-主从复制-概述（运维 06）

| 作用 | 说明 |
|---|---|---|
| 读扩展 | 读请求分摊到从库 |
| 数据备份 | 从库作为热备 |
| 故障切换 | 主库故障时提升从库 |
| 负载分担 | 备份、统计等任务跑在从库 |

- 案例：一主一从结构图：应用写主库，读从库。

## P159 运维-主从复制-原理（运维 07）

| 线程 | 所在库 | 作用 |
|---|---|---|
| Binlog Dump | 主库 | 把 binlog 发送给从库 |
| IO Thread | 从库 | 拉取 binlog 并写入 relay log |
| SQL Thread | 从库 | 重放 relay log |

- 案例：`SHOW PROCESSLIST` 中看到 `Binlog Dump`（主库）与 `system user`（从库 IO/SQL 线程）。
- 延迟原因：大事务、从库单线程回放、网络；解决：并行复制、半同步。

## P160 运维-主从复制-主库配置（运维 08）

> 模板：`[mysqld] server-id = 1 ｜ log_bin = 前缀 ｜ binlog_format = ROW`

```ini
# 主库 my.cnf
server-id = 1
log_bin = mysql-bin
binlog_format = ROW
```

> 模板：`CREATE USER '复制用户'@'%' IDENTIFIED WITH mysql_native_password BY '密码'; GRANT REPLICATION SLAVE ON *.* TO '复制用户'@'%'; SHOW MASTER STATUS;`

```sql
CREATE USER 'itcast'@'%' IDENTIFIED WITH mysql_native_password BY '1234';
GRANT REPLICATION SLAVE ON *.* TO 'itcast'@'%';
SHOW MASTER STATUS;      -- 记下 File 与 Position
```

## P161 运维-主从复制-从库配置（运维 09）

> 模板：`[mysqld] server-id = 2 ｜ relay_log = 前缀 ｜ read_only = 1`

```ini
# 从库 my.cnf
server-id = 2
relay_log = mysql-relay-bin
read_only = 1
```

> 模板：`CHANGE REPLICATION SOURCE TO SOURCE_HOST='主库IP', SOURCE_USER='用户', SOURCE_PASSWORD='密码', SOURCE_LOG_FILE='文件', SOURCE_LOG_POS=位置; START REPLICA;`

```sql
CHANGE REPLICATION SOURCE TO
  SOURCE_HOST = '192.168.200.200',
  SOURCE_USER = 'itcast',
  SOURCE_PASSWORD = '1234',
  SOURCE_LOG_FILE = 'mysql-bin.000001',
  SOURCE_LOG_POS = 663;

START REPLICA;
SHOW REPLICA STATUS\G      -- Slave_IO_Running / Slave_SQL_Running 都为 Yes
```

## P162 运维-主从复制-测试（运维 10）

> 模板：`主库执行 CREATE DATABASE / INSERT → 从库执行 SHOW DATABASES / SELECT 验证一致性`

```sql
-- 主库
CREATE DATABASE db01;
USE db01;
CREATE TABLE tb_user (id INT, name VARCHAR(20));
INSERT INTO tb_user VALUES (1, '张三');

-- 从库
SHOW DATABASES;               -- 能看到 db01
SELECT * FROM tb_user;        -- 数据一致
INSERT INTO tb_user VALUES (2, '李四');   -- read_only 下失败
```

## P163 运维-分库分表-介绍（运维 11）

| 问题 | 表现 | 解决方向 |
|---|---|---|
| 单表数据量大 | 查询变慢、索引效率下降 | 水平分表 |
| 单库并发高 | 连接数、IO 打满 | 水平分库 / 读写分离 |
| 表字段过多 | 单行过大、冷热数据混存 | 垂直分表 |
| 业务耦合 | 相互影响、故障扩散 | 垂直分库 |

- 拆分维度：垂直（按业务/字段）、水平（按行）。
- 案例：电商系统按「用户、商品、订单」垂直拆库。

## P164 运维-分库分表-介绍-拆分方式（运维 12）

| 方式 | 说明 | 案例 |
|---|---|---|
| 垂直分库 | 按业务拆成多个库 | 用户库、商品库、订单库 |
| 垂直分表 | 一张表按字段冷热拆开 | 商品表拆「基本信息表 + 详情表」 |
| 水平分库 | 同一张表按规则分散到多个库 | 订单按用户 ID 取模分到 2 个库 |
| 水平分表 | 同库内按规则拆成多张表 | 订单表拆 `tb_order_0`、`tb_order_1` |

## P165 运维-分库分表-MyCat概述-安装（运维 13）

| 端口 | 用途 |
|---|---|---|
| 8066 | 数据端口，应用像连 MySQL 一样连接 MyCat |
| 9066 | 管理端口，查看状态、执行管理命令 |

- MyCat：数据库中间件，对外伪装成 MySQL（8066 服务端口、9066 管理端口）。
- 安装：下载 → 上传 `/usr/local` → 解压 → 配 `JAVA_HOME` → 启动 `mycat start` → 查看 `logs/wrapper.log`。

> 模板：`tar -zxvf Mycat-server-*.tar.gz -C /usr/local/ ｜ mycat start`

```bash
tar -zxvf Mycat-server-1.6.7.4-release-*.tar.gz -C /usr/local/
/usr/local/mycat/bin/mycat start
```

## P166 运维-分库分表-MyCat概述-核心概念（运维 14）

| 概念 | 说明 |
|---|---|
| 逻辑库（schema） | 应用看到的库 |
| 逻辑表（table） | 应用看到的表 |
| 数据节点（dataNode） | 逻辑表映射的物理库 |
| 数据主机（dataHost） | 物理数据库连接信息 |
| 分片规则（rule） | 数据路由算法 |
| 全局序列 | 分布式自增 ID |

## P167 运维-分库分表-MyCat入门（运维 15）

- `server.xml` 配置用户与逻辑库：

> 模板：`<user name="用户" defaultAccount="true"><property name="password">密码</property><property name="schemas">逻辑库</property></user>`

```xml
<user name="root" defaultAccount="true">
  <property name="password">123456</property>
  <property name="schemas">DB01</property>
</user>
```

- `schema.xml` 配置逻辑库、逻辑表：

> 模板：`<schema name="逻辑库" ...><table name="逻辑表" dataNode="dn1"/></schema> + <dataNode .../> + <dataHost .../>`

```xml
<schema name="DB01" checkSQLschema="true" sqlMaxLimit="100">
  <table name="tb_order" dataNode="dn1"/>
</schema>
<dataNode name="dn1" dataHost="host1" database="db01"/>
<dataHost name="host1" maxCon="1000" minCon="10" balance="0" writeType="0" dbType="mysql">
  <heartbeat>select user()</heartbeat>
  <writeHost host="hostM1" url="192.168.200.210:3306" user="root" password="1234"/>
</dataHost>
```

## P168 运维-分库分表-MyCat入门-测试（运维 16）

> 模板：`mysql -h MyCat主机 -P 8066 -u 用户 -p`

```bash
mysql -h 192.168.200.210 -P 8066 -u root -p    # 连接 MyCat 而非 MySQL
```

> 模板：`mysql -h MyCat主机 -P 8066 -u 用户 -p; USE 逻辑库; SHOW TABLES;`

```sql
USE DB01;
SHOW TABLES;
CREATE TABLE tb_order (id INT, name VARCHAR(20));
INSERT INTO tb_order VALUES (1, '测试');
SELECT * FROM tb_order;
```

- 案例：通过 MyCat 建表，实际落到后端 MySQL 的 `db01` 库。

## P169 运维-分库分表-MyCat配置1（运维 17）

| 配置文件 | 作用 |
|---|---|
| `server.xml` | 用户、逻辑库、端口、防火墙 |
| `schema.xml` | 逻辑库、逻辑表、dataNode、dataHost |
| `rule.xml` | 分片规则与算法定义 |
| `sequence` | 全局序列配置 |

- `schema.xml` 详解：`schema / table / dataNode / dataHost` 层级关系与属性；
- `checkSQLschema`、`sqlMaxLimit`、`subTables`。

## P170 运维-分库分表-MyCat配置2（运维 18）

- `rule.xml` 分片规则定义；
- `server.xml` 的 `system`（端口等）、`user`（用户、逻辑库）、`firewall`（防火墙）配置。
- 案例：修改分片规则后重启 MyCat，验证数据落到不同节点。

## P171 运维-分库分表-Mycat分片-垂直分库（运维 19）

> 模板：`<table name="逻辑表" dataNode="dn1"/> ｜ <table name="逻辑表" dataNode="dn2"/>  -- 不同表落不同库`

```xml
<schema name="DB01" checkSQLschema="true" sqlMaxLimit="100">
  <table name="tb_user" dataNode="dn1"/>
  <table name="tb_order" dataNode="dn2"/>
</schema>
```

- 案例：用户表在 `db_user` 库，订单表在 `db_order` 库，应用仍只连 `DB01`。

## P172 运维-分库分表-Mycat分片-垂直分库-测试（运维 20）

> 模板：`USE 逻辑库; CREATE TABLE 逻辑表 (...); INSERT INTO 逻辑表 VALUES (...);  -- 到各后端库验证落点`

```sql
USE DB01;
CREATE TABLE tb_user (id INT, name VARCHAR(20));
CREATE TABLE tb_order (id INT, name VARCHAR(20));
INSERT INTO tb_user VALUES (1, '张三');
INSERT INTO tb_order VALUES (1, '订单1');
```

- 案例：分别登录两个后端 MySQL，确认数据各落各库。

## P173 运维-分库分表-Mycat分片-水平分表（运维 21）

> 模板：`<table name="逻辑表" dataNode="dn1,dn2" rule="分片规则"/>`

```xml
<table name="tb_log" dataNode="dn3,dn4" rule="mod-long"/>
```

> 模板：`CREATE TABLE 逻辑表 (...) ;  -- dataNode 配多个 + rule 决定路由`

```sql
CREATE TABLE tb_log (id BIGINT, name VARCHAR(100));
INSERT INTO tb_log VALUES (1, 'a'), (2, 'b'), (3, 'c'), (4, 'd');
-- id 取模：1、3 → 节点 1；2、4 → 节点 2
```

## P174 运维-分库分表-分片规则-范围分片（运维 22）

> 模板：`<tableRule name="规则名"><rule><columns>分片键</columns><algorithm>算法名</algorithm></rule></tableRule>`

```xml
<tableRule name="auto-sharding-long">
  <rule><columns>id</columns><algorithm>rang-long</algorithm></rule>
</tableRule>
```

> 模板：`范围分片：起始值-结束值=节点索引`

```text
# autopartition-long.txt
0-500M=0
500M-1000M=1
1000M-1500M=2
```

- 案例：插入 id=1（落 dn1）、id=600000000（落 dn2）。

## P175 运维-分库分表-分片规则-取模分片（运维 23）

> 模板：`取模分片：<algorithm>mod-long</algorithm>`

```xml
<tableRule name="mod-long">
  <rule><columns>id</columns><algorithm>mod-long</algorithm></rule>
</tableRule>
```

- 案例：`id % 3` 决定节点；优点是均匀，缺点是扩容需数据迁移。

## P176 运维-分库分表-分片规则-一致性hash算法（运维 24）

> 模板：`一致性 hash：<algorithm>murmur</algorithm>`

```xml
<tableRule name="sharding-by-murmur">
  <rule><columns>id</columns><algorithm>murmur</algorithm></rule>
</tableRule>
```

- 案例：新增节点时只有少量数据需要迁移，解决取模扩容问题。

## P177 运维-分库分表-分片规则-枚举分片（运维 25）

> 模板：`枚举分片：<algorithm>hash-int</algorithm>`

```xml
<tableRule name="sharding-by-intfile">
  <rule><columns>sharding_id</columns><algorithm>hash-int</algorithm></rule>
</tableRule>
```

> 模板：`枚举值=节点索引`

```text
# partition-hash-int.txt
10000=0
10010=1
```

- 案例：按省份/状态等枚举值路由到固定节点；未配置的值报错。

## P178 运维-分库分表-分片规则-应用指定算法（运维 26）

> 模板：`应用指定：<algorithm>sharding-by-substring</algorithm>`

```xml
<tableRule name="sharding-by-substring">
  <rule>
    <columns>id</columns>
    <algorithm>sharding-by-substring</algorithm>
  </rule>
</tableRule>
```

- 案例：`id = 05-1000002`，由应用在 ID 中编码分片号，MyCat 直接按位截取。

## P179 运维-分库分表-分片规则-固定hash算法（运维 27）

- 把分片键按二进制位做 hash 取模，结果固定映射到节点。
- 案例：id 的某几位决定节点，分布均匀且可预测。

## P180 运维-分库分表-分片规则-字符串hash解析（运维 28）

> 模板：`字符串 hash：<algorithm>stringhash</algorithm>`

```xml
<tableRule name="sharding-by-stringhash">
  <rule><columns>name</columns><algorithm>stringhash</algorithm></rule>
</tableRule>
```

- 案例：以字符串字段（如用户名）做 hash 后取模分片。

## P181 运维-分库分表-分片规则-按天分片（运维 29）

> 模板：`按天分片：<algorithm>sharding-by-date</algorithm> ｜ sPartionDay = 天数`

```xml
<tableRule name="sharding-by-date">
  <rule>
    <columns>create_time</columns>
    <algorithm>sharding-by-date</algorithm>
  </rule>
</tableRule>
```

> 模板：`sPartionDay = 天数`

```text
sPartionDay = 10
```

- 案例：日志表按日期每 10 天一个分片，自动路由到对应节点。

## P182 运维-分库分表-分片规则-按自然月分片（运维 30）

> 模板：`按月分片：<algorithm>sharding-by-month</algorithm>`

```xml
<tableRule name="sharding-by-month">
  <rule>
    <columns>create_time</columns>
    <algorithm>sharding-by-month</algorithm>
  </rule>
</tableRule>
```

- 案例：账单表按月分片，2026-01 的数据固定落在第一个节点。

## P183 运维-分库分表-Mycat管理与监控-原理（运维 31）

- 9066 管理端口可查看运行状态、数据节点、执行管理命令。
- 案例：`mysql -h ... -P 9066 -u root -p` 后执行 `show @@datasource;`。

## P184 运维-分库分表-Mycat管理工具（运维 32）

| 命令 | 作用 |
|---|---|---|
| mycat start | 启动 |
| mycat stop | 停止 |
| mycat restart | 重启 |
| mycat status | 查看运行状态 |
| mycat console | 前台启动，实时输出日志 |

> 模板：`mycat start|stop|restart|status|console`

```bash
mycat start / stop / restart / status / console
```

- 案例：`mycat console` 前台启动，实时看到 SQL 路由日志。

## P185 运维-分库分表-MyCat监控1（运维 33）

- 部署 mycat-eye（依赖 zookeeper），查看 QPS、连接数、慢 SQL。
- 案例：压测时观察各分片节点的读写分布。

## P186 运维-分库分表-MyCat监控2（运维 34）

- mycat-eye 的 SQL 监控、物理库监控、告警配置。
- 案例：给某个慢 SQL 配置告警阈值。

## P187 运维-分库分表-总结（运维 35）

| 分片规则 | 算法 / 配置 | 适用场景 |
|---|---|---|
| 范围分片 | auto-sharding-long | 自增 ID 按区间 |
| 取模分片 | mod-long | 均匀分布，扩容需迁移 |
| 一致性 hash | sharding-by-murmur | 减少扩容迁移 |
| 枚举分片 | sharding-by-intfile | 省份、状态等枚举值 |
| 应用指定 | sharding-by-substring | 应用在 ID 中编码分片号 |
| 固定 hash | partition-by-fixed-hash | 二进制位 hash 取模 |
| 字符串 hash | sharding-by-stringhash | 字符串字段 hash 后取模 |
| 按天分片 | sharding-by-date | 日志类时序数据 |
| 按自然月分片 | sharding-by-month | 账单类时序数据 |

- 拆分方式 → MyCat 配置 → 分片规则 → 管理与监控的完整链路。

## P188 运维-读写分离-介绍（运维 36）

| 方案 | 结构 | 适用场景 |
|---|---|---|
| 一主一从 | 1 主 1 从 | 读多写少、小规模 |
| 双主双从 | 2 主 2 从，互为主从 | 高可用、写扩展 |

## P189 运维-读写分离-一主一从准备（运维 37）

| 步骤 | 要点 |
|---|---|
| 安装 | 两台服务器分别安装 MySQL，版本一致 |
| 主库配置 | `server-id=1`、开启 `log_bin`、创建复制账号并授权 |
| 从库配置 | `server-id=2`、`relay_log`、`read_only=1`，`CHANGE REPLICATION SOURCE` |
| 验证 | `SHOW REPLICA STATUS\G`，IO / SQL 线程均为 Yes |

## P190 运维-读写分离-一主一从读写分离（运维 38）

> 模板：`<dataHost ... balance="1"><writeHost ...><readHost .../></writeHost></dataHost>`

```xml
<dataHost name="host1" maxCon="1000" minCon="10" balance="1"
          writeType="0" dbType="mysql">
  <heartbeat>select user()</heartbeat>
  <writeHost host="hostM1" url="192.168.200.211:3306" user="root" password="1234">
    <readHost host="hostS1" url="192.168.200.212:3306" user="root" password="1234"/>
  </writeHost>
</dataHost>
```

- 案例：通过 MyCat 执行 `SELECT` 观察落到从库（看从库 general log），`INSERT` 落到主库。

## P191 运维-读写分离-双主双从介绍（运维 39）

| 角色 | 作用 |
|---|---|---|
| M1 / M2 | 互为主从，都可写 |
| S1 / S2 | 分别复制 M1 / M2，承担读请求 |
| keepalived | 虚拟 IP 漂移，实现故障切换 |

## P192 运维-读写分离-双主双从搭建（运维 40）

- 四台机器：M1、M2、S1、S2；
- 配置要点：`auto_increment_increment = 2`、`auto_increment_offset`（主键不冲突）、双主互相同步、各从库指向各自主库。

> 模板：`CHANGE REPLICATION SOURCE TO SOURCE_HOST='另一主库', ...;  -- 双主互指`

```sql
-- M1
CHANGE REPLICATION SOURCE TO SOURCE_HOST='M2', ...;
-- M2
CHANGE REPLICATION SOURCE TO SOURCE_HOST='M1', ...;
```

## P193 运维-读写分离-双主双从读写分离（运维 41）

> 模板：`双主：两个 <writeHost>，各自挂 <readHost>，writeType="1"`

```xml
<dataHost name="host1" maxCon="1000" minCon="10" balance="1"
          writeType="1" dbType="mysql">
  <heartbeat>select user()</heartbeat>
  <writeHost host="hostM1" url="M1:3306" user="root" password="1234">
    <readHost host="hostS1" url="S1:3306" user="root" password="1234"/>
  </writeHost>
  <writeHost host="hostM2" url="M2:3306" user="root" password="1234">
    <readHost host="hostS2" url="S2:3306" user="root" password="1234"/>
  </writeHost>
</dataHost>
```

- 案例：停掉 M1，写请求切到 M2，验证 MyCat 自动故障切换。

## P194 运维-读写分离-总结（运维 42）

| 方案 | 优点 | 缺点 |
|---|---|---|
| 一主一从 | 结构简单、易维护 | 主库单点，写能力有限 |
| 双主双从 | 主库高可用、读写都可扩展 | 配置复杂，需处理自增主键冲突 |

- 选择：小规模用一主一从；要求故障自动切换与写扩展时用双主双从 + keepalived。

## P195 运维篇总结（运维 43）

- 日志定位问题 → 主从复制扩展读 → 分库分表解决容量 → 读写分离提升并发；案例：给出「业务量 10 倍增长」的完整演进方案。

---

# 附录：课程用到的示例表结构

## 基础篇

**emp（员工，DQL 用）**

| 字段 | 类型 | 说明 |
|---|---|---|
| id | int | 主键 |
| workno | varchar(10) | 工号 |
| name | varchar(10) | 姓名 |
| gender | char(1) | 性别 |
| age | tinyint unsigned | 年龄 |
| idcard | char(18) | 身份证号 |
| workaddress | varchar(50) | 工作地址 |
| entrydate | date | 入职日期 |
| salary | double | 薪资（多表查询用） |
| managerid | int | 直属领导 ID（自连接用） |
| dept_id | int | 部门 ID |
| job | varchar(20) | 职位（多表查询用） |

**dept**：`id int PK, name varchar(50)`
**salgrade**：`grade int, losal int, hisal int`
**student**：`id int PK, name varchar(50), no varchar(10)`
**course**：`id int PK, name varchar(50)`
**student_course**：`id int PK, studentid int, courseid int`
**tb_user_detail**：`id int PK, user_id int UNIQUE, birthday date, address varchar(50)`
**account**：`id int PK, name varchar(10), money double`

## 进阶篇

**tb_user**：`id, username, password, name, gender, phone, profession, age, status, email, createtime`
**tb_sku**：`id, sn, name, price, num, ...`（千万级数据，索引演示用）
**user_logs**：`id, operation, operate_time, operate_id, operate_params`
**tb_user_pro**：`id, name, profession`

## 运维篇

**tb_order / tb_log / tb_user**：用于 MyCat 垂直分库、水平分表、分片规则演示（结构简单，重点是路由效果）。

---

## 使用建议

1. 按分 P 顺序看，每看完一集把本手册对应条目的 SQL 在本地跑一遍。
2. `emp` 相关例子建议先按附录建表并灌入 20 行左右数据，否则查询结果看不出规律。
3. 索引与锁的演示需要 `tb_sku` / `tb_user` 的较大数据量，建议用 `LOAD DATA` 灌 100 万行以上再测。
