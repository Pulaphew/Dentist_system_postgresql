UPDATE booking
SET 
    user_tel = '0912345678',
    dentist_tel = '0623456789',
    service_name = 'Teeth cleaning',
    clinic_id = 1,
    date_range = '2025-03-01',
    time_range = '10:00:00+07',
    status = 'confirmed',
    promotion_id = 2
WHERE 
    booking_id = 3;
