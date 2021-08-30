--=============== МОДУЛЬ 4. УГЛУБЛЕНИЕ В SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--База данных: если подключение к облачной базе, то создаете новые таблицы в формате:
--таблица_фамилия, 
--если подключение к контейнеру или локальному серверу, то создаете новую схему и в ней создаете таблицы.


-- Спроектируйте базу данных для следующих сущностей:
-- 1. язык (в смысле английский, французский и тп)
-- 2. народность (в смысле славяне, англосаксы и тп)
-- 3. страны (в смысле Россия, Германия и тп)


--Правила следующие:
-- на одном языке может говорить несколько народностей
-- одна народность может входить в несколько стран
-- каждая страна может состоять из нескольких народностей

 
--Требования к таблицам-справочникам:
-- идентификатор сущности должен присваиваться автоинкрементом
-- наименования сущностей не должны содержать null значения и не должны допускаться дубликаты в названиях сущностей
 
--СОЗДАНИЕ ТАБЛИЦЫ ЯЗЫКИ

create table language (
	language_id integer primary key generated always as identity,
	language_name varchar(30) not null,
	create_date timestamp not null default now(),
	deleted int2 default 0 check (deleted in (0, 1))
)

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ ЯЗЫКИ

insert into language (language_name)
values ('Аглийский'), ('Французский'), ('Испанский'), ('Итальянский'), ('Арабский')

select * from language

--СОЗДАНИЕ ТАБЛИЦЫ НАРОДНОСТИ

create table nation (
	nation_id integer primary key generated always as identity,
	nation_name varchar(30) not null,
	create_date timestamp not null default now(),
	deleted int2 default 0 check (deleted in (0, 1))
)

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ НАРОДНОСТИ

insert into nation (nation_name)
values ('Швейцарцы'), ('Каталонцы'), ('Баски'), ('Ливанцы'), ('Мавританцы')

select * from nation

--СОЗДАНИЕ ТАБЛИЦЫ СТРАНЫ

create table country (
	country_id integer primary key generated always as identity,
	country_name varchar(30) not null,
	create_date timestamp not null default now(),
	deleted int2 default 0 check (deleted in (0, 1))
)

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СТРАНЫ

insert into country (country_name)
values ('Испания'), ('Франция'), ('Италия'), ('США'), ('Канада')

select * from country

--СОЗДАНИЕ ПЕРВОЙ ТАБЛИЦЫ СО СВЯЗЯМИ

create table nation_country (
     nation_id int2 not null references nation(nation_id),
     country_id int2 not null references country(country_id),
     create_date timestamp not null default now(),
	 deleted int2 default 0 check (deleted in (0, 1))
	 
)

alter table nation_country 
add constraint nation_country_pkey primary key (nation_id, country_id)

--drop table nation_country

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ

insert into nation_country (nation_id, country_id)
values (1, 2), (1, 3), (1, 4), (1, 5), (2, 1), (2, 2), (2, 3), (3, 1), (3, 2), (4, 4), (4, 5), (5, 2), (5, 5)

select * from nation_country

--СОЗДАНИЕ ВТОРОЙ ТАБЛИЦЫ СО СВЯЗЯМИ

create table nation_language (
     nation_id int2 not null references nation(nation_id),
     language_id int2 not null references language(language_id),
     create_date timestamp not null default now(),
	deleted int2 default 0 check (deleted in (0, 1))
)

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ

insert into nation_language (nation_id, language_id)
values (1, 2), (1, 4), (2, 2), (2, 3), (2, 4), (3, 2), (3, 3), (4, 1), (4, 2), (4, 5), (5, 2), (5, 5)

select * from nation_language





--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============


--ЗАДАНИЕ №1 
--Создайте новую таблицу film_new со следующими полями:
--·   	film_name - название фильма - тип данных varchar(255) и ограничение not null
--·   	film_year - год выпуска фильма - тип данных integer, условие, что значение должно быть больше 0
--·   	film_rental_rate - стоимость аренды фильма - тип данных numeric(4,2), значение по умолчанию 0.99
--·   	film_duration - длительность фильма в минутах - тип данных integer, ограничение not null и условие, что значение должно быть больше 0
--Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.

create table film_new (
     film_id serial primary key,
     film_name varchar(255) not null,
     film_year integer check(film_year > 0),
     film_rental_rate numeric(4,2) default 0.99,
     film_duration integer not null check(film_duration > 0),
     create_date timestamp not null default now()
)

--ЗАДАНИЕ №2 
--Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:
--·      film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--·      film_year - array[1994, 1999, 1985, 1994, 1993]
--·      film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--·   	 film_duration - array[142, 189, 116, 142, 195]

insert into film_new (film_name, film_year, film_rental_rate, film_duration)
select unnest (array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']),
       unnest (array[1994, 1999, 1985, 1994, 1993]),
       unnest (array[2.99, 0.99, 1.99, 2.99, 3.99]),
       unnest (array[142, 189, 116, 142, 195])

--ЗАДАНИЕ №3
--   Обновите стоимость аренды фильмов в таблице film_new с учетом информации, 
--   что стоимость аренды всех фильмов поднялась на 1.41

update film_new 
set film_rental_rate = film_rental_rate + 1.41
where film_id > 0


--ЗАДАНИЕ №4
--   Фильм с названием "Back to the Future" был снят с аренды, 
--   удалите строку с этим фильмом из таблицы film_new

delete from film_new
where film_id = 3

--ЗАДАНИЕ №5
--   Добавьте в таблицу film_new запись о любом другом новом фильме

insert into film_new (film_name, film_year, film_rental_rate, film_duration)
values ('Appolo Teen', 2006, 2.99, 140)

--ЗАДАНИЕ №6
--   Напишите SQL-запрос, который выведет все колонки из таблицы film_new, 
--   а также новую вычисляемую колонку "длительность фильма в часах", округлённую до десятых

select film_id, film_name, film_year, film_rental_rate, film_duration, round(film_duration/60, 1)
from film_new
order by film_id

--ЗАДАНИЕ №7 
--   Удалите таблицу film_new

drop table film_new



