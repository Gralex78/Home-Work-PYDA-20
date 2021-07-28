������� ' ' �� " "

select pg_typeof(100)

select pg_typeof('100')

select '1' + '1' 

where amount > '100'::text

'2021/01/01'

����������������� �����

select "name"
from "language" 

���������� ������� ���������� SELECT

FROM
ON
JOIN
WHERE
GROUP BY
WITH CUBE ��� WITH ROLLUP
HAVING
SELECT <-- ��������� ������ (����������)
OVER
DISTINCT
ORDER BY
limit/offset

��������_�����.��������_������� --from
��������_�������.��������_������� --select

select *
from country 

select country.name
from world.country

select temp_csv.card
from a.temp_csv 

������� ��������� �������, ��� �� ��������� ����������, � ��� ���.

select c.customer_id
from customer c
join payment p on p.customer_id = c.customer_id

select t.cln
from (select c.last_name as cln, c.first_name from customer c) t

1. �������� �������� id ������, ��������, ��������, ��� ������ �� ������� ������.
������������ ���� ���, ����� ��� ��� ���������� �� ����� Film (FilmTitle ������ title � ��)
- ����������� ER - ���������, ����� ����� ���������� �������
- as - ��� ������� ��������� 

select film_id, title, description, release_year
from film

select film_id as Filmfilm_id, title as Filmtitle, 
	description Filmdescription, release_year Filmrelease_year
from film

select film_id as "Filmfilm_id", title as "Filmtitle", 
	description "Filmdescription", 
	release_year "��� ������� ������ release year"
from film

2. � ����� �� ������ ���� ��� ��������:
rental_duration - ����� ������� ������ � ����  
rental_rate - ��������� ������ ������ �� ���� ���������� �������. 
��� ������� ������ �� ������ ������� �������� ��������� ��� ������ � ����,
������� ������������ ������� ��������� cost_per_day
- ����������� ER - ���������, ����� ����� ���������� �������
- ��������� ������ � ���� - ��������� rental_rate � rental_duration
- as - ��� ������� ��������� 

select title, rental_rate / rental_duration as cost_per_day
from film 

2*
- �������������� ��������
- �������� round

select title, rental_rate / rental_duration as cost_per_day,
	rental_rate * rental_duration as cost_per_day,
	rental_rate - rental_duration as cost_per_day,
	rental_rate + rental_duration as cost_per_day
from film 

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 

select round(1/2., 2) 

select round(1::float/2) 

- integer, numeric, float (double precision � real)

int2 = smallint 
int = int4 = integer
int8 = bigint

numeric = decimal

numeric(10,2)

float 
double precision �� 4294836225 real ����� 4294836225

2.5 + 2.5 = 2.499999 + 2.500001

SELECT x,
  round(x::numeric) AS num_round,
  round(x::double precision) AS dbl_round
FROM generate_series(-3.5, 3.5, 1) as x;

3.1 ������������� ������ ������� �� �������� ��������� �� ���� ������ (�.2)
- ����������� order by (�� ��������� ��������� �� �����������)
- desc - ���������� �� ��������

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day --asc

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc, title

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by round(rental_rate / rental_duration, 2) desc, title

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 2 asc, 1

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by  2, description

3.1* ������������ ������� �������� �� ����������� ����� ������� (amount)
- ����������� ER - ���������, ����� ����� ���������� �������
- ����������� order by 
- asc - ���������� �� ����������� 

select payment_id, amount
from payment 
where amount > 0
order by 2

3.2 ������� ���-10 ����� ������� ������� �� ��������� �� ���� ������
- ����������� limit

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc, title
limit 10

3.3 ������� ���-10 ����� ������� ������� �� ��������� ������ �� ����, ������� � 58-�� �������
- �������������� Limit � offset

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc--, title
limit 10
offset 57

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc--, title
offset 57
limit 10

3.3* ������� ���-15 ����� ������ ��������, ������� � ������� 14000
- �������������� Limit � Offset

select payment_id, amount
from payment 
order by 2
offset 13999
limit 15
	
4. ������� ��� ���������� ���� ������� �������
- �������������� distinct

select distinct release_year
from film

explain analyze
select c.customer_id, c.last_name, c.first_name
from customer c

explain analyze
select distinct c.customer_id, c.last_name, c.first_name
from customer c

4* ������� ���������� ����� �����������
- ����������� ER - ���������, ����� ����� ���������� �������
- �������������� distinct

select first_name
from customer 

explain analyze
select distinct first_name
from customer 

select distinct on (release_year) release_year, title
from film

select count(1)
from actor 

select count(distinct actor_id)
from film_actor fa 

5.1. ������� ���� ������ �������, ������� ������� 'PG-13', � ����: "�������� - ��� �������"
- ����������� ER - ���������, ����� ����� ���������� �������
- "||" - �������� ������������, ������� �� concat
- where - ����������� ����������
- "=" - �������� ���������

select title, release_year, rating
from film 
where rating = 'PG-13'

select title || ' - ' || release_year, rating
from film 
where rating = 'PG-13'

select concat(title, ' - ', release_year), rating
from film 
where rating = 'PG-13'

select concat_ws(' - ', title, release_year, rating)
from film 
where rating = 'PG-13'

select null || ' world'

select concat(null, ' - ', ' world')

5.2 ������� ���� ������ �������, ������� �������, ������������ �� 'PG'
- cast(�������� ������� as ���) - ��������������
- like - ����� �� �������
- ilike - ������������������� �����
- lower
- upper
- length

select concat(title, ' - ', release_year), pg_typeof(rating)
from film 

select pg_typeof(release_year)
from film 

select concat(title, ' - ', release_year), rating
from film 
where rating::text like '%PG%'

select concat(title, ' - ', release_year), rating
from film 
where cast(rating as text) like '%PG%'

select concat(title, ' - ', release_year), rating
from film 
where rating::text like '%-__'

select concat(title, ' - ', release_year), rating
from film 
where rating::text like '%PG%' and length(rating::text) = 5

select concat(title, ' - ', release_year), rating
from film 
where rating::text ilike '%pg%' 

select concat(title, ' - ', release_year), rating
from film 
where lower(rating::text) like lower('%Pg%')

select upper(concat(title, ' - ', release_year)), rating
from film 
where upper(rating::text) like upper('%Pg%')

select concat(title, ' - ', release_year), rating
from film 
where rating::text ilike 'P%' and rating::text ilike '%3'

select concat(title, ' - ', release_year), rating
from film 
where rating::text ilike 'P%3' 

select concat(title, ' - ', release_year), rating
from film 
where rating::text not ilike 'P%3' 

regexp_match()

5.2* �������� ���������� �� ����������� � ������ ���������� ���������'jam' (���������� �� �������� ���������), � ����: "��� �������" - ����� �������.
- "||" - �������� ������������
- where - ����������� ����������
- ilike - ������������������� �����
- strpos
- character_length
- overlay
- substring
- split_part

select last_name, first_name
from customer 
where first_name ilike '%jam%'

select strpos('Hello world!', 'world')

select character_length('Hello world!')

select length('Hello world!')

select overlay('Hello world!' placing 'Max' from 7 for 5)

select substring('Hello world!' from 7 for 5)

select overlay('Hello world!' placing 'Max' from 
	(select strpos('Hello world!', 'world')) for (select length('world')))
	
select split_part('Hello world!', ' ', 1)

select split_part('Hello world !', ' ', 2)

select split_part('Hello world !', ' ', 3)

select split_part(description, ' ', 1), split_part(description, ' ', 2),
	split_part(description, ' ', 3)
from film 

6. �������� id �����������, ������������ ������ � ���� � 27-05-2005 �� 28-05-2005 ������������
- ����������� ER - ���������, ����� ����� ���������� �������
- between - ������ ���������� (������ ... >= ... and ... <= ...)
- date_part()
- date_trunc()
- interval
- extract

select customer_id, pg_typeof(rental_date)
from rental 

select customer_id, rental_date
from rental 
where rental_date >= '27/05/2005' and rental_date <= '2005.05.28'

select customer_id, rental_date
from rental 
where rental_date between '27/05/2005 00:00:00' and '2005.05.28 00:00:00'
order by 2 desc

select customer_id, rental_date
from rental 
where rental_date between '27/05/2005 00:00:00' and '2005.05.28 23:59:59'
order by 2 desc

select customer_id, rental_date
from rental 
where rental_date between '27/05/2005 00:00:00' and '2005.05.28'::date + interval '1 day'
order by 2 desc

select customer_id, rental_date
from rental 
where rental_date::date between '27/05/2005' and '2005.05.28'
order by 2 desc

select pg_typeof('27/05/2005'::timestamp)

select customer_id, rental_date
from rental 
where rental_date between '27/05/2005 12:00:00' and '27/05/2005 13:00:00'
order by 2 desc

select '27/05/2005'::date

select extract(year from '27/05/2005'::date)

select extract(month from '27/05/2005'::date)

select extract(hour from '27/05/2005 13:00:00'::timestamp)

select customer_id, rental_date
from rental 
where extract(year from rental_date) = 2005 and extract(month from rental_date) = 5
order by 2 desc

select date_part('year', '27/05/2005'::date)

select date_part('month', '27/05/2005'::date)

select date_part('hour', '27/05/2005 13:00:00'::timestamp)

select date_trunc('year', '27/05/2005'::date)

select date_trunc('month', '27/05/2005'::date)

select date_trunc('hour', '27/05/2005 13:00:00'::timestamp)

select customer_id, rental_date
from rental 
where date_trunc('month', rental_date) = '2005-05-01'::date
order by 2 desc

6* ������� ������� ����������� ����� 30-04-2007
- ����������� ER - ���������, ����� ����� ���������� �������
- > - ������� ������ (< - ������� ������)

select payment_id, payment_date
from payment 
where payment_date::date > '30-04-2007'
order by payment_date 

7 �������� ���������� ���� � '30-04-2007' �� ����������� ����.

select now()

select last_update::date
from film 

select cast(last_update as date)
from film 

select date(last_update)
from film 

select date_part('day', now() - '30-04-2007')

select now()::date - '30-04-2007'::date

select '30-04-2007'::date - '20-04-2007'::date

select '30-04-2007 13:00:00'::timestamp - '20-04-2005 12:00:00'::timestamp

select age('30-04-2007 13:00:00'::timestamp, '20-04-2005 12:00:00'::timestamp)

�������� ���������� ������� � '30-04-2007' �� ����������� ����.

select age(now(), '30-04-2007'::date)

select date_part('month', age(now(), '30-04-2007'::date))

select date_part('year', age(now(), '30-04-2007'::date)) * 12 + 
	date_part('month', age(now(), '30-04-2007'::date))

�������� ���������� ��� � '30-04-2007' �� ����������� ����.

select date_part('year', age(now(), '30-04-2007'::date))

--���:


--������:


--����:


�������������� ������� �������� ������:
������� 1. �������� ����� �������� ���������� � �������, � ������� ������� �R� � 
��������� ������ ������� �� 0.00 �� 3.00 ������������, � ����� ������ c ��������� �PG-13� 
� ���������� ������ ������ ��� ������ 4.00.
��������� ��������� �������: https://ibb.co/Dk4PjJn

select film_id, title, description, rating, rental_rate
from film 
where (rating = 'R' and rental_rate between 0. and 3.) or
	(rating = 'PG-13' and rental_rate >= 4.)

������� 2. �������� ���������� � ��� ������� � ����� ������� ��������� ������.
��������� ��������� �������: https://ibb.co/pfMHBs0

select *
from film 
order by character_length(description) desc
limit 3

������� 3. �������� Email ������� ����������, �������� �������� Email �� 2 
��������� �������: � ������ ������� ������ ���� ��������, ��������� �� @, �� ������ 
������� ������ ���� ��������, ��������� ����� @.
��������� ��������� �������: https://ibb.co/SJng6qd

select split_part(c.email, '@', 1), split_part(c.email, '@', 2)
from customer c

������� 4. ����������� ������ �� ����������� �������, �������������� �������� � ����� ��������:
������ ����� ������ ���� ���������, ��������� ���������.
��������� ��������� �������: https://ibb.co/vv0k9b6

select initcap(split_part(c.email, '@', 1)), 
	initcap(split_part(c.email, '@', 2))
from customer c

explain analyze
select 
	concat(upper(left(split_part(c.email, '@', 1), 1)),
	substring(split_part(c.email, '@', 1), 2)), 
	concat(upper(left(split_part(c.email, '@', 2), 1)),
	substring(split_part(c.email, '@', 2), 2))
from customer c

explain analyze
select  
	concat(upper(substring(email from 1 for 1)), 
	substring(email from 2 for strpos(email, '@')-2)),
	concat(upper(substring(email from strpos(email, '@')+1 for 1)), 
	substring(email from strpos(email, '@')+2))
from customer c