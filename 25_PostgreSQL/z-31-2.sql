select city, country
from city d
join country c on c.country_id = d.country_id

explain analyze

select s.store_id, postal_code, country, city, district, address, address2, phone
from store s
left join address using(address_id) --on s.address_id = a.address_id
left join city using(city_id)
left join country using(country_id)
join customer c on c.store_id = s.store_id
join rental r on r.customer_id = c.customer_id
where city_id = 576

-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.

select c.store_id as "ID магазина", count(1) as "Количество покупателей", 
       ct.city as "Город магазина", s.last_name ||' '|| s.first_name as "Фамилия и имя продавца"
from customer c 
join store st on c.store_id = st.store_id 
join staff s on st.store_id = s.store_id 
join address a on st.address_id = a.address_id
join city ct on a.city_id = ct.city_id 
group by c.store_id, s.staff_id, ct.city_id
having count(1) > 300

классический DDL :) 

select * from film f

primary key = unique + not null + index 

select * from film_actor fa

primary key (actor_id, film_id) = unique (actor_id, film_id) + not null + index

create table film_new (like "dvd-rental".film including defaults)

select c.store_id as "ID магазина", count(1) as "Количество покупателей", ct.city as "Город магазина", 
s.last_name ||' '|| s.first_name as "Фамилия и имя продавца"
from customer c 
join store st on c.store_id = st.store_id 
join staff s on st.store_id = s.store_id 
join address a on st.address_id = a.address_id
join city ct on a.city_id = ct.city_id 
group by c.store_id, s.first_name, s.last_name, ct.city

select f.title as "Название", f.rating as "Рейтинг", c.name as "Жанр", 
       f.release_year::text as "Год выпуска", l.name as "Язык", count(r.rental_id) as "Количество аренд",
       sum(p.amount) as "Общая стоимость аренды" 
from film f 
left join film_category fc on fc.film_id = f.film_id 
left join category c on c.category_id = fc.category_id 
left join "language" l on l.language_id = f.language_id  
left join inventory i on i.film_id  = f.film_id 
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id 
group by f.film_id, c.category_id, l.language_id   
having count(r.rental_id) = 0 -- добавила, не работает, ничего не выводит
order by f.title
