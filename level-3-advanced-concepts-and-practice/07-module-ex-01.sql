-- This script demonstrates Table Inheritance and Materialized Views.
-- 0. Checking the current context
SELECT current_database(), current_schema(), current_user ;

-- Listing the current tables in the schema
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

-- Drop existing tables and materialized views
DROP TABLE IF EXISTS books, electronics, products;
DROP MATERIALIZED VIEW IF EXISTS user_post_counts;

-- 1. Table Inheritance: Create a parent 'products' table.
CREATE TABLE products (
id SERIAL PRIMARY KEY,
name VARCHAR(255) NOT NULL,
price DECIMAL(10, 2) NOT NULL
);

-- 2. Create child tables that inherit from 'products'.
-- - They automatically get the columns from the parent table.
CREATE TABLE books (
author VARCHAR(255)
) INHERITS (products);

CREATE TABLE electronics (
power_supply VARCHAR(50)
) INHERITS (products);

-- 3. Insert data into the child tables.
INSERT INTO books (name, price, author) VALUES ('The Hitchhiker''s Guide', 12.99, 'Douglas Adams');
INSERT INTO electronics (name, price, power_supply) VALUES ('Portable Speaker', 59.99, 'USB-C');

-- 4. Query the parent table to see data from both child tables.
SELECT * FROM products;
-- Query the Child Tables also
SELECT * FROM books;
SELECT * FROM electronics;

-- 5. Materialized Views: Create a complex query to count posts per user.
-- Let's Check the Users table and Posts table before creating the VIEW
SELECT * FROM users;
SELECT * FROM posts;
SELECT * FROM post_tags;
-- Create a normal view first with CREATE VIEW Statement
CREATE OR REPLACE VIEW user_post_counts_view AS
SELECT
u.username,
COUNT(p.id) AS post_count
FROM users u
JOIN posts p ON u.id = p.user_id
GROUP BY u.username;

-- Query the view
SELECT * FROM user_post_counts_view;

-- 6. Now, create a Materialized View from that query.
-- - The result is stored on disk, so future queries are much faster.
-- - We need to create dummy users and posts tables first for this to work.
DROP VIEW IF EXISTS user_post_counts_view;
DROP TABLE IF EXISTS post_tags, posts, users;

CREATE TABLE users (id SERIAL PRIMARY KEY, username VARCHAR(50));

CREATE TABLE posts (id SERIAL PRIMARY KEY, user_id INTEGER, title VARCHAR(255));

INSERT INTO users (username) VALUES ('jdoe'), ('asmith');
INSERT INTO posts (user_id, title) VALUES (1, 'post1'), (1, 'post2'), (2, 'post3');

CREATE MATERIALIZED VIEW user_post_counts AS

SELECT
u.username,
COUNT(p.id) AS post_count
FROM users u
JOIN posts p ON u.id = p.user_id
GROUP BY u.username;

-- 7. Query the materialized view. It's fast because it's already calculated.
SELECT * FROM user_post_counts;

-- 8. To get fresh data, you must manually refresh the materialized view.

-- - Note: This locks the view, so be careful on a production database.
INSERT INTO posts (user_id, title) VALUES (1, 'post4');
-- Check for the latest data insertion
SELECT * FROM user_post_counts;
-- Refresh the Materialized VIEW
REFRESH MATERIALIZED VIEW user_post_counts;
-- Now Check again
SELECT * FROM user_post_counts;

-- CLEAN THE Environment
DROP MATERIALIZED VIEW IF EXISTS user_post_counts;
DROP TABLE IF EXISTS books, electronics, products;
DROP VIEW IF EXISTS user_post_counts_view;