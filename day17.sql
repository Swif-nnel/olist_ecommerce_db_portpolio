
-- 재구매 고객 선별

SELECT 
--    count(*)
    c.customer_unique_id
    , s.seller_id
FROM 
    customers c
    INNER JOIN 
    orders o 
        ON c.customer_id = o.customer_id 
    INNER JOIN 
    order_items oi
        ON o.order_id = oi.order_id 
    INNER JOIN 
    sellers s
        ON oi.seller_id = s.seller_id;



WITH dt AS (
    SELECT 
        c.customer_unique_id
        , s.seller_id 
        , o.order_purchase_timestamp::date AS purchase_date
    FROM 
        customers c
        INNER JOIN 
        orders o 
            ON c.customer_id = o.customer_id 
        INNER JOIN 
        order_items oi
            ON o.order_id = oi.order_id 
        INNER JOIN 
        sellers s
            ON oi.seller_id = s.seller_id
        WHERE
        customer_unique_id IN ('8d50f5eadf50201ccdcedfb9e2ac8455'
                                , '397b44d5bb99eabf54ea9c2b41ebb905'
                                , 'f64ec6d8dd29940264cd0bbb5ecade8a'
                                , 'b896655e2083a1d76b7b85df8fc86e40'
                                , 'acea6bd29b8c1e3c6a8b266a8fb4475e'
                                , 'de34b16117594161a6a89c50b289d35a')
), revisited AS (
    SELECT 
        customer_unique_id
        , seller_id
        , count(DISTINCT purchase_date) - 1 AS repurchase_count
    FROM 
        dt 
    GROUP BY 
        customer_unique_id 
        , seller_id
)
SELECT 
    dt.customer_unique_id
    , dt.seller_id
    , avg(rv.repurchase_count) AS repurchase_count
    , count(*) AS record_count
FROM
    dt
    INNER JOIN 
    revisited rv
        ON rv.customer_unique_id = dt.customer_unique_id AND 
        rv.seller_id = dt.seller_id 
GROUP BY 
    dt.customer_unique_id 
    , dt.seller_id


    
WITH dt AS (
    SELECT 
        c.customer_unique_id
        , s.seller_id 
        , o.order_purchase_timestamp::date AS purchase_date
    FROM 
        customers c
        INNER JOIN 
        orders o 
            ON c.customer_id = o.customer_id 
        INNER JOIN 
        order_items oi
            ON o.order_id = oi.order_id 
        INNER JOIN 
        sellers s
            ON oi.seller_id = s.seller_id
--    WHERE
--        customer_unique_id IN ('8d50f5eadf50201ccdcedfb9e2ac8455'
--                                , '397b44d5bb99eabf54ea9c2b41ebb905'
--                                , 'f64ec6d8dd29940264cd0bbb5ecade8a'
--                                , 'b896655e2083a1d76b7b85df8fc86e40'
--                                , 'acea6bd29b8c1e3c6a8b266a8fb4475e'
--                                , 'de34b16117594161a6a89c50b289d35a')
), purchase_count AS (
    SELECT 
        customer_unique_id,
        seller_id,
        count(DISTINCT purchase_date) AS repurchase_count
    FROM 
        dt
    GROUP BY 
        customer_unique_id, 
        seller_id
), repurchase_customers AS (
    SELECT 
        *,
        CASE
            WHEN max(repurchase_count) OVER (
                PARTITION BY customer_unique_id
                ) >= 2
            THEN 1
        END AS customer_repurchased
    FROM 
        purchase_count
), repurchase_count AS (
    SELECT 
        (
        SELECT count(*)
        FROM repurchase_customers
        WHERE customer_repurchased IS NOT NULL AND 
        repurchase_count >= 2
        ) AS repurchase_count,
        (
        SELECT count(*)
        FROM repurchase_customers
        WHERE customer_repurchased IS NOT NULL
        ) AS total_count
)
SELECT 
    repurchase_count::decimal / 
    total_count * 100 AS pct_repurchase,
    (total_count - repurchase_count)::decimal / 
    total_count * 100 AS pct_non_repurchase
FROM repurchase_count


WITH dt AS (
    SELECT 
        c.customer_unique_id
        , s.seller_id 
        , o.order_purchase_timestamp::date AS purchase_date
    FROM 
        customers c
        INNER JOIN 
        orders o 
            ON c.customer_id = o.customer_id 
        INNER JOIN 
        order_items oi
            ON o.order_id = oi.order_id 
        INNER JOIN 
        sellers s
            ON oi.seller_id = s.seller_id
--    WHERE
--        customer_unique_id IN ('8d50f5eadf50201ccdcedfb9e2ac8455'
--                                , '397b44d5bb99eabf54ea9c2b41ebb905'
--                                , 'f64ec6d8dd29940264cd0bbb5ecade8a'
--                                , 'b896655e2083a1d76b7b85df8fc86e40'
--                                , 'acea6bd29b8c1e3c6a8b266a8fb4475e'
--                                , 'de34b16117594161a6a89c50b289d35a')
), purchase_count AS (
    SELECT 
        customer_unique_id,
        seller_id,
        count(DISTINCT purchase_date) AS repurchase_count
    FROM 
        dt
    GROUP BY 
        customer_unique_id, 
        seller_id
), repurchase_customers AS (
    SELECT 
        *,
        CASE
            WHEN max(repurchase_count) OVER (
                PARTITION BY customer_unique_id
                ) >= 2
            THEN 1
        END AS customer_repurchased
    FROM 
        purchase_count
), 
customer_seller_experience AS (
    SELECT 
        customer_unique_id,
        COUNT(DISTINCT seller_id) as total_sellers_experienced,
        SUM(CASE WHEN repurchase_count >= 2 THEN 1 ELSE 0 END) as actual_repurchase_relationships
    FROM repurchase_customers 
    WHERE customer_repurchased IS NOT NULL
    GROUP BY customer_unique_id
)
-- 관계별로 해당 고객의 랜덤 확률 적용
SELECT 
    AVG(1.0/total_sellers_experienced) as expected_rate_correct,
    SUM(actual_repurchase_relationships) / SUM(total_sellers_experienced) as observed_rate
FROM customer_seller_experience;


WITH dt AS (
    SELECT 
        c.customer_unique_id
        , s.seller_id 
        , o.order_purchase_timestamp::date AS purchase_date
    FROM 
        customers c
        INNER JOIN 
        orders o 
            ON c.customer_id = o.customer_id 
        INNER JOIN 
        order_items oi
            ON o.order_id = oi.order_id 
        INNER JOIN 
        sellers s
            ON oi.seller_id = s.seller_id
--    WHERE
--        customer_unique_id IN ('8d50f5eadf50201ccdcedfb9e2ac8455'
--                                , '397b44d5bb99eabf54ea9c2b41ebb905'
--                                , 'f64ec6d8dd29940264cd0bbb5ecade8a'
--                                , 'b896655e2083a1d76b7b85df8fc86e40'
--                                , 'acea6bd29b8c1e3c6a8b266a8fb4475e'
--                                , 'de34b16117594161a6a89c50b289d35a')
), purchase_count AS (
    SELECT 
        customer_unique_id,
        seller_id,
        count(DISTINCT purchase_date) AS repurchase_count
    FROM 
        dt
    GROUP BY 
        customer_unique_id, 
        seller_id
), repurchase_customers AS (
    SELECT 
        *,
        CASE
            WHEN max(repurchase_count) OVER (
                PARTITION BY customer_unique_id
                ) >= 2
            THEN 1
        END AS customer_repurchased
    FROM 
        purchase_count
), 
customer_seller_experience AS (
    SELECT 
        customer_unique_id,
        COUNT(DISTINCT seller_id) as total_sellers_experienced,
        SUM(CASE WHEN repurchase_count >= 2 THEN 1 ELSE 0 END) as actual_repurchase_relationships
    FROM repurchase_customers 
    WHERE customer_repurchased IS NOT NULL
    GROUP BY customer_unique_id
)
SELECT 
    SUM(total_sellers_experienced) as total_relationships_n,
    SUM(actual_repurchase_relationships) as observed_successes_x,
    AVG(1.0/total_sellers_experienced) as expected_probability_p
FROM customer_seller_experience;