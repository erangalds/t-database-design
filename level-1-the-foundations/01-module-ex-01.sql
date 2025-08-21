-- This script demonstrates the most basic concepts:
-- Creating a table, inserting data, and querying it.

-- 0. Checking current db context
SELECT current_database(), current_schema(), CURRENT_USER;
SELECT CURRENT_SCHEMA, CURRENT_USER;

-- Show current tables in the current schema using the information schema
SELECT table_name
FROM information_schema.tables
WHERE table_schema = current_schema();

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

-- 5. Describe Table
-- In psql, you can use the command `\d users` to describe the table.
-- To get table structure information using a standard SQL query:
-- Below statement is specific to Postgres. 
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM
    information_schema.columns
WHERE
    table_schema = current_schema() AND table_name = 'users';
