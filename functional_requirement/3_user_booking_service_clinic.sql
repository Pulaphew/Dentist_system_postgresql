INSERT INTO patient_account (tel, medical_history, allergies, ongoing_medications)
VALUES
    ('0812345678', 'No prior issues', 'Penicillin', NULL),
    ('0912345678', 'Had a root canal in 2020', NULL, NULL)
ON CONFLICT (tel) DO NOTHING;

INSERT INTO booking (user_tel, dentist_tel, service_name, clinic_id, date_range, time_range, status)
VALUES
    ('0812345678', '0123456789', 'Wisdom tooth surgery', 1, '2025-02-10', '10:00:00+07', 'confirmed'),
    ('0912345678', '0223456789', 'Teeth cleaning', 2, '2025-02-11', '14:00:00+07', 'confirmed'),
    ('0812345678', '0623456789', 'Tooth extract', 1, '2025-02-12', '09:30:00+07', 'confirmed'),
    ('0912345678', '0723456789', 'Filling', 2, '2025-02-13', '11:00:00+07', 'confirmed');
