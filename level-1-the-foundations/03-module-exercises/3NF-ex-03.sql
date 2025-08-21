-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Students_Normalized;
DROP TABLE IF EXISTS Majors;
DROP TABLE IF EXISTS Students_3NF_Violation;

-- 1. Create a table that violates 3NF.
-- `department_head` depends on `major_name` (a non-key column).
-- Transitive dependency: student_id -> major_name -> department_head.
CREATE TABLE Students_3NF_Violation (
    student_id SERIAL PRIMARY KEY,
    student_name VARCHAR(100),
    major_name VARCHAR(100),
    department_head VARCHAR(100) -- This is the transitive dependency.
);

-- 2. Insert sample data.
-- 'Albus Dumbledore' is repeated because both Harry and Ron have the 'Defense Arts' major.
INSERT INTO Students_3NF_Violation (student_name, major_name, department_head) VALUES
('Harry Potter', 'Defense Arts', 'Albus Dumbledore'),
('Hermione Granger', 'Ancient Runes', 'Bathsheba Babbling'),
('Ron Weasley', 'Defense Arts', 'Albus Dumbledore');

SELECT * FROM Students_3NF_Violation;

-- 3. Normalize to 3NF.
-- Create a `Majors` table to remove the transitive dependency.
-- `Majors` table: Stores major and department head information once.
CREATE TABLE Majors (
    major_id SERIAL PRIMARY KEY,
    major_name VARCHAR(100) UNIQUE,
    department_head VARCHAR(100)
);

-- `Students_Normalized` table: `major_name` and `department_head` are replaced with a foreign key `major_id`.
CREATE TABLE Students_Normalized (
    student_id SERIAL PRIMARY KEY,
    student_name VARCHAR(100),
    major_id INTEGER REFERENCES Majors(major_id)
);

-- 4. Insert data into normalized tables.
-- Populate the `Majors` table first.
INSERT INTO Majors (major_name, department_head) VALUES ('Defense Arts', 'Albus Dumbledore'), ('Ancient Runes', 'Bathsheba Babbling');

-- Then, insert the student data, linking to the new `Majors` table.
INSERT INTO Students_Normalized (student_name, major_id) VALUES ('Harry Potter', 1), ('Hermione Granger', 2), ('Ron Weasley', 1);

-- 5. Query the normalized data.
-- Use a JOIN to combine the student and major information.
SELECT
    s.student_name,
    m.major_name,
    m.department_head
FROM Students_Normalized s
JOIN Majors m ON s.major_id = m.major_id;
