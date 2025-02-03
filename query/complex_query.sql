-- แสดงชื่อ-นามสุกล เงินเดือน ของหมอฟันที่มีเงินเดือนมากกว่าค่าเฉลี่ยของหมอฟันทุกคนในคลินิกสาขาตัวเอง

SELECT first_name AS Dentist_First_Name , last_name AS Dentist_Last_Name, base_salary AS Salary
FROM user_account NATURAL JOIN dentist_account NATURAL JOIN (
	SELECT clinic_id , AVG(base_salary) AS avg_salary
	FROM dentist_account
	GROUP BY clinic_id
) AS subquery
WHERE base_salary > subquery.avg_salary
ORDER BY clinic_id;