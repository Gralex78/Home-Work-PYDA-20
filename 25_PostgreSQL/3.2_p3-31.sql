
select ��.��������_�������
from ��������_�����.��������_������� ��

============= ������ =============

create table table_one (
	name_one varchar(255) not null
);

create table table_two (
	name_two varchar(255) not null
);

insert into table_one (name_one)
values ('one'), ('two'), ('three'), ('four'), ('five')

insert into table_two (name_two)
values ('four'), ('five'), ('six'), ('seven'), ('eight')

select * from table_one

select * from table_two

--left, right, inner, full outer, cross

select t1.name_one, t2.name_two
from table_one t1
inner join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
left join table_two t2 on t1.name_one = t2.name_two

select count(1)
from customer c
join address a on a.address_id = c.address_id

select *
from customer c
left join address a on a.address_id = c.address_id

select t1.name_one, t2.name_two
from table_one t1
right join table_two t2 on t1.name_one = t2.name_two and t2.name_two = 'four'

select t1.name_one, t2.name_two
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two
where t1.name_one is null or t2.name_two is null

select t1.name_one, t2.name_two
from table_one t1
cross join table_two t2

select t1.name_one, t2.name_one
from table_one t1
cross join table_one t2
where t1.name_one < t2.name_one

select t1.name_one, t2.name_two
from table_one t1, table_two t2
where t1.name_one = t2.name_two

select t1.name_one, t2.name_two, t3.name_two
from table_one t1, table_two t2, table_two t3

two > one

delete from table_one;
delete from table_two;

insert into table_one (name_one)
select unnest(array[1,1,2])

insert into table_two (name_two)
select unnest(array[1,1,3])

select * from table_one

select * from table_two

select t1.name_one, t2.name_two
from table_one t1
inner join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
left join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
right join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
cross join table_two t2 

1A	1B
1a	1b
2A	3B

explain
select count(1)
from customer c
join rental r on c.customer_id = r.customer_id
join payment p on r.rental_id = p.rental_id

1A1B 1A1b 1a1B 1a1b

-- union / except

select 1 as x, 1 as y
union --distinct
select 1 as x, 2 as y
union --distinct
select 1 as x, 1 as y
union --distinct
select 1 as x, 1 as y

select 1 as x, 1 as y
union all
select 1 as x, 2 as y
union all
select 1 as x, 1 as y
union all
select 1 as x, 1 as y

select 1 as x, 1 as y
except
select 1 as x, 2 as y
except
select 1 as x, 1 as y

select name_one from table_one
except 
select name_two from table_two 

select name_one from table_one
except all
select name_two from table_two 

-- case

select t1.name_one, t2.name_two
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two
where t1.name_one is null or t2.name_two is null

select concat(t1.name_one, t2.name_two)
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two
where t1.name_one is null or t2.name_two is null

select coalesce(t1.name_one, t2.name_two)
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two
where t1.name_one is null or t2.name_two is null

select coalesce(2, null, null, 10, 50, null)

select 
	case 
		--when t1.name_one is null then t2.name_two
		when t2.name_two is null then t1.name_one
		else '���-�� ����� �� ���'
	end
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two
where t1.name_one is null or t2.name_two is null

select count(*)
from (
	select address_id
	from customer) t

============= ���������� =============

1. �������� ������ �������� ���� ������� � �� ������ (������� language)
* ����������� ������� film
* ��������� � language
* �������� ���������� � �������:
title, language."name"

select f.title, l."name"
from film f
join "language" l on l.language_id = f.language_id

1.1 �������� ��� ������ � �� ���������:
* ����������� ������� film
* ��������� � �������� film_category
* ��������� � �������� category
* ��������� ��������� �������� using

select title, name
from film
join film_category using(film_id) 
join category using(category_id)

2. �������� ������ ���� �������, ����������� � ������ Lambs Cincinatti (film_id = 508). 
* ����������� ������� film
* ��������� � film_actor
* ��������� � actor
* ������������, ��������� where � "title like" (��� ��������) ��� "film_id =" (��� id)

select f.title, a.last_name
from film f
left join film_actor fa on f.film_id = fa.film_id
left join actor a on a.actor_id = fa.actor_id
where f.film_id = 508

select f.title, a.last_name
from film f
join film_actor fa on f.film_id = fa.film_id and f.film_id = 508
join actor a on a.actor_id = fa.actor_id

2. �������� ���������� ������ �������, ������� ����� � ������ '24-05-2005'. 
* ����������� ������� film
* ��������� � inventory
* ��������� � rental
* ������������, ��������� where 

select distinct f.title
from film f
join inventory i on i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id
where r.rental_date::date = '24-05-2005'

select distinct f.title
from rental r 
join inventory i on r.inventory_id = i.inventory_id
join film f on i.film_id = f.film_id
where r.rental_date::date = '24-05-2005'

2.1 �������� ��� �������� �� ������ Woodridge (city_id = 576)
* ����������� ������� store
* ��������� ������� � address 
* ��������� ������� � city 
* ��������� ������� � country 
* ������������ �� "city_id"
* �������� ������ ����� ������� ��������� � �� id:
store_id, postal_code, country, city, district, address, address2, phone

explain analyze
select store_id, postal_code, country, city, district, address, address2, phone
from store s
left join address using(address_id)
left join city using(city_id)
left join country using(country_id)
where city_id = 576

============= ���������� ������� =============

3. ����������� ���������� ������� � ������ Grosse Wonderful (id - 384)
* ����������� ������� film
* ��������� � film_actor
* ������������, ��������� where � "film_id" 
* ��� �������� ����������� ������� count, ����������� actor_id � �������� ��������� ������ �������
* ��������� ����������� �����������

select count(actor_id)
from film_actor fa
where film_id = 384

select count(1)
from film_actor fa
where film_id = 384

select count(1)
from film f
join film_actor fa on f.film_id = fa.film_id
where f.film_id = 384

select f.title, f.release_year, f.rental_rate, count(fa.actor_id)
from film f
join film_actor fa on f.film_id = fa.film_id
group by f.title, f.release_year, f.rental_rate

select f.title, f.release_year, f.rental_rate, count(fa.actor_id), fa.film_id
from film f
join film_actor fa on f.film_id = fa.film_id
group by f.film_id, fa.film_id

select f.release_year, f.rental_rate, count(fa.actor_id)
from film f
join film_actor fa on f.film_id = fa.film_id
group by f.release_year, f.rental_rate

select f.release_year, f.rental_rate, count(fa.actor_id), string_agg(f.title, ', ')
from film f
join film_actor fa on f.film_id = fa.film_id
group by f.release_year, f.rental_rate

select f.release_year, f.rental_rate, count(fa.actor_id), array_agg(f.title)
from film f
join film_actor fa on f.film_id = fa.film_id
group by f.release_year, f.rental_rate

FROM
ON
JOIN
WHERE
GROUP by --�����, �� �� � ������ ���� ��� �����������
WITH CUBE ��� WITH ROLLUP
HAVING
select --������ 
DISTINCT
ORDER by

select f.release_year x, f.rental_rate y, count(fa.actor_id), array_agg(f.title)
from film f
join film_actor fa on f.film_id = fa.film_id
group by 1, 2


3.1 ���������� ������� ��������� ������ �� ���� �� ���� �������
* ����������� ������� film
* ��������� ������ �� ���� rental_rate/rental_duration
* avg - �������, ����������� ������� ��������
--4 ���������

select avg(rental_rate/rental_duration)
from film 

select avg(rental_rate/rental_duration),
	round(sum(rental_rate/rental_duration), 2),
	max(rental_rate/rental_duration),
	min(rental_rate/rental_duration)
from film 

n(x?X)/N*100

select percentile_disc(0.5) within group (order by things.value)
from things

============= ����������� =============

4. �������� ������, � ������� ���� ����� � ������ ����� ��� �� 10 000 �.�.

* ����������� ������� payment
* ������������ ������ �� ������ ��������� date_trunc
* ��� ������ ������ ���������� ����� ��������
* �������������� ����������� �����, ��� ������ ������� � ������ ������ ����� ��� �� 10 000 �.�.

select date_trunc('month', r.rental_date), sum(p.amount)
from payment p
join rental r on p.rental_id = r.rental_id
group by date_trunc('month', r.rental_date)
having sum(p.amount) > 10000 


4.1 �������� ������ ��������� �������, ������� ����������������� ������ ������� ����� 5 ����
* ����������� ������� film
* ��������� � �������� film_category
* ��������� � �������� category
* ������������ ���������� ������� �� category.name
* ��� ������ ������ ���������� ������ ����������������� ������ �������
* �������������� ����������� �����, ��� ������ ��������� �� ������� ������������������ > 5 ����

select name
from film f
join film_category using(film_id) 
join category c using(category_id)
group by c.category_id
having avg(f.rental_duration) > 5

select 
from customer c
group by c.customer_id

select c.customer_id, p.staff_id, date_trunc('month', p.payment_date), sum(p.amount)
from customer c
join payment p on p.customer_id = c.customer_id
where c.customer_id < 4
group by c.customer_id, p.staff_id, date_trunc('month', p.payment_date)
order by 1,2,3

select c.customer_id, p.staff_id, date_trunc('month', p.payment_date), sum(p.amount)
from customer c
join payment p on p.customer_id = c.customer_id
where c.customer_id < 4
group by grouping sets(c.customer_id, p.staff_id, date_trunc('month', p.payment_date))
order by 1,2,3

select c.customer_id, p.staff_id, date_trunc('month', p.payment_date), sum(p.amount)
from customer c
join payment p on p.customer_id = c.customer_id
where c.customer_id < 4
group by cube(c.customer_id, p.staff_id, date_trunc('month', p.payment_date))
order by 1,2,3

select c.customer_id, p.staff_id, date_trunc('month', p.payment_date), sum(p.amount)
from customer c
join payment p on p.customer_id = c.customer_id
where c.customer_id < 4
group by rollup(c.customer_id, p.staff_id, date_trunc('month', p.payment_date))
order by 1,2,3

============= ���������� =============

5. �������� ���������� �������, �� ���������� ������ �� ���� ������, ��� ������� �������� �� ���� �������
* �������� ���������, ������� ����� ��������� ������� �������� ��������� ������ �� ���� (������� 3.1)
* ����������� ������� film
* ������������ ������ � �������������� �������, ��������� �������� > (���������)
* count - ���������� ������� �������� ��������

select avg(rental_rate/rental_duration) from film 

select count(1), (select avg(rental_rate/rental_duration) from film)
from film f
where rental_rate/rental_duration > (select avg(rental_rate/rental_duration) from film)

select count(1), (select avg(rental_rate/rental_duration) from film)
from film f
join film_actor fa on fa.film_id = f.film_id
where fa.actor_id < 10 and fa.actor_id in (select actor_id from actor a where a.actor_id = fa.actor_id)


select *
from film f
where f.film_id not in (1,3,4,6,89)

6. �������� ������, � ���������� ������������ � ����� "C"
* �������� ���������:
 - ����������� ������� category
 - ������������ ������ � ������� ��������� like 
* ��������� � �������� film_category
* ��������� � �������� film
* �������� ���������� � �������:
title, category."name"
* ����������� ��������� �� from, join, where

select category_id, "name"
from category 
where "name" like 'C%'

explain analyse
select f.title, t.name
from (
	select category_id, "name"
	from category 
	where "name" like 'C%') t 
join film_category fc on fc.category_id = t.category_id
join film f on f.film_id = fc.film_id --175 / 53.29 / 0.47

explain analyse
select f.title, t.name
from film f
join film_category fc on fc.film_id = f.film_id
join (
	select category_id, "name"
	from category 
	where "name" like 'C%') t on t.category_id = fc.category_id --175 / 53.29 / 0.47

explain analyse
select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id and 
	fc.category_id in (select category_id
	from category 
	where "name" like 'C%')
join category c on c.category_id = fc.category_id --175 / 47.11 / 0.45

explain analyse
select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id 
join category c on c.category_id = fc.category_id
where c.category_id in (
	select category_id
	from category 
	where "name" like 'C%') --175 / 46.96 / 0.43
	
explain analyze
select f.title, t.name
from film f
right join film_category fc on fc.film_id = f.film_id
right join (
	select category_id, "name"
	from category 
	where "name" like 'C%') t on t.category_id = fc.category_id --175 / 53.29 / 0.43
	
explain analyze
select f.title, c.name
from film f
right join film_category fc on fc.film_id = f.film_id 
	and fc.category_id in (
		select category_id
		from category 
		where "name" like 'C%')
	left join category c on fc.category_id = c.category_id--175 / 53.29 / 0.43
where f.title is not null -- 100.53

7* ������ 2 ��� kcu

select tc.table_name, tc.constraint_name, c.column_name, c.data_type
from information_schema.table_constraints tc
join information_schema.key_column_usage kcu on kcu.constraint_name = tc.constraint_name
	and tc.table_name = kcu.table_name
	and tc.constraint_schema = kcu.constraint_schema
join information_schema.columns c on c.column_name = kcu.column_name
	and kcu.table_name = c.table_name
	and kcu.constraint_schema = c.table_schema
where tc.constraint_schema = 'dvd-rental' and tc.constraint_type = 'PRIMARY KEY'

������� 1. ���������� ��� ������� ������, ������� ��� ��� ����� � ������, � ����� ����� ��������� ������ ������ �� �� �����.
��������� ��������� �������: https://postimg.cc/5YQLw9m3



������� 2. ����������� ������ �� ����������� ������� � �������� � ������� ���� ������, ������� �� ���� �� ����� � ������.
��������� ��������� �������: https://postimg.cc/QByc9KcC



������� 3. ���������� ���������� ������, ����������� ������ ���������. �������� ����������� ������� ��������. ���� ���������� ������ ��������� 7 300, �� �������� � ������� ����� ���, ����� ������ ���� �������� ����.
��������� ��������� �������: https://postimg.cc/y3q9nqQz


