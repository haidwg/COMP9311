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
select DISTINCT code
from subjects
join orgunits on subjects.offeredby = orgunits.id
where orgunits.longname = 'School of Computer Science and Engineering'
and subjects.longname like '%Database%';

-- Q2:
DROP VIEW IF EXISTS Q2 CASCADE;
CREATE VIEW Q2(id) as
select distinct courses.id
from courses
join classes on courses.id = classes.course
join class_types on classes.ctype = class_types.id
join rooms on classes.room = rooms.id
where 
class_types.name = 'Laboratory'
and rooms.longname = 'MB-G4';

-- Q3:
DROP VIEW IF EXISTS Q3 CASCADE;
CREATE VIEW Q3(name) as
select DISTINCT people.name
from people
join course_enrolments on people.id = course_enrolments.student
join courses on course_enrolments.course = courses.id
join subjects on courses.subject = subjects.id
where mark >= 95
and subjects.code = 'COMP3311';

-- Q4:
DROP VIEW IF EXISTS Q4 CASCADE;
CREATE VIEW Q4(code) as
select DISTINCT subjects.code
from subjects
join courses on subjects.id = courses.subject
join classes on courses.id = classes.course
join rooms on classes.room = rooms.id
join room_facilities on rooms.id = room_facilities.room
join facilities on room_facilities.facility = facilities.id
where facilities.description = 'Student wheelchair access'
and subjects.code like 'COMM%';

-- Q5:
DROP VIEW IF EXISTS Q5 CASCADE;
CREATE VIEW Q5(unswid) as
(SELECT distinct unswid
from people
join course_enrolments on people.id = course_enrolments.student
join courses on course_enrolments.course = courses.id
join subjects on courses.subject = subjects.id
where grade = 'HD' and subjects.code like 'COMP9%')
EXCEPT
(SELECT distinct unswid
from people
join course_enrolments on people.id = course_enrolments.student
join courses on course_enrolments.course = courses.id
join subjects on courses.subject = subjects.id
where grade != 'HD' and subjects.code like 'COMP9%');


-- Q6:
DROP VIEW IF EXISTS Q6 CASCADE;
CREATE VIEW Q6(code, avg_mark) as
select subjects.code, round(avg(mark),2) as avg_mark
from orgunits
join subjects on orgunits.id = subjects.offeredby
join courses on subjects.id = courses.subject
join course_enrolments on courses.id = course_enrolments.course
join semesters on courses.semester = semesters.id
WHERE subjects.uoc < 6
and orgunits.longname = 'School of Civil and Environmental Engineering'
and mark is not null
and career = 'UG'
and mark >= 50
and year = '2008'
GROUP BY subjects.code
ORDER BY avg_mark DESC;

-- Q7:
DROP VIEW IF EXISTS Q7 CASCADE;
CREATE VIEW Q7(student, course) as
with student_rank as (
    select student,course,mark, rank() over (PARTITION BY course
    order by mark desc) as rank
    from course_enrolments
    join courses on course_enrolments.course = courses.id
    join subjects on courses.subject = subjects.id
    join semesters on courses.semester = semesters.id
    WHERE mark is not NULL
    and subjects.code like 'COMP93%'
    and year = '2008'
    and term = 'S1'
)
SELECT student, course
from student_rank
where rank = 1;


-- Q8:
DROP VIEW IF EXISTS Q8 CASCADE;
CREATE VIEW Q8(course_id, staffs_names) as
with large_course as (
    select course
    from course_enrolments
    GROUP BY course
    HAVING count(student) >= 650
)
select course_staff.course,string_agg(given, ', ' ORDER BY given) as staffs_name
from course_staff
JOIN people ON people.id = course_staff.staff
join large_course on large_course.course = course_staff.course
where title = 'AProf'
GROUP BY course_staff.course
HAVING count(staff) = 2
ORDER BY course_staff.course;

-- Q9:
DROP FUNCTION IF EXISTS Q9 CASCADE;
CREATE or REPLACE FUNCTION Q9(subject_code text)
returns text as $$
DECLARE
    preq text;
    result text;
BEGIN
    result = '';
    For preq in
        SELECT s2.code 
        from subjects as s1, subjects as s2
        where s1.code = subject_code and s1._prereq like '%'||s2.code||'%'
        ORDER BY s2.code
    LOOP
        result = result || preq || ', ';
    END LOOP;
    if RESULT = '' then
        result = 'There is no prerequisite for subject '||subject_code||'.';
    else
        result = 'The prerequisites for subject '||subject_code||' are '||substring(result, 1, length(result)-2)||'.';
    end if;
    return result;
END;
$$ LANGUAGE plpgsql;


-- Q10:
DROP FUNCTION IF EXISTS Q10 CASCADE;
CREATE or REPLACE FUNCTION Q10(subject_code text)
returns text as $$
DECLARE
    preq text;
    result text;
BEGIN
    CREATE Temp table prereqTable(code char(8));
    CREATE TEMP table new_prereqTable(code char(8));
    create TEMP table diffTable(code char(8));
    INSERT INTO new_prereqTable VALUES (subject_code);
    LOOP
        insert into diffTable SELECT * from new_prereqTable EXCEPT SELECT * from prereqTable;
        EXIT WHEN NOT EXISTS (SELECT * from diffTable);
        INSERT INTO prereqTable SELECT * from new_prereqTable;
        DELETE FROM new_prereqTable;
        INSERT INTO new_prereqTable
        SELECT s2.code
        from subjects as s1, subjects as s2
        where s1.code in (SELECT code from diffTable) and s1._prereq like '%'||s2.code||'%';
        DELETE FROM diffTable;
    END LOOP;
    DELETE FROM prereqTable where code = subject_code;
    -- return query SELECT * from prereqTable;
    result = '';
    FOR preq in
        SELECT DISTINCT code from prereqTable ORDER BY code
    LOOP
        result = result || preq || ', ';
    END LOOP;
    if RESULT = '' then
        result = 'There is no prerequisite for subject '||subject_code||'.';
    else
        result = 'The prerequisites for subject '||subject_code||' are '||substring(result, 1, length(result)-2)||'.';
    end if;

    drop TABLE diffTable;
    drop TABLE new_prereqTable;
    drop TABLE prereqTable;
    return result;
END;
$$ LANGUAGE plpgsql;

