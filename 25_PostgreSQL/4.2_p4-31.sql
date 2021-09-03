create database название_базы_данных

create schema lecture_4

set search_path to lecture_4

======================== Создание таблиц ========================
1. Создайте таблицу "автор" с полями:
- id 
- имя
- псевдоним (может не быть)
- дата рождения
- город рождения
- родной язык
* Используйте 
    CREATE TABLE table_name (
        column_name TYPE column_constraint,
    );
* для id подойдет serial, ограничение primary key
* Имя и дата рождения - not null
* город и язык - внешние ключи

create table author (
	author_id serial primary key,
	author_name varchar(100) not null,
	nick_name varchar(50),
	born_date date not null check(extract(year from born_date) > 1800),
	born_city int2 not null references city(city_id),
	--language_id int2 not null references language(language_id) on delete cascade,
	create_date timestamp not null default now(),
	deleted int2 default 0 check (deleted in (0, 1))
)

1*  Создайте таблицы "Язык", "Город", "Страна".
* для id подойдет serial, ограничение primary key
* названия - not null и проверка на уникальность

create table city (
	city_id serial primary key,
	city_name varchar(100) not null unique,
	country_id int2 not null references country(country_id),
	create_date timestamp not null default now(),
	deleted int2 default 0 check (deleted in (0, 1))
)

drop table city cascade
	
create table country (
	country_id integer primary key generated always as identity,
	country_name varchar(100) not null,
	create_date timestamp not null default now(),
	deleted int2 default 0 check (deleted in (0, 1))
)
	
create table language (
	language_id integer primary key generated always as identity,
	language_name varchar(100) not null,
	create_date timestamp not null default now(),
	deleted int2 default 0 check (deleted in (0, 1))
)

int2 = smallint 
int4 = int = integer 
int8 = bigint 

	inn char(10) not null,
	kpp char(8) not null,
	ogrn char(10) not null,
	unique (inn, kpp, ogrn)  
	primary key (inn, kpp, ogrn)  

======================== Заполнение таблицы ========================

2. Вставьте данные в таблицу с языками:
'Русский', 'Французский', 'Японский'
* Можно вставлять несколько строк одновременно:
    INSERT INTO table (column1, column2, …)
    VALUES
     (value1, value2, …),
     (value1, value2, …) ,...;

insert into language (language_name)
values ('Русский'), ('Французский'), ('Японский')

insert into language (language_name)
select unnest(array['Русский','Французский','Японский'])

select * from "language" 

insert into language (language_id, language_name)
values (4, 'Немецкий') -- работать не будет.

-- демонстрация работы счетчика и сброс счетчика

	
2.1 Вставьте данные в таблицу со странами из таблиц country базы dvd-rental:

insert into country (country_name)
select country from "dvd-rental".country

select * from country

2.2 Вставьте данные в таблицу с городами соблюдая связи из таблиц city базы dvd-rental:

insert into city (city_name, country_id)
select city, country_id from "dvd-rental".city -- будет ошибка

insert into city (city_name, country_id)
select distinct on (city) city, country_id from "dvd-rental".city

select city 
from "dvd-rental".city
group by 1
having count(city) > 1

select * from city

select city_id 
from "dvd-rental".city
where city = 'London'

insert into city (city_id, city_name, country_id)
values (1, 'Москва', 101)

select * 
from city
order by city_id desc 
limit 10

select * 
from city
order by create_date desc, city_id desc 
limit 10

delete from city

alter sequence city_city_id_seq restart with 1

insert into city (city_name, country_id)
values ('Москва', 101)

insert into city (city_id, city_name, country_id)
values (2, 'Москва_1', 101)

insert into city (city_name, country_id)
values ('Москва_3', 101)

2.3 Вставьте данные в таблицу с авторами, идентификаторы языков и городов оставьте пустыми.
Жюль Верн, 08.02.1828
Михаил Лермонтов, 03.10.1814
Харуки Мураками, 12.01.1949

insert into author (author_name, born_date, born_city)
values ('Жюль Верн', '08.02.1828', 1),
	('Михаил Лермонтов', '03.10.1814', 6),
	('Харуки Мураками', '12.01.1949', 14)
	
select * from author a


======================== Модификация таблицы ========================

3. Добавьте поле "идентификатор языка" в таблицу с авторами
* ALTER TABLE table_name 
  ADD COLUMN new_column_name TYPE;

-- добавление нового столбца
alter table author add column language_id int2

select * from author a

-- удаление столбца

alter table author drop column language_id

-- добавление ограничения not null

alter table author alter column language_id set not null

-- удаление ограничения not null
alter table author alter column language_id drop not null

-- добавление ограничения unique
alter table author add constraint language_id_unique unique (language_id)

-- удаление ограничения unique
alter table author drop constraint language_id_unique 

-- изменение типа данных столбца
alter table author alter column language_id type text using(language_id::text)

alter table author alter column language_id type int2 using(language_id::int2)

alter table author alter column language_id type varchar(100) using(language_id::varchar(100))

select * from pg_catalog.pg_attribute

UPDATE pg_attribute SET atttypmod = 150+4
WHERE attrelid = 'author'::regclass
AND attname = 'author_name';
 
 3* В таблице с авторами измените колонку language_id - внешний ключ - ссылка на языки
 * ALTER TABLE table_name ADD CONSTRAINT constraint_name constraint_definition
 
alter table author add constraint language_id_fkey foreign key 
	(language_id) references language(language_id)

 ======================== Модификация данных ========================

4. Обновите данные, проставив корректное языки писателям:
Жюль Габриэль Верн - Французский
Михаил Юрьевич Лермонтов - Российский
Харуки Мураками - Японский
* UPDATE table
  SET column1 = value1,
   column2 = value2 ,...
  WHERE
   condition;
  
update author 
set language_id = 2
where author_id = 1

update author 
set language_id = 1
where author_id = 2

update author 
set language_id = 3


where author_id = 3

select * from "language" l

select * from author

update author 
set language_id = 1
where author_id in (3, 15, 20, 50)

4*. Дополните оставшие связи по городам:




 ======================== Удаление данных ========================
 
5. Удалите Лермонтова

update author
set deleted = 1 
where author_id = 2

select *
from author
where deleted = 0

select *
from author
where deleted = 1

delete from author
where author_id = 2 

select * from author

5.1 Удалите все города

delete from city 

select * from author

delete from language
where language_id = 1

drop table author

insert into author (author_name, born_date, born_city, language_id)
values ('Жюль Верн', '08.02.1828', 603, 1),
	('Михаил Лермонтов', '03.10.1814', 604, 2),
	('Харуки Мураками', '12.01.1949', 605, 3)
	
select * from "language" l

drop table language cascade

drop table city cascade

drop table country

drop schema lecture_4

drop database postgres  -- не выполнять :) 

format c:\ 

select f.title, f.rating, c.name, f.release_year, l."name", count(r.rental_id), sum(p.amount)
from film f
join film_category fc on fc.film_id = f.film_id
join category c on c.category_id = fc.category_id
join "language" l on l.language_id = f.language_id
join inventory i on i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id
join payment p on p.rental_id = r.rental_id
group by f.film_id, c.category_id, l.language_id

select f.title, f.rating, c.name, f.release_year, l."name", count(r.rental_id), sum(p.amount)
from film f
left join film_category fc on fc.film_id = f.film_id
left join category c on c.category_id = fc.category_id
left join "language" l on l.language_id = f.language_id
left join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
group by f.film_id, c.category_id, l.language_id
having count(r.rental_id) = 0

select p.staff_id, count(p.amount),
	case 
		when count(p.amount) > 7300 then 'Да'
		else 'Нет'
	end
from payment p
group by p.staff_id