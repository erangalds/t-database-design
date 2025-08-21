-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Orders_Normalized;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Orders_3NF_Violation;

-- 1. Create a table that violates 3NF.
-- The primary key is `order_id`. `customer_city` depends on `customer_name`, which is not the primary key.
-- Transitive dependency: order_id -> customer_name -> customer_city.
CREATE TABLE Orders_3NF_Violation (
    order_id SERIAL PRIMARY KEY,
    order_date DATE,
    customer_name VARCHAR(100),
    customer_city VARCHAR(100) -- This is the transitive dependency.
);

-- 2. Insert sample data.
-- 'Tatooine' is repeated because 'Luke Skywalker' placed two orders.
INSERT INTO Orders_3NF_Violation (order_date, customer_name, customer_city) VALUES
('2023-10-01', 'Luke Skywalker', 'Tatooine'),
('2023-10-02', 'Leia Organa', 'Alderaan'),
('2023-10-03', 'Luke Skywalker', 'Tatooine');

SELECT * FROM Orders_3NF_Violation;

-- 3. Normalize to 3NF.
-- Create a new `Customers` table to remove the transitive dependency.
-- `Customers` table: Stores customer information once.
CREATE TABLE Customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) UNIQUE,
    customer_city VARCHAR(100)
);

-- `Orders_Normalized` table: `customer_name` and `customer_city` are replaced with a foreign key `customer_id`.
CREATE TABLE Orders_Normalized (
    order_id SERIAL PRIMARY KEY,
    order_date DATE,
    customer_id INTEGER REFERENCES Customers(customer_id)
);

-- 4. Insert data into normalized tables.
-- Populate the `Customers` table first.
INSERT INTO Customers (customer_name, customer_city) VALUES ('Luke Skywalker', 'Tatooine'), ('Leia Organa', 'Alderaan');

-- Then, insert the order data, linking to the new `Customers` table.
INSERT INTO Orders_Normalized (order_date, customer_id) VALUES ('2023-10-01', 1), ('2023-10-02', 2), ('2023-10-03', 1);

-- 5. Query the normalized data.
-- Use a JOIN to combine the order and customer information.
SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    c.customer_city
FROM Orders_Normalized o
JOIN Customers c ON o.customer_id = c.customer_id;
