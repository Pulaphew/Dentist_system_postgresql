CREATE OR REPLACE FUNCTION get_user_booking_details(p_user_tel VARCHAR)
RETURNS TABLE (
    booking_id INT,
    user_name VARCHAR,
    dentist_name VARCHAR,
    service_name VARCHAR,
    clinic_name VARCHAR,
    booking_date DATE,
    booking_time TIME WITH TIME ZONE,
    status booking_status
) 
LANGUAGE plpgsql 
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.booking_id,
        CONCAT(u.first_name, ' ', u.last_name)::VARCHAR AS user_name,
        CONCAT(d.first_name, ' ', d.last_name)::VARCHAR AS dentist_name,
        b.service_name::VARCHAR,
        c.clinic_street::VARCHAR AS clinic_name,
        b.date_range AS booking_date,
        b.time_range AS booking_time,
        b.status
    FROM booking b
    JOIN user_account u ON b.user_tel = u.tel
    JOIN user_account d ON b.dentist_tel = d.tel
    JOIN clinic c ON b.clinic_id = c.clinic_id
    WHERE b.user_tel = p_user_tel;
END;
$$;


CREATE OR REPLACE VIEW user_booking_view AS
SELECT * FROM get_user_booking_details(p_user_tel := '0812345678');

SELECT * FROM user_booking_view ;



