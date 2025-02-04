-- Ensure PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- Insert data into user_account table
INSERT INTO user_account (tel, email, password_hash, gender, birth_date, first_name, last_name, province, district, sub_district, street_name, zip_code) 
VALUES
-- Patients
('0812345678', 'alice@gmail.com', 'hashed_password1', 'Female', '1995-06-15', 'Alice', 'Smith', 'Bangkok', 'Chatuchak', 'Ladprao', 'Soi 5', '10900'),
('0912345678', 'bob@gmail.com', 'hashed_password2', 'Male', '1988-02-20', 'Bob', 'Johnson', 'Chiang Mai', 'Mueang', 'Nimmanhaemin', 'Soi 2', '50200'),
-- Dentists
('0123456789', 'dr.narongdech@gmail.com', '2110252', 'Male', '1980-12-10', 'Narongdech', 'Keeratipranon', 'Bangkok', 'Pathum Wan', 'Siam', 'Rama I Rd', '10330'),
('0223456789', 'dr.michael@gmail.com', 'hashed_password7', 'Male', '1988-03-30', 'Michael', 'Davis', 'Chiang Rai', 'Mueang', 'Sukhumvit', 'Soi 10', '57000'),
('0623456789', 'dr.charlie@gmail.com', 'hashed_password3', 'Male', '1980-12-10', 'Charlie', 'Brown', 'Bangkok', 'Pathum Wan', 'Siam', 'Rama I Rd', '10330'),
('0723456789', 'dr.diana@gmail.com', 'hashed_password4', 'Female', '1985-07-22', 'Diana', 'Miller', 'Chiang Mai', 'Mueang', 'Huay Kaew', 'Soi 8', '50200'),
('0823456789', 'dr.james@gmail.com', 'hashed_password5', 'Male', '1990-02-15', 'James', 'Smith', 'Phuket', 'Mueang', 'Patong', 'Nanai Rd', '83150'),
('0923456789', 'dr.susan@gmail.com', 'hashed_password6', 'Female', '1992-10-05', 'Susan', 'Johnson', 'Bangkok', 'Bang Khen', 'Sai Mai', 'Nawamin Rd', '10220')
ON CONFLICT (tel) DO NOTHING;

-- Insert data into patient_account table
INSERT INTO patient_account (tel, medical_history, allergies, ongoing_medications) 
VALUES
('0812345678', 'No prior issues', 'Penicillin', null),
('0912345678', 'Had a root canal in 2020', null, null);

-- Insert data into clinic table
INSERT INTO clinic (clinic_tel, gps_location, clinic_province, clinic_district, clinic_sub_district, clinic_street, clinic_number, clinic_zip) 
VALUES
('0223456789', ST_GeographyFromText('POINT(100.5018 13.7563)'), 'Bangkok', 'Pathum Wan', 'Siam', 'Rama I Rd', '123', '10330'),
('0532345678', ST_GeographyFromText('POINT(98.9853 18.7883)'), 'Chiang Mai', 'Mueang', 'Nimmanhaemin', 'Huay Kaew Rd', '456', '50200');

-- Insert data into dentist_account table
INSERT INTO dentist_account (tel, certificate_of_proficiency, employement_date, previous_work, clinic_id, base_salary) 
VALUES
('0123456789', 'Engineering Dentistry', NOW(), 'Engineer', 2, 100000),
('0223456789', 'Cosmetic Dentistry', NOW(), 'Specialist', 2, 60000),
('0623456789', 'Orthodontics', NOW(), 'Doctor', 1, 40000),
('0723456789', 'Pediatric Dentistry', NOW(), 'Marine', 2, 65000),
('0823456789', 'General Dentistry', NOW(), 'Assistant', 1, 45000),
('0923456789', 'Oral Surgery', NOW(), 'Technician', 1, 70000)
ON CONFLICT (tel) DO NOTHING;

-- Insert data into service table
INSERT INTO service (service_name, service_price, service_duration) 
VALUES
('Wisdom tooth surgery', 2500, '1 hours'),
('Wisdom tooth extract', 1500, '45 minutes'),
('Tooth extract', 800, '30 minutes'),
('Teeth cleaning', 600, '45 minutes'),
('Filling', 500, '30 minutes');

-- Insert data into promotion table with explicit IDs
INSERT INTO promotion (promotion_id, promotion_detail, promotion_duration) 
VALUES 
(1, 'New Clinic', '3 months'),
(2, 'Clean & Clear', '1 months');

-- Insert data into promotion_info table ensuring foreign key integrity
INSERT INTO promotion_info (clinic_id, promotion_id, status, promotion_limit)
VALUES
(1, 1, TRUE, 100),
(2, 2, TRUE, 50);

-- Insert data into service_available table
INSERT INTO service_available (service_name, clinic_id) 
VALUES
('Wisdom tooth surgery', 1),
('Teeth cleaning', 1),
('Filling', 2),
('Tooth extract', 2);

-- Insert data into offer table
INSERT INTO offer (service_name, tel, dentist_cut) 
VALUES
('Wisdom tooth surgery', '0123456789', 30),
('Teeth cleaning', '0223456789', 20),
('Filling', '0623456789', 25);

-- Insert data into booking table
INSERT INTO booking (user_tel, dentist_tel, service_name, clinic_id, date_range, time_range, status, promotion_id) 
VALUES
('0812345678', '0123456789', 'Wisdom tooth surgery', 1, '2025-02-10', '14:00:00+07', 'confirmed', 1),
('0912345678', '0223456789', 'Teeth cleaning', 2, '2025-02-12', '10:00:00+07', 'process', 2);

-- Insert data into clinic_income table
INSERT INTO clinic_income (clinic_id, date_income, total_amount)
VALUES
(1, '2025-02-01', 50000),
(2, '2025-02-01', 75000);

-- Insert data into clinic_outcome table
INSERT INTO clinic_outcome (clinic_id, date_outcome, total_amount)
VALUES
(1, '2025-02-01', 20000),
(2, '2025-02-01', 30000);

-- Insert data into dentist_education table
INSERT INTO dentist_education (tel, dentist_college, dentist_degree, field) 
VALUES
('0123456789', 'Chulalongkorn University', 'Doctor of Dental Surgery', 'Engineering Dentistry'),
('0223456789', 'Mahidol University', 'Master in Dentistry', 'Cosmetic Dentistry'),
('0623456789', 'Thammasat University', 'Doctor of Dental Medicine', 'Orthodontics'),
('0723456789', 'Chiang Mai University', 'Master in Dentistry', 'Pediatric Dentistry'),
('0823456789', 'Prince of Songkla University', 'Bachelor of Dental Surgery', 'General Dentistry'),
('0923456789', 'Khon Kaen University', 'Doctor of Dental Surgery', 'Oral Surgery');

-- Insert data into dentist_time_slot table
-- Insert data into dentist_time_slot table with slot_date
INSERT INTO dentist_time_slot (tel, date_time, start_time, end_time) 
VALUES
-- Dentist 0123456789 (Dr. Narongdech)
('0123456789', '2025-02-05', '08:00:00+07', '12:00:00+07'),
('0123456789', '2025-02-05', '13:00:00+07', '17:00:00+07'),
('0123456789', '2025-02-06', '08:00:00+07', '12:00:00+07'),
('0123456789', '2025-02-06', '13:00:00+07', '17:00:00+07'),

-- Dentist 0223456789 (Dr. Michael)
('0223456789', '2025-02-05', '09:00:00+07', '12:00:00+07'),
('0223456789', '2025-02-05', '14:00:00+07', '18:00:00+07'),
('0223456789', '2025-02-06', '09:00:00+07', '12:00:00+07'),
('0223456789', '2025-02-06', '14:00:00+07', '18:00:00+07'),

-- Dentist 0623456789 (Dr. Charlie)
('0623456789', '2025-02-05', '10:00:00+07', '13:00:00+07'),
('0623456789', '2025-02-05', '14:00:00+07', '17:00:00+07'),
('0623456789', '2025-02-06', '10:00:00+07', '13:00:00+07'),
('0623456789', '2025-02-06', '14:00:00+07', '17:00:00+07'),

-- Dentist 0723456789 (Dr. Diana)
('0723456789', '2025-02-05', '08:30:00+07', '12:30:00+07'),
('0723456789', '2025-02-05', '13:30:00+07', '17:30:00+07'),
('0723456789', '2025-02-06', '08:30:00+07', '12:30:00+07'),
('0723456789', '2025-02-06', '13:30:00+07', '17:30:00+07'),

-- Dentist 0823456789 (Dr. James)
('0823456789', '2025-02-05', '09:00:00+07', '12:00:00+07'),
('0823456789', '2025-02-05', '13:30:00+07', '16:30:00+07'),
('0823456789', '2025-02-06', '09:00:00+07', '12:00:00+07'),
('0823456789', '2025-02-06', '13:30:00+07', '16:30:00+07'),

-- Dentist 0923456789 (Dr. Susan)
('0923456789', '2025-02-05', '07:30:00+07', '11:30:00+07'),
('0923456789', '2025-02-05', '12:30:00+07', '16:30:00+07'),
('0923456789', '2025-02-06', '07:30:00+07', '11:30:00+07'),
('0923456789', '2025-02-06', '12:30:00+07', '16:30:00+07');

