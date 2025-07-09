
-- 실전 문제 풀이 --

-- "2018년 상반기(1월~6월)에 우리 서비스에 가장 많이 기여한 '우수 고객' 목록

-- (1) 분석 대상 데이터 준비

-- 1-1. 분석 기간에 해당하는 주문 필터링

select
	*
from
	orders
where 
	order_purchase_timestamp >= '2018-01-01'
	and order_purchase_timestamp < '2018-07-01'
	
-- 1-2. 해당 주문에 대한 결제 내역 조회 (서브쿼리 활용)
-- 참고: join을 사용하면 훨씬 간단하지만, 이 문제에서는 서브쿼리로 접근합니다.
	
with
h1_orders as (
	select
		order_id,
		customer_id
	from 
		orders
	where 
		order_purchase_timestamp >= '2018-01-01'
		and order_purchase_timestamp < '2018-07-01'
)
select
	*
from 
	order_payments pay
where 
	pay.order_id in (select order_id from h1_orders)

-- 1-3. 분석에 필요한 정보(고객, 주문, 결제) 연결
-- 아직 JOIN을 배우지 않았기에 FROM 절에 두 임시 테이블을 나열합니다.
-- 참고: FROM 절에 여러 테이블을 나열하는 암시적 JOIN보다, 명시적 JOIN을 사용하는 것이 더 좋은 방법입니다.
	
with
h1_orders as (
	select
		order_id,
		customer_id
	from 
		orders
	where 
		order_purchase_timestamp >= '2018-01-01'
		and order_purchase_timestamp < '2018-07-01'
),
h1_payments as (
	select
		order_id,
		payment_value
	from 
		order_payments pay
	where
		pay.order_id in (select order_id from h1_orders)
)
select
	h1_orders.customer_id,
	h1_orders.order_id,
	h1_payments.payment_value
from
	h1_orders,
	h1_payments
where
	h1_orders.order_id = h1_payments.order_id
	
-- 1-4. 고객별로 총 주문 건수와 총 결제액 집계 (GROUP BY)
	
with
h1_orders as (
	select
		order_id,
		customer_id
	from 
		orders
	where 
		order_purchase_timestamp >= '2018-01-01'
		and order_purchase_timestamp < '2018-07-01'
),
h1_payments as (
	select
		order_id,
		payment_value
	from 
		order_payments pay
	where
		pay.order_id in (select order_id from h1_orders)
)
select
	h1_orders.customer_id,
	count(h1_orders.order_id) as count_orders,
	sum(h1_payments.payment_value) as total_value
from
	h1_orders,
	h1_payments
where
	h1_orders.order_id = h1_payments.order_id
group by
	customer_id
	

-- (2) 우수 고객 그룹 필터링
	
-- 2-1. '우수 고객' 조건으로 결과 필터링 (HAVING)
-- 조건: 주문 건수 2회 이상, 총 결제액 100 이상

with
h1_orders as (
	select
		order_id,
		customer_id
	from 
		orders
	where 
		order_purchase_timestamp >= '2018-01-01'
		and order_purchase_timestamp < '2018-07-01'
),
h1_payments as (
	select
		order_id,
		payment_value
	from 
		order_payments pay
	where
		pay.order_id in (select order_id from h1_orders)
)
select
	h1_orders.customer_id,
	count(h1_orders.order_id) as count_orders,
	sum(h1_payments.payment_value) as total_value
from
	h1_orders,
	h1_payments
where
	h1_orders.order_id = h1_payments.order_id
group by
	customer_id
having
	count(h1_orders.order_id) >= 2 
	and sum(h1_payments.payment_value) >= 100


-- (3) 정렬 후 마무리

-- 3-1. 최종 결과 정렬 (ORDER BY)
-- 기준: 총 결제 금액(내림차순), 총 주문 건수(내림차순)

with
h1_orders as (
	select
		order_id,
		customer_id
	from 
		orders
	where 
		order_purchase_timestamp >= '2018-01-01'
		and order_purchase_timestamp < '2018-07-01'
),
h1_payments as (
	select
		order_id,
		payment_value
	from 
		order_payments pay
	where
		pay.order_id in (select order_id from h1_orders)
)
select
	h1_orders.customer_id,
	count(h1_orders.order_id) as count_orders,
	sum(h1_payments.payment_value) as total_value
from
	h1_orders,
	h1_payments
where
	h1_orders.order_id = h1_payments.order_id
group by
	customer_id
having
	count(h1_orders.order_id) >= 2 
	and sum(h1_payments.payment_value) >= 100
order by
	sum(h1_payments.payment_value) desc,
	count(h1_orders.order_id) desc
	