-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Employee_Skills;
DROP TABLE IF EXISTS Skills;
DROP TABLE IF EXISTS Employees_Normalized;
DROP TABLE IF EXISTS Employees_1NF_Violation;

-- 1. Create a table that violates 1NF.
-- The 'employee_skills' column is non-atomic.
CREATE TABLE Employees_1NF_Violation (
    employee_id SERIAL PRIMARY KEY,
    employee_name VARCHAR(100),
    employee_skills TEXT -- Example: 'Python, SQL, AWS'
);

-- 2. Insert sample data.
-- Diana Prince and Clark Kent have multiple skills listed in a single column.
INSERT INTO Employees_1NF_Violation (employee_name, employee_skills) VALUES
('Diana Prince', 'Java, Spring, Docker'),
('Bruce Wayne', 'Project Management, Finance'),
('Clark Kent', 'Journalism, Investigation, Super Strength');

SELECT * FROM Employees_1NF_Violation;

-- 3. Normalize to 1NF.
-- Create separate tables for employees, skills, and the many-to-many relationship between them.
-- `Employees_Normalized` table: Stores unique employee data.
CREATE TABLE Employees_Normalized (
    employee_id SERIAL PRIMARY KEY,
    employee_name VARCHAR(100)
);

-- `Skills` table: Stores unique skill names. This prevents repeating skill names.
CREATE TABLE Skills (
    skill_id SERIAL PRIMARY KEY,
    skill_name VARCHAR(100) UNIQUE
);

-- `Employee_Skills` table: This is a junction table. It holds foreign keys from
-- `Employees_Normalized` and `Skills`. This correctly models the many-to-many relationship.
-- The composite primary key ensures that each employee-skill pair is unique.
CREATE TABLE Employee_Skills (
    employee_id INTEGER REFERENCES Employees_Normalized(employee_id),
    skill_id INTEGER REFERENCES Skills(skill_id),
    PRIMARY KEY (employee_id, skill_id)
);

-- 4. Insert data into normalized tables.
-- First, populate the `Employees_Normalized` and `Skills` tables.
INSERT INTO Employees_Normalized (employee_name) VALUES
('Diana Prince'), ('Bruce Wayne'), ('Clark Kent');

INSERT INTO Skills (skill_name) VALUES
('Java'), ('Spring'), ('Docker'), ('Project Management'), ('Finance'), ('Journalism'), ('Investigation'), ('Super Strength');

-- Then, populate the junction table to link the employees and their skills.
INSERT INTO Employee_Skills (employee_id, skill_id) VALUES
(1, 1), (1, 2), (1, 3), -- Diana's skills
(2, 4), (2, 5),          -- Bruce's skills
(3, 6), (3, 7), (3, 8);  -- Clark's skills

-- 5. Query the normalized data.
-- Use two JOINs to connect the `Employees_Normalized`, `Employee_Skills`, and `Skills` tables.
-- This query returns a clean, structured list of each employee and their individual skills.
SELECT
    e.employee_name,
    s.skill_name
FROM Employees_Normalized e
JOIN Employee_Skills es ON e.employee_id = es.employee_id
JOIN Skills s ON es.skill_id = s.skill_id;
