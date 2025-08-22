# **Module 9: Real-World Case Study**

- **Theory:** This is the capstone module where the you will apply everything you've learned to a practical problem. The goal is to design a complete, multi-table schema for a fictional application. This involves identifying the key entities and their relationships, then using all the concepts from previous modules—keys, relationships, constraints, and data types—to build a robust, well-designed database schema.
    
## Business Requirements

### **Core Functionality**

The application is designed to help users manage projects, tasks, and communications. The key features and business rules are as follows:

- **Users:** Every person using the application must have a unique username and a unique email address. The system automatically records when each user account was created.
    
- **Projects:** A project is owned by a single user. Each project has a name and an optional description.
    
- **Tasks:** Tasks are the fundamental units of work.
    
    - Each task belongs to a specific project.
        
    - A task can be assigned to one user, but assigning it is not mandatory.
        
    - Tasks must have a title.
        
    - Every task has a status, which can only be one of three values: **'To Do'**, **'In Progress'**, or **'Done'**.
        
    - Tasks can be assigned a priority level from 1 (highest) to 5 (lowest).
        
    - An optional due date can be set for each task.
        
- **Comments:** Users can add comments to specific tasks.
    
    - Each comment is linked to a task and to the user who wrote it.
        
    - The system automatically records the date and time a comment was created.
        
- **Attachments:** Files can be attached to tasks.
    
    - An attachment is associated with a specific task and the user who uploaded the file.
        
    - The system stores the original file name and the path where the file is stored.
        

---

### **Data Relationships**

The system is built on specific relationships between these components:

- A user can own multiple projects, but a project can only have one owner.
    
- A project can have multiple tasks, but a task can only belong to one project.
    
- A user can be assigned to multiple tasks, but a task can only be assigned to one user.
    
- A task can have many comments and many attachments.
    
- A user can make many comments and upload many attachments.
    

This structure allows the application to track and organize all project-related activities, ensuring that every piece of information is correctly linked to its respective project, task, and user.

Let me know if you would like me to draft a more detailed feature list based on these requirements or if you'd like to explore how these tables could be used for reporting purposes.

    

```SQL
-- This script provides a complete schema for a project management application,
-- demonstrating the application of all concepts from the training.

-- Drop existing tables
DROP TABLE IF EXISTS task_attachments;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS tasks;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS users;

-- 1. Users: The foundation of the schema.
CREATE TABLE users (
user_id SERIAL PRIMARY KEY,
username VARCHAR(50) NOT NULL UNIQUE,
email VARCHAR(255) NOT NULL UNIQUE,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Projects: A project belongs to a user (one-to-many).
CREATE TABLE projects (
project_id SERIAL PRIMARY KEY,
project_name VARCHAR(100) NOT NULL,
description TEXT,
owner_id INTEGER NOT NULL,
FOREIGN KEY (owner_id) REFERENCES users(user_id)
);

-- 3. Tasks: A task belongs to a project (one-to-many) and is assigned to a user (one-to-one).
CREATE TABLE tasks (
task_id SERIAL PRIMARY KEY,
task_title VARCHAR(255) NOT NULL,
status VARCHAR(20) NOT NULL CHECK (status IN ('To Do', 'In Progress', 'Done')),
priority INTEGER CHECK (priority BETWEEN 1 AND 5),
due_date DATE,
project_id INTEGER NOT NULL,
assigned_to_user_id INTEGER,
FOREIGN KEY (project_id) REFERENCES projects(project_id),
FOREIGN KEY (assigned_to_user_id) REFERENCES users(user_id)
);

-- 4. Comments: A comment belongs to a task (one-to-many) and is made by a user (one-to-many).
CREATE TABLE comments (
comment_id SERIAL PRIMARY KEY,
comment_text TEXT NOT NULL,
comment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
task_id INTEGER NOT NULL,
user_id INTEGER NOT NULL,
FOREIGN KEY (task_id) REFERENCES tasks(task_id),
FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 5. Task Attachments: A task can have multiple attachments (many-to-one).
CREATE TABLE task_attachments (
attachment_id SERIAL PRIMARY KEY,
file_name VARCHAR(255) NOT NULL,
file_path VARCHAR(255) NOT NULL,
uploaded_by_user_id INTEGER NOT NULL,
task_id INTEGER NOT NULL,
FOREIGN KEY (uploaded_by_user_id) REFERENCES users(user_id),
FOREIGN KEY (task_id) REFERENCES tasks(task_id)
);

-- Insert sample data to demonstrate the relationships
INSERT INTO users (username, email) VALUES
('johndoe', 'john.doe@example.com'),
('janedoe', 'jane.doe@example.com');

INSERT INTO projects (project_name, description, owner_id) VALUES
('Website Redesign', 'Complete overhaul of the company website.', 1),
('Mobile App v1.0', 'First version of our new mobile application.', 1);
  
INSERT INTO tasks (task_title, status, priority, project_id, assigned_to_user_id) VALUES
('Design homepage mockups', 'In Progress', 1, 1, 2),
('Write user stories', 'To Do', 2, 2, 1),
('Set up database', 'Done', 1, 2, 1);

INSERT INTO comments (comment_text, task_id, user_id) VALUES
('The mockups look great!', 1, 1),
('Starting on the database setup now.', 3, 1);

-- Example JOIN queries to show how the schema works
-- Get all tasks for the "Website Redesign" project, including the assigned user's name

SELECT
t.task_title,
t.status,
u.username AS assigned_to
FROM tasks t
JOIN projects p ON t.project_id = p.project_id
JOIN users u ON t.assigned_to_user_id = u.user_id
WHERE p.project_name = 'Website Redesign';

-- Get all comments for a specific task and the name of the user who made the comment
SELECT
c.comment_text,
c.comment_date,
u.username
FROM comments c
JOIN tasks t ON c.task_id = t.task_id
JOIN users u ON c.user_id = u.user_id
WHERE t.task_title = 'Design homepage mockups';
```

