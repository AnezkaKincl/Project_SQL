-- 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
WITH detailed_data AS (
    SELECT 
        `year`,
        price,
        food,
        value, 
        unit
    FROM
        `t_{Anezka}_{Kinclova}_project_SQL_primary_final`
    WHERE 
        `year` IN (2006, 2018)
        AND food IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
    GROUP BY
    	`year`,
    	food
),
avg_salary_data AS (
    SELECT
        `year`,
        AVG(salary) AS avg_salary
    FROM
        `t_{Anezka}_{Kinclova}_project_SQL_primary_final`
    WHERE
        `year` IN (2006, 2018)
    GROUP BY
        `year`
)
SELECT
    d.`year`,
    d.food,
    d.value, 
    d.unit,
    d.price,
    ROUND(a.avg_salary) AS avg_salary,
    ROUND(a.avg_salary/d.price,0) AS quantity_food
FROM
    detailed_data d
JOIN
    avg_salary_data a
ON
    d.`year` = a.`year`
ORDER BY
    d.`year`,
   d.food;