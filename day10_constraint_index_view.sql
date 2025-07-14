
-- Constraint --

-- (1) 제약 없는 기본 테이블 생성

CREATE TABLE members (
    member_id INT
    , email VARCHAR(50)
    , nickname VARCHAR(30)
    , join_date DATE
);

INSERT INTO members 
VALUES (1, 'kim@example.com', '김철수', '2025-07-14');

SELECT * FROM members

-- (2) 기본(PRIMARY KEY) 키 제약 추가 및 테스트

ALTER TABLE members 
ADD CONSTRAINT member_id_key PRIMARY KEY (member_id);

INSERT INTO members
VALUES (1, 'lee@example.com', '이영희', '2025-07-15');

-- (3) 고유(UNIQUE) 키 제약 추가 및 테스트

ALTER TABLE members
ADD CONSTRAINT email_unique UNIQUE (email);

INSERT INTO members
VALUES (1, 'kim@example.com', '김영희', '2025-07-15');

-- (4) NOT NULL 제약 추가 및 테스트

ALTER TABLE members
ALTER COLUMN nickname 
SET NOT NULL;

INSERT INTO members
VALUES (1, 'kim@example.com', null, '2025-07-15');

-- Index --

-- (5) 인덱스 없는 상태에서 성능 측정
-- product 테이블에서 특정 카테고리 상품을 찾는 쿼리

SELECT
    product_category_name
FROM
    products
WHERE
    product_category_name = 'bebes';
    
EXPLAIN
    SELECT
        product_category_name
    FROM
        products
    WHERE
        product_category_name = 'bebes';

-- (6) 인덱스 생성 및 성능 비교
-- product_category_name 열에 인덱스 생성

CREATE INDEX i_pcn
ON products(product_category_name);

EXPLAIN
    SELECT
        product_category_name
    FROM
        products
    WHERE
        product_category_name = 'bebes';


-- View --

-- (7) 복잡한 쿼리 작성
-- orders, order_items, products 세 테이블을 조인하여 '주문 날짜', '상품 id', '가격', '상품 무게' 정보를 포함하는 '주문별 상세 내역'을 조회하는 SELECT 문을 작성

SELECT 
    orders.order_purchase_timestamp
    , order_items.product_id
    , order_items.price
    , products.product_weight_g
FROM
    orders
    JOIN
    order_items
    ON 
        orders.order_id = order_items.order_id
    JOIN
    products
    ON 
        order_items.product_id = products.product_id;

-- (8) 뷰 생성 및 활용
-- 7에서 작성한 쿼리를 사용하여 order_details_view라는 이름의 뷰를 생성

CREATE VIEW 
    order_details_view
AS 
    SELECT 
        orders.order_purchase_timestamp
        , order_items.product_id
        , order_items.price
        , products.product_weight_g
    FROM
        orders
        JOIN
        order_items
        ON 
            orders.order_id = order_items.order_id
        JOIN
        products
        ON 
            order_items.product_id = products.product_id;

SELECT 
    * 
FROM 
    order_details_view
WHERE
    price > 100;


-- (9) MATERIALIZED VIEW 활용 (심화)
-- 일반 뷰와 MATERIALIZED VIEW 성능 비교

CREATE MATERIALIZED VIEW 
    order_details_view_materialized
AS 
    SELECT 
        orders.order_purchase_timestamp
        , order_items.product_id
        , order_items.price
        , products.product_weight_g
    FROM
        orders
        JOIN
        order_items
        ON 
            orders.order_id = order_items.order_id
        JOIN
        products
        ON 
            order_items.product_id = products.product_id;

SELECT 
    avg(price)
FROM 
    order_details_view
WHERE
    price > 100;

EXPLAIN
    SELECT 
        avg(price)
    FROM 
        order_details_view
    WHERE
        price > 100;

EXPLAIN
    SELECT 
        avg(price)
    FROM 
        order_details_view_materialized
    WHERE
        price > 100;