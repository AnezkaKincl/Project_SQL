-- 4.	Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
WITH aggregated_data AS (
    SELECT
        `year`,
        ROUND(AVG(salary), 0) AS avg_salary,
        ROUND(AVG(price), 0) AS avg_price
    FROM 
        `t_{Anezka}_{Kinclova}_project_SQL_primary_final`
    GROUP BY 
        `year`
),
lagged_data AS (
    SELECT
        `year`,
        avg_salary,
        avg_price,
        LAG(avg_salary) OVER (ORDER BY `year`) AS prev_avg_salary,
        LAG(avg_price) OVER (ORDER BY `year`) AS prev_avg_price
    FROM
        aggregated_data
)
SELECT
    `year`,
    avg_salary,
    ROUND(100 * (avg_salary - prev_avg_salary) / prev_avg_salary, 2) AS prc_salary,
    avg_price,    
    ROUND(100 * (avg_price - prev_avg_price) / prev_avg_price, 2) AS prc_price,
    ROUND(100 * (avg_price - prev_avg_price) / prev_avg_price, 2) - ROUND(100 * (avg_salary - prev_avg_salary) / prev_avg_salary, 2) AS differ_prc,
    CASE
        WHEN ROUND(100 * (avg_salary - prev_avg_salary) / prev_avg_salary, 2) IS NULL THEN NULL
        WHEN ROUND(100 * (avg_price - prev_avg_price) / prev_avg_price, 2) - ROUND(100 * (avg_salary - prev_avg_salary) / prev_avg_salary, 2) < - 10 THEN 'Pomalý růst cen potravin'
        WHEN ROUND(100 * (avg_price - prev_avg_price) / prev_avg_price, 2) - ROUND(100 * (avg_salary - prev_avg_salary) / prev_avg_salary, 2) < 10 THEN 'Růst cen v normě'
        ELSE 'Vyšší růst cen potravin'
    END AS price_vs_salary
FROM
    lagged_data
ORDER BY 
    `year`;
