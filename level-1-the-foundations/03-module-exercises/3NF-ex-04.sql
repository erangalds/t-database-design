-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Events_Normalized;
DROP TABLE IF EXISTS Venues;
DROP TABLE IF EXISTS Events_3NF_Violation;

-- 1. Create a table that violates 3NF.
-- `venue_city` depends on `venue_name` (a non-key column).
-- Transitive dependency: event_id -> venue_name -> venue_city.
CREATE TABLE Events_3NF_Violation (
    event_id SERIAL PRIMARY KEY,
    event_name VARCHAR(100),
    venue_name VARCHAR(100),
    venue_city VARCHAR(100) -- This is the transitive dependency.
);

-- 2. Insert sample data.
-- 'New York' is repeated because two events are at 'Madison Square Garden'.
INSERT INTO Events_3NF_Violation (event_name, venue_name, venue_city) VALUES
('Concert A', 'Madison Square Garden', 'New York'),
('Conference B', 'Moscone Center', 'San Francisco'),
('Sports Game C', 'Madison Square Garden', 'New York');

SELECT * FROM Events_3NF_Violation;

-- 3. Normalize to 3NF.
-- Create a `Venues` table to remove the transitive dependency.
-- `Venues` table: Stores venue information once.
CREATE TABLE Venues (
    venue_id SERIAL PRIMARY KEY,
    venue_name VARCHAR(100) UNIQUE,
    venue_city VARCHAR(100)
);

-- `Events_Normalized` table: `venue_name` and `venue_city` are replaced with a foreign key `venue_id`.
CREATE TABLE Events_Normalized (
    event_id SERIAL PRIMARY KEY,
    event_name VARCHAR(100),
    venue_id INTEGER REFERENCES Venues(venue_id)
);

-- 4. Insert data into normalized tables.
-- Populate the `Venues` table first.
INSERT INTO Venues (venue_name, venue_city) VALUES ('Madison Square Garden', 'New York'), ('Moscone Center', 'San Francisco');

-- Then, insert the event data, linking to the new `Venues` table.
INSERT INTO Events_Normalized (event_name, venue_id) VALUES ('Concert A', 1), ('Conference B', 2), ('Sports Game C', 1);

-- 5. Query the normalized data.
-- Use a JOIN to combine the event and venue information.
SELECT
    e.event_name,
    v.venue_name,
    v.venue_city
FROM Events_Normalized e
JOIN Venues v ON e.venue_id = v.venue_id;