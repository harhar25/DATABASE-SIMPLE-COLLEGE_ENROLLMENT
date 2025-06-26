![Screenshot 2025-06-26 210217](https://github.com/user-attachments/assets/7f0d9198-0a8f-475a-acf1-b96d70c2ee29)
![Screenshot 2025-06-26 210217](https://github.com/user-attachments/assets/7f0d9198-0a8f-475a-acf1-b96d70c2ee29)

## 🎓 College Enrollment System

This project is a comprehensive **College Enrollment System** built using **MariaDB**. It contains a fully structured ERD with **16 relational tables**, **stored procedures**, and **triggers** to handle data integrity, constraints, and automation for enrollment workflows.

---

## 📌 Features

- ✅ Student Information Management  
- ✅ Course & Subject Tracking  
- ✅ Instructor Assignment  
- ✅ Subject Scheduling (Time, Day, Room)  
- ✅ Enrollment with Conflict Checking  
- ✅ Automatic Logging & Validation via Triggers  
- ✅ Stored Procedures for Automation  
- ✅ Archive system for dropped enrollments

---

## 🗃️ Database Structure (16 Tables)

1. `tbl_STUDENT`  
2. `tbl_COURSE`  
3. `tbl_DEPARTMENT`  
4. `tbl_STUD_AFFILIATION`  
5. `tbl_SUBJECT`  
6. `tbl_SEMESTER`  
7. `tbl_SCHOOL_YEAR`  
8. `tbl_DAY`  
9. `tbl_ROOM`  
10. `tbl_SUBJECT_SCHEDULE`  
11. `tbl_ENROLLMENT`  
12. `tbl_enrollment_archive`  
13. `tbl_INSTRUCTOR`  
14. `tbl_FACULTY_ASSIGNMENT`  
15. `tbl_FACULTY_SUB_ASS`  
16. `tbl_USER_ACCOUNT`

---

## ⚙️ Stored Procedures

- `sp_add_student`
- `sp_enroll_student`
- `sp_assign_instructor`
- `sp_add_subject`
- `sp_add_course`
- `sp_promote_sy`
- `sp_mass_promote_students`

---

## ⚡ Triggers

Includes validation and automation logic like:

- Preventing duplicate enrollments
- Enforcing subject schedule limits
- Archiving dropped enrollments
- Default role settings
- Conflict checks (room, time, etc.)

---

## 📥 How to Use

1. Clone the repository:

    ```bash
    git clone https://github.com/YOUR_USERNAME/College_Enrollment_System.git
    cd College_Enrollment_System
    ```

2. Import the SQL file into MariaDB:

    ```bash
    mysql -u root -p < college_enrollment_system_full.sql
    ```

3. Explore the tables, triggers, and procedures.

---

## 💡 Notes

- Virtual environments (`venv/`) and other cache files are excluded using `.gitignore`.
- The system is modular and ready to be paired with a front-end like Flask or Laravel.

---

## 👨‍💻 Developed by

**Harold Jey Nahid Madjos** 
BSCS Student | Data Scientist | Data Analyst | Software Developer | Software Engineer | AI & Cybersecurity Enthusiast

---

