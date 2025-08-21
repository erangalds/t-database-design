# Database Normalization Exercises: 1NF, 2NF, & 3NF

This document provides a set of 15 practical exercises to help you understand and resolve common database normalization violations. The exercises are divided into three sections: First Normal Form (1NF), Second Normal Form (2NF), and Third Normal Form (3NF). Each exercise includes the complete SQL solution.

Database normalization is a process used to organize a database to reduce data redundancy and improve data integrity. Normalization is broken down into forms, with the most common being First Normal Form (1NF), Second Normal Form (2NF), and Third Normal Form (3NF).

---

## First Normal Form (1NF) Exercises

The rule for **First Normal Form (1NF)** is that every column in a table must contain a single, atomic (indivisible) value, and each row must be unique. This means you should not have columns with comma-separated lists, multiple values in a single cell, or repeating groups of columns.

To fix 1NF violations, you must:

- **Identify** columns that contain multiple, non-atomic values.
    
- **Separate** these values into their own rows or, more commonly, move them to a new, related table.
    
- **Create** a new table with a foreign key that links back to the original table. This new table will store the multiple values as separate rows, with each value being atomic.
    

---

### Scenario 1: Customer Phones 📞

The `Customers_1NF_Violation` table stores multiple phone numbers in a single `customer_phones` column, which violates 1NF because the data is not atomic.

- **The Problem:** The `customer_phones` column holds a list of values (e.g., '555-0101, 555-0102'), which makes it difficult to query or update individual phone numbers.
    
- **The Solution:** Create a new table called `Customer_Phones` to hold each phone number on its own row. A `customer_id` column in this new table will link each phone number back to the correct customer in the `Customers_1NF_Violation` table. This approach ensures each phone number is an atomic value.
    

#### SQL Solution

```SQL
-- This first step prepares the environment by removing any old tables from previous runs.
DROP TABLE IF EXISTS Customer_Phones;
DROP TABLE IF EXISTS Customers_1NF_Violation;

-- 1. Create a table that violates 1NF.
-- The 'customer_phones' column is non-atomic.
CREATE TABLE Customers_1NF_Violation (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    customer_phones TEXT -- Example: '123-456-7890, 098-765-4321'
);

-- 2. Insert sample data into the violating table.
-- Notice how multiple phone numbers are stored in a single cell for customer_id 1 and 3.
INSERT INTO Customers_1NF_Violation (customer_name, customer_phones) VALUES
('Alice Johnson', '555-0101, 555-0102'),
('Bob Williams', '555-0103'),
('Charlie Davis', '555-0104, 555-0105, 555-0106');

SELECT * FROM Customers_1NF_Violation;

-- 3. Normalize to 1NF by creating a separate table.
-- The new 'Customer_Phones' table is created to store phone numbers atomically.
-- The 'customer_id' column acts as a foreign key to link to the customers table.
-- The 'PRIMARY KEY (customer_id, phone_number)' creates a composite key,
-- which ensures that each phone number for a customer is unique.
CREATE TABLE Customer_Phones (
    customer_id INTEGER REFERENCES Customers_1NF_Violation(customer_id),
    phone_number VARCHAR(20),
    PRIMARY KEY (customer_id, phone_number)
);

-- 4. Insert data into the normalized table.
-- Each phone number now has its own row, linked to the correct customer_id.
INSERT INTO Customer_Phones (customer_id, phone_number) VALUES
(1, '555-0101'),
(1, '555-0102'),
(2, '555-0103'),
(3, '555-0104'),
(3, '555-0105'),
(3, '555-0106');

-- 5. Query the normalized data.
-- A JOIN is used to combine data from both normalized tables and retrieve the original information.
-- This query shows that each customer can have multiple phone numbers, but the data is stored correctly in 1NF.
SELECT
    c.customer_name,
    p.phone_number
FROM Customers_1NF_Violation c
JOIN Customer_Phones p ON c.customer_id = p.customer_id;
```

---

### Scenario 2: Employee Skills 🛠️

The `Employees_1NF_Violation` table stores an employee's skills in a single `employee_skills` column, which violates 1NF.

- **The Problem:** The `employee_skills` column contains a comma-separated list of skills, which is not atomic. Storing data this way makes it impossible to search for all employees with a specific skill without using complex string-matching functions.
    
- **The Solution:** Create three new tables to fully normalize the data:
    
    1. **`Employees_Normalized`**: Stores the employee's name and a unique ID.
        
    2. **`Skills`**: Stores each skill with a unique ID.
        
    3. **`Employee_Skills`**: This is a **junction table** that links employees to skills. It has a composite primary key consisting of `employee_id` and `skill_id`. This table solves the problem by allowing an employee to have many skills and a skill to be associated with many employees, a many-to-many relationship.
        

#### SQL Solution


```SQL
-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Employee_Skills;
DROP TABLE IF EXISTS Skills;
DROP TABLE IF EXISTS Employees_Normalized;
DROP TABLE IF EXISTS Employees_1NF_Violation;

-- 1. Create a table that violates 1NF.
-- The 'employee_skills' column is non-atomic.
CREATE TABLE Employees_1NF_Violation (
    employee_id SERIAL PRIMARY KEY,
    employee_name VARCHAR(100),
    employee_skills TEXT -- Example: 'Python, SQL, AWS'
);

-- 2. Insert sample data.
-- Diana Prince and Clark Kent have multiple skills listed in a single column.
INSERT INTO Employees_1NF_Violation (employee_name, employee_skills) VALUES
('Diana Prince', 'Java, Spring, Docker'),
('Bruce Wayne', 'Project Management, Finance'),
('Clark Kent', 'Journalism, Investigation, Super Strength');

SELECT * FROM Employees_1NF_Violation;

-- 3. Normalize to 1NF.
-- Create separate tables for employees, skills, and the many-to-many relationship between them.
-- `Employees_Normalized` table: Stores unique employee data.
CREATE TABLE Employees_Normalized (
    employee_id SERIAL PRIMARY KEY,
    employee_name VARCHAR(100)
);

-- `Skills` table: Stores unique skill names. This prevents repeating skill names.
CREATE TABLE Skills (
    skill_id SERIAL PRIMARY KEY,
    skill_name VARCHAR(100) UNIQUE
);

-- `Employee_Skills` table: This is a junction table. It holds foreign keys from
-- `Employees_Normalized` and `Skills`. This correctly models the many-to-many relationship.
-- The composite primary key ensures that each employee-skill pair is unique.
CREATE TABLE Employee_Skills (
    employee_id INTEGER REFERENCES Employees_Normalized(employee_id),
    skill_id INTEGER REFERENCES Skills(skill_id),
    PRIMARY KEY (employee_id, skill_id)
);

-- 4. Insert data into normalized tables.
-- First, populate the `Employees_Normalized` and `Skills` tables.
INSERT INTO Employees_Normalized (employee_name) VALUES
('Diana Prince'), ('Bruce Wayne'), ('Clark Kent');

INSERT INTO Skills (skill_name) VALUES
('Java'), ('Spring'), ('Docker'), ('Project Management'), ('Finance'), ('Journalism'), ('Investigation'), ('Super Strength');

-- Then, populate the junction table to link the employees and their skills.
INSERT INTO Employee_Skills (employee_id, skill_id) VALUES
(1, 1), (1, 2), (1, 3), -- Diana's skills
(2, 4), (2, 5),          -- Bruce's skills
(3, 6), (3, 7), (3, 8);  -- Clark's skills

-- 5. Query the normalized data.
-- Use two JOINs to connect the `Employees_Normalized`, `Employee_Skills`, and `Skills` tables.
-- This query returns a clean, structured list of each employee and their individual skills.
SELECT
    e.employee_name,
    s.skill_name
FROM Employees_Normalized e
JOIN Employee_Skills es ON e.employee_id = es.employee_id
JOIN Skills s ON es.skill_id = s.skill_id;
```

---

### Scenario 3: Product Tags 🏷️

The `Products_1NF_Violation` table has a `product_tags` column with multiple tags in a single string, which violates 1NF.

- **The Problem:** Storing multiple tags in one column makes it difficult to search for all products with a specific tag. For example, finding all "Gadget" products would require a search on a partial string.
    
- **The Solution:** This is another many-to-many relationship (one product can have many tags, and one tag can belong to many products). The best way to normalize this is to create a junction table.
    
    1. **`Products_Normalized`**: Stores the product name and ID.
        
    2. **`Tags`**: Stores each unique tag name with its own ID.
        
    3. **`Product_Tags`**: A junction table that links a `product_id` to a `tag_id`. This allows for a clean, flexible structure.
        

#### SQL Solution

```SQL
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
```

---

### Scenario 4: Book Genres 📚

The `Books_1NF_Violation` table stores multiple genres in a single `book_genres` column, violating 1NF.

- **The Problem:** The `book_genres` column contains a comma-separated string, making it non-atomic. This leads to data duplication and inefficient queries if you wanted to find all books of a specific genre.
    
- **The Solution:** Similar to the previous scenarios, this is a many-to-many relationship (one book can have many genres, and one genre can be associated with many books). A junction table is the correct solution.
    
    1. **`Books_Normalized`**: Stores the book title and a unique ID.
        
    2. **`Genres`**: Stores each unique genre with an ID.
        
    3. **`Book_Genres`**: A junction table that links `book_id` to `genre_id`.
        

#### SQL Solution

```SQL
-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Book_Genres;
DROP TABLE IF EXISTS Genres;
DROP TABLE IF EXISTS Books_Normalized;
DROP TABLE IF EXISTS Books_1NF_Violation;

-- 1. Create a table that violates 1NF.
-- The 'book_genres' column is not atomic.
CREATE TABLE Books_1NF_Violation (
    book_id SERIAL PRIMARY KEY,
    book_title VARCHAR(255),
    book_genres TEXT -- Example: 'Fantasy, Adventure'
);

-- 2. Insert sample data.
-- The 'book_genres' column contains lists of genres.
INSERT INTO Books_1NF_Violation (book_title, book_genres) VALUES
('The Way of Kings', 'Fantasy, Epic'),
('Dune', 'Science Fiction, Adventure');

SELECT * FROM Books_1NF_Violation;

-- 3. Normalize to 1NF.
-- Create three tables to handle the many-to-many relationship between books and genres.
CREATE TABLE Books_Normalized (
    book_id SERIAL PRIMARY KEY,
    book_title VARCHAR(255)
);

CREATE TABLE Genres (
    genre_id SERIAL PRIMARY KEY,
    genre_name VARCHAR(50) UNIQUE
);

-- The junction table `Book_Genres` links books and genres.
CREATE TABLE Book_Genres (
    book_id INTEGER REFERENCES Books_Normalized(book_id),
    genre_id INTEGER REFERENCES Genres(genre_id),
    PRIMARY KEY (book_id, genre_id)
);

-- 4. Insert data into normalized tables.
-- First, populate the `Books_Normalized` and `Genres` tables.
INSERT INTO Books_Normalized (book_title) VALUES ('The Way of Kings'), ('Dune');
INSERT INTO Genres (genre_name) VALUES ('Fantasy'), ('Epic'), ('Science Fiction'), ('Adventure');

-- Then, populate the junction table with the correct book-genre pairings.
INSERT INTO Book_Genres (book_id, genre_id) VALUES
(1, 1), (1, 2), -- 'The Way of Kings' genres
(2, 3), (2, 4); -- 'Dune' genres

-- 5. Query the normalized data.
-- Use two JOINs to connect the tables and display the book and its genres.
SELECT
    b.book_title,
    g.genre_name
FROM Books_Normalized b
JOIN Book_Genres bg ON b.book_id = bg.book_id
JOIN Genres g ON bg.genre_id = g.genre_id;
```

---

### Scenario 5: Order Items 🛒

The `Orders_1NF_Violation` table has a `order_items` column with product names and quantities combined in a single string, violating 1NF.

- **The Problem:** The `order_items` column is non-atomic and contains mixed data (product name and quantity). This makes it impossible to perform calculations or sort by product quantity without using complex string manipulation.
    
- **The Solution:** Create a new table called `Order_Details` to hold each product and quantity combination on its own row.
    
    1. **`Orders_Normalized`**: Stores the customer name and a unique ID.
        
    2. **`Order_Details`**: Stores each product and its quantity in a separate row, linked to the `Orders_Normalized` table via `order_id`. This correctly separates the data into atomic values.
        

#### SQL Solution

```SQL
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
```


## Second Normal Form (2NF) Exercises

The rule for **Second Normal Form (2NF)** is that a table must be in 1NF, and all non-key columns must be fully dependent on the **entire primary key**. This rule primarily applies to tables with **composite primary keys** (keys made of two or more columns). A violation occurs when a non-key column depends on only part of the composite key, which is called a **partial dependency**.

To fix 2NF violations, you must:

- **Identify** partial dependencies within a composite primary key.
    
- **Create** a new table to store the data that is partially dependent.
    
- **Move** the partially dependent columns and the part of the composite key they depend on into the new table. The new table's primary key will be the column that the data depended on.
    

---

### Scenario 1: Order Items and Product Categories 📦

The `OrderDetails_2NF_Violation` table has a composite key of (`order_id`, `product_id`). The columns `product_name` and `category_name` depend only on `product_id`, not the full key.

- **The Problem:** The `product_name` and `category_name` are repeated for every order that includes a specific product. This is a partial dependency because they only depend on `product_id`, not on the `order_id` part of the key. This leads to redundant data. For example, 'Laptop' and 'Electronics' are repeated for both orders 101 and 102.
    
- **The Solution:** Create separate tables for products and categories.
    
    1. **`Categories`**: Stores unique `category_name`s with a `category_id`.
        
    2. **`Products`**: Stores `product_name` and links to the `Categories` table via `category_id`. The `product_id`is the primary key.
        
    3. **`Order_Details_Normalized`**: This table will contain the composite key (`order_id`, `product_id`) and the `quantity`, which fully depends on both parts of the key.
        

#### SQL Solution

```SQL
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
```

---

### Scenario 2: Student Enrollment and Department 🎓

The `StudentEnrollment_2NF_Violation` table has a composite key of (`student_id`, `course_id`). The `course_title` and `department_name` columns depend only on `course_id`.

- **The Problem:** The `course_title` and `department_name` are repeated for every student enrolled in a specific course. This is a partial dependency because they only depend on `course_id`, not on the full composite key.
    
- **The Solution:** Create a new `Courses` table to store `course_title` and link to a separate `Departments`table. The `Enrollments` table will then link `student_id` and `course_id` and hold the `grade`, which is fully dependent on both.
    
    1. **`Departments`**: Stores unique `department_name`s with a `department_id`.
        
    2. **`Courses`**: Stores `course_title` and links to the `Departments` table. The `course_id` is the primary key.
        
    3. **`Enrollments`**: Stores the composite key of (`student_id`, `course_id`) and the `grade`, which is dependent on both parts of the key (i.e., a student's grade is specific to a course).
        

#### SQL Solution

```SQL
-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Enrollments;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Departments;
DROP TABLE IF EXISTS StudentEnrollment_2NF_Violation;

-- 1. Create a table that violates 2NF.
-- The primary key is `(student_id, course_id)`.
-- The `course_title` and `department_name` columns depend only on `course_id`, not on the full key.
CREATE TABLE StudentEnrollment_2NF_Violation (
    student_id INTEGER,
    course_id INTEGER,
    course_title VARCHAR(100),
    department_name VARCHAR(100),
    grade CHAR(1),
    PRIMARY KEY (student_id, course_id)
);

-- 2. Insert sample data.
-- Notice the redundancy: 'Intro to CS' and 'Computer Science' are repeated for each student taking the course.
INSERT INTO StudentEnrollment_2NF_Violation (student_id, course_id, course_title, department_name, grade) VALUES
(1, 101, 'Intro to CS', 'Computer Science', 'A'),
(2, 101, 'Intro to CS', 'Computer Science', 'B'),
(1, 201, 'Calculus I', 'Mathematics', 'A');

SELECT * FROM StudentEnrollment_2NF_Violation;

-- 3. Normalize to 2NF.
-- Create new tables to remove the partial and transitive dependencies.
-- `Departments` table: Stores unique departments.
CREATE TABLE Departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) UNIQUE
);

-- `Courses` table: Stores course information. `course_title` now depends on `course_id`.
-- This table also links to `Departments`, which removes a transitive dependency.
CREATE TABLE Courses (
    course_id SERIAL PRIMARY KEY,
    course_title VARCHAR(100),
    department_id INTEGER REFERENCES Departments(department_id)
);

-- `Enrollments` table: Contains the composite key and `grade`, which is fully dependent on both `student_id` and `course_id`.
CREATE TABLE Enrollments (
    student_id INTEGER,
    course_id INTEGER REFERENCES Courses(course_id),
    grade CHAR(1),
    PRIMARY KEY (student_id, course_id)
);

-- 4. Insert data into normalized tables.
-- Populate the `Departments` and `Courses` tables first.
INSERT INTO Departments (department_name) VALUES ('Computer Science'), ('Mathematics');
INSERT INTO Courses (course_id, course_title, department_id) VALUES (101, 'Intro to CS', 1), (201, 'Calculus I', 2);

-- Then, insert the enrollment data, linking to the new `Courses` table.
INSERT INTO Enrollments (student_id, course_id, grade) VALUES (1, 101, 'A'), (2, 101, 'B'), (1, 201, 'A');

-- 5. Query the normalized data.
-- Use JOINs to retrieve the student, course, department, and grade information.
-- The query demonstrates how the data is now correctly structured without redundancy.
SELECT
    e.student_id,
    c.course_title,
    d.department_name,
    e.grade
FROM Enrollments e
JOIN Courses c ON e.course_id = c.course_id
JOIN Departments d ON c.department_id = d.department_id;
```


### Scenario 3: Employee Projects and Department Location 📍

The `EmployeeProjects_2NF_Violation` table has a composite key of (`employee_id`, `project_id`). The `employee_name` and `department_location` columns depend only on `employee_id`.

- **The Problem:** `employee_name` and `department_location` are repeated for every project an employee is assigned to. This is a partial dependency because they only depend on `employee_id`, not on the full composite key.
    
- **The Solution:** Create a new `Employees` table to store employee-specific details, as they are not dependent on the project. The `Employee_Projects_Normalized` table will then link employees and projects.
    
    1. **`Employees`**: Stores `employee_name` and `department_location`. The `employee_id` is the primary key.
        
    2. **`Employee_Projects_Normalized`**: Stores the composite key of (`employee_id`, `project_id`) and `hours_worked`, which is fully dependent on both.
        

#### SQL Solution

```SQL
-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Employee_Projects_Normalized;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS EmployeeProjects_2NF_Violation;

-- 1. Create a table that violates 2NF.
-- The primary key is `(employee_id, project_id)`.
-- `employee_name` and `department_location` depend only on `employee_id`. This is a partial dependency.
CREATE TABLE EmployeeProjects_2NF_Violation (
    employee_id INTEGER,
    project_id INTEGER,
    employee_name VARCHAR(100),
    department_location VARCHAR(100),
    hours_worked INTEGER,
    PRIMARY KEY (employee_id, project_id)
);

-- 2. Insert sample data.
-- Notice the redundancy: 'John Doe' and 'New York' are repeated because he is on two projects.
INSERT INTO EmployeeProjects_2NF_Violation (employee_id, project_id, employee_name, department_location, hours_worked) VALUES
(1, 10, 'John Doe', 'New York', 40),
(1, 20, 'John Doe', 'New York', 20),
(2, 10, 'Jane Smith', 'London', 35);

SELECT * FROM EmployeeProjects_2NF_Violation;

-- 3. Normalize to 2NF.
-- Create a new `Employees` table to remove the partial dependency.
-- `Employees` table: Stores employee information once.
CREATE TABLE Employees (
    employee_id SERIAL PRIMARY KEY,
    employee_name VARCHAR(100),
    department_location VARCHAR(100)
);

-- `Employee_Projects_Normalized` table: This table now only contains columns that are fully dependent
-- on the composite primary key `(employee_id, project_id)`.
CREATE TABLE Employee_Projects_Normalized (
    employee_id INTEGER REFERENCES Employees(employee_id),
    project_id INTEGER,
    hours_worked INTEGER,
    PRIMARY KEY (employee_id, project_id)
);

-- 4. Insert data into normalized tables.
-- Populate the `Employees` table first, removing redundant employee information.
INSERT INTO Employees (employee_id, employee_name, department_location) VALUES (1, 'John Doe', 'New York'), (2, 'Jane Smith', 'London');

-- Then, insert the project data, linking to the new `Employees` table.
INSERT INTO Employee_Projects_Normalized (employee_id, project_id, hours_worked) VALUES (1, 10, 40), (1, 20, 20), (2, 10, 35);

-- 5. Query the normalized data.
-- Use a JOIN to combine the employee and project information.
SELECT
    e.employee_name,
    e.department_location,
    ep.project_id,
    ep.hours_worked
FROM Employees e
JOIN Employee_Projects_Normalized ep ON e.employee_id = ep.employee_id;
```

---

### Scenario 4: Sales and Store City 🏙️

The `Sales_2NF_Violation` table has a composite key of (`product_id`, `store_id`). The `store_city` column is only dependent on `store_id`.

- **The Problem:** The `store_city` is repeated for every product sold at a specific store. This is a partial dependency because `store_city` only depends on `store_id`, not on the full composite key.
    
- **The Solution:** Create a new `Stores` table to hold store-specific details. The `Sales_Normalized` table will then link products and stores and hold the sale amount, which is fully dependent on both.
    
    1. **`Stores`**: Stores `store_city` with `store_id` as the primary key.
        
    2. **`Sales_Normalized`**: Stores the composite key of (`product_id`, `store_id`) and the `sale_amount`, which is fully dependent on both.
        

#### SQL Solution

```SQL
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
```

---

### Scenario 5: Flight Bookings and Flight Details ✈️

The `FlightBookings_2NF_Violation` table has a composite key of (`passenger_id`, `flight_id`). The `departure_airport` and `arrival_airport` columns depend only on `flight_id`.

- **The Problem:** The `departure_airport` and `arrival_airport` are repeated for every passenger on a specific flight. This is a partial dependency, as they only depend on `flight_id`.
    
- **The Solution:** Create a new `Flights` table to store flight-specific details. The `Bookings` table will then link passengers and flights and hold the `seat_number`, which is fully dependent on both.
    
    1. **`Flights`**: Stores `departure_airport` and `arrival_airport` with `flight_id` as the primary key.
        
    2. **`Bookings`**: Stores the composite key of (`passenger_id`, `flight_id`) and the `seat_number`, which is fully dependent on both (a seat number is specific to a passenger on a particular flight).
        

#### SQL Solution

```SQL
-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Flights;
DROP TABLE IF EXISTS FlightBookings_2NF_Violation;

-- 1. Create a table that violates 2NF.
-- The primary key is `(passenger_id, flight_id)`.
-- `departure_airport` and `arrival_airport` depend only on `flight_id`, a partial dependency.
CREATE TABLE FlightBookings_2NF_Violation (
    passenger_id INTEGER,
    flight_id INTEGER,
    departure_airport VARCHAR(3),
    arrival_airport VARCHAR(3),
    seat_number VARCHAR(4),
    PRIMARY KEY (passenger_id, flight_id)
);

-- 2. Insert sample data.
-- 'JFK' and 'LAX' are repeated because two passengers are on flight 101.
INSERT INTO FlightBookings_2NF_Violation (passenger_id, flight_id, departure_airport, arrival_airport, seat_number) VALUES
(1, 101, 'JFK', 'LAX', '12A'),
(2, 101, 'JFK', 'LAX', '12B'),
(3, 202, 'LHR', 'CDG', '22F');

SELECT * FROM FlightBookings_2NF_Violation;

-- 3. Normalize to 2NF.
-- Create a `Flights` table to remove the partial dependency.
-- `Flights` table: Stores flight information once.
CREATE TABLE Flights (
    flight_id SERIAL PRIMARY KEY,
    departure_airport VARCHAR(3),
    arrival_airport VARCHAR(3)
);

-- `Bookings` table: This table now only contains columns (`seat_number`) that are fully dependent
-- on the composite primary key `(passenger_id, flight_id)`.
CREATE TABLE Bookings (
    passenger_id INTEGER,
    flight_id INTEGER REFERENCES Flights(flight_id),
    seat_number VARCHAR(4),
    PRIMARY KEY (passenger_id, flight_id)
);

-- 4. Insert data into normalized tables.
-- Populate the `Flights` table first.
INSERT INTO Flights (flight_id, departure_airport, arrival_airport) VALUES (101, 'JFK', 'LAX'), (202, 'LHR', 'CDG');

-- Then, insert the booking data, linking to the new `Flights` table.
INSERT INTO Bookings (passenger_id, flight_id, seat_number) VALUES (1, 101, '12A'), (2, 101, '12B'), (3, 202, '22F');

-- 5. Query the normalized data.
-- Use a JOIN to combine the booking and flight information.
SELECT
    b.passenger_id,
    f.departure_airport,
    f.arrival_airport,
    b.seat_number
FROM Bookings b
JOIN Flights f ON b.flight_id = f.flight_id;
```

---

## Third Normal Form (3NF) Exercises

The rule for **Third Normal Form (3NF)** is that a table must be in 2NF, and all non-key columns must depend only on the primary key, not on other non-key columns. This is known as a **transitive dependency**. A transitive dependency occurs when a non-key column depends on another non-key column.

To fix 3NF violations, you must:

- **Identify** transitive dependencies where a non-key column determines the value of another non-key column.
    
- **Create** a new table for the non-key columns that are transitively dependent.
    
- **Move** these columns into the new table, using the determining non-key column as the new primary key.
    
- **Replace** the moved non-key columns in the original table with a foreign key that references the new table.
    

---

### Scenario 1: Employee and Department Manager 🏢

The `Employees_3NF_Violation` table has `employee_id` as the primary key. However, the `manager_name`depends on the `department_name`, which is not the primary key.

- **The Problem:** `manager_name` is transitively dependent on `employee_id` through `department_name`. This means if a new employee is added to an existing department, the `department_name` and `manager_name` would be redundantly re-entered. For example, `Mr. Anderson` is repeated for every employee in the IT department.
    
- **The Solution:** Create a new `Departments` table to store department-specific details.
    
    1. **`Departments`**: Stores `department_name` and its `manager_name`. The `department_id` is the primary key.
        
    2. **`Employees_Normalized`**: Stores `employee_name` and a foreign key to the new `Departments` table.
        

#### SQL Solution

```SQL
-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Employees_Normalized;
DROP TABLE IF EXISTS Departments;
DROP TABLE IF EXISTS Employees_3NF_Violation;

-- 1. Create a table that violates 3NF.
-- The primary key is `employee_id`. `manager_name` depends on `department_name`, not on `employee_id`.
-- This is a transitive dependency: employee_id -> department_name -> manager_name.
CREATE TABLE Employees_3NF_Violation (
    employee_id SERIAL PRIMARY KEY,
    employee_name VARCHAR(100),
    department_name VARCHAR(100),
    manager_name VARCHAR(100) -- This is the transitive dependency.
);

-- 2. Insert sample data.
-- Notice the redundancy: 'Mr. Anderson' is repeated for every employee in the 'IT' department.
INSERT INTO Employees_3NF_Violation (employee_name, department_name, manager_name) VALUES
('Neo', 'IT', 'Mr. Anderson'),
('Trinity', 'IT', 'Mr. Anderson'),
('Morpheus', 'HR', 'Ms. Smith');

SELECT * FROM Employees_3NF_Violation;

-- 3. Normalize to 3NF.
-- Create a `Departments` table to remove the transitive dependency.
-- `Departments` table: Stores department and manager information once.
CREATE TABLE Departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) UNIQUE,
    manager_name VARCHAR(100)
);

-- `Employees_Normalized` table: The original `manager_name` column is removed and replaced by a foreign key
-- `department_id`, which directly links to the new `Departments` table.
CREATE TABLE Employees_Normalized (
    employee_id SERIAL PRIMARY KEY,
    employee_name VARCHAR(100),
    department_id INTEGER REFERENCES Departments(department_id)
);

-- 4. Insert data into normalized tables.
-- Populate the `Departments` table first.
INSERT INTO Departments (department_name, manager_name) VALUES ('IT', 'Mr. Anderson'), ('HR', 'Ms. Smith');

-- Then, insert the employee data, linking to the new `Departments` table.
INSERT INTO Employees_Normalized (employee_name, department_id) VALUES ('Neo', 1), ('Trinity', 1), ('Morpheus', 2);

-- 5. Query the normalized data.
-- Use a JOIN to combine the employee and department information.
SELECT
    e.employee_name,
    d.department_name,
    d.manager_name
FROM Employees_Normalized e
JOIN Departments d ON e.department_id = d.department_id;
```

---

### Scenario 2: Orders and Customer City 📦

The `Orders_3NF_Violation` table has `order_id` as the primary key. However, the `customer_city` depends on `customer_name`, which is a non-key column.

- **The Problem:** The `customer_city` is repeated every time a customer places an order. This is a transitive dependency: `order_id` -> `customer_name` -> `customer_city`.
    
- **The Solution:** Create a new `Customers` table to store customer-specific details.
    
    1. **`Customers`**: Stores `customer_name` and `customer_city`. The `customer_id` is the primary key.
        
    2. **`Orders_Normalized`**: Stores `order_date` and a foreign key to the `Customers` table.
        

#### SQL Solution

```SQL
-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Orders_Normalized;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Orders_3NF_Violation;

-- 1. Create a table that violates 3NF.
-- The primary key is `order_id`. `customer_city` depends on `customer_name`, which is not the primary key.
-- Transitive dependency: order_id -> customer_name -> customer_city.
CREATE TABLE Orders_3NF_Violation (
    order_id SERIAL PRIMARY KEY,
    order_date DATE,
    customer_name VARCHAR(100),
    customer_city VARCHAR(100) -- This is the transitive dependency.
);

-- 2. Insert sample data.
-- 'Tatooine' is repeated because 'Luke Skywalker' placed two orders.
INSERT INTO Orders_3NF_Violation (order_date, customer_name, customer_city) VALUES
('2023-10-01', 'Luke Skywalker', 'Tatooine'),
('2023-10-02', 'Leia Organa', 'Alderaan'),
('2023-10-03', 'Luke Skywalker', 'Tatooine');

SELECT * FROM Orders_3NF_Violation;

-- 3. Normalize to 3NF.
-- Create a new `Customers` table to remove the transitive dependency.
-- `Customers` table: Stores customer information once.
CREATE TABLE Customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) UNIQUE,
    customer_city VARCHAR(100)
);

-- `Orders_Normalized` table: `customer_name` and `customer_city` are replaced with a foreign key `customer_id`.
CREATE TABLE Orders_Normalized (
    order_id SERIAL PRIMARY KEY,
    order_date DATE,
    customer_id INTEGER REFERENCES Customers(customer_id)
);

-- 4. Insert data into normalized tables.
-- Populate the `Customers` table first.
INSERT INTO Customers (customer_name, customer_city) VALUES ('Luke Skywalker', 'Tatooine'), ('Leia Organa', 'Alderaan');

-- Then, insert the order data, linking to the new `Customers` table.
INSERT INTO Orders_Normalized (order_date, customer_id) VALUES ('2023-10-01', 1), ('2023-10-02', 2), ('2023-10-03', 1);

-- 5. Query the normalized data.
-- Use a JOIN to combine the order and customer information.
SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    c.customer_city
FROM Orders_Normalized o
JOIN Customers c ON o.customer_id = c.customer_id;
```

---

### Scenario 3: Student and Major Department Head 🎓

The `Students_3NF_Violation` table has `student_id` as the primary key. However, the `department_head`depends on `major_name`, which is a non-key column.

- **The Problem:** The `department_head` is repeated for every student with the same major. This is a transitive dependency: `student_id` -> `major_name` -> `department_head`.
    
- **The Solution:** Create a new `Majors` table to store major-specific details.
    
    1. **`Majors`**: Stores `major_name` and `department_head`. The `major_id` is the primary key.
        
    2. **`Students_Normalized`**: Stores `student_name` and a foreign key to the new `Majors` table.
        

#### SQL Solution

```SQL
-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Students_Normalized;
DROP TABLE IF EXISTS Majors;
DROP TABLE IF EXISTS Students_3NF_Violation;

-- 1. Create a table that violates 3NF.
-- `department_head` depends on `major_name` (a non-key column).
-- Transitive dependency: student_id -> major_name -> department_head.
CREATE TABLE Students_3NF_Violation (
    student_id SERIAL PRIMARY KEY,
    student_name VARCHAR(100),
    major_name VARCHAR(100),
    department_head VARCHAR(100) -- This is the transitive dependency.
);

-- 2. Insert sample data.
-- 'Albus Dumbledore' is repeated because both Harry and Ron have the 'Defense Arts' major.
INSERT INTO Students_3NF_Violation (student_name, major_name, department_head) VALUES
('Harry Potter', 'Defense Arts', 'Albus Dumbledore'),
('Hermione Granger', 'Ancient Runes', 'Bathsheba Babbling'),
('Ron Weasley', 'Defense Arts', 'Albus Dumbledore');

SELECT * FROM Students_3NF_Violation;

-- 3. Normalize to 3NF.
-- Create a `Majors` table to remove the transitive dependency.
-- `Majors` table: Stores major and department head information once.
CREATE TABLE Majors (
    major_id SERIAL PRIMARY KEY,
    major_name VARCHAR(100) UNIQUE,
    department_head VARCHAR(100)
);

-- `Students_Normalized` table: `major_name` and `department_head` are replaced with a foreign key `major_id`.
CREATE TABLE Students_Normalized (
    student_id SERIAL PRIMARY KEY,
    student_name VARCHAR(100),
    major_id INTEGER REFERENCES Majors(major_id)
);

-- 4. Insert data into normalized tables.
-- Populate the `Majors` table first.
INSERT INTO Majors (major_name, department_head) VALUES ('Defense Arts', 'Albus Dumbledore'), ('Ancient Runes', 'Bathsheba Babbling');

-- Then, insert the student data, linking to the new `Majors` table.
INSERT INTO Students_Normalized (student_name, major_id) VALUES ('Harry Potter', 1), ('Hermione Granger', 2), ('Ron Weasley', 1);

-- 5. Query the normalized data.
-- Use a JOIN to combine the student and major information.
SELECT
    s.student_name,
    m.major_name,
    m.department_head
FROM Students_Normalized s
JOIN Majors m ON s.major_id = m.major_id;
```

---

### Scenario 4: Events and Venue City 🏟️

The `Events_3NF_Violation` table has `event_id` as the primary key. However, the `venue_city` depends on `venue_name`, which is a non-key column.

- **The Problem:** The `venue_city` is repeated for every event at the same venue. This is a transitive dependency: `event_id` -> `venue_name` -> `venue_city`.
    
- **The Solution:** Create a new `Venues` table to store venue-specific details.
    
    1. **`Venues`**: Stores `venue_name` and `venue_city`. The `venue_id` is the primary key.
        
    2. **`Events_Normalized`**: Stores `event_name` and a foreign key to the new `Venues` table.
        

#### SQL Solution

```SQL
-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Events_Normalized;
DROP TABLE IF EXISTS Venues;
DROP TABLE IF EXISTS Events_3NF_Violation;

-- 1. Create a table that violates 3NF.
-- `venue_city` depends on `venue_name` (a non-key column).
-- Transitive dependency: event_id -> venue_name -> venue_city.
CREATE TABLE Events_3NF_Violation (
    event_id SERIAL PRIMARY KEY,
    event_name VARCHAR(100),
    venue_name VARCHAR(100),
    venue_city VARCHAR(100) -- This is the transitive dependency.
);

-- 2. Insert sample data.
-- 'New York' is repeated because two events are at 'Madison Square Garden'.
INSERT INTO Events_3NF_Violation (event_name, venue_name, venue_city) VALUES
('Concert A', 'Madison Square Garden', 'New York'),
('Conference B', 'Moscone Center', 'San Francisco'),
('Sports Game C', 'Madison Square Garden', 'New York');

SELECT * FROM Events_3NF_Violation;

-- 3. Normalize to 3NF.
-- Create a `Venues` table to remove the transitive dependency.
-- `Venues` table: Stores venue information once.
CREATE TABLE Venues (
    venue_id SERIAL PRIMARY KEY,
    venue_name VARCHAR(100) UNIQUE,
    venue_city VARCHAR(100)
);

-- `Events_Normalized` table: `venue_name` and `venue_city` are replaced with a foreign key `venue_id`.
CREATE TABLE Events_Normalized (
    event_id SERIAL PRIMARY KEY,
    event_name VARCHAR(100),
    venue_id INTEGER REFERENCES Venues(venue_id)
);

-- 4. Insert data into normalized tables.
-- Populate the `Venues` table first.
INSERT INTO Venues (venue_name, venue_city) VALUES ('Madison Square Garden', 'New York'), ('Moscone Center', 'San Francisco');

-- Then, insert the event data, linking to the new `Venues` table.
INSERT INTO Events_Normalized (event_name, venue_id) VALUES ('Concert A', 1), ('Conference B', 2), ('Sports Game C', 1);

-- 5. Query the normalized data.
-- Use a JOIN to combine the event and venue information.
SELECT
    e.event_name,
    v.venue_name,
    v.venue_city
FROM Events_Normalized e
JOIN Venues v ON e.venue_id = v.venue_id;
```

---

### Scenario 5: Patient and Doctor's Specialty 🩺

The `Patients_3NF_Violation` table has `patient_id` as the primary key. However, the `doctor_specialty` depends on `doctor_name`, which is a non-key column.

- **The Problem:** The `doctor_specialty` is repeated for every patient of the same doctor. This is a transitive dependency: `patient_id` -> `doctor_name` -> `doctor_specialty`.
    
- **The Solution:** Create a new `Doctors` table to store doctor-specific details.
    
    1. **`Doctors`**: Stores `doctor_name` and `doctor_specialty`. The `doctor_id` is the primary key.
        
    2. **`Patients_Normalized`**: Stores `patient_name` and a foreign key to the new `Doctors` table.
        

#### SQL Solution

```SQL
-- Drop existing tables to start fresh.
DROP TABLE IF EXISTS Patients_Normalized;
DROP TABLE IF EXISTS Doctors;
DROP TABLE IF EXISTS Patients_3NF_Violation;

-- 1. Create a table that violates 3NF.
-- `doctor_specialty` depends on `doctor_name` (a non-key column).
-- Transitive dependency: patient_id -> doctor_name -> doctor_specialty.
CREATE TABLE Patients_3NF_Violation (
    patient_id SERIAL PRIMARY KEY,
    patient_name VARCHAR(100),
    doctor_name VARCHAR(100),
    doctor_specialty VARCHAR(100) -- This is the transitive dependency.
);

-- 2. Insert sample data.
-- 'Diagnostics' is repeated because both John Smith and Jim Brown have 'Dr. House' as their doctor.
INSERT INTO Patients_3NF_Violation (patient_name, doctor_name, doctor_specialty) VALUES
('John Smith', 'Dr. House', 'Diagnostics'),
('Jane Doe', 'Dr. Cuddy', 'Endocrinology'),
('Jim Brown', 'Dr. House', 'Diagnostics');

SELECT * FROM Patients_3NF_Violation;

-- 3. Normalize to 3NF.
-- Create a `Doctors` table to remove the transitive dependency.
-- `Doctors` table: Stores doctor information once.
CREATE TABLE Doctors (
    doctor_id SERIAL PRIMARY KEY,
    doctor_name VARCHAR(100) UNIQUE,
    doctor_specialty VARCHAR(100)
);

-- `Patients_Normalized` table: `doctor_name` and `doctor_specialty` are replaced with a foreign key `doctor_id`.
CREATE TABLE Patients_Normalized (
    patient_id SERIAL PRIMARY KEY,
    patient_name VARCHAR(100),
    doctor_id INTEGER REFERENCES Doctors(doctor_id)
);

-- 4. Insert data into normalized tables.
-- Populate the `Doctors` table first.
INSERT INTO Doctors (doctor_name, doctor_specialty) VALUES ('Dr. House', 'Diagnostics'), ('Dr. Cuddy', 'Endocrinology');

-- Then, insert the patient data, linking to the new `Doctors` table.
INSERT INTO Patients_Normalized (patient_name, doctor_id) VALUES ('John Smith', 1), ('Jane Doe', 2), ('Jim Brown', 1);

-- 5. Query the normalized data.
-- Use a JOIN to combine the patient and doctor information.
SELECT
    p.patient_name,
    d.doctor_name,
    d.doctor_specialty
FROM Patients_Normalized p
JOIN Doctors d ON p.doctor_id = d.doctor_id;
```