CREATE TABLE `t_{Anezka}_{Kinclova}_project_SQL_primary_final` AS
SELECT 
    profession.`year`,
    food.price,
    food.food,
    food.value,
    food.unit,
    profession.salary,
    profession.profession 	
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
    GROUP BY 
        year_food,
        cpc.name
    ORDER BY 
        year_food,
        value
    ) AS food
LEFT JOIN (
    SELECT 
        value AS salary,
        name AS profession, 
        payroll_year AS `year`	 
    FROM czechia_payroll AS cp
    JOIN czechia_payroll_industry_branch AS cpib 
        ON cp.industry_branch_code = cpib.code 
    WHERE 
        value_type_code = 5958 AND 
        payroll_year BETWEEN 2006 AND 2018 AND
        industry_branch_code IS NOT NULL 
    GROUP BY 
        payroll_year,
        industry_branch_code 
    ORDER BY 
        payroll_year,
        value 
    ) AS profession
ON food.year_food = profession.`year`
GROUP BY 
    food.food,
    profession.profession,
    profession.`year`;