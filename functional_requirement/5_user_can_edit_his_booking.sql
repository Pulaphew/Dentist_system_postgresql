CREATE OR REPLACE PROCEDURE edit_booking(
    p_booking_id INT,
    p_user_tel VARCHAR,
    p_new_dentist_tel VARCHAR,
    p_new_service_name VARCHAR,
    p_new_clinic_id INT,
    p_new_booking_date DATE,
    p_new_booking_time TIME WITH TIME ZONE
)
LANGUAGE plpgsql 
AS $$
DECLARE
    v_existing_booking INT;
    v_dentist_available INT;
BEGIN
    -- Check if the booking exists and belongs to the user
    SELECT COUNT(*) INTO v_existing_booking
    FROM booking
    WHERE booking_id = p_booking_id AND user_tel = p_user_tel;

    IF v_existing_booking = 0 THEN
        RAISE EXCEPTION 'Booking not found or does not belong to the user';
    END IF;

    -- Check if the dentist is available at the new date and time
    SELECT COUNT(*) INTO v_dentist_available
    FROM dentist_time_slot
    WHERE tel = p_new_dentist_tel 
    AND date_time = p_new_booking_date
    AND start_time <= p_new_booking_time
    AND end_time > p_new_booking_time;

    IF v_dentist_available = 0 THEN
        RAISE EXCEPTION 'The selected dentist is not available at this time';
    END IF;

    -- Update the booking details
    UPDATE booking
    SET dentist_tel = p_new_dentist_tel,
        service_name = p_new_service_name,
        clinic_id = p_new_clinic_id,
        date_range = p_new_booking_date,
        time_range = p_new_booking_time,
        status = 'confirmed'
    WHERE booking_id = p_booking_id AND user_tel = p_user_tel;
END;
$$;

CALL edit_booking(
    26, -- Booking ID
    '0812345678', -- User Tel
    '0123456789', -- New Dentist Tel
    'Tooth extract', -- New Service
    2, -- New Clinic ID
    '2025-02-05', -- New Date
    '08:00:00+07:00' -- New Time
);

