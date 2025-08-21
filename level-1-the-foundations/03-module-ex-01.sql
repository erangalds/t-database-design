-- This script shows how to normalize a de-normalized table
-- to reduce data redundancy and improve data integrity.
-- Drop existing tables
DROP TABLE IF EXISTS normalized_orders;
DROP TABLE IF EXISTS normalized_customers;
DROP TABLE IF EXISTS de_normalized_orders;

-- 1. Create a de-normalized table with repeated customer information
CREATE TABLE de_normalized_orders (
order_id SERIAL PRIMARY KEY,
customer_name VARCHAR(100),
customer_email VARCHAR(100),
order_date DATE,
product_name VARCHAR(100)
);

-- 2. Insert sample data. Notice the redundancy in customer information.
INSERT INTO de_normalized_orders (customer_name, customer_email, order_date, product_name) VALUES
('Jane Doe', 'jane.doe@example.com', '2023-10-01', 'Laptop'),
('John Smith', 'john.smith@example.com', '2023-10-02', 'Mouse'),
('Jane Doe', 'jane.doe@example.com', '2023-10-03', 'Keyboard');

-- 3. Now, let's normalize this data into two tables: customers and orders.
-- - This eliminates repeated customer data.
CREATE TABLE normalized_customers (
customer_id SERIAL PRIMARY KEY,
customer_name VARCHAR(100),
customer_email VARCHAR(100) UNIQUE
);

CREATE TABLE normalized_orders (
order_id SERIAL PRIMARY KEY,
order_date DATE,
product_name VARCHAR(100),
customer_id INTEGER,
FOREIGN KEY (customer_id) REFERENCES normalized_customers(customer_id)
);

-- 4. Insert data into the normalized tables.
-- - First, insert customers (only once).
INSERT INTO normalized_customers (customer_name, customer_email) VALUES
('Jane Doe', 'jane.doe@example.com'),
('John Smith', 'john.smith@example.com');

-- - Then, insert orders using the customer_id as the link.
-- (Assuming customer_id 1 is Jane Doe and 2 is John Smith)
INSERT INTO normalized_orders (customer_id, order_date, product_name) VALUES
(1, '2023-10-01', 'Laptop'),
(2, '2023-10-02', 'Mouse'),
(1, '2023-10-03', 'Keyboard');

-- 5. Query the normalized tables using a JOIN to get the full order details.
SELECT
o.order_id,
c.customer_name,
c.customer_email,
o.order_date,
o.product_name
FROM normalized_orders o
JOIN normalized_customers c ON o.customer_id = c.customer_id;
