-- 1.	Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?   
WITH aggregated_data AS (
    SELECT
        year,
        profession,
        AVG(salary) AS avg_salary
    FROM 
        `t_{Anezka}_{Kinclova}_project_SQL_primary_final`
    GROUP BY 
        year,
        profession
),
lagged_data AS (
    SELECT
        year,
        profession,
        avg_salary,
        LAG(avg_salary) OVER (PARTITION BY profession ORDER BY `year`) AS prev_avg_salary
    FROM 
        aggregated_data
)
SELECT
    year,
    profession,
    avg_salary,
    prev_avg_salary,
    (avg_salary - prev_avg_salary) AS change_in_payroll
FROM 
    lagged_data
WHERE 
    (avg_salary - prev_avg_salary) < 0
ORDER BY
    (avg_salary - prev_avg_salary) DESC,
    profession,
    `year`;