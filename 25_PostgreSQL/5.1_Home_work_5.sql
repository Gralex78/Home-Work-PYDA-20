--=============== ������ 5. ������ � POSTGRESQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ������ � ������� payment � � ������� ������� ������� �������� ����������� ������� �������� ��������:
--	������������ ��� ������� �� 1 �� N �� ����
--	������������ ������� ��� ������� ����������, ���������� �������� ������ ���� �� ����
--	���������� ����������� ������ ����� ���� �������� ��� ������� ����������, ���������� ������ ���� ������ �� ���� �������, � ����� �� ����� ������� �� ���������� � �������
--	������������ ������� ��� ������� ���������� �� ��������� ������� �� ���������� � ������� ���, ����� ������� � ���������� ��������� ����� ���������� �������� ������.
-- ����� ��������� �� ������ ����� ��������� SQL-������, � ����� ���������� ��� ������� � ����� �������.


select 
  customer_id, payment_id, payment_date,
  row_number() over (order by payment_date) as column_1,
  row_number() over (partition by customer_id order by payment_date) as column_2,
  sum(amount) over (partition by customer_id order by payment_date, amount) as column_3,
  dense_rank() over (partition by customer_id order by amount desc) as column_4
from payment p
order by customer_id, column_4


--������� �2
-- � ������� ������� ������� �������� ��� ������� ���������� ��������� ������� 
-- � ��������� ������� �� ���������� ������ �� ��������� �� ��������� 0.0 � ����������� �� ����.
 
select customer_id, payment_id, payment_date, amount,
    lag(amount, 1, 0.) over (partition by customer_id order by payment_date, amount) as last_ammount
from payment p 
group by customer_id, payment_id
order by customer_id, payment_date


--������� �3
-- � ������� ������� ������� ����������, �� ������� ������ 
-- ��������� ������ ���������� ������ ��� ������ ��������.

select customer_id, payment_id, payment_date, amount,
    amount - lead(sum(amount),1, 0.) over(partition by customer_id order by payment_date) as difference
from payment p 
group by customer_id, payment_id


--������� �4
-- � ������� ������� ������� ��� ������� ���������� �������� ������ � ��� ��������� ������ ������.

select customer_id, payment_id, payment_date, amount
from (
    select customer_id, payment_id, payment_date, amount,
        row_number() over (partition by customer_id order by payment_date desc)
    from payment) t
where row_number = 1
order by customer_id



--======== �������������� ����� ==============

--������� �1
--� ������� ������� ������� �������� ��� ������� ���������� ����� ������ �� ���� 2007 ����
-- � ����������� ������ �� ������� ���������� � 
-- �� ������ ���� ������� (��� ����� �������) � ����������� �� ����.

select staff_id, date_trunc('day', payment_date) as payment_date_ , sum(amount) as sum_amount,
    sum(sum(amount)) over (partition by staff_id order by date_trunc('day', payment_date)) as sum_
from payment p
where extract(month from p.payment_date::DATE) = 3
group by staff_id, payment_date_


--������� �2
--10 ������ 2007 ���� � ��������� ��������� �����: ����������, ����������� ������ 100�� ������
-- ������� �������������� ������ �� ��������� ������.
-- � ������� ������� ������� �������� ���� �����������, ������� � ���� ���������� ����� �������� ������.

select customer_id, payment_id, payment_date, row_number as payment_number
from (
    select customer_id, payment_id, payment_date,
        row_number() over (order by payment_date)
    from payment 
    where payment_date::date = '10/04/2007') t
where row_number % 100 = 0  
order by payment_number


--������� �3
--��� ������ ������ ���������� � �������� ����� SQL-�������� �����������, ������� �������� ��� �������:
-- 1. ����������, ������������ ���������� ���������� �������
-- 2. ����������, ������������ ������� �� ����� ������� �����
-- 3. ����������, ������� ��������� ��������� �����

with c1 as (
	select concat(c.first_name, ' ', c.last_name) as full_name, c3.country_id, count(i.film_id), sum(p.amount), max(r.rental_date)
	from customer c
	join rental r on r.customer_id = c.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join payment p on p.rental_id = r.rental_id
	join address a on a.address_id = c.address_id
	join city c2 on c2.city_id = a.city_id
	join country c3 on c3.country_id = c2.country_id
	group by c.customer_id, c3.country_id),
c2 as (
	select full_name, country_id,
		row_number () over (partition by country_id order by count desc) cf,
		row_number () over (partition by country_id order by sum desc) sa,
		row_number () over (partition by country_id order by max desc) md
	from c1)
select c.country, c_1.full_name as cust_max_rent_quantity, c_2.full_name as cust_max_sum, c_3.full_name as last_customer
from country c
left join c2 c_1 on c_1.country_id = c.country_id and c_1.cf = 1
left join c2 c_2 on c_2.country_id = c.country_id and c_2.sa = 1
left join c2 c_3 on c_3.country_id = c.country_id and c_3.md = 1
order by 1







-- MAX QUANTITY

select country, name_max_qntt, qntt, rank_max_qntt
from (
	select country, concat(first_name, ' ', last_name) as name_max_qntt, count(r.rental_id) as qntt,
		 dense_rank() over (partition by country order by count(r.rental_id) desc) as rank_max_qntt
	from country c4
    join city c3 on c3.country_id = c4.country_id 
    join address a on a.city_id = c3.city_id 
    join customer c on c.address_id = a.address_id
    join rental r on r.customer_id = c.customer_id 
    join payment p on p.rental_id = r.rental_id
    group by country, name_max_qntt) t
where rank_max_qntt = 1 
order by country


-- MAX SUM

select country, name_max_sum, max_sum, rank_max_sum
from (
	select country, concat(first_name, ' ', last_name) as name_max_sum, sum(p.amount) as max_sum,
		dense_rank() over (partition by country order by sum(p.amount) desc) as rank_max_sum
	from country c4
    join city c3 on c3.country_id = c4.country_id 
    join address a on a.city_id = c3.city_id 
    join customer c on c.address_id = a.address_id
    join rental r on r.customer_id = c.customer_id 
    join payment p on p.rental_id = r.rental_id
    group by country, name_max_sum) t
where rank_max_sum = 1 
order by country

-- LAST PAYMENT

select country, name_last_cust, rank_last_date
from (
	select country, concat(first_name, ' ', last_name) as name_last_cust, p.payment_id, --, p.payment_date,
		dense_rank() over (partition by country order by p.payment_id) as rank_last_date
	from country c4
    join city c3 on c3.country_id = c4.country_id 
    join address a on a.city_id = c3.city_id 
    join customer c on c.address_id = a.address_id
    join rental r on r.customer_id = c.customer_id 
    join payment p on p.rental_id = r.rental_id
    group by country, name_last_cust, p.payment_id) t
where rank_last_date = 1 
order by country



-- MAX QUANTITY + MAX SUM


select country, name_max_qntt, name_max_sum
from (
	select country, concat(first_name, ' ', last_name) as name_max_qntt, count(r.rental_id) as qntt,
		 dense_rank() over (partition by country order by count(r.rental_id) desc) as rank_max_qntt,
		 concat(first_name, ' ', last_name) as name_max_sum, sum(p.amount) as max_sum,
		 dense_rank() over (partition by country order by sum(p.amount) desc) as rank_max_sum	
	from country c4
    join city c3 on c3.country_id = c4.country_id 
    join address a on a.city_id = c3.city_id 
    join customer c on c.address_id = a.address_id
    join rental r on r.customer_id = c.customer_id 
    join payment p on p.rental_id = r.rental_id
    group by country, name_max_qntt) t
where rank_max_qntt = 1 or rank_max_sum = 1 
order by country



-- ??????????

select country, name_max_qntt, name_max_sum, name_last_cust
from (
	select country, concat(first_name, ' ', last_name) as name_max_qntt, count(r.rental_id) as qntt,
		 dense_rank() over (partition by country order by count(r.rental_id) desc) as rank_max_qntt,
		 concat(first_name, ' ', last_name) as name_max_sum, sum(p.amount) as max_sum,
		 dense_rank() over (partition by country order by sum(p.amount) desc) as rank_max_sum,
		 concat(c.first_name, ' ', c.last_name) as name_last_cust, p.payment_id,
		 dense_rank() over (partition by c4.country order by p.payment_id) as rank_last_payment
	from country c4
    join city c3 on c3.country_id = c4.country_id 
    join address a on a.city_id = c3.city_id 
    join customer c on c.address_id = a.address_id
    join rental r on r.customer_id = c.customer_id 
    join payment p on p.rental_id = r.rental_id
    group by country, name_max_qntt, p.payment_id--, c.first_name,c.last_name, p.payment_date --, name_max_qntt, p.payment_date--, name_max_sum, name_last_cust
    ) t
where rank_max_qntt = 1 or rank_max_sum = 1 or rank_last_payment = 1
order by country








