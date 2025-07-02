
-- LIKE --

-- 단어 'cama'가 포함된 제품 카테고리
select * 
from products
where
	product_category_name like '%cama%'
	
	
-- 단어 'sao'로 시작하는 도시 이름 찾기
select *
from customers
where
	customer_city like 'sao%'
	
	
-- 두번째 글자가 1이고 네번째 글자가 0인 5자리 우편번호
select * 
from customers
where 
	customer_zip_code_prefix::TEXT like '_1_0_'
	

-- ORDER BY --

-- 가장 최근에 고객에게 배송이 완료된 주문 10건의 order_id와 배송 완료 날짜
select
	order_id,
	order_delivered_customer_date 
from 
	orders
order by 
	order_delivered_customer_date desc
limit
	10

-- 고객 정보 조회, state 오름차순, 같은 state에서 city 내림차순 정렬
select * 
from 
	customers
order by
	customer_state, customer_city desc
	
-- 주문 내역 조회, 배송이 완료되지 않은 주문 먼저 표시, 주문 승인 날짜 오래된 순서로 정렬(오름차순)
select count(*)
from orders
where order_delivered_customer_date is null	

select *
from 
	orders
order by
	order_delivered_customer_date, order_approved_at -- asc: null 값 나중에 표시, 이 경우는 빈 문자열이 먼저 표시.
limit 20

-- LIMIT, OFFSET --

-- 상품을 무게가 무거운 순서대로 정렬했을 때 11-20위 삼품의 product_id, product_category_name, product_weight_g 조회
select
	product_id,
	product_category_name,
	product_weight_g 
from 
	products
order by 
	product_weight_g desc nulls last
limit 10
offset 10


-- numeric calculation --

-- 월 할부금 계산, 월 할부금 상위 20개 조회
select
	payment_value,
	payment_installments,
	(payment_value / payment_installments) as "monthly_payment",
	ROUND(payment_value / payment_installments) as round
from 
	order_payments
where 
	payment_installments <> 0
order by
	monthly_payment desc
	
-- 상품 가격 대비 배송비 퍼센트 계산
select 
	price,
	freight_value,
	(freight_value / price) * 100 as "freight_ratio_pct",
	ROUND(((freight_value / price) * 100)::NUMERIC, 2)
from order_items
where (freight_value / price) * 100 >= 50
order by freight_ratio_pct desc


-- string calculation --

-- 고객 위치 정보 합치기
-- 고객의 도시 정보와 주 정보를 합쳐서 '도시, 주' 정보 만들기
-- 모든 알파벳은 소문자로 변환하고, 오름차순 기준 상위 10개만 표시
select
	customer_city ,
	customer_state ,
	LOWER(customer_city || ', ' || customer_state) as "city_state"
from
	customers
order by
	city_state
limit 10

-- 상품 카테고리 이름 분리하기
-- 상품 카테고리에 언더바가 있다면, 첫 번째 언더바 전 단어 추출
select 
	product_category_name,
	SPLIT_PART(product_category_name , '_', 1)
from 
	products
	
-- 고객 ID 축약
-- ID의 맨 앞 8자리와 맨 뒷 8자리를 하이픈으로 연결
select
	customer_unique_id,
	substring(customer_unique_id, 1, 8) ||
	'-' ||
	substring(customer_unique_id, CHAR_LENGTH(customer_unique_id)-7, 8)
	as "short_id"
from
	customers
limit 10


-- time calculation

select current_date, current_time, current_timestamp

SELECT
    column_name,
    data_type
FROM
    information_schema.columns
WHERE
    table_name = 'orders' and column_name = 'order_delivered_customer_date'
    
select 
	order_delivered_customer_date,
	to_timestamp(order_delivered_customer_date, 'YYYY-MM-DD HH24:MI:SS') as "order_delieverd_timestamp"
from orders

-- 평균 배송 소요 시각 계산
-- 주문한 시각에서 실제 배송받은 시각까지 평균 며칠이 걸리는지 계산

select
	sum(order_delivered_interval),
	count(order_delivered_interval),
	( sum(order_delivered_interval::DECIMAL) / count(order_delivered_interval::DECIMAL) ) as "avg_di"
from
(
	select
		order_delievered_date - order_purchased_date as "order_delivered_interval"
	from 
	(
		select 
			to_date(order_purchase_timestamp, 'YYYY-MM-DD HH24:MI:SS') as "order_purchased_date",
			to_date(order_delivered_customer_date, 'YYYY-MM-DD HH24:MI:SS') as "order_delievered_date"
		from 
			orders
		where 
			order_status = 'delivered' and
			(order_purchase_timestamp is not null or order_purchase_timestamp <> '') and
			(order_delivered_customer_date is not null or order_delivered_customer_date <> '')
	)
)
where order_delivered_interval > 0
	

-- CASE --

-- 결제 수단 한글로 바꾸기
select
	op.payment_type,
	case op.payment_type
		when 'credit_card' then '신용카드'
		when 'boleto' then '현금결제'
		when 'voucher' then '상품권'
		else '기타'
	end as "payment_type_kor"
from
	order_payments op
	
-- 상품 무게 등급 나누기
select 
	p.product_weight_g,
	case
		when p.product_weight_g < 500 then 'Light'
		when p.product_weight_g < 5000 then 'Medium'
		when p.product_weight_g >= 5000 then 'Heavy'
	end
from 
	products p 

-- 주문의 최종 상태일자 구하기
-- 빈 값들이 0이므로 이를 NULL 값으로 대체하여야 함
select 
	o.order_delivered_customer_date,
	o.order_delivered_carrier_date,
	o.order_approved_at,
	coalesce(o.order_delivered_customer_date,
	o.order_delivered_carrier_date,
	o.order_approved_at)
	as "final_status_date"
from
	orders o 