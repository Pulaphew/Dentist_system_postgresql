-- note. total 14 tables
-- extension for GPS coordinates
CREATE EXTENSION IF NOT EXISTS postgis ;

-- create table user
CREATE TABLE user_account(
	tel VARCHAR(10) PRIMARY KEY,
	email VARCHAR(50) NOT NULL ,
	password_hash VARCHAR(255) NOT NULL,
	gender VARCHAR(10) NOT NULL,
	birth_date DATE NOT NULL,
	first_name VARCHAR(255) NOT NULL,
	last_name VARCHAR(255) NOT NULL,
	-- จังหวัด
	province VARCHAR(255) NOT NULL,
	-- เมือง
	district VARCHAR(255) NOT NULL,
	-- ตำบล
	sub_district VARCHAR(255) NOT NULL,
	street_name VARCHAR(255),
	zip_code VARCHAR(5) NOT NULL
);

-- create clinic

CREATE TABLE clinic(
-- SERIAL auto increment integer row in column
	clinic_id SERIAL PRIMARY KEY,
	clinic_tel VARCHAR(10) NOT NULL,
	-- 
	gps_location GEOGRAPHY(POINT,4326) NOT NULL,
	-- 
	clinic_province VARCHAR(255) NOT NULL,
	clinic_district VARCHAR(255) NOT NULL,
	clinic_sub_district VARCHAR(255) NOT NULL,
	clinic_street VARCHAR(255) NOT NULL,
	clinic_number VARCHAR(255) NOT NULL,
	clinic_zip VARCHAR(5) NOT NULL ;
);

-- create clinic income
CREATE TABLE clinic_income(
	clinic_id SERIAL NOT NULL ,
	date_income DATE NOT NULL,
	total_amount NUMERIC CHECK (total_amount >= 0) NOT NULL,
	PRIMARY KEY (clinic_id,date_income),
	FOREIGN KEY (clinic_id) REFERENCES clinic(clinic_id)
);

-- create clinic outcome
CREATE TABLE clinic_outcome(
	clinic_id SERIAL NOT NULL,
	date_outcome DATE NOT NULL,
	total_amount NUMERIC CHECK (total_amount >= 0) NOT NULL,
	PRIMARY KEY (clinic_id,date_outcome),
	FOREIGN KEY (clinic_id) REFERENCES clinic(clinic_id)
);

-- create patient table
CREATE TABLE patient_account(
	tel VARCHAR(10) PRIMARY KEY,
	medical_history TEXT,
	-- ยาที่แพ้
	allergies VARCHAR(50) ,
	ongoing_medications VARCHAR(50),
	FOREIGN KEY (tel) REFERENCES user_account(tel)
);

-- create dentist table
CREATE TABLE dentist_account(
	tel VARCHAR(10) PRIMARY KEY,
	certificate_of_proficiency VARCHAR(255) NOT NULL,
	employement_date DATE NOT NULL,
	previous_work VARCHAR(255),
	clinic_id INTEGER NOT NULL,
	base_salary NUMERIC CHECK (base_salary > 0) NOT NULL,
	FOREIGN KEY (tel) REFERENCES user_account(tel),
	FOREIGN KEY (clinic_id) REFERENCES clinic(clinic_id)
) ;

-- create dentist time slot table
CREATE TABLE dentist_time_slot(
	tel VARCHAR(10),
	-- date_time DATE NOT NULL ,
	start_time TIME WITH TIME ZONE,
	end_time TIME WITH TIME ZONE ,
	PRIMARY KEY (tel,start_time,end_time),
	FOREIGN KEY (tel) REFERENCES dentist_account(tel)
);

-- create dentist education table
CREATE TABLE dentist_education(
	tel VARCHAR(10),
	dentist_college VARCHAR(255),
	dentist_degree VARCHAR(255),
	field VARCHAR(255),
	PRIMARY KEY (tel,dentist_college,dentist_degree,field)
);

-- create service table
CREATE TABLE service(
	service_name VARCHAR(255) PRIMARY KEY,
	service_price NUMERIC CHECK (service_price > 0) NOT NULL,
	service_duration INTERVAL NOT NULL
);

-- create service available table
CREATE TABLE service_available(
	service_name VARCHAR(255),
	clinic_id INTEGER,
	PRIMARY KEY (service_name ,clinic_id)
	FOREIGN KEY (service_name) REFERENCES service(service_name),
	FOREIGN KEY (clinic_id) REFERENCES clinic(clinic_id)
);

-- create offer table
CREATE TABLE offer(
	service_name VARCHAR(255),
	tel VARCHAR(10),
	dentist_cut NUMERIC CHECK (dentist_cut >= 0) NOT NULL,
	PRIMARY KEY (service_name , tel),
	FOREIGN KEY (service_name) REFERENCES service(service_name),
	FOREIGN KEY (tel) REFERENCES dentist(tel)
);

-- create promotion
CREATE TABLE promotion(
	promotion_id SERIAL PRIMARY KEY,
	promotion_detail TEXT NOT NULL,
	promotion_duration INTERVAL
);

-- create promotion info
CREATE TABLE promotion_info(
	clinic_id SERIAL,
	promotion_id SERIAL,
	status BOOLEAN NOT NULL,
	promotion_limit INTEGER CHECK (promotion_limit >= 1),
	PRIMARY KEY (clinic_id,promotion_id),
	FOREIGN KEY (clinic_id) REFERENCES clinic(clinic_id),
	FOREIGN KEY (promotion_id) REFERENCES promotion(promotion_id),
);

-- create booking table
DROP TYPE IF EXISTS booking_status;
CREATE TYPE booking_status AS ENUM(
	'confirmed',
	'process',
	'cancelled',
	'completed'
);

CREATE TABLE booking(
	booking_id SERIAL PRIMARY KEY,
	user_tel VARCHAR(10) NOT NULL,
	dentist_tel VARCHAR(10) NOT NULL,
	service_name VARCHAR(255) NOT NULL,
	clinic_id SERIAL NOT NULL,
	date_range DATE NOT NULL,
	time_range TIME WITH TIME ZONE NOT NULL,
	status booking_status NOT NULL DEFAULT 'confirmed',
	promotion_id INTEGER ,
	FOREIGN KEY (user_tel) REFERENCES patient_account(tel),
	FOREIGN KEY (dentist_tel) REFERENCES dentist_account(tel),
	FOREIGN KEY (service_name) REFERENCES service(service_name),
	FOREIGN KEY (clinic_id) REFERENCES clinic(clinic_id),
	FOREIGN KEY (promotion_id) REFERENCES promotion(promotion_id),
);