-- 3.	Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
-- s CTE (Common Table Expression)
	
WITH year_food_stats AS (
    SELECT    
        name AS food,
        YEAR(date_from) AS year_food,
        price_value AS `number`,
        price_unit AS unit,
        value AS price,
        LAG(value) OVER (
            PARTITION BY cpc.code 
            ORDER BY cpc.name, YEAR(date_from)
        ) AS LAG_price,
        ABS(100 - (value * 100) / LAG(value) OVER (
            PARTITION BY cpc.code 
            ORDER BY cpc.name, YEAR(date_from)
        )) AS prc_year_food
    FROM czechia_price AS cp 
    JOIN czechia_price_category AS cpc 
        ON cp.category_code = cpc.code
    GROUP BY 
        cpc.name,
        YEAR(date_from),
        price_value,
        price_unit
)
SELECT 
    food,
    year_food,
    `number`,
    unit,
    price,
    LAG_price,
    prc_year_food
FROM year_food_stats
WHERE prc_year_food = (
    SELECT MIN(prc_year_food)
    FROM year_food_stats
	);