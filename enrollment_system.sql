CREATE DATABASE IF NOT EXISTS college_enrollment_system;
USE college_enrollment_system;


CREATE TABLE tbl_STUDENT (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    birth_date DATE,
    gender VARCHAR(10),
    address TEXT
);


CREATE TABLE tbl_COURSE (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(100),
    major_path VARCHAR(100),
    course_description TEXT
);

CREATE TABLE tbl_DEPARTMENT (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100),
    acronym VARCHAR(10),
    dept_desc TEXT
);


CREATE TABLE tbl_STUD_AFFILIATION (
    affiliation_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    department_id INT,
    FOREIGN KEY (student_id) REFERENCES tbl_STUDENT(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES tbl_COURSE(course_id),
    FOREIGN KEY (department_id) REFERENCES tbl_DEPARTMENT(department_id)
);


CREATE TABLE tbl_SUBJECT (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(100),
    subject_code VARCHAR(50) UNIQUE,
    unit INT,
    prerequisite VARCHAR(100)
);


CREATE TABLE tbl_SEMESTER (
    sem_id INT AUTO_INCREMENT PRIMARY KEY,
    semester VARCHAR(20)
);


CREATE TABLE tbl_SCHOOL_YEAR (
    sy_id INT AUTO_INCREMENT PRIMARY KEY,
    year_start YEAR,
    year_end YEAR
);


CREATE TABLE tbl_DAY (
    day_id INT AUTO_INCREMENT PRIMARY KEY,
    day VARCHAR(20)
);


CREATE TABLE tbl_ROOM (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_no VARCHAR(20),
    room_description TEXT
);


CREATE TABLE tbl_SUBJECT_SCHEDULE (
    subject_sched_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_id INT,
    day_id INT,
    schedule_time VARCHAR(50),
    room_id INT,
    sem_id INT,
    sy_id INT,
    max INT,
    total INT,
    FOREIGN KEY (subject_id) REFERENCES tbl_SUBJECT(subject_id),
    FOREIGN KEY (day_id) REFERENCES tbl_DAY(day_id),
    FOREIGN KEY (room_id) REFERENCES tbl_ROOM(room_id),
    FOREIGN KEY (sem_id) REFERENCES tbl_SEMESTER(sem_id),
    FOREIGN KEY (sy_id) REFERENCES tbl_SCHOOL_YEAR(sy_id)
);


CREATE TABLE tbl_ENROLLMENT (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    dropped VARCHAR(50)
    active VARCHAR(50)
    student_id INT,
    subject_sched_id INT,
    FOREIGN KEY (student_id) REFERENCES tbl_STUDENT(student_id),
    FOREIGN KEY (subject_sched_id) REFERENCES tbl_SUBJECT_SCHEDULE(subject_sched_id)
);

CREATE TABLE tbl_enrollment_archive (
    enrollment_archive_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    subject_sched_id INT,
    dropped_at DATETIME,
    reason TEXT
    FOREIGN KEY (enrollment_id) REFERENCES tbl_ENROLLMENT(enrollment_id),
);


CREATE TABLE tbl_INSTRUCTOR (
    instructor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE
);


CREATE TABLE tbl_FACULTY_ASSIGNMENT (
    fac_ass_id INT AUTO_INCREMENT PRIMARY KEY,
    instructor_id INT,
    department_id INT,
    FOREIGN KEY (instructor_id) REFERENCES tbl_INSTRUCTOR(instructor_id),
    FOREIGN KEY (department_id) REFERENCES tbl_DEPARTMENT(department_id)
);


CREATE TABLE tbl_FACULTY_SUB_ASS (
    fac_sub_ass_id INT AUTO_INCREMENT PRIMARY KEY,
    instructor_id INT,
    subject_sched_id INT,
    FOREIGN KEY (instructor_id) REFERENCES tbl_INSTRUCTOR(instructor_id),
    FOREIGN KEY (subject_sched_id) REFERENCES tbl_SUBJECT_SCHEDULE(subject_sched_id)
);

CREATE TABLE tbl_USER_ACCOUNT (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    password_hash VARCHAR(255),
    role ENUM('Student', 'Instructor'),
    user_id INT
  
);
-- ========== STORED PROCEDURES ==========
DELIMITER //
CREATE PROCEDURE sp_add_student(IN fn VARCHAR(50), ln VARCHAR(50), em VARCHAR(100), bd DATE, gen VARCHAR(10), addr TEXT)
BEGIN
    INSERT INTO tbl_STUDENT(first_name, last_name, email, birth_date, gender, address)
    VALUES (fn, ln, em, bd, gen, addr);
END;
//

CREATE PROCEDURE sp_enroll_student(IN sid INT, IN sched_id INT)
BEGIN
    INSERT INTO tbl_ENROLLMENT(student_id, subject_sched_id)
    VALUES (sid, sched_id);
END;
//

CREATE PROCEDURE sp_assign_instructor(IN iid INT, IN ssid INT)
BEGIN
    INSERT INTO tbl_FACULTY_SUB_ASS(instructor_id, subject_sched_id)
    VALUES (iid, ssid);
END;
//

CREATE PROCEDURE sp_add_subject(IN sname VARCHAR(100), scode VARCHAR(50), unit INT, prereq VARCHAR(100))
BEGIN
    INSERT INTO tbl_SUBJECT(subject_name, subject_code, unit, prerequisite)
    VALUES (sname, scode, unit, prereq);
END;
//

CREATE PROCEDURE sp_add_course(IN cname VARCHAR(100), path VARCHAR(100), cdesc TEXT)
BEGIN
    INSERT INTO tbl_COURSE(course_name, major_path, course_description)
    VALUES (cname, path, cdesc);
END;
//

CREATE PROCEDURE sp_promote_sy()
BEGIN
    DECLARE current_year_start YEAR;
    DECLARE current_year_end YEAR;
    SELECT MAX(year_start) INTO current_year_start FROM tbl_SCHOOL_YEAR;
    SET current_year_end = current_year_start + 1;
    INSERT INTO tbl_SCHOOL_YEAR(year_start, year_end)
    VALUES (current_year_start + 1, current_year_end + 1);
END;
//

CREATE PROCEDURE sp_mass_promote_students(IN from_sy INT, IN to_sy INT)
BEGIN
    DECLARE sid INT DEFAULT 0;
    WHILE sid < 100 DO
        INSERT INTO tbl_enrollment_log(student_id, subject_sched_id, deleted_at)
        VALUES (sid, 1, NOW());
        SET sid = sid + 1;
    END WHILE;
END;
//
DELIMITER ;

-- ========== TRIGGERS ==========
DELIMITER //
CREATE TRIGGER trg_drop_enrollment
BEFORE UPDATE ON tbl_ENROLLMENT
FOR EACH ROW
BEGIN
    -- Only act when changing status from active to dropped
    IF OLD.status = 'active' AND NEW.status = 'dropped' THEN
        -- Archive the record
        INSERT INTO tbl_enrollment_archive(student_id, subject_sched_id, dropped_at, reason)
        VALUES (OLD.student_id, OLD.subject_sched_id, NOW(), 'Student dropped the subject');

        -- Reduce the total in schedule
        UPDATE tbl_SUBJECT_SCHEDULE
        SET total = total - 1
        WHERE subject_sched_id = OLD.subject_sched_id;
    END IF;
END;
//

CREATE TRIGGER trg_update_total_after_enroll AFTER INSERT ON tbl_ENROLLMENT
FOR EACH ROW
BEGIN
    UPDATE tbl_SUBJECT_SCHEDULE SET total = total + 1 WHERE subject_sched_id = NEW.subject_sched_id;
END;
//

CREATE TRIGGER trg_check_max_enrollment BEFORE INSERT ON tbl_ENROLLMENT
FOR EACH ROW
BEGIN
    DECLARE max_enroll INT;
    DECLARE current_total INT;
    SELECT max, total INTO max_enroll, current_total FROM tbl_SUBJECT_SCHEDULE WHERE subject_sched_id = NEW.subject_sched_id;
    IF current_total >= max_enroll THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Maximum enrollment reached for this subject schedule';
    END IF;
END;
//

CREATE TRIGGER trg_reduce_total_after_delete AFTER DELETE ON tbl_ENROLLMENT
FOR EACH ROW
BEGIN
    UPDATE tbl_SUBJECT_SCHEDULE SET total = total - 1 WHERE subject_sched_id = OLD.subject_sched_id;
END;
//

CREATE TRIGGER trg_default_role_user BEFORE INSERT ON tbl_USER_ACCOUNT
FOR EACH ROW
BEGIN
    IF NEW.role IS NULL THEN
        SET NEW.role = 'Student';
    END IF;
END;
//

CREATE TRIGGER trg_check_duplicate_instructor_schedule BEFORE INSERT ON tbl_FACULTY_SUB_ASS
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM tbl_FACULTY_SUB_ASS WHERE instructor_id = NEW.instructor_id AND subject_sched_id = NEW.subject_sched_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This instructor is already assigned to this subject schedule';
    END IF;
END;
//

CREATE TRIGGER trg_no_duplicate_enrollment BEFORE INSERT ON tbl_ENROLLMENT
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM tbl_ENROLLMENT WHERE student_id = NEW.student_id AND subject_sched_id = NEW.subject_sched_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This student is already enrolled in this subject schedule';
    END IF;
END;
//

CREATE TRIGGER trg_log_enrollment_delete AFTER DELETE ON tbl_ENROLLMENT
FOR EACH ROW
BEGIN
    INSERT INTO tbl_enrollment_log(student_id, subject_sched_id, deleted_at)
    VALUES (OLD.student_id, OLD.subject_sched_id, NOW());
END;
//

CREATE TRIGGER trg_gender_default BEFORE INSERT ON tbl_STUDENT
FOR EACH ROW
BEGIN
    IF NEW.gender IS NULL OR TRIM(NEW.gender) = '' THEN
        SET NEW.gender = 'Unspecified';
    ELSEIF NEW.gender NOT IN ('Male', 'Female') THEN
        SET NEW.gender = 'Unspecified';
    END IF;
END;
//

CREATE TRIGGER trg_validate_schedule_time BEFORE INSERT ON tbl_SUBJECT_SCHEDULE
FOR EACH ROW
BEGIN
    DECLARE start_time TIME;
    DECLARE end_time TIME;
    SET start_time = STR_TO_DATE(SUBSTRING_INDEX(NEW.schedule_time, '-', 1), '%H:%i');
    SET end_time = STR_TO_DATE(SUBSTRING_INDEX(NEW.schedule_time, '-', -1), '%H:%i');
    IF start_time < '07:00:00' OR end_time > '18:00:00' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Subject schedule must be between 07:00 and 18:00';
    END IF;
END;
//

CREATE TRIGGER trg_check_schedule_room_conflict BEFORE INSERT ON tbl_SUBJECT_SCHEDULE
FOR EACH ROW
BEGIN
    DECLARE count_conflict INT DEFAULT 0;
    SELECT COUNT(*) INTO count_conflict
    FROM tbl_SUBJECT_SCHEDULE
    WHERE room_id = NEW.room_id AND day_id = NEW.day_id AND schedule_time = NEW.schedule_time;
    IF count_conflict > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Room is already booked for the given time and day';
    END IF;
END;
//

CREATE TRIGGER trg_auto_set_semester BEFORE INSERT ON tbl_SEMESTER
FOR EACH ROW
BEGIN
    CASE MONTH(CURDATE())
        WHEN 6 THEN SET NEW.semester = '1st Semester';
        WHEN 11 THEN SET NEW.semester = '2nd Semester';
        ELSE SET NEW.semester = 'Summer';
    END CASE;
END;
//
DELIMITER ;


# Save the SQL script to a file
file_path = "/mnt/data/college_enrollment_system_full.sql"
with open(file_path, "w") as f:
    f.write(sql_script)

file_path