-- Example 3: Achieving 3NF by removing transitive dependencies
-- Drop existing tables
DROP TABLE IF EXISTS authors_3nf_normalized;
DROP TABLE IF EXISTS books_3nf_normalized;
DROP TABLE IF EXISTS books_3nf_violation;

-- 1. Create a table that violates 3NF.
-- 'author_country' is transitively dependent on 'book_id'
-- through 'author_name'.
CREATE TABLE books_3nf_violation (
    book_id SERIAL PRIMARY KEY,
    book_title VARCHAR(255),
    author_name VARCHAR(100),
    author_country VARCHAR(100)
);

-- 2. Insert sample data. Note the redundancy in author information.
INSERT INTO books_3nf_violation (book_title, author_name, author_country) VALUES
('The Lord of the Rings', 'J.R.R. Tolkien', 'United Kingdom'),
('The Hobbit', 'J.R.R. Tolkien', 'United Kingdom'), -- Redundancy here
('Dune', 'Frank Herbert', 'United States');

-- 3. Normalize to 3NF by splitting the table.
-- We'll create a separate 'authors' table to remove the transitive dependency.
CREATE TABLE authors_3nf_normalized (
    author_id SERIAL PRIMARY KEY,
    author_name VARCHAR(100) UNIQUE,
    author_country VARCHAR(100)
);

CREATE TABLE books_3nf_normalized (
    book_id SERIAL PRIMARY KEY,
    book_title VARCHAR(255),
    author_id INTEGER REFERENCES authors_3nf_normalized(author_id)
);

-- 4. Insert data into the normalized tables.
INSERT INTO authors_3nf_normalized (author_name, author_country) VALUES
('J.R.R. Tolkien', 'United Kingdom'),
('Frank Herbert', 'United States');

-- 5. Insert into the books table using the foreign key.
INSERT INTO books_3nf_normalized (book_title, author_id) VALUES
('The Lord of the Rings', 1),
('The Hobbit', 1),
('Dune', 2);

-- 6. Query the normalized tables using a JOIN.
SELECT
    b.book_title,
    a.author_name,
    a.author_country
FROM books_3nf_normalized b
JOIN authors_3nf_normalized a ON b.author_id = a.author_id;
