CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Register a new user
INSERT INTO user_account (tel, email, password_hash, gender, birth_date, first_name, last_name, province, district, sub_district, street_name, zip_code)  
VALUES 
('0612345678', 
 'newuser@gmail.com', 
 crypt('securepass', gen_salt('bf')),
 'Male', 
 '1997-04-10', 
 'John', 
 'Doe', 
 'Phuket', 
 'Mueang', 
 'Patong', 
 'Nanai Rd', 
 '83150')
ON CONFLICT (tel) DO NOTHING;
