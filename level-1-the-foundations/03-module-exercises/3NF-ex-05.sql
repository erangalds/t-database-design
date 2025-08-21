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
