------------------------------------------------------
-- COMP9311 24T2 Project 1 
-- SQL and PL/pgSQL 
-- Solution Template
-- Name:
-- zID:
------------------------------------------------------
-- Note: Before submission, please check your solution on the nw-syd-vxdb server using the check file.


-- Q1:
DROP VIEW IF EXISTS Q1 CASCADE;
CREATE VIEW Q1(code) as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q2:
DROP VIEW IF EXISTS Q2 CASCADE;
CREATE VIEW Q2(id) as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q3:
DROP VIEW IF EXISTS Q3 CASCADE;
CREATE VIEW Q3(name) as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q4:
DROP VIEW IF EXISTS Q4 CASCADE;
CREATE VIEW Q4(code) as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q5:
DROP VIEW IF EXISTS Q5 CASCADE;
CREATE VIEW Q5(unswid) as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q6:
DROP VIEW IF EXISTS Q6 CASCADE;
CREATE VIEW Q6(code, avg_mark) as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q7:
DROP VIEW IF EXISTS Q7 CASCADE;
CREATE VIEW Q7(student, course) as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q8:
DROP VIEW IF EXISTS Q8 CASCADE;
CREATE VIEW Q8(course_id, staffs_names) as 
--... SQL statements, possibly using other views/functions defined by you ...
;


-- Q9
DROP FUNCTION IF EXISTS Q9 CASCADE;
CREATE or REPLACE FUNCTION Q9(subject_code text) returns text
as $$
--... PL/pgSQL statements, possibly using other views/functions defined by you ...
$$ language plpgsql;


-- Q10
DROP FUNCTION IF EXISTS Q10 CASCADE;
CREATE or REPLACE FUNCTION Q10(subject_code text) returns text
as $$
--... PL/pgSQL statements, possibly using other views/functions defined by you ...
$$ language plpgsql;