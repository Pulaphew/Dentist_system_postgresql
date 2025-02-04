-- Create admin_account TABLE
DROP TABLE IF EXISTS admin_account ;
CREATE TABLE admin_account (
    tel VARCHAR(10) PRIMARY KEY REFERENCES user_account(tel) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL DEFAULT 'admin',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insert Admins
INSERT INTO admin_account (tel, role) VALUES 
    ('0123456789', 'super_admin'),
    ('0223456789', 'admin'),
    ('0623456789', 'admin')
ON CONFLICT (tel) DO NOTHING ;

-- Create Admin Booking Log TABLE
DROP TABLE IF EXISTS admin_booking_log ;
CREATE TABLE admin_booking_log (
    log_id SERIAL PRIMARY KEY,
    exec_time TIMESTAMP DEFAULT NOW(),
    admin_tel VARCHAR(10) REFERENCES admin_account(tel) ON DELETE SET NULL,
    action_type VARCHAR(20) CHECK (action_type IN ('VIEW', 'EDIT', 'DELETE', 'ADD_PATIENT')),
    booking_id INTEGER REFERENCES booking(booking_id) ON DELETE SET NULL,
    details TEXT
);

-- Create Function to Log Admin Actions
CREATE OR REPLACE FUNCTION log_admin_booking_action()
RETURNS TRIGGER AS $$ 
BEGIN
    INSERT INTO admin_booking_log (admin_tel, action_type, booking_id, details)
    VALUES (
        current_setting('app.current_admin', true), 
        CASE 
            WHEN TG_OP = 'INSERT' THEN 'ADD_PATIENT'
            WHEN TG_OP = 'UPDATE' THEN 'EDIT'
            WHEN TG_OP = 'DELETE' THEN 'DELETE'
            ELSE 'UNKNOWN'
        END, 
        CASE 
            WHEN TG_OP = 'DELETE' THEN NULL  -- Don't insert deleted booking_id
            ELSE COALESCE(NEW.booking_id, OLD.booking_id)
        END, 
        CASE 
            WHEN TG_OP = 'INSERT' THEN 'New patient booking added'
            WHEN TG_OP = 'UPDATE' THEN 'Booking edited'
            WHEN TG_OP = 'DELETE' THEN 'Booking deleted'
            ELSE 'Unknown action'
        END
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Triggers for Logging Admin Actions
DROP TRIGGER IF EXISTS admin_add_booking_trigger ON booking  ;
CREATE TRIGGER admin_add_booking_trigger
AFTER INSERT ON booking
FOR EACH ROW
EXECUTE FUNCTION log_admin_booking_action();

DROP TRIGGER IF EXISTS admin_edit_booking_trigger ON booking;
CREATE TRIGGER admin_edit_booking_trigger
AFTER UPDATE ON booking
FOR EACH ROW
EXECUTE FUNCTION log_admin_booking_action();

DROP TRIGGER IF EXISTS admin_delete_booking_trigger ON booking;
CREATE TRIGGER admin_delete_booking_trigger
AFTER DELETE ON booking
FOR EACH ROW
EXECUTE FUNCTION log_admin_booking_action();


-- Function for Admin to View Bookings
CREATE OR REPLACE FUNCTION admin_view_booking()
RETURNS TABLE (
    booking_id INTEGER,
    user_tel VARCHAR,
    dentist_tel VARCHAR,
    service_name VARCHAR,
    clinic_id INTEGER,
    date_range DATE,
    time_range TIME WITH TIME ZONE,
    status booking_status
) AS $$ 
BEGIN
    -- Return all booking details
    RETURN QUERY
    SELECT 
        b.booking_id, 
        b.user_tel, 
        b.dentist_tel, 
        b.service_name, 
        b.clinic_id, 
        b.date_range, 
        b.time_range, 
        b.status
    FROM booking b;
END;
$$ LANGUAGE plpgsql;


-- Grant Admin Permissions
	-- if admin_role role doenst exists in PostgreSQL , then create admin_role
	-- pg_roles is system table that store database role
DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'admin_role') THEN
		CREATE ROLE admin_role;
	END IF ;
END $$;

-- permission admin_role can manage booking
GRANT SELECT , UPDATE , DELETE ON booking TO admin_role ;
-- give USAGE to adminrole to manage eg.INSERT by sequenece of booking_id
GRANT USAGE , SELECT ON SEQUENCE booking_booking_id_seq TO admin_role;


DO $$ 
DECLARE
    admin_tel VARCHAR(10);
    role_name TEXT;
BEGIN
    FOR admin_tel IN (SELECT tel FROM admin_account) LOOP
        -- Generate a valid role name
        role_name := 'admin_' || admin_tel;

        -- Check if the role exists, if not, create it
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = role_name) THEN
            EXECUTE FORMAT('CREATE ROLE %I', role_name);
        END IF;

        -- Grant admin_role to the generated role
        EXECUTE FORMAT('GRANT admin_role TO %I', role_name);
    END LOOP;
END $$;

-- create view using stored function
-- Create View Using Refactored Function
DROP VIEW IF EXISTS admin_booking_view;
CREATE OR REPLACE VIEW admin_booking_view AS
SELECT * FROM admin_view_booking();

-- grant admin_booking_view to admin_role
GRANT SELECT ON admin_booking_view TO admin_role;

-- example
-- update
SET app.current_admin = '0123456789';
UPDATE booking 
SET date_range = '2025-02-16' 
WHERE booking_id = 28;

-- delete
DELETE FROM booking WHERE booking_id = 28;

-- view booking
SELECT * FROM admin_booking_view;








