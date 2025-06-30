
-- 테이블 리스트를 반환하는 구문
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';


select * from
	olist_products_dataset;

select 
	product_id,
	product_category_name
from 
	olist_products_dataset;


select * from 
	olist_customers_dataset;

select 
	customer_city,
	customer_state
from 
	olist_customers_dataset;


select * from 
	olist_orders_dataset;

select 
	order_status
from 
	olist_orders_dataset;