UPDATE booking
SET 
    date_range = '2025-02-15',  
    time_range = '11:00:00+07', 
    service_name = 'Teeth cleaning', 
    status = 'confirmed' 
WHERE 
    booking_id = 1         
    AND user_tel = '0812345678'; 
