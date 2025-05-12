-- Creating Database
CREATE DATABASE StudentRecordsDB;
USE StudentRecordsDB;

-- Creating the Students table
CREATE TABLE Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    registered_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
select * from Students;
-- Creating the Courses table
CREATE TABLE Courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(150) NOT NULL,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    credits INT NOT NULL
);

-- Creating the Enrollments table that Tracks which students are enrolled in which courses
CREATE TABLE Enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE
);

-- Creating the Grades table (Stores student performance)
CREATE TABLE Grades (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT,
    grade CHAR(2) CHECK (grade IN ('A', 'B', 'C', 'D', 'E', 'F')),
    graded_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (enrollment_id) REFERENCES Enrollments(enrollment_id) ON DELETE CASCADE
);
-- Creating the Attendance table
CREATE TABLE Attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT,
    attendance_date DATE NOT NULL,
    status ENUM('Present', 'Absent') NOT NULL,
    FOREIGN KEY (enrollment_id) REFERENCES Enrollments(enrollment_id) ON DELETE CASCADE
);
-- Creating the Fees table
CREATE TABLE Fees (
    fee_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    amount DECIMAL(10,2) NOT NULL,
    payment_status ENUM('Paid', 'Pending') NOT NULL,
    payment_date DATE,
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE
);
-- Creating the Library table
CREATE TABLE Library (
    borrow_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    book_title VARCHAR(255) NOT NULL,
    borrow_date DATE NOT NULL,
    return_date DATE,
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE
);

-- Creating the Users table (Manages system users)
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'reporting', 'data_entry', 'backup', 'audit') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creating the Audit Log table
CREATE TABLE AuditLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    operation VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE SET NULL
);
-- Creating Indexes for Optimized Queries
CREATE INDEX idx_student_email ON Students(email);
CREATE INDEX idx_course_code ON Courses(course_code);
CREATE INDEX idx_enrollment ON Enrollments(student_id, course_id);

-- Creating a View for Quick Reporting
CREATE VIEW StudentGradesReport AS
SELECT s.name AS StudentName, c.course_name AS CourseName, g.grade
FROM Grades g
JOIN Enrollments e ON g.enrollment_id = e.enrollment_id
JOIN Students s ON e.student_id = s.student_id
JOIN Courses c ON e.course_id = c.course_id;

-- Creating a Stored Procedure to Enroll a Student
DELIMITER //
CREATE PROCEDURE EnrollStudent(IN student_id INT, IN course_id INT)
BEGIN
    INSERT INTO Enrollments (student_id, course_id) VALUES (student_id, course_id);
END //
DELIMITER ;

-- Creating a Trigger to Ensure Grades Are Inserted Only for Enrolled Students
DELIMITER //
CREATE TRIGGER EnsureValidGrade BEFORE INSERT ON Grades
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Enrollments WHERE enrollment_id = NEW.enrollment_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Enrollment does not exist!';
    END IF;
END //
DELIMITER ;

-- Inserting Sample Data
INSERT INTO Students (name, email, phone, date_of_birth) VALUES
('Rency Jeptanui', 'jeps@gmail.com', '254-722-51415', '2003-07-15'),
('Resly Jerop', 'jerop@gmai.com', '254-654-61623', '2005-08-21');

INSERT INTO Courses (course_name, course_code, credits) VALUES
('Mathematics', 'MATH101', 3),
('Computer Science', 'CS102', 4);

CALL EnrollStudent(1, 1);
CALL EnrollStudent(2, 2);

INSERT INTO Grades (enrollment_id, grade) VALUES
(1, 'A'),
(2, 'B');
-- Creating users with appropriate privileges
CREATE USER 'admuser'@'localhost' IDENTIFIED BY 'adminPass123';
CREATE USER 'report_user'@'localhost' IDENTIFIED BY 'ReadOnlyPass';
CREATE USER 'data_entry'@'localhost' IDENTIFIED BY 'DataEntryPass';
CREATE USER 'backup_user'@'localhost' IDENTIFIED BY 'BackupPass';
CREATE USER 'audit_user'@'localhost' IDENTIFIED BY 'AuditPass';

-- Granting privileges to each role
GRANT ALL PRIVILEGES ON StudentRecordsDB.* TO 'admuser'@'localhost' WITH GRANT OPTION;
GRANT SELECT ON StudentRecordsDB.* TO 'report_user'@'localhost';
GRANT INSERT, UPDATE ON StudentRecordsDB.* TO 'data_entry'@'localhost';
GRANT LOCK TABLES, SELECT, FILE ON *.* TO 'backup_user'@'localhost';
GRANT SELECT, SHOW DATABASES, PROCESS ON *.* TO 'audit_user'@'localhost';

-- Applying changes
FLUSH PRIVILEGES;
