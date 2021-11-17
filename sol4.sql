SELECT name, COUNT(*) AS days
FROM t_contractor_work_day
GROUP BY name

SELECT name, COUNT(*) AS days
FROM t_contractor_work_day
GROUP BY name
HAVING COUNT(*) > 10

SELECT name
FROM t_contractor_work_day
WHERE date_begin >= '14.01.2019' AND date_begin < '17.01.2019'
GROUP BY name
HAVING COUNT(*) = 3