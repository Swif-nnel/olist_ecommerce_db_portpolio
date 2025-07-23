

-- 연간 재구매율 계산 --

SELECT 
    c.customer_unique_id
    , o.order_purchase_timestamp
FROM 
    orders o
INNER JOIN 
    customers c ON
    o.customer_id = c.customer_id;

-- customers in 2018
SELECT
    DISTINCT c.customer_unique_id
FROM
    orders o
INNER JOIN
    customers c ON
    o.customer_id = c.customer_id
WHERE 
    date_part('year', o.order_purchase_timestamp::date) = '2018';

-- customers in 2017
SELECT
    DISTINCT c.customer_unique_id
FROM
    orders o
INNER JOIN
    customers c ON
    o.customer_id = c.customer_id
WHERE 
    date_part('year', o.order_purchase_timestamp::date) = '2017';

-- result 1
WITH 
customer_2018 AS (
    SELECT
        DISTINCT c.customer_unique_id
    FROM
        orders o
    INNER JOIN
        customers c ON
        o.customer_id = c.customer_id
    WHERE 
        date_part('year', o.order_purchase_timestamp::date) = '2018'
)
, 
customer_2017 AS (
    SELECT
        DISTINCT c.customer_unique_id
    FROM
        orders o
    INNER JOIN
        customers c ON
        o.customer_id = c.customer_id
    WHERE 
        date_part('year', o.order_purchase_timestamp::date) = '2017'
)
SELECT
    count(*) 
    , (SELECT count(*) FROM customer_2017)
    , count(*) / (SELECT count(*) FROM customer_2017)::decimal * 100 AS revisit_rate_pct
FROM
    customer_2017 AS c17
WHERE 
    c17.customer_unique_id IN (
        SELECT
            customer_unique_id
        FROM
            customer_2018
    );

-- result 2
WITH 
customer_2017 AS (
    SELECT
        DISTINCT c.customer_unique_id
    FROM
        orders o
    INNER JOIN
        customers c ON
        o.customer_id = c.customer_id
    WHERE 
        date_part('year', o.order_purchase_timestamp::date) = '2017'
)
, 
customer_2016 AS (
    SELECT
        DISTINCT c.customer_unique_id
    FROM
        orders o
    INNER JOIN
        customers c ON
        o.customer_id = c.customer_id
    WHERE 
        date_part('year', o.order_purchase_timestamp::date) = '2016'
)
SELECT
    count(*) 
    , (SELECT count(*) FROM customer_2016)
    , count(*) / (SELECT count(*) FROM customer_2016)::decimal * 100 AS revisit_rate_pct
FROM
    customer_2016 AS c16
WHERE 
    c16.customer_unique_id IN (
        SELECT
            customer_unique_id
        FROM
            customer_2017
    );

SELECT 
    min(order_purchase_timestamp)
    , max(order_purchase_timestamp)
FROM 
    orders;

-- result 3
WITH 
table1 AS (
    SELECT
        c.customer_unique_id
        , o.order_purchase_timestamp::date AS purchase_date
        , LEAD(o.order_purchase_timestamp::date) OVER (
            PARTITION BY c.customer_unique_id
        ORDER BY
            o.order_purchase_timestamp::date
        ) - o.order_purchase_timestamp::date
        AS days_revisit
    FROM
        orders o
    INNER JOIN
        customers c ON
        o.customer_id = c.customer_id
)
,
table2 AS (
    SELECT
        customer_unique_id
    FROM
        table1
    WHERE
        days_revisit <> 0
        AND 
        purchase_date BETWEEN '2018-01-01' AND '2018-02-01'
    GROUP BY 
        customer_unique_id
    HAVING 
        min(days_revisit) <= 90
)
SELECT
    (
        SELECT
            count(*)
        FROM
            table2
    )
    , (
        SELECT
            count(DISTINCT customer_unique_id)
        FROM
            table1
        WHERE
            purchase_date BETWEEN '2018-01-01' AND '2018-02-01'
    )
    , (
        SELECT
            count(*)
        FROM
            table2
    ) / (
        SELECT
            count(DISTINCT customer_unique_id)
        FROM
            table1
        WHERE
            purchase_date BETWEEN '2018-01-01' AND '2018-02-01'
    )::decimal * 100 AS "RESULT";

WITH 
table1 AS (
    SELECT
        c.customer_unique_id
        , o.order_purchase_timestamp::date AS purchase_date
        , LEAD(o.order_purchase_timestamp::date) OVER (
            PARTITION BY c.customer_unique_id
        ORDER BY
            o.order_purchase_timestamp::date
        ) - o.order_purchase_timestamp::date
        AS days_revisit
    FROM
        orders o
    INNER JOIN
        customers c ON
        o.customer_id = c.customer_id
)
SELECT 
    count(DISTINCT
        CASE 
            WHEN 
                purchase_date BETWEEN '2018-01-01' AND '2018-02-01' AND 
                days_revisit BETWEEN 1 AND 90
            THEN 
                customer_unique_id
        END
    )
    ,
    count(DISTINCT 
        CASE 
            WHEN 
                purchase_date BETWEEN '2018-01-01' AND '2018-02-01'
            THEN 
                customer_unique_id
        END
    )
    ,
    count(DISTINCT
        CASE 
            WHEN 
                purchase_date BETWEEN '2018-01-01' AND '2018-02-01' AND 
                days_revisit BETWEEN 1 AND 90
            THEN 
                customer_unique_id
        END
    )::decimal
    / count(DISTINCT 
        CASE 
            WHEN 
                purchase_date BETWEEN '2018-01-01' AND '2018-02-01'
            THEN 
                customer_unique_id
        END
    ) * 100 AS "RESULT"
FROM
    table1;


WITH 
table1 AS (
    SELECT
        c.customer_unique_id
        , o.order_purchase_timestamp::date AS purchase_date
        , LEAD(o.order_purchase_timestamp::date) OVER (
            PARTITION BY c.customer_unique_id
        ORDER BY
            o.order_purchase_timestamp::date
        ) - o.order_purchase_timestamp::date
        AS days_revisit
    FROM
        orders o
    INNER JOIN
        customers c ON
        o.customer_id = c.customer_id
)
SELECT 
    date_part('year', purchase_date)::text || '-' || date_part('month', purchase_date)::text AS purchase_month
    ,
    count(DISTINCT
        CASE 
            WHEN days_revisit BETWEEN 1 AND 90
            THEN customer_unique_id
        END
    ) AS revisit_customer
    ,
    count(DISTINCT customer_unique_id) AS total_customer
    ,
    count(DISTINCT
        CASE 
            WHEN days_revisit BETWEEN 1 AND 90
            THEN customer_unique_id
        END
    )::decimal
    / count(DISTINCT customer_unique_id) * 100 AS revisit_customer_pct
FROM
    table1
GROUP BY 
    date_part('year', purchase_date)
    , date_part('month', purchase_date);
