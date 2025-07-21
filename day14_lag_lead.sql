
-- Value window function --

-- (1)

SELECT 
    p2.product_category_name_english 
    , o.price 
    , first_value(o.price) over(
        PARTITION BY product_category_name_english 
        ORDER BY o.price
    )
FROM 
    order_items o
    INNER JOIN 
    products p1
        ON o.product_id = p1.product_id 
    INNER JOIN 
    product_category_name_translation p2
        ON p1.product_category_name = p2.product_category_name;

-- (2)

SELECT 
    p2.product_category_name_english 
    , o.price 
    , first_value(o.price) OVER(
        PARTITION BY p2.product_category_name_english 
        ORDER BY o.price
    )
    , last_value(o.price) OVER(
        PARTITION BY p2.product_category_name_english
        ORDER BY o.price
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    )
FROM 
    order_items o
    INNER JOIN 
    products p1
        ON o.product_id = p1.product_id 
    INNER JOIN 
    product_category_name_translation p2
        ON p1.product_category_name = p2.product_category_name;

-- (3)

SELECT 
    p2.product_category_name_english 
    , o.price 
    , nth_value(o.price, 3) OVER(
        PARTITION BY p2.product_category_name_english 
        ORDER BY o.price
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING 
    )
FROM 
    order_items o
    INNER JOIN 
    products p1
        ON o.product_id = p1.product_id 
    INNER JOIN 
    product_category_name_translation p2
        ON p1.product_category_name = p2.product_category_name;


-- Aggregate window function --

-- (4)

SELECT 
    p2.product_category_name_english 
    , o.price 
    , count(*) OVER(PARTITION BY product_category_name_english) AS count_sales
    , sum(price) OVER(PARTITION BY product_category_name_english) AS sum_sales
    , avg(price) OVER(PARTITION BY product_category_name_english) AS avg_sales
    , min(price) OVER(PARTITION BY product_category_name_english) AS min_price
    , max(price) OVER(PARTITION BY product_category_name_english) AS max_price
FROM 
    order_items o
    INNER JOIN 
    products p1
        ON o.product_id = p1.product_id 
    INNER JOIN 
    product_category_name_translation p2
        ON p1.product_category_name = p2.product_category_name;


-- LAG, LEAD --

-- (5) 

WITH temp1 AS (
SELECT
    o1.customer_id 
    , to_date(o1.order_purchase_timestamp, 'YYYY-MM-DD') AS purchased_date
FROM 
    orders o1
    INNER JOIN 
    order_items o2
        ON o1.order_id  = o2.order_id 
    INNER JOIN 
    products p1
        ON o2.product_id = p1.product_id 
),  temp2 AS (
    SELECT 
        customer_id
        , purchased_date
        , lag(purchased_date) OVER( 
            PARTITION BY customer_id
            ORDER BY purchased_date
        ) - purchased_date AS days_since_last_order
    FROM 
        temp1
)
SELECT 
    DISTINCT days_since_last_order
FROM
    temp2;

WITH temp1 AS (
SELECT
    o1.customer_id 
    , c.customer_unique_id
    , to_date(o1.order_purchase_timestamp, 'YYYY-MM-DD') AS purchased_date
FROM 
    orders o1
    INNER JOIN 
    order_items o2
        ON o1.order_id  = o2.order_id 
    INNER JOIN 
    products p1
        ON o2.product_id = p1.product_id 
    INNER JOIN 
    customers c 
        ON o1.customer_id = c.customer_id 
),  temp2 AS (
    SELECT 
        customer_id
        , customer_unique_id
        , purchased_date
        , lag(purchased_date) OVER( 
            PARTITION BY customer_id
            ORDER BY purchased_date
        ) - purchased_date AS days_since_last_order
    FROM 
        temp1
)
SELECT 
    count(*)
FROM
    temp2
GROUP BY 
    customer_unique_id
ORDER BY 
    count(*) DESC;

WITH temp1 AS (
SELECT
    c.customer_unique_id
    , to_date(o1.order_purchase_timestamp, 'YYYY-MM-DD') AS purchased_date
FROM 
    orders o1
    INNER JOIN 
    order_items o2
        ON o1.order_id  = o2.order_id 
    INNER JOIN 
    products p1
        ON o2.product_id = p1.product_id 
    INNER JOIN 
    customers c 
        ON o1.customer_id = c.customer_id 
),  temp2 AS (
    SELECT 
        customer_unique_id
        , purchased_date
        , lead(purchased_date) OVER( 
            PARTITION BY customer_unique_id
            ORDER BY purchased_date DESC 
        ) AS date_since_last_order
        , purchased_date - 
          lead(purchased_date) OVER( 
            PARTITION BY customer_unique_id
            ORDER BY purchased_date DESC
        ) AS days_since_last_order
    FROM 
        temp1
)
SELECT 
    *
FROM
    temp2
WHERE
    days_since_last_order <> 0
    AND days_since_last_order IS NOT NULL;

WITH temp1 AS (
SELECT
    c.customer_unique_id
    , to_date(o1.order_purchase_timestamp, 'YYYY-MM-DD') AS purchased_date
FROM 
    orders o1
    INNER JOIN 
    order_items o2
        ON o1.order_id  = o2.order_id 
    INNER JOIN 
    products p1
        ON o2.product_id = p1.product_id 
    INNER JOIN 
    customers c 
        ON o1.customer_id = c.customer_id 
),  temp2 AS (
    SELECT 
        customer_unique_id
        , purchased_date
        , lead(purchased_date) OVER( 
            PARTITION BY customer_unique_id
            ORDER BY purchased_date DESC
        ) AS date_since_last_order
        , purchased_date - 
          lead(purchased_date) OVER( 
            PARTITION BY customer_unique_id
            ORDER BY purchased_date DESC
        ) AS days_since_last_order
    FROM 
        temp1
)
SELECT 
    customer_unique_id 
    , count(*)
    , avg(days_since_last_order)
FROM
    temp2
WHERE
    days_since_last_order <> 0
    AND days_since_last_order IS NOT NULL
GROUP BY 
    customer_unique_id;

WITH temp1 AS (
SELECT
    c.customer_unique_id
    , to_date(o1.order_purchase_timestamp, 'YYYY-MM-DD') AS purchased_date
FROM 
    orders o1
    INNER JOIN 
    order_items o2
        ON o1.order_id  = o2.order_id 
    INNER JOIN 
    products p1
        ON o2.product_id = p1.product_id 
    INNER JOIN 
    customers c 
        ON o1.customer_id = c.customer_id 
),  temp2 AS (
    SELECT 
        customer_unique_id
        , purchased_date
        , lead(purchased_date) OVER( 
            PARTITION BY customer_unique_id
            ORDER BY purchased_date DESC
        ) AS date_since_last_order
        , purchased_date - 
          lead(purchased_date) OVER( 
            PARTITION BY customer_unique_id
            ORDER BY purchased_date DESC
        ) AS days_since_last_order
    FROM 
        temp1
)
SELECT 
    customer_unique_id 
    , count(*)
    , avg(days_since_last_order)
FROM
    temp2
WHERE
    days_since_last_order <> 0
    AND days_since_last_order IS NOT NULL
GROUP BY 
    customer_unique_id
HAVING 
    count(*) >= 3;

WITH temp1 AS (
SELECT
    c.customer_unique_id
    , to_date(o1.order_purchase_timestamp, 'YYYY-MM-DD') AS purchased_date
FROM 
    orders o1
    INNER JOIN 
    order_items o2
        ON o1.order_id  = o2.order_id 
    INNER JOIN 
    products p1
        ON o2.product_id = p1.product_id 
    INNER JOIN 
    customers c 
        ON o1.customer_id = c.customer_id 
),  temp2 AS (
    SELECT 
        customer_unique_id
        , purchased_date
        , lead(purchased_date) OVER( 
            PARTITION BY customer_unique_id
            ORDER BY purchased_date DESC
        ) AS date_since_last_order
        , purchased_date - 
          lead(purchased_date) OVER( 
            PARTITION BY customer_unique_id
            ORDER BY purchased_date DESC
        ) AS days_since_last_order
    FROM 
        temp1
), temp3 AS (
    SELECT 
        avg(days_since_last_order) AS days_recoming
    FROM
        temp2
    WHERE
        days_since_last_order <> 0
        AND days_since_last_order IS NOT NULL
    GROUP BY 
        customer_unique_id
    HAVING 
        count(*) >= 3
)
SELECT 
    avg(days_recoming) AS avg_days_recoming
FROM 
    temp3;
