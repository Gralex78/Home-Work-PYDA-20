============= ������������� =============

4. �������� view � ��������� ������ (���; email) � title ������, ������� �� ���� 
	� ������ ���������
+ �������� �������������:
* �������� CTE, 
- ���������� ������ �� ������� rental, 
- ��������� ����������� row_number() � ���� �� customer_id
- ����������� � ���� ���� �� rental_date �� �������� (desc)
* ���������� customer � ���������� cte 
* ��������� � inventory
* ��������� � film
* ������������ �� row_number = 1

create view task_1 as 
	with cte as (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental 
	)
	select f.title, c2.last_name
	from cte c 
	join inventory i on i.inventory_id = c.inventory_id
	join film f on f.film_id = i.film_id
	join customer c2 on c2.customer_id = c.customer_id
	where row_number = 1

explain analyse
select * from task_1

4.1. �������� ������������� � 3-�� ������: �������� ������, ��� ������ � ���������� �������, 
� ������� �� ��������
+ �������� �������������:
* ����������� ������� film
* ��������� � film_actor
* ��������� � actor
* count - ���������� ������� �������� ��������
* ������� ���� � �������������� ����������� over � partition by

create view task_2 as
	select f.title, a.last_name, count(f.film_id) over (partition by a.actor_id)
	from film f
	join film_actor fa on fa.film_id = f.film_id
	join actor a on a.actor_id = fa.actor_id
	
select * from task_2

============= ����������������� ������������� =============

5. �������� ���������������� ������������� � ��������� ������ (���; email) � title ������, ������� �� ���� � ������ ���������
�������������� ���������� � �������� ������ � �������������.
+ �������� ����������������� ������������� ��� ���������� (with NO DATA):
* �������� CTE, 
- ���������� ������ �� ������� rental, 
- ��������� ����������� row_number() � ���� �� customer_id
- ����������� � ���� ���� �� rental_date �� �������� (desc)
* ���������� customer � ���������� cte 
* ��������� � inventory
* ��������� � film
* ������������ �� row_number = 1
+ �������� �������������
+ �������� ������

create materialized view task_3 as 
	with cte as (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental 
	)
	select f.title, c2.last_name
	from cte c 
	join inventory i on i.inventory_id = c.inventory_id
	join film f on f.film_id = i.film_id
	join customer c2 on c2.customer_id = c.customer_id
	where row_number = 1
with no data 

refresh materialized view task_3

explain analyze
select * from task_3

��������_������������� | ����_���������� | �������������_��_����������

5.1. ������� ���������� ����������������� �������������, ����������:
������ ��������� �������, ������� ����������������� ������ ������� ����� 5 ����
+ �������� ����������������� ������������� � ����������� (with DATA)
* ����������� ������� film
* ��������� � �������� film_category
* ��������� � �������� category
* ������������ ���������� ������� �� category.name
* ��� ������ ������ ���������� ������ ����������������� ������ �������
* �������������� ����������� �����, ��� ������ ��������� �� ������� ������������������ > 5 ����
 + �������� ������
 
create materialized view task_4 as 
	select c."name"
	from film f
	join film_category fc on f.film_id = fc.film_id
	join category c on c.category_id = fc.category_id
	group by c.category_id
	having avg(f.rental_duration) > 5
with data

explain analyze
select * from task_4

============ ������� ===========

https://habr.com/ru/company/postgrespro/blog/326096/

btree = > < null 

hash =

1 - 1 000 000

1 - 500 000 | 500 001 - 1 000 000
1 - 250 000 | 250 001 - 500 000

primary key = unique + not null + index

alter table film_actor drop constraint film_actor_pkey cascade

drop index idx_fk_film_id

explain analyze
select f.title
from film f 
join film_actor fa on fa.film_id = f.film_id
where f.title ilike '%gold%'

-- ��� �������� 165 / 552kb
-- ������ �� film_id 107 / 592kb

alter table film add constraint film_pkey primary key (film_id)

create index idx_film_release_year on film(release_year) --632

create index idx_film_title on film(title) --688

drop index idx_film_title

create index idx_film_title on film using hash (title)

============ explain ===========

������ �� ������ �� ������� ����� ������� 
https://explain.depesz.com/
https://tatiyants.com/pev/
https://habr.com/ru/post/203320/

EXPLAIN [ ( �������� [, ...] ) ] ��������
EXPLAIN [ ANALYZE ] [ VERBOSE ] ��������

����� ����������� ��������:

    ANALYZE [ boolean ]
    VERBOSE [ boolean ]
    COSTS [ boolean ]
    BUFFERS [ boolean ]
    TIMING [ boolean ]
    FORMAT { TEXT | XML | JSON | YAML }
 
explain (format json, analyze)
select (
	select name
	from category c
	where c.category_id = fc.category_id)
from film f
join film_category fc on f.film_id = fc.film_id


explain analyze
select c."name"
from film f
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id

select 100%3 = 0
	

======================== json ========================
 �������� ������� orders
 
CREATE TABLE orders (
     ID serial PRIMARY KEY,
     info json NOT NULL
);

INSERT INTO orders (info)
VALUES
 (
'{ "customer": "John Doe", "items": {"product": "Beer","qty": 6}}'
 ),
 (
'{ "customer": "Lily Bush", "items": {"product": "Diaper","qty": 24}}'
 ),
 (
'{ "customer": "Josh William", "items": {"product": "Toy Car","qty": 1}}'
 ),
 (
'{ "customer": "Mary /"ttt Clark", "items": {"product": "Toy Train","qty": 2}}'
 );
 
select * from orders

INSERT INTO orders (info)
VALUES
 (
'{ "a": { "a": { "a": { "a": { "a": { "c": "b"}}}}}}'
 )
 
|{��������_������: quantity, product_id: quantity, product_id: quantity}|����� ����� ������|


6. �������� ����� ���������� �������:
* CAST ( data AS type) �������������� �����
* SUM - ���������� ������� �����
* -> ���������� JSON
*->> ���������� �����

select id, pg_typeof(info)
from orders 

select id, pg_typeof(info->'items'), info->'items'
from orders 

select id, pg_typeof(info->'items'->'qty'), info->'items'->'qty'
from orders 

select sum((info->'items'->>'qty')::int)
from orders 

6*  �������� ������� ���������� �������, ��������� ������������ �� "Toy"

select avg((info->'items'->>'qty')::int)
from orders 
where info->'items'->>'product' ilike 't%'

--�������� ��� ����� �� json
select json_object_keys(info->'items') 
from orders

======================== array ========================
7. �������� ������� ��� ����������� ����������� ������� (special_features) �
������ -- ������� ��������� �������� ������� special_features
* array_length(anyarray, int) - ���������� ����� ��������� ����������� �������

wish_list 	[1, 4, 89, 405]
			'1, 4, 89, 405'

text[] --������ �������� ������
int[] --������ �������� �����

select title, pg_typeof(special_features)
from film 

select title, array_length(special_features, 1)
from film 

select array_length('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::text[], 2)

7* �������� ��� ������ ���������� ����������� ��������: 'Trailers','Commentaries'
* ����������� ���������:
@> - ��������
<@ - ���������� �
*  ARRAY[��������] - ��� �������� �������

https://postgrespro.ru/docs/postgresql/12/functions-subquery
https://postgrespro.ru/docs/postgrespro/12/functions-array


-- ������ �������� --
select title, special_features
from film 
where special_features::text ilike '%Trailers%' or 
	special_features::text ilike '%Commentaries%'

select title, special_features
from film 
where special_features[1] = 'Trailers' or 
	special_features[1] = 'Commentaries' or 
	special_features[2] = 'Trailers' or 
	special_features[2] = 'Commentaries' or 
	special_features[3] = 'Trailers' or
	special_features[3] = 'Commentaries' or 

-- ���-�� ������� �������� --

select t.film_id, t.title, string_agg(t.unnest, ', ')
from (
	select film_id, title, unnest(special_features)
	from film) t 
where t.unnest = 'Trailers' or t.unnest = 'Commentaries'
group by t.film_id, t.title

-- ������� �������� --
select title, special_features
from film
where special_features @> array['Trailers'] or 
	special_features @> array['Commentaries']
	
	select title, special_features
from film
where special_features <@ array['Trailers'] or 
	special_features <@ array['Commentaries'] or 
	special_features <@ array['Commentaries', 'Trailers']
	
select title, special_features
from film
where  'Trailers' = any(special_features) or 
	'Commentaries' = any(special_features)
	
any = some
	
select title, special_features
from film
where 'Trailers' = all(special_features) or 
	'Commentaries' = all(special_features) 
	
select title, special_features
from film
where array_position(special_features, 'Trailers') is not null or 
	array_position(special_features, 'Commentaries') is not null
	
select title, special_features
from film
where array_positions(special_features, 'Trailers') is not null or 
	array_positions(special_features, 'Commentaries') is not null
	
-- �� ��������
select title, special_features
from film
where not special_features @> array['Trailers'] and 
	not special_features @> array['Commentaries']
	
select array_dims('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::text[])

select array_dims('{1,2,3,5,6,7,8,9,0,0}'::text[])

select array_dims(a)
from a

select * from a

update a 
set a[5] = 555
where c = 2

SELECT a[array_upper(a, 1)], array_upper(a, 1)
from a