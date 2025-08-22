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
-- 0. Checking the current context
SELECt current_database(), current_schema(), current_user;

-- Listing the current tables in the schema
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

-- This script demonstrates the use of constraints to enforce data integrity.

-- Drop the table if it already exists to start with a clean slate.
DROP TABLE IF EXISTS e_commerce_products;

-- Create the table with constraints.
CREATE TABLE e_commerce_products (
    product_id SERIAL PRIMARY KEY,
    -- NOT NULL and UNIQUE constraints on product_name to prevent duplicates.
    product_name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    -- CHECK constraint to ensure the price is always greater than 0.
    CONSTRAINT positive_price CHECK (price > 0),
    -- DEFAULT constraint to automatically set 'in_stock' to TRUE.
    in_stock BOOLEAN DEFAULT TRUE,
    added_date DATE DEFAULT CURRENT_DATE
);

-- 2. Insert sample data that respects the constraints.
-- The first insert provides all values.
INSERT INTO e_commerce_products (product_name, description, price)
VALUES ('Laptop Pro', 'A powerful laptop for professionals.', 1200.50);

-- The second insert omits `in_stock` and `added_date`,
-- which will be automatically populated by their DEFAULT values.
INSERT INTO e_commerce_products (product_name, description, price)
VALUES ('Wireless Mouse', 'Ergonomic and reliable mouse.', 25.00);

-- 3. The following statements will fail, demonstrating how constraints prevent invalid data.
-- This insert fails due to the UNIQUE constraint on product_name.
-- INSERT INTO e_commerce_products (product_name, description, price)
-- VALUES ('Laptop Pro', 'Another laptop.', 1500.00);

-- This insert fails due to the CHECK constraint on price.
-- INSERT INTO e_commerce_products (product_name, description, price)
-- VALUES ('Broken Widget', 'A useless item.', -5.00);

-- 4. Query the table to see the inserted data, including the default values.
SELECT * FROM e_commerce_products;
```
