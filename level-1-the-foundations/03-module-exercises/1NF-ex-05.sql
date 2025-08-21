-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Order_Details;
DROP TABLE IF EXISTS Orders_Normalized;
DROP TABLE IF EXISTS Orders_1NF_Violation;

-- 1. Create a table that violates 1NF.
-- The 'order_items' column holds a non-atomic list of products and quantities.
CREATE TABLE Orders_1NF_Violation (
    order_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    order_items TEXT -- Example: 'Laptop (1), Mouse (1)'
);

-- 2. Insert sample data.
-- The 'order_items' column contains multiple items and their quantities.
INSERT INTO Orders_1NF_Violation (customer_name, order_items) VALUES
('Peter Parker', 'Web Fluid (10), Camera (1)'),
('Tony Stark', 'Arc Reactor (1), Suit Polish (3)');

SELECT * FROM Orders_1NF_Violation;

-- 3. Normalize to 1NF.
-- Create two tables: one for the main order information and another for the individual items within the order.
CREATE TABLE Orders_Normalized (
    order_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100)
);

-- The `Order_Details` table holds the detailed, atomic information for each order item.
-- The composite primary key of `(order_id, product_name)` ensures unique item-order pairs.
CREATE TABLE Order_Details (
    order_id INTEGER REFERENCES Orders_Normalized(order_id),
    product_name VARCHAR(100),
    quantity INTEGER,
    PRIMARY KEY (order_id, product_name)
);

-- 4. Insert data into normalized tables.
-- First, insert the main order data into `Orders_Normalized`.
INSERT INTO Orders_Normalized (customer_name) VALUES ('Peter Parker'), ('Tony Stark');

-- Then, insert the individual order items into `Order_Details`. Each item is on its own row.
INSERT INTO Order_Details (order_id, product_name, quantity) VALUES
(1, 'Web Fluid', 10),
(1, 'Camera', 1),
(2, 'Arc Reactor', 1),
(2, 'Suit Polish', 3);

-- 5. Query the normalized data.
-- Use a JOIN to combine the order and order details.
-- This query provides a clear, structured view of each order and its items.
SELECT
    o.order_id,
    o.customer_name,
    od.product_name,
    od.quantity
FROM Orders_Normalized o
JOIN Order_Details od ON o.order_id = od.order_id;