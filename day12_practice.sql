
-- 문제 1 --

-- 1. 평균 가격 계산

SELECT 
    avg(price)
FROM    
    order_items
  
-- 2. 카테고리별 평균 가격 계산

SELECT
    products.product_category_name
    , avg(order_items.price)
    , (SELECT avg(price) FROM order_items)
FROM 
    order_items
    INNER JOIN 
    products
        ON order_items.product_id = products.product_id
WHERE
    product_category_name <> ''
GROUP BY 
    products.product_category_name

-- 3. 조건 지정하여 필터링
    
SELECT
    products.product_category_name AS category
    , round(avg(order_items.price)::DECIMAL, 2) AS avg_price_category
    , round((SELECT avg(price) FROM order_items)::DECIMAL, 2) AS avg_price_total
FROM 
    order_items
    INNER JOIN 
    products
        ON order_items.product_id = products.product_id
WHERE
    product_category_name <> ''
GROUP BY 
    products.product_category_name
HAVING
    avg(order_items.price) > (SELECT avg(price) FROM order_items)



-- + 상위 카테고리 평균 계산

WITH temp_ AS (
    SELECT
        products.product_category_name AS category
        , avg(order_items.price) OVER (PARTITION BY products.product_category_name) AS avg_price_category
        , (SELECT avg(price) FROM order_items) AS avg_price_total
    FROM 
        order_items
        INNER JOIN 
        products
            ON order_items.product_id = products.product_id
    WHERE
        product_category_name <> ''
) 
SELECT 
    avg(avg_price_category)
FROM
    temp_
WHERE
    avg_price_category < avg_price_total

