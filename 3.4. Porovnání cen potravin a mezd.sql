-- 4.	Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
-- u spodní WHERE odfiltrovává sloupečky PRC se zápornými hodnotami
SELECT 
    `year`,
    average_salary,
    prc_avg_salary,
    price,
    prc_price,
    (prc_avg_salary - prc_price) AS differ_prc,
    CASE
	    WHEN prc_avg_salary IS NULL THEN NULL
		WHEN  (prc_avg_salary - prc_price) < 10 THEN "Růst cen v normě"
		ELSE  "Vyšší růst cen potravin"
	END	AS price_vs_salary
FROM (
    SELECT 
        salary_year AS `year`,
        ROUND(average_salary, 0) AS average_salary,
        ROUND(
            ((average_salary * 100) / LAG(average_salary) OVER (ORDER BY salary_year) - 100), 2
        ) AS prc_avg_salary,
        ROUND(price, 0) AS price,
        ROUND(
            ((price * 100) / LAG(price) OVER (ORDER BY year_food) - 100), 2
        ) AS prc_price
    FROM (
        SELECT 
            cp.payroll_year AS salary_year,
            AVG(cp.value) AS average_salary
        FROM czechia_payroll AS cp
        JOIN czechia_payroll_industry_branch AS cpib ON cp.industry_branch_code = cpib.code 
        WHERE 
            cp.value_type_code = 5958 AND 
            cp.payroll_year BETWEEN 2006 AND 2018 AND
            cp.industry_branch_code IS NOT NULL 
        GROUP BY 		
            cp.payroll_year
    ) AS salary
    JOIN (
        SELECT 
            YEAR(cp2.date_from) AS year_food,
            AVG(cp2.value) AS price
        FROM czechia_price AS cp2 
        JOIN czechia_price_category AS cpc ON cp2.category_code = cpc.code
        GROUP BY YEAR(cp2.date_from)
    ) AS food
    ON salary.salary_year = food.year_food
) AS subquery
ORDER BY `year`;