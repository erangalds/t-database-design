# **Module 2: Relational Concepts**

- **Theory:** The "relational" in RDBMS refers to how data is connected across multiple tables. These connections are made using **keys**. A **Primary Key** is a special column (or set of columns) that uniquely identifies each row in a table—think of it as a unique ID number. A **Foreign Key** is a column in one table that references the primary key of another table, creating a link between them. This is how we define relationships:
    
    - **One-to-One:** A single record in one table is linked to a single record in another (e.g., a user and their user profile).
        
    - **One-to-Many:** A single record in one table can be linked to multiple records in another (e.g., a single author can write many books).
        
    - **Many-to-Many:** Multiple records in one table can be linked to multiple records in another (e.g., a book can have many authors, and an author can write many books). This requires a separate "junction" or "join" table to connect the two.
        
- **PostgreSQL Example:**
    
    - Create a `posts` table that has a foreign key referencing the `users` table.
        
    - Demonstrate a many-to-many relationship by creating a `tags` table and a `post_tags` junction table.

```SQL
-- This script illustrates how to create relationships between tables
-- using Primary Keys and Foreign Keys.
-- Drop existing tables to start fresh
DROP TABLE IF EXISTS post_tags;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS tags;

-- 1. Create the 'users' table (our primary key source)
CREATE TABLE users (
id SERIAL PRIMARY KEY,
username VARCHAR(50) UNIQUE NOT NULL
);

-- 2. Create the 'posts' table with a one-to-many relationship to 'users'
-- - The 'user_id' column is a Foreign Key referencing the 'id' in the 'users' table.
CREATE TABLE posts (
id SERIAL PRIMARY KEY,
title VARCHAR(255) NOT NULL,
content TEXT,
user_id INTEGER NOT NULL,
FOREIGN KEY (user_id) REFERENCES users (id)
);

-- 3. Create the 'tags' table
CREATE TABLE tags (
id SERIAL PRIMARY KEY,
name VARCHAR(50) UNIQUE NOT NULL
);

-- 4. Create the 'post_tags' junction table for the many-to-many relationship
-- - It links posts to tags. A post can have many tags, and a tag can be on many posts.
CREATE TABLE post_tags (
post_id INTEGER NOT NULL,
tag_id INTEGER NOT NULL,
PRIMARY KEY (post_id, tag_id),
FOREIGN KEY (post_id) REFERENCES posts (id),
FOREIGN KEY (tag_id) REFERENCES tags (id)
);

-- 5. Insert sample data
INSERT INTO users (username) VALUES ('jdoe'), ('asmith');

INSERT INTO posts (title, content, user_id) VALUES
('My First Blog Post', 'Welcome to my blog.', 1),
('PostgreSQL is Awesome', 'Learning about databases is fun!', 1),
('A Day in the Park', 'Enjoyed the weather today.', 2);

INSERT INTO tags (name) VALUES ('tech'), ('personal'), ('learning');

INSERT INTO post_tags (post_id, tag_id) VALUES
(1, 2), -- 'My First Blog Post' has tag 'personal'
(2, 1), -- 'PostgreSQL is Awesome' has tag 'tech'
(2, 3), -- 'PostgreSQL is Awesome' also has tag 'learning'
(3, 2); -- 'A Day in the Park' has tag 'personal'
  
-- 6. Show the relationships with a JOIN query
-- - Find the tags for a specific post
SELECT
p.title,
t.name AS tag
FROM posts p
JOIN post_tags pt ON p.id = pt.post_id
JOIN tags t ON pt.tag_id = t.id
WHERE p.title = 'PostgreSQL is Awesome';

-- 7. Find all posts by a specific user
SELECT
p.title,
u.username
FROM posts p
JOIN users u ON p.user_id = u.id
WHERE u.username = 'jdoe';
```
