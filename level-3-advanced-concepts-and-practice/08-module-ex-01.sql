-- This script demonstrates a case where denormalization can improve performance.
-- 0. Checking the current context
SELECT current_database(), current_schema(), current_user ;

-- Listing the current tables in the schema
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

-- Drop existing tables
DROP TABLE IF EXISTS posts_denormalized;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS users;

-- 1. Create normalized tables: users and posts.
CREATE TABLE users (
id SERIAL PRIMARY KEY,
username VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE posts (
id SERIAL PRIMARY KEY,
title VARCHAR(255),
user_id INTEGER NOT NULL,
FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 2. Insert sample data.
INSERT INTO users (username) VALUES ('jdoe'), ('asmith');
INSERT INTO posts (title, user_id) VALUES
('First post by Jane', 1),
('Second post by Jane', 1),
('Post by Alex', 2);
-- Verify Data Insertion
SELECT * FROM users;
SELECT * FROM posts;

-- 3. To get the username with each post, we need a JOIN.
-- - This is the standard, normalized approach.
SELECT p.title, u.username
FROM posts p
JOIN users u ON p.user_id = u.id;

-- 4. Now, let's create a denormalized version of the posts table.
-- - We'll add the 'username' column directly to the 'posts' table.
-- - This breaks normalization but can improve read performance on large datasets.
CREATE TABLE posts_denormalized (
id SERIAL PRIMARY KEY,
title VARCHAR(255),
user_id INTEGER NOT NULL,
username VARCHAR(50) NOT NULL -- Denormalized column
);

-- 5. Insert data into the denormalized table.
INSERT INTO posts_denormalized (title, user_id, username) VALUES
('First post by Jane', 1, 'jdoe'),
('Second post by Jane', 1, 'jdoe'),
('Post by Alex', 2, 'asmith');
-- Verify Data Insertion
SELECT * FROM posts_denormalized;

-- 6. Now, the same query is much simpler and faster.
-- - No JOIN is needed.
SELECT title, username
FROM posts_denormalized;

-- CLEAN the Environment
DROP TABLE IF EXISTS posts_denormalized;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS users;