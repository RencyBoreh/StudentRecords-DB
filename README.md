Student Record Management System
 Project Overview
The Student Record Management System is a relational database designed using MySQL to efficiently
track student records, course enrollments, academic performance, attendance, financial transactions,
and library usage. It provides structured storage, seamless querying, and robust security through user roles and audit logs.

Features
- Student Management – Store student details like name, contact info, and enrollment date.
- Course Management – Define courses with unique codes and credits. 
- Enrollment Tracking – Link students to courses dynamically.
- Grades System – Maintain academic performance records. 
- Attendance Monitoring – Track student attendance per enrollment.
- Fee Management – Manage financial records and payments. 
- Library Tracking – Log book borrowing and return details. 
- User Roles & Security – Ensure data access control (Admin, Reporting, Data Entry). 
- Audit Logging – Record database modifications for security tracking.

ER Diagram Overview
The database schema follows a structured Entity-Relationship Model (ERD):

1-to-Many: 
         Students → Enrollments,
         Courses → Enrollments, 
         Users → Audit Log

Many-to-Many : Students ↔ Courses

1-to-1: Enrollments → Grades
## ERD Link
![ER DIAGRAM](https://github.com/RencyBoreh/StudentRecords-DB/blob/aaf0de20d22189ce241c1ce2c8c1ea7d16033faf/StudentRecordER-Diagram.JPG)

-- Technologies Used
Database: MySQL
ERD Tools: Draw.io
Security Features: User roles, permissions, and audit logging
SQL Features: Stored Procedures, Indexing, Triggers, Views
