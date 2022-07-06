SELECT gear,
    COUNT(*) AS TOTAL,
    MIN(mpg) AS MIN_MPG,
    MAX(mpg) AS MAX_MPG,
    AVG(mpg) AS AVG_MPG,
    MIN(hp) AS MIN_HP,
    MAX(hp) AS MAX_HP,
    AVG(hp) AS AVG_HP_DAGO
FROM {{ ref('dago01') }}
GROUP BY gear
ORDER BY gear DESC