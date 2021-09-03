FROM
ON
JOIN
WHERE
GROUP BY
WITH CUBE или WITH ROLLUP
HAVING
select
over
DISTINCT
ORDER by

x in (1, 5, 8. 'sdfsd')

select exists (select 1 from film where film_id >5000)

select coalesce(null, null, null, 10)

select nullif(7, 8)

select nullif(7, 8)

select replace('abcdefabcdef', 'cd', 'XX')

is null

============= оконные функции =============

1. Вывести ФИО пользователя и название третьего фильма, который он брал в аренду.
* В подзапросе получите порядковые номера для каждого пользователя по дате аренды
* Задайте окно с использованием предложений over, partition by и order by
* Соедините с customer
* Соедините с inventory
* Соедините с film
* В условии укажите 3 фильм по порядку

explain analyze
select c.last_name, c.first_name, f.title
from (
	select customer_id, array_agg(rental_id) as a
	from (select customer_id, rental_id 
		from rental r 
		order by customer_id, rental_date) t
	group by customer_id) t
join rental r on r.rental_id = t.a[3]
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join customer c on c.customer_id = r.customer_id
order by c.customer_id --2470 /15.2

explain analyze
select last_name, first_name, title
from (
	select c.customer_id, c.last_name, c.first_name, f.title,
		row_number() over (partition by c.customer_id order by r.rental_date)
	from customer c
	join rental r on r.customer_id = c.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id) t
where row_number = 3 
order by customer_id --2306 / 27

select f.title, a.last_name, count(f.film_id) over (partition by a.actor_id)
from film f
join film_actor fa on fa.film_id = f.film_id
join actor a on a.actor_id = fa.actor_id

1.1. Выведите таблицу, содержащую имена покупателей, арендованные ими фильмы и средний платеж каждого
покупателя
* используйте таблицу customer
* соедините с paymen
* соедините с rental
* соедините с inventory
* соедините с film
* avg - функция, вычисляющая среднее значение
* Задайте окно с использованием предложений over и partition by

select c.last_name, f.title, 
	avg(p.amount) over (partition by c.customer_id)
from customer c
join rental r on r.customer_id = c.customer_id
join payment p on p.rental_id = r.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id

-- демоснтрация агрегатных функций

select c.last_name, f.title, 
	avg(p.amount) over (partition by c.customer_id),
	max(p.amount) over (partition by c.customer_id),
	min(p.amount) over (partition by c.customer_id),
	sum(p.amount) over (partition by c.customer_id),
	count(p.amount) over (partition by c.customer_id)
from customer c
join rental r on r.customer_id = c.customer_id
join payment p on p.rental_id = r.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id

-- работа функций lead и lag

select c.last_name, f.title, 
	lag(p.amount) over (partition by c.customer_id),
	p.amount,
	lead(p.amount) over (partition by c.customer_id)
from customer c
join rental r on r.customer_id = c.customer_id
join payment p on p.rental_id = r.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id

select c.last_name, f.title, 
	lag(p.amount, 3) over (partition by c.customer_id),
	p.amount,
	lead(p.amount, 3) over (partition by c.customer_id)
from customer c
join rental r on r.customer_id = c.customer_id
join payment p on p.rental_id = r.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id

select c.last_name, f.title, 
	lag(p.amount, 3, 0.) over (partition by c.customer_id),
	p.amount,
	lead(p.amount, 3, 0.) over (partition by c.customer_id)
from customer c
join rental r on r.customer_id = c.customer_id
join payment p on p.rental_id = r.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id

-- формирование накопительного итога

explain analyze
select c.last_name, sum(p.amount) * 100 / (select sum(amount) from payment)--, sum(amount) over ()
from customer c
join rental r on r.customer_id = c.customer_id
join payment p on p.rental_id = r.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
group by c.customer_id --1519

explain analyze

select c.last_name, sum(p.amount) * 100 / sum(sum(p.amount)) over ()
from customer c
join rental r on r.customer_id = c.customer_id
join payment p on p.rental_id = r.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
group by c.customer_id --1274

select c.last_name, f.title, p.amount, p.payment_date,
	sum(p.amount) over (partition by c.customer_id order by p.payment_date),
	sum(p.amount) over (partition by c.customer_id)
from customer c
join rental r on r.customer_id = c.customer_id
join payment p on p.rental_id = r.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id

select c.last_name, f.title, p.amount, date_trunc('month', p.payment_date),
	sum(p.amount) over (partition by c.customer_id, date_trunc('month', p.payment_date) order by p.payment_date),
	sum(p.amount) over (partition by c.customer_id)
from customer c
join rental r on r.customer_id = c.customer_id
join payment p on p.rental_id = r.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id

select c.last_name, f.title, p.amount, p.payment_date,
	avg(p.amount) over (partition by c.customer_id order by p.payment_date),
	sum(p.amount) over (partition by c.customer_id)
from customer c
join rental r on r.customer_id = c.customer_id
join payment p on p.rental_id = r.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id

select c.last_name, f.title, p.amount, date_trunc('month', p.payment_date),
	sum(p.amount) over (partition by c.customer_id, date_trunc('month', p.payment_date) 
		order by date_trunc('month', p.payment_date) ),
	sum(p.amount) over (partition by c.customer_id)
from customer c
join rental r on r.customer_id = c.customer_id
join payment p on p.rental_id = r.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id

select c.last_name, f.title, p.amount, p.payment_date, p.payment_id,
	sum(p.amount) over (partition by c.customer_id 
		order by p.payment_date rows between unbounded preceding and current row),
	sum(p.amount) over (partition by c.customer_id)
from customer c
join rental r on r.customer_id = c.customer_id
join payment p on p.rental_id = r.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
where p.payment_date::date = ' 14/05/2007'

select c.last_name, f.title, p.amount,
	sum(p.amount) over (partition by c.customer_id 
		order by date_trunc('month', p.payment_date) rows current row),
	sum(p.amount) over (partition by c.customer_id)
from customer c
join rental r on r.customer_id = c.customer_id
join payment p on p.rental_id = r.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id

rows between unbounded preceding and current row

https://postgrespro.ru/docs/postgresql/12/sql-expressions#SYNTAX-WINDOW-FUNCTIONS

-- работа с рангами и порядковыми номерами

select c.last_name, f.title, date_trunc('month', p.payment_date),
	row_number() over (partition by c.customer_id order by date_trunc('month', p.payment_date)),
	rank() over (partition by c.customer_id order by date_trunc('month', p.payment_date)),
	dense_rank() over (partition by c.customer_id order by  date_trunc('month', p.payment_date))
from customer c
join rental r on r.customer_id = c.customer_id
join payment p on p.rental_id = r.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id


1.2 Одним запросом ответить на два вопроса: в какой из месяцев взяли в аренду фильмов больше всего? 
На сколько по отношению к предыдущему месяцу было сдано в аренду больше/меньше фильмов.

select m, d, max(m) filter (where mc = c) over ()
from (
	select date_trunc('month', rental_date) m, count(rental_id) c, 
		max(count(rental_id)) over () mc, 	
		count(rental_id) - lag(count(rental_id)::numeric, 1, 0.) over () d
	from rental 
	group by date_trunc('month', rental_date)
	order by date_trunc('month', rental_date)) t 

select date_trunc('month', payment_date), 
	max(amount) filter (where payment_date > '01.04.2007'),
	min(amount) filter (where payment_date < '01.04.2007')
from payment p
group by date_trunc('month', payment_date)

============= общие табличные выражения =============

2.  При помощи CTE выведите таблицу со следующим содержанием:
Название фильма продолжительностью более 3 часов и к какой категории относится фильм
* Создайте CTE:
 - Используйте таблицу film
 - отфильтруйте данные по длительности
 * напишите запрос к полученной CTE:
 - соедините с film_category
 - соедините с category
 -- показать отличие работы CTE в 10 и 12 postgre

 select version()
 
explain analyze
with cte_1 as ( 
	select film_id, title
	from film 
	where rental_duration > 3),
cte_2 as (
	select *
	from film_category),
cte_3 as (
	select category_id, name 
	from category)
select c1.title, c3.name
from cte_1 c1
join cte_2 c2 on c2.film_id = c1.film_id
join cte_3 c3 on c2.category_id = c3.category_id

--10 138.82
--12 99.11

2.1. Выведите фильмы, с категорией начинающейся с буквы "C"
* Создайте CTE:
 - Используйте таблицу category
 - Отфильтруйте строки с помощью оператора like 
* Соедините полученное табличное выражение с таблицей film_category
* Соедините с таблицей film
* Выведите информацию о фильмах:
title, category."name"

with cte_1 as ( 
	select film_id, title
	from film ),
cte_2 as (
	select *
	from film_category),
cte_3 as (
	select category_id, name 
	from category
	where name like 'C%')
select c1.title, c3.name
from cte_1 c1
join cte_2 c2 on c2.film_id = c1.film_id
join cte_3 c3 on c2.category_id = c3.category_id

 ============= общие табличные выражения (рекурсивные) =============
 
 3.Вычислите факториал
 + Создайте CTE
 * стартовая часть рекурсии (т.н. "anchor") должна позволять вычислять начальное значение
 *  рекурсивная часть опираться на данные с предыдущей итерации и иметь условие останова
 + Напишите запрос к CTE

with recursive r as (
	--якорь
	select 1 as x, 1 as factorial
	union 
	--рекурсия
	select x + 1 as x, factorial * (x + 1) as factorial
	from r 
	where x < 10
)
select *
from r

create table geo ( 
	id int primary key, 
	parent_id int references geo(id), 
	name varchar(1000) );

insert into geo (id, parent_id, name)
values 
	(1, null, 'Планета Земля'),
	(2, 1, 'Континент Евразия'),
	(3, 1, 'Континент Северная Америка'),
	(4, 2, 'Европа'),
	(5, 4, 'Россия'),
	(6, 4, 'Германия'),
	(7, 5, 'Москва'),
	(8, 5, 'Санкт-Петербург'),
	(9, 6, 'Берлин');

select * from geo
order by id

with recursive r(a,b,c, d) as (
	select id, parent_id, "name", 1 as level
	from geo
	where id = 5
	union
	select geo.id, geo.parent_id, geo."name", d + 1 as level
	from r 
	join geo on geo.id = r.b
)
select * 
from r
where d = 3

with recursive r(a,b,c) as (
	select id, parent_id, "name", 1 as level
	from geo
	where id = 2
	union
	select geo.id, geo.parent_id, geo."name", level + 1 as level
	from r 
	join geo on geo.parent_id = r.a
)
select  *
from r
 
3.2 Работа с рядами.

select generate_series(1, 100, 6)

explain analyze
select generate_series('01/01/2021'::date, '31/01/2021'::date, interval '1 day')::date

explain analyze
with recursive r as (
	select '01/01/2021'::date as x 
	union
	select x + 1
	from r
	where x <= '31/01/2021'::date
)
select * from r

select * from film

Есть исходные данные:
create table test (
	date_event timestamp,
	field varchar(50),
	old_value varchar(50),
	new_value varchar(50)
)

insert into test (date_event, field, old_value, new_value)
values
('2017-08-05', 'val', 'ABC', '800'),
('2017-07-26', 'pin', '', '10-AA'),
('2017-07-21', 'pin', '300-L', ''),
('2017-07-26', 'con', 'CC800', 'null'),
('2017-08-11', 'pin', 'EKH', 'ABC-500'),
('2017-08-16', 'val', '990055', '100')

select * from test order by date(date_event)

В данной таблице хранят информацию по изменению "статуса" для каждого типа поля (field ). 
То есть, есть поле pin, на 21.07.2017 было изменено значение, соответственно новое (new_value ) стало '' 
(пустая строка) и старое  (old_value), записалось как '300-L'.
Далее 26.07.2017 изменили значение с '' (пустая строка) на '10-AA'. И так по разным полям в разные даты 
были какие-то изменения значений.

Задача: составить запрос таким образом, что бы в новой результирующей таблице был календарь изменения 
значений для каждого поля. 
Всего три столбца: дата, поле, текущий статус.
То есть для каждого поля будет отображение каждого дня с отображением текущего статуса. К примеру, 
для поля pin на 21.07.2017 статус будет  '' (пустая строка), на 22.07.2017 -  '' (пустая строка). и т.д. 
до 26.07.2017, где статус станет '10-AA'

Решение должно быть универсальным для любого SQL, не только под PostgreSQL ;)

explain analyze --8 000 000
select
	gs::date as change_date,
	fields.field as field_name,
	case 
		when (
			select new_value 
			from test t 
			where t.field = fields.field and t.date_event = gs::date) is not null 
			then (
				select new_value 
				from test t 
				where t.field = fields.field and t.date_event = gs::date)
		else (
			select new_value 
			from test t 
			where t.field = fields.field and t.date_event < gs::date 
			order by date_event desc 
			limit 1) 
	end as field_value
from 
	generate_series((select min(date(date_event)) from test), (select max(date(date_event)) from test), interval '1 day') as gs, 
	(select distinct field from test) as fields
order by 
	field_name, change_date
	
explain analyze --93 000	
select
	distinct field, gs, first_value(new_value) over (partition by value_partition)
from
	(select
		t2.*,
		t3.new_value,
		sum(case when t3.new_value is null then 0 else 1 end) over (order by t2.field, t2.gs) as value_partition
	from
		(select
			field,
			generate_series((select min(date_event)::date from test), (select max(date_event)::date from test), interval '1 day')::date as gs
		from test) as t2
	left join test t3 on t2.field = t3.field and t2.gs = t3.date_event::date) t4
order by 
	field, gs

explain analyze --2616
with recursive r(a, b, c) as (
    select temp_t.i, temp_t.field, t.new_value
    from 
	    (select min(date(t.date_event)) as i, f.field
	    from test t, (select distinct field from test) as f
	    group by f.field) as temp_t
    left join test t on temp_t.i = t.date_event and temp_t.field = t.field
    union all
    select a + 1, b, 
    	case 
    		when t.new_value is null then c
    		else t.new_value
		end
    from r  
    left join test t on t.date_event = a + 1 and b = t.field
    where a < (select max(date(date_event)) from test)
)    
SELECT *
FROM r
order by b, a

explain analyze --476
with recursive r as (
 	--стартовая часть рекурсии
 	 	select
 	     	min(t.date_event) as c_date
		   ,max(t.date_event) as max_date
	from test t
	union
	-- рекурсивная часть
	select
	     r.c_date+ INTERVAL '1 day' as c_date
	    ,r.max_date
	from r
	where r.c_date < r.max_date
 ),
t as (select t.field
		, t.new_value
		, t.date_event
		, case when lead(t.date_event) over (partition by t.field order by t.date_event) is null
			   then max(t.date_event) over ()
			   else lead(t.date_event) over (partition by t.field order by t.date_event)- INTERVAL '1 day'
		  end	  
			   as next_date
		, min (t.date_event) over () as min_date
		, max(t.date_event) over () as max_date	  
from (
select t1.date_event
		,t1.field
		,t1.new_value
		,t1.old_value
from test t1
union all
select distinct min (t2.date_event) over () as date_event --первые стартовые даты
		,t2.field
		,null as new_value
		,null as old_value
from test t2) t
)
select r.c_date, t.field , t.new_value
from r
join t on r.c_date between t.date_event and t.next_date
order by t.field,r.c_date

Задание 1. С помощью оконной функции выведите для каждого сотрудника магазина стоимость продажи из предыдущей строки 
со значением по умолчанию 0.0 с сортировкой по дате продажи


Задание 2. С помощью оконной функции выведите для каждого сотрудника сумму продаж за март 2007 года с нарастающим 
итогом по каждому сотруднику и по каждой дате продажи (дата без учета времени) с сортировкой по дате продажи


Задание 3. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
·   	покупатель, арендовавший наибольшее количество фильмов
·   	покупатель, арендовавший фильмов на самую большую сумму
·   	покупатель, который последним арендовал фильм

