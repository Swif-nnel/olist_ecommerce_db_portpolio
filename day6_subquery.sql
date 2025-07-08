
-- where sub query --
-- (1) 전체 상품의 평균 가격보다 비싼 상품들의 정보
select 
	price
from order_items o 
where price > (
	select avg(price)
	from order_items o2 
	)

-- select sub query --
-- (2) 전체 상품의 평균 무게를 계산하고 원래 무게와 같이 표시
select 
	p.product_weight_g, (
	select round(avg(product_weight_g)::DECIMAL, 0)
	from products)
from products p 

-- set sub query --
-- (3) product_summary 테이블을 만들고 상품별 총 판매액을 업데이트
create table product_summary (
	total_sales decimal
)

insert into product_summary
select price
from order_items

select *
from product_summary

update product_summary
set total_sales = (
	select sum(price)
	from order_items o
	)

select *
from product_summary

--drop table product_summary


-- from sub query --
-- (4) 월별 총 주문건수를 계산하고 주문이 가장 많았던 달과 가장 적었던 달의 '월'과 '주문건수' 표시
select 
	date_part('month', order_purchase_timestamp::DATE) as month,
	count(date_part('month', order_purchase_timestamp::DATE)) as monthly_count
from
	orders
group by
	date_part('month', order_purchase_timestamp::DATE)
order by
	date_part('month', order_purchase_timestamp::DATE)
	
select 
	date_part('month', order_purchase_timestamp::DATE) as month,
	count(date_part('month', order_purchase_timestamp::DATE)) as monthly_count
from
	orders
group by
	date_part('month', order_purchase_timestamp::DATE)
order by
	monthly_count desc
limit 1

	
select 
	min(monthly_count), 
	max(monthly_count)
from (
	select 
		date_part('month', order_purchase_timestamp::DATE) as month,
		count(date_part('month', order_purchase_timestamp::DATE)) as monthly_count
	from
		orders
	group by
		date_part('month', order_purchase_timestamp::DATE)
	order by
		date_part('month', order_purchase_timestamp::DATE)
	) as monthly_orders
	

-- INSERT SELECT --
-- (5) 'SP' 주에 사는 고객들을 골라내어 'sp_customers' 테이블에 복사
create table sp_customers (
	customer_id text,
	customer_unique_id text,
	customer_zip_code_prefix int,
	customer_city text,
	customer_state text
)

select *
from sp_customers

insert into sp_customers
select *
from customers
where customer_state = 'SP'

select *
from sp_customers

--drop table sp_customers


-- EXISTS relative subquery --
-- (6) 'products' 테이블 상품 중, order_items 테이블에 한번이라도 판매된 적이 있는 상품 조회
select *
from products
where
	exists (
		select *
		from order_items
		where products.product_id = order_items.product_id
	)
	
select products.product_id, order_items.product_id
from products, order_items
where products.product_id = order_items.product_id

-- IN relative subquery --
-- (7) 'products' 테이블에서 상품 카테고리가 'beleza_saude'인 상품들의 'product_id'를 먼저 찾고 'order_items'에서 주문 내역 조회
select 
	products.product_id,
	product_category_name
from products, order_items
where 
	products.product_id = order_items.product_id
	and product_category_name = 'beleza_saude'
	
select *
from order_items
where
	order_items.product_id in (
		select 
			products.product_id
		from products
		where
			products.product_id = order_items.product_id
			and product_category_name = 'beleza_saude'
	)

-- 복합 문제 1)
-- 'products' 테이블에서 각 상품 카테고리의 평균 무게보다 더 무거운 상품의 ID, 무게, 카테고리 조회

--- 각 상품 카테고리마다 평균 무게
select 
	product_category_name,
	avg(product_weight_g) as avg_weight,
	round(avg(product_weight_g)::DECIMAL)
from 
	products
group by
	product_category_name
	
--- from subquery 적용
select
	a.product_id,
	a.product_category_name,
	a.product_weight_g,
	b.round_avg_weight
from 
	(
	select 
		product_category_name,
		avg(product_weight_g) as avg_weight,
		round(avg(product_weight_g)::DECIMAL) as round_avg_weight
	from 
		products
	group by
		product_category_name
	) as b,
	products as a
where
	a.product_weight_g > b.avg_weight
	

-- 복합 문제 2)
-- 'order_payments' 테이블에서 전체 평균 할부 개월 수보다 더 많은 할부를 선택한 결제 건 중, 결제 수단이 'credit_card'인 건들의 평균 결제액

-- 전체 평균 할부 개월 수와 더 많은 할부 개월인지 여부
select
	payment_type,
	payment_installments,
	(
	select avg(payment_installments)
	from order_payments
	),
	(
	select avg(payment_installments)
	from order_payments
	) < payment_installments as ins_larger_than_avg
from order_payments

-- where subquery 적용
select 
	payment_type,
	payment_installments,
	payment_value,
	payment_value / payment_installments as avg_payment_value
from 
	order_payments
where
	(
	select avg(payment_installments)
	from order_payments
	) < payment_installments 
	and payment_type = 'credit_card'

	
-- credit_card 외 다른 결제수단에서 평균 할부 개월 수 이상이 있는지 확인
select
	payment_type,
	(
	select avg(payment_installments)
	from order_payments 
	) < payment_installments,
	count(order_payments.order_id)
from
	order_payments
group by
	payment_type,
	(
	select avg(payment_installments)
	from order_payments
	) < payment_installments
order by 
	payment_type


