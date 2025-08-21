# Module 4: Data Types

- **Theory:** **Data types** define the kind of data a column can hold. Choosing the right data type is crucial for efficiency and data integrity. PostgreSQL offers a wide range of types:
    
    - `numeric` (`integer`, `decimal`): For numbers. Use `decimal` for precise values like currency.
        
    - `text` (`varchar`, `text`): For strings. Use `varchar` with a length limit for short strings, or `text` for long content where length doesn't matter.
        
    - `date/time` (`timestamp`, `date`): For storing dates and times.
        
    - `jsonb`: A highly efficient binary format for storing JSON data. This is great for semi-structured data where the schema might not be fully known upfront.
        
    - `array`: Allows you to store a list of values in a single column.
        
- **PostgreSQL Example:**
    
    - Design a more complex table, such as an `e-commerce_products` table, using appropriate data types for fields like price, description, images, and product specifications (`jsonb`).

```SQL
-- This script demonstrates the use of various PostgreSQL data types.
-- Drop existing table
DROP TABLE IF EXISTS products;
  
-- 1. Create a products table with diverse data types.
CREATE TABLE products (
product_id SERIAL PRIMARY KEY,
product_name VARCHAR(255) NOT NULL,
description TEXT,
price DECIMAL(10, 2) NOT NULL,
in_stock BOOLEAN DEFAULT TRUE,
added_date DATE DEFAULT CURRENT_DATE,
specifications JSONB, -- Stores structured data
tags TEXT[] -- Stores an array of text strings
);

-- 2. Insert sample products with various data types.
INSERT INTO products (product_name, description, price, specifications, tags) VALUES
('Laptop Pro', 'A powerful laptop for professionals.', 1200.50, '{"processor": "Intel i7", "ram_gb": 16, "storage_gb": 512}', ARRAY['electronics', 'computer']),
('Wireless Mouse', 'Ergonomic and reliable mouse.', 25.00, '{"color": "black", "connection": "bluetooth"}', ARRAY['electronics', 'accessories']),
('Coffee Mug', 'A simple white ceramic mug.', 9.99, NULL, ARRAY['home', 'kitchen']);

-- 3. Query the table, showing different ways to access the data.
-- - Select all products
SELECT * FROM products;

-- - Query specific fields from the JSONB column
SELECT
product_name,
specifications ->> 'processor' AS processor,
specifications ->> 'ram_gb' AS ram
FROM products
WHERE specifications IS NOT NULL;

-- - Find products that have a specific tag using the array operator
SELECT
product_name,
tags
FROM products
WHERE 'computer' = ANY(tags);
```
