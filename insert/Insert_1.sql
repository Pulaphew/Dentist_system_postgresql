-- User Table
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

-- Patients Table
INSERT INTO patient_account (tel, medical_history, allergies, ongoing_medications) 
VALUES
('0812345678', 'No prior issues', 'Penicillin' , null),
('0912345678', 'Had a root canal in 2020', null , null);

INSERT INTO dentist_account (tel, certificate_of_proficiency, employement_date, previous_work , clinic_id , base_salary) 
VALUES
('0123456789', 'Engineering Dentistry', NOW(), 'Engineer' , 2 , 100000),
('0223456789', 'Cosmetic Dentistry', NOW(), 'Specialist', 2, 60000),
('0623456789', 'Orthodontics', NOW(), 'Doctor', 1, 40000),
('0723456789', 'Pediatric Dentistry', NOW(), 'Marine', 2, 65000),
('0823456789', 'General Dentistry', NOW(), 'Assistant', 1, 45000),
('0923456789', 'Oral Surgery', NOW(), 'Technician', 1, 70000)
ON CONFLICT (tel) DO NOTHING;

-- Clinic Table
INSERT INTO clinic (clinic_tel, gps_location, clinic_province, clinic_district, clinic_sub_district, clinic_street, clinic_number, clinic_zip) 
VALUES
('0223456789', ST_GeographyFromText('POINT(13.7563 100.5018)'), 'Bangkok', 'Pathum Wan', 'Siam', 'Rama I Rd', '123', '10330'),
('0532345678', ST_GeographyFromText('POINT(18.7883 98.9853)'), 'Chiang Mai', 'Mueang', 'Nimmanhaemin', 'Huay Kaew Rd', '456', '50200');

-- Service Table
INSERT INTO service (service_name , service_price , service_duration) 
VALUES
('Wisdom tooth surgery' , 2500 , '1 hours'),
('Wisdom tooth extract' , 1500 , '45 minutes'),
('Tooth extract' , 800 , '30 minutes'),
('Teeth cleaning' , 600 , '45 minutes'),
('Filling' , 500 , '30 minutes');

-- Promotion Table
INSERT INTO promotion (promotion_detail , promotion_duration) 
VALUES 
('New Clinic' , '3 months'),
('Clean & Clear' , '1 months');