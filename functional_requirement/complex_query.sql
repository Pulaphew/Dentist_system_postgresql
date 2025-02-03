--  complex query that show 
-- booking that have patient who has allergies Penicillin
SELECT
    ua.first_name || ' ' || ua.last_name AS patient_name,
    pa.allergies,
    b.booking_id,
    b.date_range AS booking_date,
    b.time_range AS booking_time,
    s.service_name,
    uda.first_name || ' ' || uda.last_name AS dentist_name,
    c.clinic_number || ', ' || c.clinic_street || ', ' || c.clinic_district AS clinic_address
FROM
    patient_account pa
JOIN
    user_account ua ON pa.tel = ua.tel
JOIN
    booking b ON pa.tel = b.user_tel
JOIN
    service s ON b.service_name = s.service_name
JOIN
    dentist_account da ON b.dentist_tel = da.tel
JOIN
    user_account uda ON da.tel = uda.tel
JOIN
    clinic c ON b.clinic_id = c.clinic_id
WHERE
    pa.allergies LIKE '%Penicillin%'
ORDER BY
    b.date_range, b.time_range;
