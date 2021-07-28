--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

select c.last_name ||' '|| c.first_name as "Фамилия и имя", a.address as "Адрес", c2.city as "Город", c3.country as "Страна"
from customer c 
left join address a on c.address_id = a.address_id
left join city c2 on a.city_id = c2.city_id 
left join country c3 on c2.country_id = c3.country_id 



--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.

select store_id as "ID магазина", count(customer_id) as "Количество покупателей"
from customer c
group by store_id


--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.

select store_id as "ID магазина", count(customer_id) as "Количество покупателей"
from customer c
group by store_id
having count(customer_id) > 300



-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.

select s.store_id as "ID магазина", count(customer_id) as "Количество покупателей", 
       c.city as "Город магазина", concat(s2.last_name, ' ', s2.first_name) as "Фамилия и имя продавца"
from store s 
left join address a on s.address_id = a.address_id 
left join city c on a.city_id = c.city_id
left join staff s2 on s.store_id = s2.store_id
left join customer c2 on c2.store_id = s2.store_id
group by concat(s2.last_name, ' ', s2.first_name), s.store_id, c.city 
having count(customer_id) > 300



--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов

select concat(c.last_name, ' ', c.first_name) as "Фамилия и имя покупателя", count(r.rental_id) as "Количество фильмов"
from customer c 
left join rental r on r.customer_id = c.customer_id 
group by concat(c.last_name, ' ', c.first_name)
order by count(r.rental_id) desc
limit(5)



--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма

select concat(c.last_name, ' ', c.first_name) as last_first_name, count(r.rental_id) as quantity_films, 
       round(sum(p.amount)) as total_payment, min(p.amount) as min_payment, max(p.amount) as max_payment
from payment p
left join customer c on c.customer_id = p.customer_id
left join rental r on r.rental_id = p.rental_id
group by last_first_name
having min(p.amount) > 0


--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
 
select a.city, b.city
from city a
cross join city b
where a.city < b.city

--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
 
select customer_id, round(avg(date(return_date) - date(rental_date)), 2) as average_days_for_rent
from rental 
group by customer_id
order by customer_id



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.

select title, rating, c2.name as genre, release_year, l.name as language_, count(r.rental_id) as quantity_films, sum(amount) as total
from film f 
left join film_category fc on fc.film_id = f.film_id 
left join category c2 on c2.category_id = fc.category_id
left join "language" l on l.language_id = f.language_id
left join inventory i on i.film_id = f.film_id 
left join rental r on r.inventory_id = i.inventory_id 
left join payment p on p.rental_id = r.rental_id
group by title, rating, genre, release_year, language_
order by title



--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.

select title, rating, c2.name as genre, release_year, l.name as language_, count(r.rental_id) as quantity_films, sum(amount) as total
from film f 
left join film_category fc on fc.film_id = f.film_id 
left join category c2 on c2.category_id = fc.category_id
left join "language" l on l.language_id = f.language_id
left join inventory i on i.film_id = f.film_id 
left join rental r on r.inventory_id = i.inventory_id 
left join payment p on p.rental_id = r.rental_id
group by title, rating, genre, release_year, language_
having count(r.rental_id) < 1 
order by title



--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".


select staff_id, count(rental_id),
  case 
     when count(rental_id) > 7300 then 'YES'
     else 'NO'
  end as premium
from payment p 
group by staff_id




