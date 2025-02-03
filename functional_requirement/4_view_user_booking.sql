DROP VIEW IF EXISTS simple_user_bookings;

CREATE VIEW simple_user_bookings AS
SELECT 
    b.booking_id,
    b.date_range,
    b.time_range,
    b.status AS booking_status,
    s.service_name,
    ua.first_name AS patient_first_name,
    ua.last_name AS patient_last_name
FROM 
    booking b
JOIN 
    service s ON b.service_name = s.service_name
JOIN 
    user_account ua ON b.user_tel = ua.tel
WHERE 
    b.user_tel = '0812345678'; 

-- insert booking data
INSERT INTO booking (user_tel, dentist_tel, service_name, clinic_id, date_range, time_range, status, promotion_id) 
VALUES
('0812345678', '0123456789', 'Wisdom tooth surgery', 2, '2025-02-10', '10:00:00+07', 'confirmed', 1),
('0912345678', '0223456789', 'Tooth extract', 1, '2025-02-12', '14:00:00+07', 'process', 2); 


SELECT * FROM simple_user_bookings;
