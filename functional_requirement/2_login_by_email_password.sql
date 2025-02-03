-- User Login Query
SELECT tel, first_name, last_name
FROM user_account
WHERE email = 'newuser@gmail.com'
AND password_hash = crypt('securepass', password_hash);
