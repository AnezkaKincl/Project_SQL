-- 1.	Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?  
WITH ranked_data AS (
    SELECT
    	cpib.name,
		cp.payroll_year,
    	ROUND(AVG(cp.value), -2) AS average_payroll,
    	LAG(ROUND(AVG(cp.value), -2)) OVER (PARTITION BY cp.industry_branch_code ORDER BY cp.payroll_year) AS prev_year_payroll -- LAG posunutí o 1 řádek níž
	FROM 
		czechia_payroll AS cp
	JOIN 
    	czechia_payroll_industry_branch AS cpib 
    	ON cp.industry_branch_code = cpib.code 
	WHERE 
    	cp.value_type_code = 5958 
	GROUP BY 
		cpib.name,
		cp.payroll_year
)
SELECT
    payroll_year,
    name,
    average_payroll,
    prev_year_payroll,
    (average_payroll - prev_year_payroll) AS change_in_payroll
FROM
    ranked_data
WHERE 
	payroll_year BETWEEN 2006 AND 2018
	AND (average_payroll - prev_year_payroll) < 0
ORDER BY
    payroll_year;