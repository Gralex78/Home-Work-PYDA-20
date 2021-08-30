--=============== ������ 4. ���������� � SQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--���� ������: ���� ����������� � �������� ����, �� �������� ����� ������� � �������:
--�������_�������, 
--���� ����������� � ���������� ��� ���������� �������, �� �������� ����� ����� � � ��� �������� �������.


-- ������������� ���� ������ ��� ��������� ���������:
-- 1. ���� (� ������ ����������, ����������� � ��)
-- 2. ���������� (� ������ �������, ���������� � ��)
-- 3. ������ (� ������ ������, �������� � ��)


--������� ���������:
-- �� ����� ����� ����� �������� ��������� �����������
-- ���� ���������� ����� ������� � ��������� �����
-- ������ ������ ����� �������� �� ���������� �����������

 
--���������� � ��������-������������:
-- ������������� �������� ������ ������������� ���������������
-- ������������ ��������� �� ������ ��������� null �������� � �� ������ ����������� ��������� � ��������� ���������
 
--�������� ������� �����

create table language (
	language_id integer primary key generated always as identity,
	language_name varchar(30) not null,
	create_date timestamp not null default now(),
	deleted int2 default 0 check (deleted in (0, 1))
)

--�������� ������ � ������� �����

insert into language (language_name)
values ('���������'), ('�����������'), ('���������'), ('�����������'), ('��������')

select * from language

--�������� ������� ����������

create table nation (
	nation_id integer primary key generated always as identity,
	nation_name varchar(30) not null,
	create_date timestamp not null default now(),
	deleted int2 default 0 check (deleted in (0, 1))
)

--�������� ������ � ������� ����������

insert into nation (nation_name)
values ('���������'), ('���������'), ('�����'), ('�������'), ('����������')

select * from nation

--�������� ������� ������

create table country (
	country_id integer primary key generated always as identity,
	country_name varchar(30) not null,
	create_date timestamp not null default now(),
	deleted int2 default 0 check (deleted in (0, 1))
)

--�������� ������ � ������� ������

insert into country (country_name)
values ('�������'), ('�������'), ('������'), ('���'), ('������')

select * from country

--�������� ������ ������� �� �������

create table nation_country (
     nation_id int2 not null references nation(nation_id),
     country_id int2 not null references country(country_id),
     create_date timestamp not null default now(),
	 deleted int2 default 0 check (deleted in (0, 1))
	 
)

alter table nation_country 
add constraint nation_country_pkey primary key (nation_id, country_id)

--drop table nation_country

--�������� ������ � ������� �� �������

insert into nation_country (nation_id, country_id)
values (1, 2), (1, 3), (1, 4), (1, 5), (2, 1), (2, 2), (2, 3), (3, 1), (3, 2), (4, 4), (4, 5), (5, 2), (5, 5)

select * from nation_country

--�������� ������ ������� �� �������

create table nation_language (
     nation_id int2 not null references nation(nation_id),
     language_id int2 not null references language(language_id),
     create_date timestamp not null default now(),
	deleted int2 default 0 check (deleted in (0, 1))
)

--�������� ������ � ������� �� �������

insert into nation_language (nation_id, language_id)
values (1, 2), (1, 4), (2, 2), (2, 3), (2, 4), (3, 2), (3, 3), (4, 1), (4, 2), (4, 5), (5, 2), (5, 5)

select * from nation_language





--======== �������������� ����� ==============


--������� �1 
--�������� ����� ������� film_new �� ���������� ������:
--�   	film_name - �������� ������ - ��� ������ varchar(255) � ����������� not null
--�   	film_year - ��� ������� ������ - ��� ������ integer, �������, ��� �������� ������ ���� ������ 0
--�   	film_rental_rate - ��������� ������ ������ - ��� ������ numeric(4,2), �������� �� ��������� 0.99
--�   	film_duration - ������������ ������ � ������� - ��� ������ integer, ����������� not null � �������, ��� �������� ������ ���� ������ 0
--���� ��������� � �������� ����, �� ����� ��������� ������� ������� ������������ ����� �����.

create table film_new (
     film_id serial primary key,
     film_name varchar(255) not null,
     film_year integer check(film_year > 0),
     film_rental_rate numeric(4,2) default 0.99,
     film_duration integer not null check(film_duration > 0),
     create_date timestamp not null default now()
)

--������� �2 
--��������� ������� film_new ������� � ������� SQL-�������, ��� �������� ������������� ������� ������:
--�      film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--�      film_year - array[1994, 1999, 1985, 1994, 1993]
--�      film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--�   	 film_duration - array[142, 189, 116, 142, 195]

insert into film_new (film_name, film_year, film_rental_rate, film_duration)
select unnest (array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']),
       unnest (array[1994, 1999, 1985, 1994, 1993]),
       unnest (array[2.99, 0.99, 1.99, 2.99, 3.99]),
       unnest (array[142, 189, 116, 142, 195])

--������� �3
--   �������� ��������� ������ ������� � ������� film_new � ������ ����������, 
--   ��� ��������� ������ ���� ������� ��������� �� 1.41

update film_new 
set film_rental_rate = film_rental_rate + 1.41
where film_id > 0


--������� �4
--   ����� � ��������� "Back to the Future" ��� ���� � ������, 
--   ������� ������ � ���� ������� �� ������� film_new

delete from film_new
where film_id = 3

--������� �5
--   �������� � ������� film_new ������ � ����� ������ ����� ������

insert into film_new (film_name, film_year, film_rental_rate, film_duration)
values ('Appolo Teen', 2006, 2.99, 140)

--������� �6
--   �������� SQL-������, ������� ������� ��� ������� �� ������� film_new, 
--   � ����� ����� ����������� ������� "������������ ������ � �����", ���������� �� �������

select film_id, film_name, film_year, film_rental_rate, film_duration, round(film_duration/60, 1)
from film_new
order by film_id

--������� �7 
--   ������� ������� film_new

drop table film_new



