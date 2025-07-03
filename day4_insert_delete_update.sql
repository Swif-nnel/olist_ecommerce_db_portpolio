
-- create table --
create table sample (
	id int,
	name varchar(50),
	created_at timestamp
)


-- 
alter table sample
alter column created_at set default '2025-01-01'

select
    column_name,
    data_type,
    is_nullable,
    column_default
from
    information_schema.columns
where
    table_name = 'sample'
    
select  * from sample

-- insert --
    
-- 
insert into 
	sample
values 
	(25, 'tf', current_timestamp)

insert into 
	sample(id, name)
values 
	(42, 'ft')

insert into
	sample
values
	(42, 'ft', null)

insert into
	sample
values
	(default, default, default)

insert into 
	sample(id)
values
	(89)


	
-- delete --
	
select * from sample

delete 
	from 
		sample 
	where
		id = 25
		
delete 
	from
		sample
	where 
		id is null

		
-- update --

select * from sample
		
update
	sample
set
	id = 43
where
	created_at is null

update
	sample
set
	created_at = default



-- example data 1 --
	
create table members (
    member_id INT,
    member_name TEXT,
    email TEXT,
    join_date DATE
)

select * from members

insert into 
	members
values
	(1, 'ChulSoo', 'chulsoo@example.com', '2025-07-01'), 
	(2, 'YoungHee', 'younghee@example.com', '2025-07-02')
	
select * from members

update 
	members
set
	email = 'chulsoo.kim@example.com'
where
	member_id = 1
	
select * from members

delete from members where member_id = 2

select * from members


-- example data 2 --

create table gadget_inventory (
    product_code TEXT,
    product_name TEXT,
    stock_quantity INT,
    status TEXT
)

select * from gadget_inventory

insert into
	gadget_inventory
values
	('LOGI-MXM3', '로지텍 MX Master 3S 마우스', 50, '판매중'),
	('KEY-HHKB', '해피해킹 프로 키보드', 5, '판매중'),
	('WEBCAM-C920', '로지텍 C920 웹캠', 0, '재고없음')

select * from gadget_inventory

-- 재고 10개 미만 상품 상태 '재고임박'으로 수정
update
	gadget_inventory
set 
	status = '재고임박'
where 
	stock_quantity < 10 and status <> '재고없음'
	
select * from gadget_inventory

-- 재고 수향 0인 상품 삭제
delete from
	gadget_inventory
where
	stock_quantity = 0

select * from gadget_inventory
