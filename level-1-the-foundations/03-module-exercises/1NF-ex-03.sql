-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Product_Tags;
DROP TABLE IF EXISTS Tags;
DROP TABLE IF EXISTS Products_Normalized;
DROP TABLE IF EXISTS Products_1NF_Violation;

-- 1. Create a table that violates 1NF.
-- The 'product_tags' column holds a non-atomic list of values.
CREATE TABLE Products_1NF_Violation (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    product_tags TEXT -- Example: 'Electronics, Gadgets'
);

-- 2. Insert sample data.
-- 'Smart Watch' and 'Ergonomic Chair' have multiple tags in a single field.
INSERT INTO Products_1NF_Violation (product_name, product_tags) VALUES
('Smart Watch', 'Electronics, Wearable, Gadget'),
('Ergonomic Chair', 'Furniture, Office, Health');

SELECT * FROM Products_1NF_Violation;

-- 3. Normalize to 1NF.
-- Create separate tables for products, tags, and the many-to-many junction table.
CREATE TABLE Products_Normalized (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100)
);

CREATE TABLE Tags (
    tag_id SERIAL PRIMARY KEY,
    tag_name VARCHAR(50) UNIQUE
);

-- The junction table `Product_Tags` links products and tags.
-- The composite primary key ensures unique product-tag pairings.
CREATE TABLE Product_Tags (
    product_id INTEGER REFERENCES Products_Normalized(product_id),
    tag_id INTEGER REFERENCES Tags(tag_id),
    PRIMARY KEY (product_id, tag_id)
);

-- 4. Insert data into normalized tables.
-- First, populate the main `Products_Normalized` and `Tags` tables.
INSERT INTO Products_Normalized (product_name) VALUES ('Smart Watch'), ('Ergonomic Chair');
INSERT INTO Tags (tag_name) VALUES ('Electronics'), ('Wearable'), ('Gadget'), ('Furniture'), ('Office'), ('Health');

-- Then, populate the junction table with the correct product-tag relationships.
INSERT INTO Product_Tags (product_id, tag_id) VALUES
(1, 1), (1, 2), (1, 3), -- Smart Watch tags
(2, 4), (2, 5), (2, 6); -- Ergonomic Chair tags

-- 5. Query the normalized data.
-- Use two JOINs to connect `Products_Normalized`, `Product_Tags`, and `Tags` tables.
-- The result shows each product linked to its individual, atomic tags.
SELECT
    p.product_name,
    t.tag_name
FROM Products_Normalized p
JOIN Product_Tags pt ON p.product_id = pt.product_id
JOIN Tags t ON pt.tag_id = t.tag_id;