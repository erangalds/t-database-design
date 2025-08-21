-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Employees_Normalized;
DROP TABLE IF EXISTS Departments;
DROP TABLE IF EXISTS Employees_3NF_Violation;

-- 1. Create a table that violates 3NF.
-- The primary key is `employee_id`. `manager_name` depends on `department_name`, not on `employee_id`.
-- This is a transitive dependency: employee_id -> department_name -> manager_name.
CREATE TABLE Employees_3NF_Violation (
    employee_id SERIAL PRIMARY KEY,
    employee_name VARCHAR(100),
    department_name VARCHAR(100),
    manager_name VARCHAR(100) -- This is the transitive dependency.
);

-- 2. Insert sample data.
-- Notice the redundancy: 'Mr. Anderson' is repeated for every employee in the 'IT' department.
INSERT INTO Employees_3NF_Violation (employee_name, department_name, manager_name) VALUES
('Neo', 'IT', 'Mr. Anderson'),
('Trinity', 'IT', 'Mr. Anderson'),
('Morpheus', 'HR', 'Ms. Smith');

SELECT * FROM Employees_3NF_Violation;

-- 3. Normalize to 3NF.
-- Create a `Departments` table to remove the transitive dependency.
-- `Departments` table: Stores department and manager information once.
CREATE TABLE Departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) UNIQUE,
    manager_name VARCHAR(100)
);

-- `Employees_Normalized` table: The original `manager_name` column is removed and replaced by a foreign key
-- `department_id`, which directly links to the new `Departments` table.
CREATE TABLE Employees_Normalized (
    employee_id SERIAL PRIMARY KEY,
    employee_name VARCHAR(100),
    department_id INTEGER REFERENCES Departments(department_id)
);

-- 4. Insert data into normalized tables.
-- Populate the `Departments` table first.
INSERT INTO Departments (department_name, manager_name) VALUES ('IT', 'Mr. Anderson'), ('HR', 'Ms. Smith');

-- Then, insert the employee data, linking to the new `Departments` table.
INSERT INTO Employees_Normalized (employee_name, department_id) VALUES ('Neo', 1), ('Trinity', 1), ('Morpheus', 2);

-- 5. Query the normalized data.
-- Use a JOIN to combine the employee and department information.
SELECT
    e.employee_name,
    d.department_name,
    d.manager_name
FROM Employees_Normalized e
JOIN Departments d ON e.department_id = d.department_id;
