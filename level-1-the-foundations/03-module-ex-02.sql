-- Example 1: Fixing a 1NF Violation by creating a junction table
-- Drop existing tables to start fresh
DROP TABLE IF EXISTS student_courses;
DROP TABLE IF EXISTS students_1nf_violation;
DROP TABLE IF EXISTS students_normalized;
DROP TABLE IF EXISTS courses;

-- 1. Create a table that violates 1NF with a non-atomic 'courses' column.
-- This is bad practice and makes querying difficult.
CREATE TABLE students_1nf_violation (
    student_id SERIAL PRIMARY KEY,
    student_name VARCHAR(100),
    courses TEXT -- Non-atomic value (e.g., 'Math, Physics, Chemistry')
);

-- 2. Insert sample data with repeating groups.
INSERT INTO students_1nf_violation (student_name, courses) VALUES
('Alex Johnson', 'History, Literature'),
('Beth Williams', 'Math, Physics, Chemistry'),
('Charlie Davis', 'Biology');

-- 3. Now, let's normalize this data to 1NF.
-- We'll create a normalized 'students' table and a separate 'courses' table.
-- Then we'll use a junction table to link them.
CREATE TABLE students_normalized (
    student_id SERIAL PRIMARY KEY,
    student_name VARCHAR(100)
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(100) UNIQUE
);

-- 4. Create the junction table to handle the many-to-many relationship
-- A student can take many courses, and a course can have many students.
CREATE TABLE student_courses (
    student_id INTEGER REFERENCES students_normalized(student_id),
    course_id INTEGER REFERENCES courses(course_id),
    PRIMARY KEY (student_id, course_id)
);

-- 5. Insert data into the normalized tables.
INSERT INTO students_normalized (student_name) VALUES
('Alex Johnson'),
('Beth Williams'),
('Charlie Davis');

INSERT INTO courses (course_name) VALUES
('History'),
('Literature'),
('Math'),
('Physics'),
('Chemistry'),
('Biology');

-- 6. Now, insert into the junction table to link students to their courses.
INSERT INTO student_courses (student_id, course_id) VALUES
(1, 1), -- Alex takes History
(1, 2), -- Alex takes Literature
(2, 3), -- Beth takes Math
(2, 4), -- Beth takes Physics
(2, 5), -- Beth takes Chemistry
(3, 6); -- Charlie takes Biology

-- 7. Query the normalized tables to get the full data.
SELECT
    s.student_name,
    c.course_name
FROM students_normalized s
JOIN student_courses sc ON s.student_id = sc.student_id
JOIN courses c ON sc.course_id = c.course_id;