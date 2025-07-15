
-- ER Diagram --

-- ER 다이어그램을 위해 각 테이블 총 개수와 기본키 개수를 조회

SELECT count(*), count(distinct order_id) FROM orders;
SELECT count(*), count(distinct customer_id) FROM customers;
SELECT count(*), count(distinct seller_id) FROM sellers;
SELECT count(*), count(distinct product_id) FROM products;
SELECT count(*), count(distinct order_id) FROM order_items;
SELECT count(*), count(distinct order_id) FROM order_payments;
SELECT count(*), count(distinct product_category_name) FROM product_category_name_translation;


-- Transaction --

-- 모든 과정이 성공적으로 끝났을 때

BEGIN TRANSACTION;
INSERT INTO orders (order_status) VALUES ('delivered');
UPDATE orders SET order_status = 'delivered' WHERE order_purchase_timestamp < '2017-01-01' ;
COMMIT;

-- 중간에 오류가 발생했을 때

BEGIN TRANSACTION;
INSERT INTO orders (order_status) VALUES ('delivered');
-- 재고 차감 중 오류 발생 가정
ROLLBACK;



