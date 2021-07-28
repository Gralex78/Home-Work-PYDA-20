--=============== ������ 3. ������ SQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ��� ������� ���������� ��� ����� ����������, 
--����� � ������ ����������.

select c.last_name ||' '|| c.first_name as "������� � ���", a.address as "�����", c2.city as "�����", c3.country as "������"
from customer c 
left join address a on c.address_id = a.address_id
left join city c2 on a.city_id = c2.city_id 
left join country c3 on c2.country_id = c3.country_id 



--������� �2
--� ������� SQL-������� ���������� ��� ������� �������� ���������� ��� �����������.

select store_id as "ID ��������", count(customer_id) as "���������� �����������"
from customer c
group by store_id


--����������� ������ � �������� ������ �� ��������, 
--� ������� ���������� ����������� ������ 300-��.
--��� ������� ����������� ���������� �� ��������������� ������� 
--� �������������� ������� ���������.

select store_id as "ID ��������", count(customer_id) as "���������� �����������"
from customer c
group by store_id
having count(customer_id) > 300



-- ����������� ������, ������� � ���� ���������� � ������ ��������, 
--� ����� ������� � ��� ��������, ������� �������� � ���� ��������.

select s.store_id as "ID ��������", count(customer_id) as "���������� �����������", 
       c.city as "����� ��������", concat(s2.last_name, ' ', s2.first_name) as "������� � ��� ��������"
from store s 
left join address a on s.address_id = a.address_id 
left join city c on a.city_id = c.city_id
left join staff s2 on s.store_id = s2.store_id
left join customer c2 on c2.store_id = s2.store_id
group by concat(s2.last_name, ' ', s2.first_name), s.store_id, c.city 
having count(customer_id) > 300



--������� �3
--�������� ���-5 �����������, 
--������� ����� � ������ �� �� ����� ���������� ���������� �������

select concat(c.last_name, ' ', c.first_name) as "������� � ��� ����������", count(r.rental_id) as "���������� �������"
from customer c 
left join rental r on r.customer_id = c.customer_id 
group by concat(c.last_name, ' ', c.first_name)
order by count(r.rental_id) desc
limit(5)



--������� �4
--���������� ��� ������� ���������� 4 ������������� ����������:
--  1. ���������� �������, ������� �� ���� � ������
--  2. ����� ��������� �������� �� ������ ���� ������� (�������� ��������� �� ������ �����)
--  3. ����������� �������� ������� �� ������ ������
--  4. ������������ �������� ������� �� ������ ������

select concat(c.last_name, ' ', c.first_name) as last_first_name, count(r.rental_id) as quantity_films, 
       round(sum(p.amount)) as total_payment, min(p.amount) as min_payment, max(p.amount) as max_payment
from payment p
left join customer c on c.customer_id = p.customer_id
left join rental r on r.rental_id = p.rental_id
group by last_first_name
having min(p.amount) > 0


--������� �5
--��������� ������ �� ������� ������� ��������� ����� �������� ������������ ���� ������� ����� �������,
 --����� � ���������� �� ���� ��� � ����������� ���������� �������. 
 --��� ������� ���������� ������������ ��������� ������������.
 
select a.city, b.city
from city a
cross join city b
where a.city < b.city

--������� �6
--��������� ������ �� ������� rental � ���� ������ ������ � ������ (���� rental_date)
--� ���� �������� ������ (���� return_date), 
--��������� ��� ������� ���������� ������� ���������� ����, �� ������� ���������� ���������� ������.
 
select customer_id, round(avg(date(return_date) - date(rental_date)), 2) as average_days_for_rent
from rental 
group by customer_id
order by customer_id



--======== �������������� ����� ==============

--������� �1
--���������� ��� ������� ������ ������� ��� ��� ����� � ������ � �������� ����� ��������� ������ ������ �� �� �����.

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



--������� �2
--����������� ������ �� ����������� ������� � �������� � ������� ������� ������, ������� �� ���� �� ����� � ������.

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



--������� �3
--���������� ���������� ������, ����������� ������ ���������. �������� ����������� ������� "������".
--���� ���������� ������ ��������� 7300, �� �������� � ������� ����� "��", ����� ������ ���� �������� "���".


select staff_id, count(rental_id),
  case 
     when count(rental_id) > 7300 then 'YES'
     else 'NO'
  end as premium
from payment p 
group by staff_id




