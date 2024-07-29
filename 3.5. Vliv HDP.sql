-- 5.	Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
-- projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

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
),
GDP_data AS (
    SELECT 
        `year`,
        ROUND(AVG(GDP),0) AS avg_GDP,
        LAG(AVG(GDP)) OVER (ORDER BY `year`) AS prev_GDP,
        ROUND(((AVG(GDP) * 100) / LAG(AVG(GDP)) OVER (ORDER BY `year`) - 100),2) AS prc_GDP,
        CASE 
            WHEN ((AVG(GDP) * 100) / LAG(AVG(GDP)) OVER (ORDER BY `year`) - 100) IS NULL THEN NULL
            WHEN ((AVG(GDP) * 100) / LAG(AVG(GDP)) OVER (ORDER BY `year`) - 100) < -10 THEN "Výrazně klesá" 
            WHEN ((AVG(GDP) * 100) / LAG(AVG(GDP)) OVER (ORDER BY `year`) - 100) < 0 THEN "Klesá"
            WHEN ((AVG(GDP) * 100) / LAG(AVG(GDP)) OVER (ORDER BY `year`) - 100) < 10 THEN "Roste"
            ELSE "Roste"
        END AS GDP_status
    FROM `t_{Anezka}_{Kinclova}_project_SQL_secondary_final`
    GROUP BY `year`
)
SELECT
    l.`year`,
    l.avg_salary,
    ROUND(100 * (l.avg_salary - l.prev_avg_salary) / l.prev_avg_salary, 2) AS prc_salary,
    CASE 
    	WHEN ROUND(100 * (l.avg_salary - l.prev_avg_salary) / l.prev_avg_salary, 2) IS NULL THEN NULL
        WHEN ROUND(100 * (l.avg_salary - l.prev_avg_salary) / l.prev_avg_salary, 2) < -10 THEN "Výrazně klesá" 
        WHEN ROUND(100 * (l.avg_salary - l.prev_avg_salary) / l.prev_avg_salary, 2) < 0 THEN "Klesá"
        WHEN ROUND(100 * (l.avg_salary - l.prev_avg_salary) / l.prev_avg_salary, 2) < 10 THEN "Roste"
        ELSE "Výrazně roste"
    END AS Salary_status,
    l.avg_price,    
    ROUND(100 * (l.avg_price - l.prev_avg_price) / l.prev_avg_price, 2) AS prc_price,
    CASE 
    	WHEN ROUND(100 * (l.avg_price - l.prev_avg_price) / l.prev_avg_price, 2) IS NULL THEN NULL
        WHEN ROUND(100 * (l.avg_price - l.prev_avg_price) / l.prev_avg_price, 2) < -10 THEN "Výrazně klesá" 
        WHEN ROUND(100 * (l.avg_price - l.prev_avg_price) / l.prev_avg_price, 2) < 0 THEN "Klesá"
        WHEN ROUND(100 * (l.avg_price - l.prev_avg_price) / l.prev_avg_price, 2) < 10 THEN "Roste"
        ELSE "Výrazně roste"
    END AS Price_status,
    g.avg_GDP,
    g.prc_GDP,
    g.GDP_status
FROM
    lagged_data l
JOIN
    GDP_data g
ON
    l.`year` = g.`year`
ORDER BY 
    l.`year`;