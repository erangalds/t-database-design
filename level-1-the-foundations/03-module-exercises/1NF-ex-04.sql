-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Book_Genres;
DROP TABLE IF EXISTS Genres;
DROP TABLE IF EXISTS Books_Normalized;
DROP TABLE IF EXISTS Books_1NF_Violation;

-- 1. Create a table that violates 1NF.
-- The 'book_genres' column is not atomic.
CREATE TABLE Books_1NF_Violation (
    book_id SERIAL PRIMARY KEY,
    book_title VARCHAR(255),
    book_genres TEXT -- Example: 'Fantasy, Adventure'
);

-- 2. Insert sample data.
-- The 'book_genres' column contains lists of genres.
INSERT INTO Books_1NF_Violation (book_title, book_genres) VALUES
('The Way of Kings', 'Fantasy, Epic'),
('Dune', 'Science Fiction, Adventure');

SELECT * FROM Books_1NF_Violation;

-- 3. Normalize to 1NF.
-- Create three tables to handle the many-to-many relationship between books and genres.
CREATE TABLE Books_Normalized (
    book_id SERIAL PRIMARY KEY,
    book_title VARCHAR(255)
);

CREATE TABLE Genres (
    genre_id SERIAL PRIMARY KEY,
    genre_name VARCHAR(50) UNIQUE
);

-- The junction table `Book_Genres` links books and genres.
CREATE TABLE Book_Genres (
    book_id INTEGER REFERENCES Books_Normalized(book_id),
    genre_id INTEGER REFERENCES Genres(genre_id),
    PRIMARY KEY (book_id, genre_id)
);

-- 4. Insert data into normalized tables.
-- First, populate the `Books_Normalized` and `Genres` tables.
INSERT INTO Books_Normalized (book_title) VALUES ('The Way of Kings'), ('Dune');
INSERT INTO Genres (genre_name) VALUES ('Fantasy'), ('Epic'), ('Science Fiction'), ('Adventure');

-- Then, populate the junction table with the correct book-genre pairings.
INSERT INTO Book_Genres (book_id, genre_id) VALUES
(1, 1), (1, 2), -- 'The Way of Kings' genres
(2, 3), (2, 4); -- 'Dune' genres

-- 5. Query the normalized data.
-- Use two JOINs to connect the tables and display the book and its genres.
SELECT
    b.book_title,
    g.genre_name
FROM Books_Normalized b
JOIN Book_Genres bg ON b.book_id = bg.book_id
JOIN Genres g ON bg.genre_id = g.genre_id;
