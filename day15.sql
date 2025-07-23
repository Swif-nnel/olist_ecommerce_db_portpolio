SELECT 
    geolocation_zip_code_prefix AS zip_code_prefix
    , avg(geolocation_lat) AS latitude
    , avg(geolocation_lng) AS longitude
    , geolocation_state AS state
    , geolocation_city AS city
FROM 
    geolocation
WHERE
    geolocation_zip_code_prefix IS NOT NULL AND 
    geolocation_state IS NOT NULL AND
    geolocation_city IS NOT NULL 
GROUP BY 
    zip_code_prefix
    , state
    , city;

-- 빈 값을 null 값으로 변환

-- geolocation 테이블
UPDATE geolocation SET geolocation_city = NULL WHERE geolocation_city = '';
UPDATE geolocation SET geolocation_state = NULL WHERE geolocation_state = '';

-- sellers 테이블
UPDATE sellers SET seller_id = NULL WHERE seller_id = '';
UPDATE sellers SET seller_city = NULL WHERE seller_city = '';
UPDATE sellers SET seller_state = NULL WHERE seller_state = '';

-- order_items 테이블
UPDATE order_items SET order_id = NULL WHERE order_id = '';
UPDATE order_items SET product_id = NULL WHERE product_id = '';
UPDATE order_items SET seller_id = NULL WHERE seller_id = '';
UPDATE order_items SET shipping_limit_date = NULL WHERE shipping_limit_date = '';

-- products 테이블
UPDATE products SET product_id = NULL WHERE product_id = '';
UPDATE products SET product_category_name = NULL WHERE product_category_name = '';

-- customers 테이블
UPDATE customers SET customer_id = NULL WHERE customer_id = '';
UPDATE customers SET customer_unique_id = NULL WHERE customer_unique_id = '';
UPDATE customers SET customer_city = NULL WHERE customer_city = '';
UPDATE customers SET customer_state = NULL WHERE customer_state = '';

-- order_payments 테이블
UPDATE order_payments SET order_id = NULL WHERE order_id = '';
UPDATE order_payments SET payment_type = NULL WHERE payment_type = '';

-- orders 테이블
UPDATE orders SET order_id = NULL WHERE order_id = '';
UPDATE orders SET customer_id = NULL WHERE customer_id = '';
UPDATE orders SET order_status = NULL WHERE order_status = '';
UPDATE orders SET order_purchase_timestamp = NULL WHERE order_purchase_timestamp = '';
UPDATE orders SET order_approved_at = NULL WHERE order_approved_at = '';
UPDATE orders SET order_delivered_carrier_date = NULL WHERE order_delivered_carrier_date = '';
UPDATE orders SET order_delivered_customer_date = NULL WHERE order_delivered_customer_date = '';
UPDATE orders SET order_estimated_delivery_date = NULL WHERE order_estimated_delivery_date = '';

-- product_category_name_translation 테이블
UPDATE product_category_name_translation SET product_category_name = NULL WHERE product_category_name = '';
UPDATE product_category_name_translation SET product_category_name_english = NULL WHERE product_category_name_english = '';


