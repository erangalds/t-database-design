# Module 5: Constraints & Integrity
- **Theory:** **Constraints** are rules that you apply to columns to prevent invalid data from being inserted. They are essential for enforcing data integrity and business rules at the database level.
    
    - `NOT NULL`: Ensures that a column cannot have a `NULL` (empty) value.
        
    - `UNIQUE`: Guarantees that every value in a column is unique across the entire table.
        
    - `CHECK`: Enforces a specific condition. For example, you can use a `CHECK` constraint to ensure a product's price is always positive.
        
    - `DEFAULT`: Automatically assigns a specified value to a column if no value is provided during an `INSERT`.
        
- **PostgreSQL Example:**
    
    - Add constraints to the `e-commerce_products` table to ensure that product names are unique and prices are always positive.
        
    - Show how `DEFAULT` can simplify data entry.

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
