
-- UNION --

-- (1) 고객이 사는 도시(customers 테이블의 customer_city)와 판매자가 있는 도시(sellers 테이블의 seller_city)를 합쳐서, 
-- 우리 쇼핑몰과 관련된 전체 도시 목록을 중복 없이 조회

(SELECT customer_city FROM customers)
UNION
(SELECT seller_city FROM sellers);

-- (2) 고객의 우편번호 앞자리(customers 테이블의 customer_zip_code_prefix)와 판매자의 우편번호 앞자리(sellers 테이블의 seller_zip_code_prefix)를 합쳐서,
-- zip_code_prefix라는 하나의 열 이름으로 조회

(SELECT customer_zip_code_prefix AS zip_code_prefix FROM customers)
UNION 
(SELECT seller_zip_code_prefix AS zip_code_prefix FROM sellers);

-- 행 개수 조회

SELECT 
    (SELECT count(customer_zip_code_prefix) FROM customers)
    , (SELECT count(seller_zip_code_prefix) FROM sellers)
    , count(*)
FROM 
    (
    (SELECT customer_zip_code_prefix FROM customers)
    UNION
    (SELECT seller_zip_code_prefix FROM sellers)
    );

-- (3) 2번 결과를 우편 번호 앞자리 기준 오름차순으로 정렬
-- 앞자리 기준이므로 숫자를 텍스트로 바꿔 정렬

(SELECT customer_zip_code_prefix::text AS zip_code FROM customers)
UNION 
(SELECT seller_zip_code_prefix::text AS zip_code FROM sellers)
ORDER BY 
    zip_code;

-- (4) 고객이 사는 도시와 판매자가 있는 도시를 합치되, 중복을 제거하지 말고 UNION ALL을 사용

(SELECT customer_city FROM customers)
UNION ALL 
(SELECT seller_city FROM sellers);

-- (5) sellers 테이블과 product_category_name_translation 테이블을 교차 결합하여, 
-- 나올 수 있는 모든 판매자와 카테고리 조합의 결과를 상위 10개만 조회
    
SELECT
    *
FROM
    sellers
    , product_category_name_translation
LIMIT
    10;
    
-- (6) orders 테이블과 order_items 테이블을 INNER JOIN 하여, 
-- 각 주문에 어떤 상품(product_id)이 몇 개(order_item_id) 포함되었는지 조회
    
-- JOIN 테이블 조회

SELECT 
    orders.order_id
    , item.product_id
    , item.order_item_id
FROM
    orders
    JOIN
    order_items AS item
    ON
        orders.order_id = item.order_id;
    
-- (7) customers 테이블을 기준으로 orders 테이블을 LEFT JOIN 하여, 
-- 가입은 했지만 아직 한 번도 주문하지 않은 고객의 customer_id
    
SELECT
    c.customer_id
    , o.customer_id
FROM
    customers c
    LEFT JOIN
    orders o
    ON c.customer_id = o.customer_id
WHERE
    o.customer_id IS NULL

-- 가입만 하고 주문을 하지 않은 고객이 없다. 


-- <실전 미션> --
    
-- 'SP' 주 고객들이 가장 많이 주문한 상품 카테고리 TOP 5와, 그 카테고리의 주문 건수를 조회. 결과는 주문 건수가 많은 순서대로 정렬
    
SELECT
    customer_state
    , customer_id 
    , 
FROM 
    customers;

SELECT
    product_category_name
    , product_id
    , 
FROM
    products;

SELECT
    *
FROM
    product_category_name_translation;

-- customers 테이블과 orders 테이블을 합친다

SELECT  
    customers.customer_id
FROM
    customers
    JOIN
    orders
    ON
        customers.customer_id = orders.customer_id;

-- order_items 테이블을 합친다.
        
SELECT  
    customers.customer_id
    , orders.order_id
FROM
    customers
    JOIN
    orders
    ON
        customers.customer_id = orders.customer_id
    JOIN 
    order_items
    ON
        orders.order_id = order_items.order_id;

-- products 테이블을 합친다.
        
SELECT  
    customers.customer_id
    , orders.order_id
    , order_items.product_id
FROM
    customers
    JOIN
    orders
    ON
        customers.customer_id = orders.customer_id
    JOIN 
    order_items
    ON
        orders.order_id = order_items.order_id
    JOIN
    products
    ON
        order_items.product_id = products.product_id;

-- product_category_name_translation 테이블을 합친다.
        
SELECT  
    customers.customer_id
    , orders.order_id
    , order_items.product_id
    , products.product_category_name
FROM
    customers
    JOIN
    orders
    ON
        customers.customer_id = orders.customer_id
    JOIN 
    order_items
    ON
        orders.order_id = order_items.order_id
    JOIN
    products
    ON
        order_items.product_id = products.product_id
    JOIN
    product_category_name_translation AS category_translation
    ON 
        products.product_category_name = category_translation.product_category_name;

-- customer_state와 product_category_name_english를 불러온다.
    
SELECT  
    customers.customer_id
    , customers.customer_state
    , orders.order_id
    , order_items.product_id
    , products.product_category_name
    , category_translation.product_category_name_english
FROM
    customers
    JOIN
    orders
    ON
        customers.customer_id = orders.customer_id
    JOIN 
    order_items
    ON
        orders.order_id = order_items.order_id
    JOIN
    products
    ON
        order_items.product_id = products.product_id
    JOIN
    product_category_name_translation AS category_translation
    ON 
        products.product_category_name = category_translation.product_category_name;

-- 'SP' 주 지역에 사는 고객들로 한정한다.
    
SELECT  
    customers.customer_id
    , customers.customer_state
    , orders.order_id
    , order_items.product_id
    , products.product_category_name
    , category_translation.product_category_name_english
FROM
    customers
    JOIN
    orders
    ON
        customers.customer_id = orders.customer_id
    JOIN 
    order_items
    ON
        orders.order_id = order_items.order_id
    JOIN
    products
    ON
        order_items.product_id = products.product_id
    JOIN
    product_category_name_translation AS category_translation
    ON 
        products.product_category_name = category_translation.product_category_name
WHERE
    customer_state = 'SP';

-- product_category_name_english 기준으로 그룹화하고 주문 개수(count(order_items.order_item_id))를 조회한다.

SELECT
    category_translation.product_category_name_english AS catogory
    , sum(order_items.order_item_id) AS count_orders
FROM
    customers
    JOIN
    orders
    ON
        customers.customer_id = orders.customer_id
    JOIN 
    order_items
    ON
        orders.order_id = order_items.order_id
    JOIN
    products
    ON
        order_items.product_id = products.product_id
    JOIN
    product_category_name_translation AS category_translation
    ON 
        products.product_category_name = category_translation.product_category_name
WHERE
    customer_state = 'SP'
GROUP BY 
    category_translation.product_category_name_english;

-- 주문 개수가 많은 순서대로 정렬한다

SELECT
    category_translation.product_category_name_english AS catogory
    , sum(order_items.order_item_id) AS count_orders
FROM
    customers
    JOIN
    orders
    ON
        customers.customer_id = orders.customer_id
    JOIN 
    order_items
    ON
        orders.order_id = order_items.order_id
    JOIN
    products
    ON
        order_items.product_id = products.product_id
    JOIN
    product_category_name_translation AS category_translation
    ON 
        products.product_category_name = category_translation.product_category_name
WHERE
    customer_state = 'SP'
GROUP BY 
    category_translation.product_category_name_english
ORDER BY
    sum(order_items.order_item_id) DESC;