
-- count --

-- (1) 배송이 완료된 주문 건수 계산
select
	count(o.order_delivered_customer_date)
from
	orders o
where
	o.order_delivered_customer_date <> ''

-- (2) 전체 상품의 개수
select 
	count(*)
from 
	products p 


-- distinct --

-- (3) 결제수단의 종류 중복 없이
select 
	distinct o.payment_type
from 
	order_payments o 

-- (4) 고객들의 거주 주(state) 개수 계산
select 
	distinct c.customer_state
from
	customers c 
	
select 
	count(distinct c.customer_state)
from 
	customers c


-- SUM, AVG, MIN, MAX --

-- (5) 모든 상품 가격의 총합 계산
select 
	sum(price)
from 
	order_items o 

-- (6) 운임의 평균 계산
select 
	avg(o.freight_value), 
	round(avg(o.freight_value)::DECIMAL, 2)
from 
	order_items o 

-- (7) 단일 주문에서 가장 비싼 상품의 가격, 싼 상품의 가격 
-- 첫 선적기한, 마지막 선적기한, 가장 비싼 운임, 가장 싼 운임 한번에 조회
select 
	max(o.price) as max_price,
	min(o.price) as min_price,
	min(o.shipping_limit_date) as first_sld,
	max(o.shipping_limit_date) as last_sld,
	max(o.freight_value) as max_fv,
	min(o.freight_value) as min_fv
from
	order_items o 


-- GROUP BY, HAVING --

-- (8) 각 상품 카테고리별로 상품 개수 계산
select 
	p.product_category_name,
	count(p.product_category_name)
from 
	products p 
group by
	p.product_category_name 

-- (9) 각 주(state)의 도시(city) 별로 상품 개수 계산
select
	c.customer_state, 
	c.customer_city,
	count(*)
from 
	customers c 
group by
	c.customer_state, c.customer_city 

-- (10) 각 결제수단 별로 할부 개월 수 평균 계산
select 
	o.payment_type,
	sum(o.payment_installments),
	count(o.payment_installments),
	avg(o.payment_installments)
from 
	order_payments o 
group by
	o.payment_type

-- (11) 주문 상태별로 주문 건수 계산, 주문 건수가 많은 순서대로 정렬
select 
	o.order_status,
	count(*) as cs
from
	orders o 
group by
	o.order_status
order by
	cs desc
	
-- (12) 
--SELECT customer_state, COUNT(*) FROM customers;

-- (13) 5번 이상 주문된 상품의 ID와 주문 횟수 조회
select 
	o.product_id,
	count(o.product_id)
from
	order_items o 
group by 	
	o.product_id
having
	count(o.product_id) >= 5