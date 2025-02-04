-- create table store about user login logout
CREATE TABLE user_session (
    session_id SERIAL PRIMARY KEY,
    tel VARCHAR(10) NOT NULL,
    action_type VARCHAR(10) CHECK (action_type IN ('login', 'logout')) NOT NULL,
    action_timestamp TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (tel) REFERENCES user_account(tel)
);

-- stored function that can insert into user_session
DROP FUNCTION IF EXISTS user_login(p_email VARCHAR, p_password VARCHAR) ;
CREATE OR REPLACE FUNCTION user_login(p_email VARCHAR, p_password VARCHAR)
RETURNS VOID AS $$
DECLARE
    v_tel VARCHAR(10);
    v_password VARCHAR(255);
BEGIN
    -- Get the user's telephone number and password hash
    SELECT tel, password_hash INTO v_tel, v_password 
    FROM user_account 
    WHERE email = p_email;

    -- Check if user exists and password matches
    IF v_tel IS NULL OR v_password != p_password THEN
        RAISE EXCEPTION 'Invalid email or password';
    END IF;

    -- Insert login record
    INSERT INTO user_session (tel, action_type) 
    VALUES (v_tel, 'login');
END;
$$ LANGUAGE plpgsql;


-- logout
DROP FUNCTION IF EXISTS user_logout(p_email VARCHAR) ;
CREATE OR REPLACE FUNCTION user_logout(p_email VARCHAR)
RETURNS VOID AS $$
DECLARE
    v_tel VARCHAR(10);
BEGIN
    -- Get the user's telephone number from email
    SELECT tel INTO v_tel FROM user_account WHERE email = p_email;

    -- Check if user exists
    IF v_tel IS NULL THEN
        RAISE EXCEPTION 'Invalid email';
    END IF;

    -- Insert logout record
    INSERT INTO user_session (tel, action_type) 
    VALUES (v_tel, 'logout');
END;
$$ LANGUAGE plpgsql;

-- call function
SELECT user_login('alice@gmail.com', 'hashed_password1');
SELECT user_logout('alice@gmail.com');

-- show user_session
SELECT * FROM user_session ;



