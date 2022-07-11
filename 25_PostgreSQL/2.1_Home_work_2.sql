--=============== ������ 2. ������ � ������ ������ =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ���������� �������� �������� �� ������� �������

select distinct district 
from address a
;
  


--������� �2
--����������� ������ �� ����������� �������, ����� ������ ������� ������ �� �������, 
--�������� ������� ���������� �� "K" � ������������� �� "a", � �������� �� �������� ��������

select distinct district 
from address
WHERE district like 'K%a' and district not like '% %'
;



--������� �3
--�������� �� ������� �������� �� ������ ������� ���������� �� ��������, ������� ����������� 
--� ���������� � 17 ����� 2007 ���� �� 19 ����� 2007 ���� ������������, 
--� ��������� ������� ��������� 1.00.
--������� ����� ������������� �� ���� �������.

select payment_id, payment_date, amount 
from payment
where payment_date >= '17-03-2007' and payment_date < '20-03-2007' and amount > 1.00
order by payment_date asc
;



--������� �4
-- �������� ���������� � 10-�� ��������� �������� �� ������ �������.

select payment_id, payment_date, amount 
from payment
order by payment_date desc
limit 10
;



--������� �5
--�������� ��������� ���������� �� �����������:
--  1. ������� � ��� (� ����� ������� ����� ������)
--  2. ����������� �����
--  3. ����� �������� ���� email
--  4. ���� ���������� ���������� ������ � ���������� (��� �������)
--������ ������� ������� ������������ �� ������� �����.

select last_name ||' '||first_name as "������� � ���", email as "����������� �����", 
       character_length(email) as "����� Email", last_update::date as "����" 
from customer
order by last_update desc
;



--������� �6
--�������� ����� �������� �������� �����������, ����� ������� Kelly ��� Willie.
--��� ����� � ������� � ����� �� ������� �������� ������ ���� ���������� � ������� �������.

select upper(last_name), upper(first_name) 
from customer
where first_name = 'Kelly' or first_name = 'Willie'
;

select last_name, first_name
from customer
where first_name = 'LINDA'
;



--======== �������������� ����� ==============

--������� �1
--�������� ����� �������� ���������� � �������, � ������� ������� "R" 
--� ��������� ������ ������� �� 0.00 �� 3.00 ������������, 
--� ����� ������ c ��������� "PG-13" � ���������� ������ ������ ��� ������ 4.00.

select film_id, title, description, rating, rental_rate 
from film
where rating = 'R' and rental_rate <= 3.00 or rating = 'PG-13' and rental_rate >= 4.00
;



--������� �2
--�������� ���������� � ��� ������� � ����� ������� ��������� ������.

select film_id, title, description, character_length(description) as len_str 
from film
order by character_length(description) desc
limit (3)
;



--������� �3
-- �������� Email ������� ����������, �������� �������� Email �� 2 ��������� �������:
--� ������ ������� ������ ���� ��������, ��������� �� @, 
--�� ������ ������� ������ ���� ��������, ��������� ����� @.

select customer_id, email as "Email", 
substring(email from 1 for strpos(email, '@')-1) as "Email before @",
substring(email from strpos(email, '@')+1 for strpos(email, '@')+15) as "Email before @"
from customer
;



--������� �4
--����������� ������ �� ����������� �������, �������������� �������� � ����� ��������: 
--������ ����� ������ ���� ���������, ��������� ���������.

select customer_id, email as "Email", 
initcap(substring(email from 1 for strpos(email, '@')-1)) as "Email before @",
initcap(substring(email from strpos(email, '@')+1 for strpos(email, '@')+15)) as "Email before @"
from customer
;

