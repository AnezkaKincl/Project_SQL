CREATE TABLE `t_{Anezka}_{Kinclova}_project_SQL_secondary_final` AS
SELECT
	country,
	`year`,
	GDP,
	gini,
	population	
FROM economies AS e 
WHERE
	`year` BETWEEN 2006 AND 2018
	AND country LIKE '%Euro%'
GROUP BY 
	country,
	`year`
ORDER BY 
	country ;