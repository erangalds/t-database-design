-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Flights;
DROP TABLE IF EXISTS FlightBookings_2NF_Violation;

-- 1. Create a table that violates 2NF.
-- The primary key is `(passenger_id, flight_id)`.
-- `departure_airport` and `arrival_airport` depend only on `flight_id`, a partial dependency.
CREATE TABLE FlightBookings_2NF_Violation (
    passenger_id INTEGER,
    flight_id INTEGER,
    departure_airport VARCHAR(3),
    arrival_airport VARCHAR(3),
    seat_number VARCHAR(4),
    PRIMARY KEY (passenger_id, flight_id)
);

-- 2. Insert sample data.
-- 'JFK' and 'LAX' are repeated because two passengers are on flight 101.
INSERT INTO FlightBookings_2NF_Violation (passenger_id, flight_id, departure_airport, arrival_airport, seat_number) VALUES
(1, 101, 'JFK', 'LAX', '12A'),
(2, 101, 'JFK', 'LAX', '12B'),
(3, 202, 'LHR', 'CDG', '22F');

SELECT * FROM FlightBookings_2NF_Violation;

-- 3. Normalize to 2NF.
-- Create a `Flights` table to remove the partial dependency.
-- `Flights` table: Stores flight information once.
CREATE TABLE Flights (
    flight_id SERIAL PRIMARY KEY,
    departure_airport VARCHAR(3),
    arrival_airport VARCHAR(3)
);

-- `Bookings` table: This table now only contains columns (`seat_number`) that are fully dependent
-- on the composite primary key `(passenger_id, flight_id)`.
CREATE TABLE Bookings (
    passenger_id INTEGER,
    flight_id INTEGER REFERENCES Flights(flight_id),
    seat_number VARCHAR(4),
    PRIMARY KEY (passenger_id, flight_id)
);

-- 4. Insert data into normalized tables.
-- Populate the `Flights` table first.
INSERT INTO Flights (flight_id, departure_airport, arrival_airport) VALUES (101, 'JFK', 'LAX'), (202, 'LHR', 'CDG');

-- Then, insert the booking data, linking to the new `Flights` table.
INSERT INTO Bookings (passenger_id, flight_id, seat_number) VALUES (1, 101, '12A'), (2, 101, '12B'), (3, 202, '22F');

-- 5. Query the normalized data.
-- Use a JOIN to combine the booking and flight information.
SELECT
    b.passenger_id,
    f.departure_airport,
    f.arrival_airport,
    b.seat_number
FROM Bookings b
JOIN Flights f ON b.flight_id = f.flight_id;