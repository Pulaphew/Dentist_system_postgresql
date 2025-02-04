CREATE OR REPLACE PROCEDURE cancel_booking(
    p_booking_id INT,
    p_user_tel VARCHAR
)
LANGUAGE plpgsql 
AS $$
DECLARE
    v_existing_booking INT;
BEGIN
    -- Check if the booking exists and belongs to the user
    SELECT COUNT(*) INTO v_existing_booking
    FROM booking
    WHERE booking_id = p_booking_id 
    AND user_tel = p_user_tel;

    IF v_existing_booking = 0 THEN
        RAISE EXCEPTION 'Booking not found or does not belong to the user';
    END IF;

    -- Update the booking status to "cancelled"
    UPDATE booking
    SET status = 'cancelled'
    WHERE booking_id = p_booking_id 
    AND user_tel = p_user_tel;

    RAISE NOTICE 'Booking cancelled successfully!';
END;
$$;
