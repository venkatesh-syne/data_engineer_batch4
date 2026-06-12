use hospital

CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    gender VARCHAR(10)
);

CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100),
    specialization VARCHAR(100)
);


CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    diagnosis VARCHAR(255)
);

CREATE TABLE bills (
    bill_id INT PRIMARY KEY,
    patient_id INT,
    amount DECIMAL(10,2),
    bill_date DATE
);



INSERT INTO patients VALUES
(1, 'Ravi', 30, 'M'),
(2, 'Anita', 25, 'F'),
(3, 'Kiran', 40, 'M'),
(4, 'Meena', 35, 'F'),
(5, 'Arjun', 28, 'M'),
(6, 'Divya', 32, 'F'),
(7, 'Rahul', 45, 'M'),
(8, 'Sneha', 29, 'F');

INSERT INTO doctors VALUES
(101, 'Dr. Sharma', 'Cardiology'),
(102, 'Dr. Rao', 'Neurology'),
(103, 'Dr. Mehta', 'Orthopedics'),
(104, 'Dr. Iyer', 'Dermatology'),
(105, 'Dr. Khan', 'General Medicine');

INSERT INTO appointments VALUES
(1001, 1, 101, '2024-04-01', 'Heart Checkup'),
(1002, 2, 102, '2024-04-02', 'Migraine'),
(1003, 3, 103, '2024-04-03', 'Fracture'),
(1004, 4, 104, '2024-04-04', 'Skin Allergy'),
(1005, 5, 105, '2024-04-05', 'Fever'),
(1006, 6, 101, '2024-04-06', 'Chest Pain'),
(1007, 7, 102, '2024-04-07', 'Headache'),
(1008, 8, 105, '2024-04-08', 'Cold'),
(1009, 1, 105, '2024-04-09', 'Follow-up'),
(1010, 2, 101, '2024-04-10', 'Heart Screening');


INSERT INTO bills VALUES
(5001, 1, 2000, '2024-04-01'),
(5002, 2, 1500, '2024-04-02'),
(5003, 3, 3000, '2024-04-03'),
(5004, 4, 1200, '2024-04-04'),
(5005, 5, 800, '2024-04-05'),
(5006, 6, 2500, '2024-04-06'),
(5007, 7, 1800, '2024-04-07'),
(5008, 8, 900, '2024-04-08'),
(5009, 1, 1000, '2024-04-09'),
(5010, 2, 2200, '2024-04-10');