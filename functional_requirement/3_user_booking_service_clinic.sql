-- function to list available dentist with request
-- 
CREATE OR REPLACE FUNCTION get_available_dentists(
	p_patient_tel VARCHAR,
	p_service_name VARCHAR,
	p_booking_date DATE
)
RETURNS TABLE(
	dentist_tel VARCHAR,
	dentist_name VARCHAR,
	exp_year NUMERIC,
	expertise VARCHAR,
	clinic_id INTEGER,
	clinic_name VARCHAR,
	clinic_location GEOGRAPHY(POINT,4326)
)AS
$$
BEGIN
	RETURN query
	SELECT
		d.tel AS dentist_tel,
		CONCAT(u.first_name,' ',u.last_name)::VARCHAR AS dentist_name,
		EXTRACT(YEAR FROM AGE(CURRENT_DATE,d.employement_date))
		AS exp_year,
		d.certificate_of_proficiency AS expertise,
		c.clinic_id,
		c.clinic_street::VARCHAR AS clinic_name,
		c.gps_location AS clinic_location
	FROM dentist_account d
	JOIN user_account u ON d.tel = u.tel
	JOIN clinic c ON d.clinic_id = c.clinic_id
	JOIN service_available sa ON sa.clinic_id = c.clinic_id
	JOIN dentist_time_slot ts ON ts.tel = d.tel
	WHERE sa.service_name = p_service_name
	AND ts.date_time = p_booking_date ;
END;
$$ LANGUAGE plpgsql ;

-- try function
SELECT * 
FROM get_available_dentists('0812345678', 'Wisdom tooth surgery', '2025-02-05');

-- booking function
-- 
DROP PROCEDURE IF EXISTS  patient_booking(
    p_patient_name VARCHAR,
    p_patient_tel VARCHAR,
    p_dentist_name VARCHAR,
    p_dentist_tel VARCHAR,
    p_service_name VARCHAR,
    p_booking_date DATE,
    p_clinic_id INTEGER,
    p_status booking_status
);
-- 
CREATE OR REPLACE PROCEDURE patient_booking(
    p_patient_tel VARCHAR,
    p_dentist_tel VARCHAR,
    p_service_name VARCHAR,
    p_booking_date DATE,
    p_clinic_id INTEGER,
    p_status booking_status DEFAULT 'confirmed'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_existing_booking INT;
    v_start_time TIME WITH TIME ZONE;
BEGIN
    -- Check if the patient already has a booking on the same day
    SELECT COUNT(*) INTO v_existing_booking 
    FROM booking 
    WHERE user_tel = p_patient_tel 
    AND date_range = p_booking_date 
    AND status IN ('confirmed', 'process');

    IF v_existing_booking > 0 THEN
        RAISE EXCEPTION 'Patient already has a booking on this date';
    END IF;

    -- Get the earliest available time slot for the dentist on that date
    SELECT start_time INTO v_start_time
    FROM dentist_time_slot 
    WHERE tel = p_dentist_tel 
    AND date_time = p_booking_date
    ORDER BY start_time 
    LIMIT 1;

    IF v_start_time IS NULL THEN
        RAISE EXCEPTION 'Dentist is not available on this date';
    END IF;

    -- Insert the booking
    INSERT INTO booking (user_tel, dentist_tel, service_name, clinic_id, date_range, time_range, status)
    VALUES (p_patient_tel, p_dentist_tel, p_service_name, p_clinic_id, p_booking_date, v_start_time, p_status);
END;
$$;

CALL patient_booking(
    '0812345678',  -- Alice (Patient)
    '0123456789',  -- Dr. Narongdech (Dentist)
    'Wisdom tooth surgery',
    '2025-02-05',
    1,             -- Clinic ID
    'confirmed'
);

SELECT * FROM booking ;

