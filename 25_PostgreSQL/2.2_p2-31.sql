Отличие ' ' от " "

select pg_typeof(100)

select pg_typeof('100')

select '1' + '1' 

where amount > '100'::text

'2021/01/01'

Зарезервированные слова

select "name"
from "language" 

логический порядок инструкции SELECT

FROM
ON
JOIN
WHERE
GROUP BY
WITH CUBE или WITH ROLLUP
HAVING
SELECT <-- объявляем алиасы (псевдонимы)
OVER
DISTINCT
ORDER BY
limit/offset

название_схемы.название_таблицы --from
название_таблицы.название_столбца --select

select *
from country 

select country.name
from world.country

select temp_csv.card
from a.temp_csv 

Область видимости алиасов, где их указывать необходимо, а где нет.

select c.customer_id
from customer c
join payment p on p.customer_id = c.customer_id

select t.cln
from (select c.last_name as cln, c.first_name from customer c) t

1. Получите атрибуты id фильма, название, описание, год релиза из таблицы фильмы.
Переименуйте поля так, чтобы все они начинались со слова Film (FilmTitle вместо title и тп)
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- as - для задания синонимов 

select film_id, title, description, release_year
from film

select film_id as Filmfilm_id, title as Filmtitle, 
	description Filmdescription, release_year Filmrelease_year
from film

select film_id as "Filmfilm_id", title as "Filmtitle", 
	description "Filmdescription", 
	release_year "Год выпуска фильма release year"
from film

2. В одной из таблиц есть два атрибута:
rental_duration - длина периода аренды в днях  
rental_rate - стоимость аренды фильма на этот промежуток времени. 
Для каждого фильма из данной таблицы получите стоимость его аренды в день,
задайте вычисленному столбцу псевдоним cost_per_day
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- стоимость аренды в день - отношение rental_rate к rental_duration
- as - для задания синонимов 

select title, rental_rate / rental_duration as cost_per_day
from film 

2*
- арифметические действия
- оператор round

select title, rental_rate / rental_duration as cost_per_day,
	rental_rate * rental_duration as cost_per_day,
	rental_rate - rental_duration as cost_per_day,
	rental_rate + rental_duration as cost_per_day
from film 

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 

select round(1/2., 2) 

select round(1::float/2) 

- integer, numeric, float (double precision и real)

int2 = smallint 
int = int4 = integer
int8 = bigint

numeric = decimal

numeric(10,2)

float 
double precision до 4294836225 real после 4294836225

2.5 + 2.5 = 2.499999 + 2.500001

SELECT x,
  round(x::numeric) AS num_round,
  round(x::double precision) AS dbl_round
FROM generate_series(-3.5, 3.5, 1) as x;

3.1 Отсортировать список фильмов по убыванию стоимости за день аренды (п.2)
- используйте order by (по умолчанию сортирует по возрастанию)
- desc - сортировка по убыванию

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

3.1* Отсортируйте таблицу платежей по возрастанию суммы платежа (amount)
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- используйте order by 
- asc - сортировка по возрастанию 

select payment_id, amount
from payment 
where amount > 0
order by 2

3.2 Вывести топ-10 самых дорогих фильмов по стоимости за день аренды
- используйте limit

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc, title
limit 10

3.3 Вывести топ-10 самых дорогих фильмов по стоимости аренды за день, начиная с 58-ой позиции
- воспользуйтесь Limit и offset

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

3.3* Вывести топ-15 самых низких платежей, начиная с позиции 14000
- воспользуйтесь Limit и Offset

select payment_id, amount
from payment 
order by 2
offset 13999
limit 15
	
4. Вывести все уникальные годы выпуска фильмов
- воспользуйтесь distinct

select distinct release_year
from film

explain analyze
select c.customer_id, c.last_name, c.first_name
from customer c

explain analyze
select distinct c.customer_id, c.last_name, c.first_name
from customer c

4* Вывести уникальные имена покупателей
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- воспользуйтесь distinct

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

5.1. Вывести весь список фильмов, имеющих рейтинг 'PG-13', в виде: "название - год выпуска"
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- "||" - оператор конкатенации, отличие от concat
- where - конструкция фильтрации
- "=" - оператор сравнения

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

5.2 Вывести весь список фильмов, имеющих рейтинг, начинающийся на 'PG'
- cast(название столбца as тип) - преобразование
- like - поиск по шаблону
- ilike - регистронезависимый поиск
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

5.2* Получить информацию по покупателям с именем содержашим подстроку'jam' (независимо от регистра написания), в виде: "имя фамилия" - одной строкой.
- "||" - оператор конкатенации
- where - конструкция фильтрации
- ilike - регистронезависимый поиск
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

6. Получить id покупателей, арендовавших фильмы в срок с 27-05-2005 по 28-05-2005 включительно
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- between - задает промежуток (аналог ... >= ... and ... <= ...)
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

6* Вывести платежи поступившие после 30-04-2007
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- > - строгое больше (< - строгое меньше)

select payment_id, payment_date
from payment 
where payment_date::date > '30-04-2007'
order by payment_date 

7 Получить количество дней с '30-04-2007' по сегодняшний день.

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

Получить количество месяцев с '30-04-2007' по сегодняшний день.

select age(now(), '30-04-2007'::date)

select date_part('month', age(now(), '30-04-2007'::date))

select date_part('year', age(now(), '30-04-2007'::date)) * 12 + 
	date_part('month', age(now(), '30-04-2007'::date))

Получить количество лет с '30-04-2007' по сегодняшний день.

select date_part('year', age(now(), '30-04-2007'::date))

--дни:


--Месяцы:


--Года:


Дополнительные задания домашней работы:
Задание 1. Выведите одним запросом информацию о фильмах, у которых рейтинг “R” и 
стоимость аренды указана от 0.00 до 3.00 включительно, а также фильмы c рейтингом “PG-13” 
и стоимостью аренды больше или равной 4.00.
Ожидаемый результат запроса: https://ibb.co/Dk4PjJn

select film_id, title, description, rating, rental_rate
from film 
where (rating = 'R' and rental_rate between 0. and 3.) or
	(rating = 'PG-13' and rental_rate >= 4.)

Задание 2. Получите информацию о трёх фильмах с самым длинным описанием фильма.
Ожидаемый результат запроса: https://ibb.co/pfMHBs0

select *
from film 
order by character_length(description) desc
limit 3

Задание 3. Выведите Email каждого покупателя, разделив значение Email на 2 
отдельных колонки: в первой колонке должно быть значение, указанное до @, во второй 
колонке должно быть значение, указанное после @.
Ожидаемый результат запроса: https://ibb.co/SJng6qd

select split_part(c.email, '@', 1), split_part(c.email, '@', 2)
from customer c

Задание 4. Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках:
первая буква должна быть заглавной, остальные строчными.
Ожидаемый результат запроса: https://ibb.co/vv0k9b6

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