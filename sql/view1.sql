SELECT 
    p.name AS patient_name,
    p.age,
    d.name AS doctor_name,
    d.specialization,
    a.appointment_date,
    a.diagnosis,
    b.amount
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
LEFT JOIN bills b ON p.patient_id = b.patient_id;

-- Hospital Summary
CREATE VIEW hospital_summary AS
SELECT 
    p.name AS patient_name,
    p.age,
    d.name AS doctor_name,
    d.specialization,
    a.appointment_date,
    a.diagnosis,
    b.amount
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
LEFT JOIN bills b ON p.patient_id = b.patient_id;

-- Patient Total Billing
CREATE VIEW patient_total_bill AS
SELECT 
    p.patient_id,
    p.name,
    SUM(b.amount) AS total_bill
FROM patients p
JOIN bills b ON p.patient_id = b.patient_id
GROUP BY p.patient_id, p.name;

-- Doctor Performance
CREATE VIEW doctor_performance AS
SELECT 
    d.doctor_id,
    d.name,
    d.specialization,
    COUNT(a.patient_id) AS total_patients
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.name, d.specialization;

-- Daily Hospital Activity
CREATE VIEW daily_activity AS
SELECT 
    a.appointment_date,
    COUNT(a.appointment_id) AS total_appointments,
    SUM(b.amount) AS total_revenue
FROM appointments a
LEFT JOIN bills b ON a.patient_id = b.patient_id
GROUP BY a.appointment_date;

-- Top 3 revenue patients
-- Most busy doctor
-- Daily revenue trend