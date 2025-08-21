-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Sales_Normalized;
DROP TABLE IF EXISTS Stores;
DROP TABLE IF EXISTS Sales_2NF_Violation;

-- 1. Create a table that violates 2NF.
-- The primary key is `(product_id, store_id)`.
-- `store_city` depends only on `store_id`, which is a partial dependency.
CREATE TABLE Sales_2NF_Violation (
    product_id INTEGER,
    store_id INTEGER,
    store_city VARCHAR(100),
    sale_amount DECIMAL(10, 2),
    PRIMARY KEY (product_id, store_id)
);

-- 2. Insert sample data.
-- 'San Francisco' is repeated because two products were sold at store_id 1.
INSERT INTO Sales_2NF_Violation (product_id, store_id, store_city, sale_amount) VALUES
(101, 1, 'San Francisco', 1200.00),
(102, 1, 'San Francisco', 50.00),
(101, 2, 'Tokyo', 1500.00);

SELECT * FROM Sales_2NF_Violation;

-- 3. Normalize to 2NF.
-- Create a `Stores` table to remove the partial dependency.
-- `Stores` table: Stores store information once.
CREATE TABLE Stores (
    store_id SERIAL PRIMARY KEY,
    store_city VARCHAR(100)
);

-- `Sales_Normalized` table: This table now only contains `sale_amount`, which is fully dependent
-- on the composite primary key `(product_id, store_id)`.
CREATE TABLE Sales_Normalized (
    product_id INTEGER,
    store_id INTEGER REFERENCES Stores(store_id),
    sale_amount DECIMAL(10, 2),
    PRIMARY KEY (product_id, store_id)
);

-- 4. Insert data into normalized tables.
-- Populate the `Stores` table first.
INSERT INTO Stores (store_id, store_city) VALUES (1, 'San Francisco'), (2, 'Tokyo');

-- Then, insert the sales data, linking to the new `Stores` table.
INSERT INTO Sales_Normalized (product_id, store_id, sale_amount) VALUES (101, 1, 1200.00), (102, 1, 50.00), (101, 2, 1500.00);

-- 5. Query the normalized data.
-- Use a JOIN to combine the sales and store information.
SELECT
    s.product_id,
    st.store_city,
    s.sale_amount
FROM Sales_Normalized s
JOIN Stores st ON s.store_id = st.store_id;