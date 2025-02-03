CREATE TABLE admin_user_log(
	exec_time timestamp NOT NULL,
	tel VARCHAR(10),
	email VARCHAR(50) NOT NULL ,
	password_hash VARCHAR(255) NOT NULL,
	gender VARCHAR(10) NOT NULL,
	birth_date DATE NOT NULL,
	first_name VARCHAR(255) NOT NULL,
	last_name VARCHAR(255) NOT NULL,
	province VARCHAR(255) NOT NULL,
	district VARCHAR(255) NOT NULL,
	sub_district VARCHAR(255) NOT NULL,
	street_name VARCHAR(255),
	zip_code VARCHAR(5) NOT NULL
);

CREATE OR REPLACE FUNCTION admin_user_history()
 	RETURNS TRIGGER
 	language plpgsql
 	AS $$
 	BEGIN
 		INSERT INTO admin_user_log 
 		VALUES(now() , OLD.tel , OLD.email , OLD.password_hash , OLD.gender , OLD.birth_date , OLD.first_name , OLD.last_name , 
 				OLD.province , OLD.district , OLD.sub_district , OLD.street_name , OLD.zip_code);
 		RETURN NEW;
 	END;
 	$$

CREATE TRIGGER update_user_data
 	BEFORE UPDATE
 	ON user_account
 	FOR EACH ROW
 	EXECUTE PROCEDURE admin_user_history();
