-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Enrollments;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Departments;
DROP TABLE IF EXISTS StudentEnrollment_2NF_Violation;

-- 1. Create a table that violates 2NF.
-- The primary key is `(student_id, course_id)`.
-- The `course_title` and `department_name` columns depend only on `course_id`, not on the full key.
CREATE TABLE StudentEnrollment_2NF_Violation (
    student_id INTEGER,
    course_id INTEGER,
    course_title VARCHAR(100),
    department_name VARCHAR(100),
    grade CHAR(1),
    PRIMARY KEY (student_id, course_id)
);

-- 2. Insert sample data.
-- Notice the redundancy: 'Intro to CS' and 'Computer Science' are repeated for each student taking the course.
INSERT INTO StudentEnrollment_2NF_Violation (student_id, course_id, course_title, department_name, grade) VALUES
(1, 101, 'Intro to CS', 'Computer Science', 'A'),
(2, 101, 'Intro to CS', 'Computer Science', 'B'),
(1, 201, 'Calculus I', 'Mathematics', 'A');

SELECT * FROM StudentEnrollment_2NF_Violation;

-- 3. Normalize to 2NF.
-- Create new tables to remove the partial and transitive dependencies.
-- `Departments` table: Stores unique departments.
CREATE TABLE Departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) UNIQUE
);

-- `Courses` table: Stores course information. `course_title` now depends on `course_id`.
-- This table also links to `Departments`, which removes a transitive dependency.
CREATE TABLE Courses (
    course_id SERIAL PRIMARY KEY,
    course_title VARCHAR(100),
    department_id INTEGER REFERENCES Departments(department_id)
);

-- `Enrollments` table: Contains the composite key and `grade`, which is fully dependent on both `student_id` and `course_id`.
CREATE TABLE Enrollments (
    student_id INTEGER,
    course_id INTEGER REFERENCES Courses(course_id),
    grade CHAR(1),
    PRIMARY KEY (student_id, course_id)
);

-- 4. Insert data into normalized tables.
-- Populate the `Departments` and `Courses` tables first.
INSERT INTO Departments (department_name) VALUES ('Computer Science'), ('Mathematics');
INSERT INTO Courses (course_id, course_title, department_id) VALUES (101, 'Intro to CS', 1), (201, 'Calculus I', 2);

-- Then, insert the enrollment data, linking to the new `Courses` table.
INSERT INTO Enrollments (student_id, course_id, grade) VALUES (1, 101, 'A'), (2, 101, 'B'), (1, 201, 'A');

-- 5. Query the normalized data.
-- Use JOINs to retrieve the student, course, department, and grade information.
-- The query demonstrates how the data is now correctly structured without redundancy.
SELECT
    e.student_id,
    c.course_title,
    d.department_name,
    e.grade
FROM Enrollments e
JOIN Courses c ON e.course_id = c.course_id
JOIN Departments d ON c.department_id = d.department_id;
