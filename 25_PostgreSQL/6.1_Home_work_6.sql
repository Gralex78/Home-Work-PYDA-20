---=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".

explain analyse
select film_id, title, special_features
from film f
where special_features @> array['Behind the Scenes']
order by film_id --538 / 91.7 / 0.55



--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.

explain analyse
select film_id, title, special_features
from film f
where special_features && array['Behind the Scenes']
order by film_id --538 / 91.7 / 0.48

explain analyse
select film_id, title, special_features
from film f
where 'Behind the Scenes' = any(special_features)
order by film_id --538 / 101.57 / 0.44

explain analyse
select film_id, title, special_features
from film f
where array_position (special_features, 'Behind the Scenes') is not null
order by film_id --538 / 95.19 / 0.55



--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.


explain analyse
with cte_1 as ( 
	select *
	from customer),
cte_2 as (
	select * 
	from rental),
cte_3 as (
	select *
	from inventory),
cte_4 as (
	select film_id, title, special_features
	from film
	where special_features && array['Behind the Scenes'])
select c1.customer_id, count(c4.film_id)
from cte_1 c1
join cte_2 c2 on c2.customer_id = c1.customer_id
join cte_3 c3 on c3.inventory_id = c2.inventory_id
join cte_4 c4 on c4.film_id = c3.film_id
group by c1.customer_id
order by c1.customer_id --599 / 719.19 / 11.10


explain analyse
with cte_1 as ( 
	select *
	from customer),
cte_2 as (
	select * 
	from rental),
cte_3 as (
	select *
	from inventory),
cte_4 as (
	select film_id, title, special_features
	from film
	where 'Behind the Scenes' = any (special_features))
select c1.customer_id, count(c4.film_id)
from cte_1 c1
join cte_2 c2 on c2.customer_id = c1.customer_id
join cte_3 c3 on c3.inventory_id = c2.inventory_id
join cte_4 c4 on c4.film_id = c3.film_id
group by c1.customer_id
order by c1.customer_id -- 599 / 729.06 / 10.80


explain analyse
with cte_1 as ( 
	select *
	from customer),
cte_2 as (
	select * 
	from rental),
cte_3 as (
	select *
	from inventory),
cte_4 as (
	select film_id, title, special_features
	from film
	where special_features @> array['Behind the Scenes'])
select c1.customer_id, count(c4.film_id)
from cte_1 c1
join cte_2 c2 on c2.customer_id = c1.customer_id
join cte_3 c3 on c3.inventory_id = c2.inventory_id
join cte_4 c4 on c4.film_id = c3.film_id
group by c1.customer_id
order by c1.customer_id --599 / 719.19 / 12.23


explain analyse
with cte_1 as ( 
	select *
	from customer),
cte_2 as (
	select * 
	from rental),
cte_3 as (
	select *
	from inventory),
cte_4 as (
	select film_id, title, special_features
	from film
	where array_position (special_features, 'Behind the Scenes') is not null)
select c1.customer_id, count(c4.film_id)
from cte_1 c1
join cte_2 c2 on c2.customer_id = c1.customer_id
join cte_3 c3 on c3.inventory_id = c2.inventory_id
join cte_4 c4 on c4.film_id = c3.film_id
group by c1.customer_id
order by c1.customer_id --599 / 780.82 / 11.90



--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

explain analyse
select c.customer_id, count(t.film_id)
from (
    select film_id, title, special_features
	from film f
	where special_features && array['Behind the Scenes']
	order by film_id) t
	join inventory i on i.film_id = t.film_id
	join rental r on r.inventory_id = i.inventory_id
	join customer c on c.customer_id = r.customer_id
group by c.customer_id
order by c.customer_id --599 / 833.48 / 8.14


explain analyse
select c.customer_id, count(t.film_id)
from (
    select film_id, title, special_features
	from film f
	where 'Behind the Scenes' = any (special_features)
	order by film_id) t
	join inventory i on i.film_id = t.film_id
	join rental r on r.inventory_id = i.inventory_id
	join customer c on c.customer_id = r.customer_id
group by c.customer_id
order by c.customer_id --599 / 843.35 / 7.35


explain analyse
select c.customer_id, count(t.film_id)
from (
    select film_id, title, special_features
	from film f
	where special_features @> array['Behind the Scenes']
	order by film_id) t
	join inventory i on i.film_id = t.film_id
	join rental r on r.inventory_id = i.inventory_id
	join customer c on c.customer_id = r.customer_id
group by c.customer_id
order by c.customer_id --599 / 833.48 / 8.00


explain analyse
select c.customer_id, count(t.film_id)
from (
    select film_id, title, special_features
	from film f
	where array_position (special_features, 'Behind the Scenes') is not null
	order by film_id) t
	join inventory i on i.film_id = t.film_id
	join rental r on r.inventory_id = i.inventory_id
	join customer c on c.customer_id = r.customer_id
group by c.customer_id
order by c.customer_id --599 / 998.24 / 10.78


--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления

explain analyse
create materialized view behind_the_scenes as
	with cte as(
		select film_id, title, special_features
	from film f
	where special_features && array['Behind the Scenes']
	order by film_id)
	select c.customer_id, count(cte.film_id)
	from cte
	join inventory i on i.film_id = cte.film_id
	join rental r on r.inventory_id = i.inventory_id
	join customer c on c.customer_id = r.customer_id
group by c.customer_id
order by customer_id 
with data --599 / 833.48 /30.75 (10.24 - с 4-й попытки)

refresh materialized view behind_the_scenes

explain analyse
select * from behind_the_scenes --599 / 9.99 / 0.09



--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее
--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса

--1. Explain analyse запросов из 1-го и 2-го заданий (вывести информацию о фильмах со специальным
--атрибутом "Behind the Scenes") указывают на то, что оптимальным по затратам и времени является запрос 
--где в фильтрации применяется функция "&& array[]" (пересечение значений) результат: 91.7 / 0.48мс.
--По скорости выполнения он не самый быстрый (на 2-м месте из 4-х), как например с опрератором "any", у которого скорость 
--выполнения запроса 0.44 мс (самый быстрый запрос), но зато ресурсозатратность меньше, всего 91.7 против 101.57.

--2. Касательно вопроса о сравнении скорости вариантов вычесления с использованием СТЕ и подзапроса, 
--очевидно, что подзапросы быстрее СТЕ: 7.35мс против 10.8мс (в случае фильтрации с использованием оператора "any"),
--но ресурсозатратность с использованием подзапросов несколько больше, чем с использованием СТЕ: 843.35 против 729.06. 



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии




--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.

select t.staff_id, f.film_id, f.title, t.amount, t.payment_date, c.last_name, c.first_name 
from (
    select staff_id, payment_date, amount, rental_id, customer_id,
        row_number() over (partition by staff_id order by payment_date)
    from payment p) t
    join rental r on t.rental_id = r.rental_id 
    join inventory i on r.inventory_id = i.inventory_id 
    join film f on i.film_id = f.film_id
    join customer c on t.customer_id = c.customer_id 
where row_number = 1
order by staff_id   -- 2221.77 / 18.65


explain analyse
with cte_1 as ( 
	select staff_id, payment_date, amount, rental_id, customer_id,
        row_number() over (partition by staff_id order by payment_date)
	from payment),
cte_2 as (
	select * 
	from rental),
cte_3 as (
	select *
	from inventory),
cte_4 as (
	select *
	from film),
cte_5 as (
	select *
	from customer)
select c1.staff_id, c4.film_id, c4.title, c1.amount, c1.payment_date, c5.last_name, c5.first_name
from cte_1 c1
join cte_2 c2 on c2.rental_id = c1.rental_id
join cte_3 c3 on c3.inventory_id = c2.inventory_id
join cte_4 c4 on c4.film_id = c3.film_id
join cte_5 c5 on c1.customer_id = c5.customer_id
where row_number = 1
order by c1.staff_id  -- 2221.77 / 17.74


--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день

explain analyse
select t1.store_id, t1.day_max_rent, t1.quantity, t2.day_min_sum, t2.min_sum
from (
	select i.store_id, rental_date::date as day_max_rent, count(i.film_id) as quantity,
		row_number() over (partition by store_id order by count(i.film_id) desc) row_num_1
	from inventory i
	join rental r on i.inventory_id = r.inventory_id
	group by i.store_id, day_max_rent) t1 
join (
	select s.store_id, payment_date::date as day_min_sum, sum(amount) as min_sum, 
		row_number() over (partition by p.staff_id order by sum(amount)) row_num_2
	from payment p
	join staff s on s.staff_id = p.staff_id
	join store s2 on s2.store_id = s.store_id
	group by s.store_id, day_min_sum, p.staff_id) t2 on t1.store_id = t2.store_id
where row_num_1 = 1 and row_num_2 = 1  --4887.05 / 19.29
