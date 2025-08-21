-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Order_Details_Normalized;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS OrderDetails_2NF_Violation;

-- 1. Create a table that violates 2NF.
-- The composite primary key is `(order_id, product_id)`.
-- `product_name` and `category_name` depend only on `product_id`, not the whole key. This is a partial dependency.
CREATE TABLE OrderDetails_2NF_Violation (
    order_id INTEGER,
    product_id INTEGER,
    product_name VARCHAR(100),
    category_name VARCHAR(100),
    quantity INTEGER,
    PRIMARY KEY (order_id, product_id)
);

-- 2. Insert sample data.
-- Notice the redundancy: 'Laptop' and 'Electronics' are repeated for each order that includes the product.
INSERT INTO OrderDetails_2NF_Violation (order_id, product_id, product_name, category_name, quantity) VALUES
(101, 1, 'Laptop', 'Electronics', 1),
(101, 2, 'Mouse', 'Peripherals', 1),
(102, 1, 'Laptop', 'Electronics', 2);

SELECT * FROM OrderDetails_2NF_Violation;

-- 3. Normalize to 2NF.
-- Create new tables to remove the partial dependencies.
-- `Categories` table: Stores unique categories.
CREATE TABLE Categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE
);

-- `Products` table: Stores product information. `product_name` now depends solely on `product_id`.
-- It also has a foreign key to `Categories`, removing the transitive dependency.
CREATE TABLE Products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INTEGER REFERENCES Categories(category_id)
);

-- `Order_Details_Normalized` table: This table now only contains columns (`quantity`) that are fully dependent
-- on the composite primary key `(order_id, product_id)`.
CREATE TABLE Order_Details_Normalized (
    order_id INTEGER,
    product_id INTEGER REFERENCES Products(product_id),
    quantity INTEGER,
    PRIMARY KEY (order_id, product_id)
);

-- 4. Insert data into normalized tables.
-- First, populate the `Categories` and `Products` tables to eliminate redundancy.
INSERT INTO Categories (category_name) VALUES ('Electronics'), ('Peripherals');
INSERT INTO Products (product_id, product_name, category_id) VALUES (1, 'Laptop', 1), (2, 'Mouse', 2);

-- Then, insert the order details, linking to the new `Products` table.
INSERT INTO Order_Details_Normalized (order_id, product_id, quantity) VALUES (101, 1, 1), (101, 2, 1), (102, 1, 2);

-- 5. Query the normalized data.
-- Use JOINs to retrieve all the original information from the normalized tables.
-- The query demonstrates how the data is now structured correctly without redundancy.
SELECT
    od.order_id,
    p.product_name,
    c.category_name,
    od.quantity
FROM Order_Details_Normalized od
JOIN Products p ON od.product_id = p.product_id
JOIN Categories c ON p.category_id = c.category_id;
