-- This script illustrates the performance benefits of using an index.
-- Drop existing table and index
DROP TABLE IF EXISTS sales;
DROP INDEX IF EXISTS idx_sales_transaction_id;

-- 1. Create a large sales table without an index.
-- - We'll insert 1 million rows to simulate a busy database.
CREATE TABLE sales (
id SERIAL PRIMARY KEY,
transaction_id UUID NOT NULL,
amount DECIMAL(10, 2),
sale_date DATE
);

-- 2. Insert 1 million rows of mock data. This might take a moment.
INSERT INTO sales (transaction_id, amount, sale_date)
SELECT
gen_random_uuid(),
(random() * 1000)::DECIMAL(10, 2),
('2023-01-01'::DATE + (random() * 365)::INTEGER)
FROM generate_series(1, 1000000);

-- 3. Analyze a query on the non-indexed column 'transaction_id'.
-- - The EXPLAIN ANALYZE command shows the query plan and execution time.
-- - You will see a "Seq Scan" (sequential scan), which means PostgreSQL reads the entire table.
EXPLAIN ANALYZE
SELECT *
FROM sales
WHERE transaction_id = (SELECT transaction_id FROM sales LIMIT 1 OFFSET 500000);

-- 4. Create an index on the 'transaction_id' column.
CREATE INDEX idx_sales_transaction_id ON sales (transaction_id);

-- 5. Analyze the same query again after creating the index.
-- - You should now see an "Index Scan" or "Bitmap Heap Scan", which is much faster.
EXPLAIN ANALYZE
SELECT *
FROM sales
WHERE transaction_id = (SELECT transaction_id FROM sales LIMIT 1 OFFSET 500000);