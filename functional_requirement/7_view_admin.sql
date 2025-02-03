SELECT 
    b.booking_id,
    b.date_range,
    b.time_range,
    b.status AS booking_status,
    s.service_name,
    ua.first_name AS patient_first_name,
    ua.last_name AS patient_last_name,
    ua.first_name AS dentist_first_name,
    ua.last_name AS dentist_last_name,
    c.clinic_province,
    c.clinic_district,
    c.clinic_sub_district,
    c.clinic_street,
    c.clinic_number
FROM 
    booking b
JOIN 
    service s ON b.service_name = s.service_name
JOIN 
    user_account ua ON b.user_tel = ua.tel
JOIN 
    dentist_account da ON b.dentist_tel = da.tel
JOIN 
    clinic c ON b.clinic_id = c.clinic_id;
