-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Employee_Projects_Normalized;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS EmployeeProjects_2NF_Violation;

-- 1. Create a table that violates 2NF.
-- The primary key is `(employee_id, project_id)`.
-- `employee_name` and `department_location` depend only on `employee_id`. This is a partial dependency.
CREATE TABLE EmployeeProjects_2NF_Violation (
    employee_id INTEGER,
    project_id INTEGER,
    employee_name VARCHAR(100),
    department_location VARCHAR(100),
    hours_worked INTEGER,
    PRIMARY KEY (employee_id, project_id)
);

-- 2. Insert sample data.
-- Notice the redundancy: 'John Doe' and 'New York' are repeated because he is on two projects.
INSERT INTO EmployeeProjects_2NF_Violation (employee_id, project_id, employee_name, department_location, hours_worked) VALUES
(1, 10, 'John Doe', 'New York', 40),
(1, 20, 'John Doe', 'New York', 20),
(2, 10, 'Jane Smith', 'London', 35);

SELECT * FROM EmployeeProjects_2NF_Violation;

-- 3. Normalize to 2NF.
-- Create a new `Employees` table to remove the partial dependency.
-- `Employees` table: Stores employee information once.
CREATE TABLE Employees (
    employee_id SERIAL PRIMARY KEY,
    employee_name VARCHAR(100),
    department_location VARCHAR(100)
);

-- `Employee_Projects_Normalized` table: This table now only contains columns that are fully dependent
-- on the composite primary key `(employee_id, project_id)`.
CREATE TABLE Employee_Projects_Normalized (
    employee_id INTEGER REFERENCES Employees(employee_id),
    project_id INTEGER,
    hours_worked INTEGER,
    PRIMARY KEY (employee_id, project_id)
);

-- 4. Insert data into normalized tables.
-- Populate the `Employees` table first, removing redundant employee information.
INSERT INTO Employees (employee_id, employee_name, department_location) VALUES (1, 'John Doe', 'New York'), (2, 'Jane Smith', 'London');

-- Then, insert the project data, linking to the new `Employees` table.
INSERT INTO Employee_Projects_Normalized (employee_id, project_id, hours_worked) VALUES (1, 10, 40), (1, 20, 20), (2, 10, 35);

-- 5. Query the normalized data.
-- Use a JOIN to combine the employee and project information.
SELECT
    e.employee_name,
    e.department_location,
    ep.project_id,
    ep.hours_worked
FROM Employees e
JOIN Employee_Projects_Normalized ep ON e.employee_id = ep.employee_id;
