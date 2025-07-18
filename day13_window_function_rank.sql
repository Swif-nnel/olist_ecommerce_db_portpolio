
-- syntax --

--SELECT
--    window_function() OVER(
--         PARTITION BY partition_expression
--         ORDER BY order_expression
--         window_frame_extent
--    ) AS window_column_alias
--FROM table_name

--SELECT
--    window_function() OVER(window_name)
--FROM table_name
--WINDOW window_name AS (
--     PARTITION BY partition_expression
--     ORDER BY order_expression
--     window_frame_extent
--)


-- order by --

SELECT  
    order_id 
    , price
    , RANK() OVER (ORDER BY price DESC)
FROM 
    order_items;

-- partition by --

SELECT 
    order_status
FROM 
    orders
GROUP BY 
    order_status;

SELECT
    order_id 
    , order_status
    , count(order_id) OVER (PARTITION BY order_status)
FROM
    orders;

-- window frame --

SELECT 
    o.order_id
    , o.order_delivered_customer_date
    , o2.price
    , sum(price) OVER (
        PARTITION BY
            EXTRACT(YEAR FROM o.order_delivered_customer_date::timestamp)
            , EXTRACT(MONTH FROM o.order_delivered_customer_date::timestamp) -- 년도, 월로 그룹화
        ORDER BY o.order_delivered_customer_date
        ROWS BETWEEN 
            UNBOUNDED PRECEDING AND CURRENT ROW
    )
FROM 
    orders o
        INNER JOIN 
        order_items o2
            ON o.order_id = o2.order_id
WHERE
    o.order_delivered_customer_date <> '';
    
    

     