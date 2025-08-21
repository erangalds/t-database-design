# **Module 8: The Art of Denormalization**

- **Theory:** While normalization is the gold standard for data integrity, there are times when it's beneficial to deliberately introduce redundancy to boost performance. This is called **denormalization**. The trade-off is simple: you make `SELECT` queries faster by avoiding `JOIN` operations, but you make `INSERT`, `UPDATE`, and `DELETE`operations slower because you have to update the redundant data. This is typically done for highly frequent, read-heavy operations where a small performance gain can have a big impact.
    
- **PostgreSQL Example:**
    
    - Show a scenario where a denormalized column (e.g., adding `user_name` to the `posts` table) can improve the performance of a frequently run query, even though it introduces redundancy.

```SQL
-- This script demonstrates a case where denormalization can improve performance.

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

-- 6. Now, the same query is much simpler and faster.
-- - No JOIN is needed.

SELECT title, username
FROM posts_denormalized;
```