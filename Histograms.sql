-- Create histogram of user base's website visit RECENCY (how many people visited last 1 days ago, 2 days ago, 3 days ago .... n days ago)

WITH counts AS 
(
select user_crm_id AS user, DATE_DIFF(CAST('2022-01-01' AS DATE), CAST(MAX(date) AS DATE), DAY) as number_of_days
FROM `Prism_Main.transactions`
GROUP BY user_crm_id
)

SELECT number_of_days, COUNT(user) as number_of_users
FROM counts
GROUP BY number_of_days
ORDER BY 1


--Create histogram of use base's MONETARY return (How many customers provide £1 in revenue per year, £2 in rev per year, £3 in rev per year ... £n in rev per year)

WITH counts AS 
(
select user_crm_id, SUM(transaction_total) as total_spent
FROM `Prism_Main.transactions`
GROUP BY user_crm_id
)

SELECT total_spent, COUNT(user_crm_id) as number_of_users
FROM counts
GROUP BY total_spent
ORDER BY 1