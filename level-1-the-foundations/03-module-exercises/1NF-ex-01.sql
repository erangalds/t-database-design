-- This first step prepares the environment by removing any old tables from previous runs.
DROP TABLE IF EXISTS Customer_Phones;
DROP TABLE IF EXISTS Customers_1NF_Violation;

-- 1. Create a table that violates 1NF.
-- The 'customer_phones' column is non-atomic.
CREATE TABLE Customers_1NF_Violation (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    customer_phones TEXT -- Example: '123-456-7890, 098-765-4321'
);

-- 2. Insert sample data into the violating table.
-- Notice how multiple phone numbers are stored in a single cell for customer_id 1 and 3.
INSERT INTO Customers_1NF_Violation (customer_name, customer_phones) VALUES
('Alice Johnson', '555-0101, 555-0102'),
('Bob Williams', '555-0103'),
('Charlie Davis', '555-0104, 555-0105, 555-0106');

SELECT * FROM Customers_1NF_Violation;

-- 3. Normalize to 1NF by creating a separate table.
-- The new 'Customer_Phones' table is created to store phone numbers atomically.
-- The 'customer_id' column acts as a foreign key to link to the customers table.
-- The 'PRIMARY KEY (customer_id, phone_number)' creates a composite key,
-- which ensures that each phone number for a customer is unique.
CREATE TABLE Customer_Phones (
    customer_id INTEGER REFERENCES Customers_1NF_Violation(customer_id),
    phone_number VARCHAR(20),
    PRIMARY KEY (customer_id, phone_number)
);

-- 4. Insert data into the normalized table.
-- Each phone number now has its own row, linked to the correct customer_id.
INSERT INTO Customer_Phones (customer_id, phone_number) VALUES
(1, '555-0101'),
(1, '555-0102'),
(2, '555-0103'),
(3, '555-0104'),
(3, '555-0105'),
(3, '555-0106');

-- 5. Query the normalized data.
-- A JOIN is used to combine data from both normalized tables and retrieve the original information.
-- This query shows that each customer can have multiple phone numbers, but the data is stored correctly in 1NF.
SELECT
    c.customer_name,
    p.phone_number
FROM Customers_1NF_Violation c
JOIN Customer_Phones p ON c.customer_id = p.customer_id;