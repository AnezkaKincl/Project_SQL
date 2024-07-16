-- 5.	Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
-- projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

SELECT 
    GDP.`year`,
    avg_GDP,
    prc_GDP,
    avg_salary,
    prc_avg_salary,
    price,
    prc_price,
    GDP,
    CASE 
        WHEN prc_avg_salary IS NULL THEN NULL
        WHEN prc_avg_salary < -10 THEN "Salary výrazně klesá"
        WHEN prc_avg_salary < 0 THEN "Salary klesá" 
        WHEN prc_avg_salary < 10 THEN "Salary roste"
        ELSE "Salary výrazně roste"
    END AS salary,
    CASE 
        WHEN prc_price IS NULL THEN NULL
        WHEN prc_price < -10 THEN "Price výrazně klesá"
        WHEN prc_price < 0 THEN "Price klesá" 
        WHEN prc_price < 10 THEN "Price roste"
        ELSE "Price výrazně roste"
    END AS price
FROM (
    SELECT
        `year`,
        ROUND(AVG(GDP),0) AS avg_GDP,
        LAG(AVG(GDP)) OVER (ORDER BY `year`) AS prev_GDP,
        ROUND(((AVG(GDP) * 100) / LAG(AVG(GDP)) OVER (ORDER BY `year`) - 100),2) AS prc_GDP,
        CASE 
            WHEN ((AVG(GDP) * 100) / LAG(AVG(GDP)) OVER (ORDER BY `year`) - 100) IS NULL THEN NULL
            WHEN ((AVG(GDP) * 100) / LAG(AVG(GDP)) OVER (ORDER BY `year`) - 100) < -10 THEN "GDP výrazně klesá" 
            WHEN ((AVG(GDP) * 100) / LAG(AVG(GDP)) OVER (ORDER BY `year`) - 100) < 0 THEN "GDP klesá"
            WHEN ((AVG(GDP) * 100) / LAG(AVG(GDP)) OVER (ORDER BY `year`) - 100) < 10 THEN "GDP roste"
            ELSE "GDP výrazně roste"
        END AS GDP  
    FROM
        economies AS e 
    WHERE
        `year` BETWEEN 2006 AND 2018
        AND country LIKE "European UNION"
    GROUP BY 
        `year`
    ORDER BY 
        `year`
) AS GDP
JOIN (   
    SELECT 
        `year`,
        avg_salary,
        prc_avg_salary,
        price,
        prc_price
    FROM (
        SELECT 
            salary_year AS `year`,
            ROUND(avg_salary, 0) AS avg_salary,
            ROUND(
                ((avg_salary * 100) / LAG(avg_salary) OVER (ORDER BY salary_year) - 100), 2
            ) AS prc_avg_salary,
            ROUND(price, 0) AS price,
            ROUND(
                ((price * 100) / LAG(price) OVER (ORDER BY year_food) - 100), 2
            ) AS prc_price
        FROM (
            SELECT 
                cp.payroll_year AS salary_year,
                AVG(cp.value) AS avg_salary
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
    ) AS food_salary
    ORDER BY `year`
) AS food_salary
ON GDP.`year` = food_salary.`year`;