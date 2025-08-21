-- Example 2: Achieving 2NF by removing partial dependencies
-- Drop existing tables
DROP TABLE IF EXISTS orders_2nf_normalized;
DROP TABLE IF EXISTS products_2nf_normalized;
DROP TABLE IF EXISTS de_normalized_order_details;

-- 1. Create a de-normalized table that violates 2NF.
-- The composite primary key is (order_id, product_id).
-- product_name only depends on product_id, not the full key.
CREATE TABLE de_normalized_order_details (
    order_id INTEGER,
    product_id INTEGER,
    product_name VARCHAR(100),
    quantity INTEGER,
    PRIMARY KEY (order_id, product_id)
);

-- 2. Insert sample data.
INSERT INTO de_normalized_order_details (order_id, product_id, product_name, quantity) VALUES
(101, 1, 'Laptop', 1),
(101, 2, 'Mouse', 1),
(102, 1, 'Laptop', 2); -- Redundancy: 'Laptop' is repeated with different orders.

-- 3. Normalize to 2NF by splitting the table.
-- We'll create a separate 'products' table for product-specific data.
CREATE TABLE products_2nf_normalized (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) UNIQUE
);

CREATE TABLE orders_2nf_normalized (
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (product_id) REFERENCES products_2nf_normalized(product_id)
);

-- 4. Insert data into the normalized tables.
INSERT INTO products_2nf_normalized (product_id, product_name) VALUES
(1, 'Laptop'),
(2, 'Mouse');

INSERT INTO orders_2nf_normalized (order_id, product_id, quantity) VALUES
(101, 1, 1),
(101, 2, 1),
(102, 1, 2);

-- 5. Query the normalized tables using a JOIN.
SELECT
    o.order_id,
    p.product_name,
    o.quantity
FROM orders_2nf_normalized o
JOIN products_2nf_normalized p ON o.product_id = p.product_id;