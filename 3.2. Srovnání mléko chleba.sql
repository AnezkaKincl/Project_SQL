-- 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
SELECT 
	profession.`year`,
	food.food,
	food.value,
	food.unit,
	food.price,
	profession.avg_salary,
	ROUND(profession.avg_salary/food.price,0) AS quantity_food
FROM (
	SELECT 
    	value AS price,
    	name AS food,
    	YEAR(date_from) AS year_food,
    	price_value AS value,
    	price_unit AS unit
	FROM czechia_price AS cp 
	JOIN czechia_price_category AS cpc 
    	ON cp.category_code = cpc.code
    WHERE 
    	 (cp.category_code = 111301 OR cp.category_code = 114201)
    AND (YEAR(cp.date_from) = 2006 OR YEAR(cp.date_from) = 2018)
	GROUP BY 
    	year_food,
    	cpc.name
	ORDER BY 
		year_food,
		value
	) AS food
LEFT JOIN (
	SELECT 
		ROUND(AVG(value))  AS avg_salary, 
		payroll_year AS `year`	 
	FROM czechia_payroll AS cp
	JOIN czechia_payroll_industry_branch AS cpib 
		ON cp.industry_branch_code = cpib.code 
	WHERE 
		value_type_code = 5958 AND 
		industry_branch_code IS NOT NULL 
	GROUP BY 
		payroll_year		
	ORDER BY 
		payroll_year		 
	) AS profession
ON food.year_food = profession.`year`
WHERE profession.`year` IN (2006, 2018)
GROUP BY 	
	food.food,
	profession.`year`;