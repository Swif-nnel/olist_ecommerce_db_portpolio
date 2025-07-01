select * from products

select 
	product_id,
	product_category_name 
from
	products
where
	product_category_name = 'bebes'
	
	
select 
	product_id,
	product_category_name 
from
	products
where
	product_category_name <> 'bebes'
	

select product_description_lenght from products

select 
	product_description_lenght 
from 
	products
where
	product_description_lenght > 1000
	

select 
	product_id,
	product_category_name,
	product_name_lenght
from
	products
where
	product_category_name = 'bebes' and product_name_lenght = 40
	

select 
	product_id,
	product_category_name
from
	products
where
	product_category_name = 'bebes' or product_category_name = 'artes'
	
	
select
	product_id,
	product_category_name,
	product_description_lenght
from
	products
where
	(product_category_name = 'babes' or product_category_name = 'artes')
	and (product_description_lenght >= 800 and product_description_lenght <= 1000)
	

select
	product_id,
	product_category_name
from
	products
where
	not (product_category_name <> 'bebes')
