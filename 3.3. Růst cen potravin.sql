-- 3.	Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
-- s CTE (Common Table Expression)
WITH calculated_data AS (
    SELECT 
        `year`,
        food,
        price,
        LAG(price) OVER (PARTITION BY food ORDER BY `year`) AS prev_price,
        ABS((100 - (price * 100) / LAG(price) OVER (PARTITION BY food ORDER BY `year`))) AS prc_year_food
    FROM
        `t_{Anezka}_{Kinclova}_project_SQL_primary_final`
    GROUP BY
        `year`,
        food,
        price
    ORDER BY 
        food,
        `year`
)
SELECT 
    `year`,
    food,
    price,
    prev_price,
    ROUND( prc_year_food,3) AS prc_year_food
FROM
    calculated_data
WHERE
    prc_year_food = 0
ORDER BY
	food,
	`year`;
