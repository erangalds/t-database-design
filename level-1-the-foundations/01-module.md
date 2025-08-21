# **Module 1: What is a Database?**

- **Theory:** At its core, a **database** is just an organized collection of data. A **Relational Database Management System (RDBMS)**, like PostgreSQL, is the software used to manage that data. The most basic building block is a **table**, which is structured like a spreadsheet with rows and columns. A **column** defines an attribute (like a name or email address), and a **row** represents a single record or entry. The **schema** is the blueprint that defines the structure of all your tables and their relationships.
    
- **PostgreSQL Example:**
    
    - Create a simple `users` table.
        
    - Insert a few sample users.
        
    - Query the table to show the basic structure.

```SQL
-- This script demonstrates the most basic concepts:
-- Creating a table, inserting data, and querying it.

-- 1. Drop the table if it already exists to ensure a clean state
DROP TABLE IF EXISTS users;

-- 2. Create the users table with three columns:
-- - id: A unique integer identifier for each user.
-- - first_name: A string for the user's first name.
-- - last_name: A string for the user's last name.
CREATE TABLE users (
id SERIAL PRIMARY KEY,
first_name VARCHAR(50),
last_name VARCHAR(50)
);

-- 3. Insert some sample data into the users table.
INSERT INTO users (first_name, last_name) VALUES
('Alice', 'Johnson'),
('Bob', 'Smith'),
('Charlie', 'Brown');

-- 4. Select all data from the users table to view the results.
SELECT * FROM users;
```
