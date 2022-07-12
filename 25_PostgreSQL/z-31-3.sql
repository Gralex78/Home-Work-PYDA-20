/*
 * Задание 1. Посчитайте для каждого фильма, сколько раз его брали в аренду, а также общую 
 * стоимость аренды фильма за всё время.
 * Ожидаемый результат запроса: https://ibb.co/BCqbGcp
 */

select f.title, f.rating, c.name, f.release_year, l."name", count(i.film_id), sum(p.amount)
from film f
join film_category fc on fc.film_id = f.film_id
join category c on c.category_id = fc.category_id
join "language" l on l.language_id = f.language_id
join inventory i on i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id
join payment p on p.rental_id = r.rental_id
group by f.film_id, c.category_id, l.language_id

1 аренда = 1 инвентарный номер = 1 фильм

count(rental.inventory_id)

/*Задание 2. Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, 
 * которые ни разу не брали в аренду.
 * Ожидаемый результат запроса: https://ibb.co/kyv5S9z
*/

select f.title, f.rating, c."name", f.release_year, l."name", count(i.film_id), sum(p.amount)
from film f
left join film_category fc on fc.film_id = f.film_id
left join category c on c.category_id = fc.category_id
left join language l on l.language_id = f.language_id
left join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
where i.film_id is null
group by f.film_id, c.category_id, l.language_id
--having count(i.film_id) = 0

/*Задание 3. Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую 
 * колонку «Премия». Если количество продаж превышает 7 300, то значение в колонке будет «Да», 
 * иначе должно быть значение «Нет».
 * Ожидаемый результат запроса: https://ibb.co/p08qt78
*/

select p.staff_id, count(p.amount),
	case 
		when count(p.amount) > 7300 then 'Да'
		else 'Нет'
	end
from payment p
group by p.staff_id

Задание 1. Создайте новую таблицу film_new со следующими полями:
· film_name — название фильма — тип данных varchar(255) и ограничение not null;
· film_year — год выпуска фильма — тип данных integer, условие, что значение должно быть больше 0;
· film_rental_rate — стоимость аренды фильма — тип данных numeric(4,2), значение по умолчанию 0.99;
· film_duration — длительность фильма в минутах — тип данных integer, ограничение not null и условие, 
	что значение должно быть больше 0.
Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.

create table film_new (
	id serial primary key,
	film_name varchar(255) not null,
	film_year integer check(film_year > 0),
	film_rental_rate numeric(4,2) default 0.99,
	film_duration integer not null check(film_duration > 0)
)

drop table film_new

select * from film_new

Задание 2. Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют 
массивы данных:
· film_name — array[The Shawshank Redemption, The Green Mile, Back to the Future, Forrest Gump, 
Schindler’s List];
· film_year — array[1994, 1999, 1985, 1994, 1993];
· film_rental_rate — array[2.99, 0.99, 1.99, 2.99, 3.99];
· film_duration — array[142, 189, 116, 142, 195].

insert into film_new (film_name, film_year, film_rental_rate, film_duration)
select unnest(array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 
	'Schindler’s List']), 
	unnest(array[1994, 1999, 1985, 1994, 1993]),
	unnest(array[2.99, 0.99, 1.99, 2.99, 3.99]),
	unnest(array[142, 189, 116, 142, 195])

Задание 3. Обновите стоимость аренды фильмов в таблице film_new с учётом информации, 
что стоимость аренды всех фильмов поднялась на 1.41.

update film_new
set film_rental_rate = film_rental_rate + 1.41

select * from film_new

Задание 4. Фильм с названием Back to the Future был снят с аренды, удалите строку с этим фильмом 
из таблицы film_new.

delete from film_new
where film_name = 'Back to the Future'

Задание 5. Добавьте в таблицу film_new запись о любом другом новом фильме.

insert into film_new (film_name, film_year, film_rental_rate, film_duration)
values ('aaaaaaa', 3, 4, 5)

Задание 6. Напишите SQL-запрос, который выведет все колонки из таблицы film_new, а также новую 
вычисляемую колонку «длительность фильма в часах», округлённую до десятых.

select *, round(film_duration / 60., 1)
from film_new

Задание 7. Удалите таблицу film_new.

drop table film_new

 Посчитайте для каждого покупателя 4 аналитических показателя:
· количество взятых в аренду фильмов;
· общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа);
· минимальное значение платежа за аренду фильма;
· максимальное значение платежа за аренду фильма.

explain analyze
select customer_id,
	(select count(rental_id)
	from rental r
	where r.customer_id = c.customer_id
	group by customer_id),
	(select sum(amount)
	from payment p
	where p.customer_id = c.customer_id
	group by customer_id),
	(select min(amount)
	from payment p
	where p.customer_id = c.customer_id
	group by customer_id),
	(select max(amount)
	from payment p
	where p.customer_id = c.customer_id
	group by customer_id)
from customer c --324000

explain analyze
select c.customer_id, count, sum, min, max
from customer c
join (select count(rental_id), r.customer_id 
	from rental r
	group by customer_id) r on r.customer_id = c.customer_id
join (select sum(amount), p.customer_id
	from payment p
	group by customer_id) p1 on p1.customer_id = c.customer_id
join (select min(amount), p.customer_id
	from payment p
	group by customer_id) p2 on p2.customer_id = c.customer_id
join (select max(amount), p.customer_id
	from payment p
	group by customer_id) p3 on p3.customer_id = c.customer_id --1472

explain analyze
select r.customer_id, count(r.inventory_id), sum(p.amount), min(p.amount), max(p.amount)
from rental r
join payment p on p.rental_id = r.rental_id --993
group by r.customer_id

select *
from "dvd-rental".payment

create table payment_new (like "dvd-rental".payment including defaults) partition by range (amount)

create table pay_1 partition of payment_new for values from (minvalue) to (5)

create table pay_2 partition of payment_new for values from (5) to (7)

create table pay_2 partition of payment_new for values from (7) to (maxvalue)pay_1 p

delete from payment_new

drop table pay_2

insert into payment_new
select * from "dvd-rental".payment

select * from only payment_new

explain analyze
select * from payment_new

explain analyze
select * from "dvd-rental".payment

explain analyze

select customer_id from pay_2

create table cust_new (like "dvd-rental".customer including defaults) partition by range (last_name)

create table cust_1 partition of cust_new for values from ('a') 
	to ('p')

create table cust_2 partition of cust_new for values from ('p') 
	to ('z')
	
insert into cust_new
select * from "dvd-rental".customer

select * from cust_2

create table cust_3 partition of cust_new for values from (1) 
	to (10)
