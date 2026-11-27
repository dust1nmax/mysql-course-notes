-- 黑马 MySQL 课程示例库（itcast）
--
-- 用途：导入 learn 库后，课程手册与 logs/ 中基于 emp / dept / salgrade 的案例可直接复现。
-- 说明：课程附录只给出表结构，没有 INSERT 数据；本文件的示例数据按课堂演示重建
--       （武侠人物、6 个部门、5 档薪资），行数与字段和课程保持一致。
--
-- 导入：docker exec -i mysql-learn mysql -uroot -p'<密码>' learn < learning-notes/sql/itcast.sql

DROP TABLE IF EXISTS emp;
DROP TABLE IF EXISTS dept;
DROP TABLE IF EXISTS salgrade;

-- 部门表
CREATE TABLE dept (
  id   INT PRIMARY KEY AUTO_INCREMENT COMMENT '部门ID',
  name VARCHAR(50) NOT NULL COMMENT '部门名称'
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '部门表';

INSERT INTO dept (id, name) VALUES
(1, '研发部'),
(2, '市场部'),
(3, '财务部'),
(4, '销售部'),
(5, '总经办'),
(6, '人事部');

-- 员工表
CREATE TABLE emp (
  id         INT PRIMARY KEY AUTO_INCREMENT COMMENT '员工ID',
  name       VARCHAR(50) NOT NULL COMMENT '姓名',
  age        INT COMMENT '年龄',
  gender     CHAR(1) COMMENT '性别',
  dept_id    INT COMMENT '部门ID',
  salary     INT COMMENT '薪资',
  entry_date DATE COMMENT '入职日期'
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '员工表';

INSERT INTO emp (id, name, age, gender, dept_id, salary, entry_date) VALUES
(1,  '金庸',   66, '男', 1, 20000, '2000-01-01'),
(2,  '张无忌', 20, '男', 2, 10000, '2001-02-01'),
(3,  '杨逍',   33, '男', 3,  8000, '2002-03-01'),
(4,  '韦一笑', 48, '男', 4,  5000, '2003-04-01'),
(5,  '常遇春', 43, '男', 5,  8000, '2004-05-01'),
(6,  '小昭',   19, '女', 6,  6000, '2005-06-01'),
(7,  '杨不悔', 20, '女', 1,  7000, '2006-07-01'),
(8,  '赵敏',   20, '女', 2,  9000, '2007-08-01'),
(9,  '周芷若', 20, '女', 3, 11000, '2008-09-01'),
(10, '灭绝',   36, '女', 4,  4000, '2009-10-01'),
(11, '张三丰', 90, '男', 5, 12000, '2010-11-01'),
(12, '杨过',   23, '男', 6,  8000, '2011-12-01'),
(13, '小龙女', 23, '女', 1,  6000, '2012-01-01'),
(14, '郭靖',   50, '男', 2,  8000, '2013-02-01'),
(15, '黄蓉',   30, '女', 3,  9000, '2014-03-01'),
(16, '韦小宝', 18, '男', 4,  6000, '2015-04-01'),
(17, '段誉',   22, '男', 5,  9000, '2016-05-01'),
(18, '虚竹',   24, '男', 6,  8000, '2017-06-01'),
(19, '乔峰',   32, '男', 1, 15000, '2018-07-01'),
(20, '阿朱',   20, '女', 2,  7000, '2019-08-01');

-- 薪资等级表
CREATE TABLE salgrade (
  grade INT COMMENT '等级',
  losal INT COMMENT '最低薪资',
  hisal INT COMMENT '最高薪资'
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '薪资等级表';

INSERT INTO salgrade (grade, losal, hisal) VALUES
(1,     0,  3000),
(2,  3001,  5000),
(3,  5001,  8000),
(4,  8001, 12000),
(5, 12001, 20000);

-- 导入后自检（手动执行，索引/优化章节会用到）
-- SELECT COUNT(*) FROM emp;                       -- 期望 20
-- SELECT COUNT(*) FROM dept;                      -- 期望 6
-- SELECT e.name, d.name FROM emp e JOIN dept d ON e.dept_id = d.id LIMIT 5;