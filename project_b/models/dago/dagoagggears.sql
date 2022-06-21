SELECT GEAR,
    COUNT(*) AS TOTAL,
    MIN(MPG) AS MIN_MPG,
    MAX(MPG) AS MAX_MPG,
    AVG(MPG) AS AVG_MPG,
    MIN(HP) AS MIN_HP,
    MAX(HP) AS MAX_HP,
    AVG(HP) AS AVG_HP
FROM {{ ref('dago01') }}
GROUP BY GEAR