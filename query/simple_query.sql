-- แสดงเบอร์โทรหมอฟัน และ รหัสคลินิก โดยที่เงินเดือนหมอฟันมากกว่า 50000 บาท

SELECT tel , clinic_id
FROM dentist_account
WHERE base_salary > 50000