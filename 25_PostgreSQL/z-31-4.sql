--Задание 1. С помощью оконной функции выведите для каждого сотрудника сумму продаж за март 2007 
--года с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учета времени) с сортировкой по дате.
--Ожидаемый результат запроса: https://ibb.co/Kmc3wVP

select p.staff_id, payment_date, sum(amount) over (partition by p.staff_id, p.payment_date::date order by payment_date)
from payment p
where date_trunc('month', payment_date) = '01.03.2007'

select *--p.staff_id, payment_date, sum(amount) --over (partition by p.staff_id, p.payment_date::date order by payment_date)
from payment p
--where date_trunc('month', payment_date) = '01.03.2007'

--Задание 2. 10 апреля 2007 года в магазинах проходила акция: покупатель каждого сотого платежа 
--получал дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей, 
--которые в день проведения акции получили скидку.
--Ожидаемый результат запроса: https://ibb.co/tpg689v

select *
from (
	select p.customer_id, p.payment_date, row_number() over (order by p.payment_date)
	from payment p) t
where row_number%100 = 0 and payment_date::date = '10.04.2007'

--Задание 3. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
--· покупатель, арендовавший наибольшее количество фильмов;
--· покупатель, арендовавший фильмов на самую большую сумму;
--· покупатель, который последним арендовал фильм.
--Ожидаемый результат запроса: https://ibb.co/wMVzJ0N

explain analyze

with c1 as (
	select c.customer_id, c3.country_id, count(i.film_id), sum(p.amount), max(r.rental_date)
	from customer c
	join rental r on r.customer_id = c.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join payment p on p.rental_id = r.rental_id
	join address a on a.address_id = c.address_id
	join city c2 on c2.city_id = a.city_id
	join country c3 on c3.country_id = c2.country_id
	group by c.customer_id, c3.country_id),
c2 as (
	select customer_id, country_id,
		row_number () over (partition by country_id order by count desc) cf,
		row_number () over (partition by country_id order by sum desc) sa,
		row_number () over (partition by country_id order by max desc) md
	from c1
)
select c.country, c_1.customer_id, c_2.customer_id, c_3.customer_id
from country c
left join c2 c_1 on c_1.country_id = c.country_id and c_1.cf = 1
left join c2 c_2 on c_2.country_id = c.country_id and c_2.sa = 1
left join c2 c_3 on c_3.country_id = c.country_id and c_3.md = 1
order by 1

explain analyze

with c as (
	with c1 as (
		select c.customer_id, c3.country_id, count(i.film_id), sum(p.amount), max(r.rental_date),
		max(count(i.film_id)) over (partition by c3.country_id) mc, 
		max(sum(p.amount)) over (partition by c3.country_id) ma, 
		max(max(r.rental_date)) over (partition by c3.country_id) md,
		c3.country
		from customer c
		join rental r on r.customer_id = c.customer_id
		join inventory i on i.inventory_id = r.inventory_id
		join payment p on p.rental_id = r.rental_id
		join address a on a.address_id = c.address_id
		join city c2 on c2.city_id = a.city_id
		join country c3 on c3.country_id = c2.country_id
		group by c.customer_id, c3.country_id)
	select country_id, country,
		case 
			when count = mc then customer_id
		end a,
		case 
			when sum = ma then customer_id
		end b,
		case 
			when max = md then customer_id
		end c
	from c1)
select country.country, string_agg(a::text, ', '), string_agg(b::text, ', '), string_agg(c::text, ', ')
from country 
left join c on c.country_id = country.country_id
group by country.country

explain analyze

WITH t1 as(
SELECT cr.country
		,ag.customer_id
		,ag.customer_name
		,ag.pcount
		,ag.psum
		,ag.maxp_date
		,ag.maxpid
		,ag.maxr_date
		,ag.maxrid
FROM (
SELECT 
		c.customer_id,
		c.address_id 
		,concat(c.last_name,  ' ', c.first_name ) AS customer_name
		,count(r.rental_id) AS pcount
		,sum(p.amount) AS psum
		,MAX(p.payment_date) AS maxp_date
		,MAX(p.payment_id)  AS maxpid
		,MAX(r.rental_id)  AS maxrid
		,MAX(r.rental_date)  AS maxr_date
FROM customer c 
LEFT JOIN payment p ON c.customer_id = p.customer_id 
LEFT JOIN rental r ON r.customer_id = c.customer_id  AND r.rental_id = p.rental_id 
group BY c.customer_id 
) AS ag
JOIN address a ON ag.address_id = a.address_id 
JOIN city ct ON ct.city_id = a.city_id 
LEFT JOIN country cr ON cr.country_id = ct.country_id
),
t2 AS 
(SELECT t1.country
		,t1.customer_name
		,t1.pcount
		,max(t1.pcount) OVER(PARTITION BY t1.country) AS max_count 
		,t1.psum
		,max(t1.psum) OVER(PARTITION BY t1.country) AS max_sum 
--		,t1.maxp_date
--		,MAX(t1.maxp_date) OVER(PARTITION BY t1.country) AS max_payment_date
--		,t1.maxpid
--		,MAX(t1.maxpid) OVER(PARTITION BY t1.country) AS max_payment_id
		,t1.maxr_date
		,MAX(t1.maxr_date) OVER(PARTITION BY t1.country) AS max_rental_date
		,t1.maxrid
		,MAX(t1.maxrid) OVER(PARTITION BY t1.country) AS max_rental_id
FROM t1
 )
SELECT  * FROM 	
(SELECT t2.country, t2.customer_name AS "наибольшее количество фильмов" FROM t2 WHERE t2.pcount = t2.max_count )AS ct
JOIN 
(SELECT t2.country, t2.customer_name AS "на самую большую сумму" FROM t2 WHERE t2.psum = t2.max_sum )AS sm USING(country)
JOIN 
(SELECT t2.country, t2.customer_name AS "последним арендовал фильм" FROM t2 WHERE t2.maxrid = t2.max_rental_id)AS pd USING(country)
ORDER BY country 

explain analyze
WITH AGGREGATION_TABLE AS
         (
             SELECT  CSTM.FIRST_NAME || ' ' || CSTM.LAST_NAME AS FULL_NAME
                  , CNTR.COUNTRY
                  , COUNT(INV.FILM_ID)                       AS CNT_FILM
                  , SUM(P.AMOUNT)                            AS SUM_AMOUNT
                  , MAX(R.RENTAL_DATE)                       AS LAST_RENTAL
             FROM PUBLIC.PAYMENT        P
                  JOIN PUBLIC.RENTAL    R ON P.RENTAL_ID = R.RENTAL_ID
                  JOIN PUBLIC.INVENTORY INV ON R.INVENTORY_ID = INV.INVENTORY_ID
                  JOIN PUBLIC.CUSTOMER  CSTM ON CSTM.CUSTOMER_ID = P.CUSTOMER_ID
                  JOIN PUBLIC.ADDRESS   A ON A.ADDRESS_ID = CSTM.ADDRESS_ID
                  JOIN PUBLIC.CITY      CT ON A.CITY_ID = CT.CITY_ID
                  JOIN PUBLIC.COUNTRY   CNTR ON CT.COUNTRY_ID = CNTR.COUNTRY_ID
--              WHERE CNTR.COUNTRY = 'Algeria'
             GROUP BY CSTM.LAST_NAME, CSTM.FIRST_NAME, CNTR.COUNTRY
         )
, NUMBERING_TABLE AS
    (
        SELECT  COUNTRY
             , FULL_NAME
             , ROW_NUMBER() OVER (PARTITION BY COUNTRY ORDER BY CNT_FILM DESC )    AS RN_CNT_FILM
             , ROW_NUMBER() OVER (PARTITION BY COUNTRY ORDER BY SUM_AMOUNT DESC )  AS RN_SUM_AMOUNT
             , ROW_NUMBER() OVER (PARTITION BY COUNTRY ORDER BY LAST_RENTAL DESC ) AS RN_LAST_RENTAL
        FROM AGGREGATION_TABLE
    )
SELECT DISTINCT
       COUNTRY                                                                            AS "Страна"
    , max (CASE WHEN RN_CNT_FILM = 1 THEN FULL_NAME END ) OVER (PARTITION BY COUNTRY)     AS "Покупател, арендовавший наибольнее кол-во фильмов"
    , max (CASE WHEN RN_SUM_AMOUNT = 1 THEN FULL_NAME END ) OVER (PARTITION BY COUNTRY)   AS "Покупател, арендовавший фильмов на самую большую сумму"
    , max (CASE WHEN RN_LAST_RENTAL = 1 THEN FULL_NAME END ) OVER (PARTITION BY COUNTRY)  AS "Покупател, который последним арендовал фильм"
FROM NUMBERING_TABLE
ORDER BY COUNTRY;

--Задание 1. Откройте по ссылке SQL-запрос.
--· Сделайте explain analyze этого запроса.
--· Основываясь на описании запроса, найдите узкие места и опишите их.
--· Сравните с вашим запросом из основной части (если ваш запрос изначально укладывается в 15мс — отлично!).
--· Сделайте построчное описание explain analyze на русском языке оптимизированного запроса. 
--Описание строк в explain можно посмотреть по ссылке.

--Задание 2. Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже.
--Ожидаемый результат запроса: https://ibb.co/jZY6MWs

explain analyze
select *
from (
	select p.staff_id, p.payment_date, row_number() over (partition by p.staff_id order by p.payment_date)
	from payment p) t
where row_number = 1

explain analyze
select *
from (
	select p.staff_id, p.payment_date, min(p.payment_date) over (partition by p.staff_id)
	from payment p) t
where payment_date = min

--Задание 3. Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
--· день, в который арендовали больше всего фильмов (в формате год-месяц-день);
--· количество фильмов, взятых в аренду в этот день;
--· день, в который продали фильмов на наименьшую сумму (в формате год-месяц-день);
--· сумму продажи в этот день.
--Ожидаемый результат запроса: https://ibb.co/kgGD4KW

select t1.store_id, t1.date, t1.cnt, t2.date, t2.amount
from (select i.store_id, rental_date::date as date, count(i.film_id) as cnt,
	row_number() over (PARTITION BY store_id ORDER BY count(i.film_id) desc) rn
	from inventory i
	join rental r on i.inventory_id = r.inventory_id
	group by 1,2) t1 
join (select i2.store_id, payment_date::date as date, sum(amount) as amount, 
	row_number() over (PARTITION BY i2.store_id ORDER BY sum(amount)) rn
	from payment p
	join rental r2 on r2.rental_id = p.rental_id
	join inventory i2 on i2.inventory_id = r2.inventory_id
	group by 1,2) t2 on t1.store_id = t2.store_id
where t1.rn=1 and t2.rn=1


select *
from (
	select unnest(employees_id) 
	from projects p) t
join employee e on e.emp_id = t.unnest

select min(amount) filter (where payment_date::date = '01.03.2007'), 
	max(amount) filter (where payment_date::date = '02.03.2007')
from payment p

create extension tablefunc;

select *
from crosstab(
	'select customer_id, payment_date, amount
	from payment
	order by 1, 2') as ct(customer_id int2, a numeric, b numeric, c numeric, d numeric, e numeric)
	
select pg_typeof(customer_id), payment_date, pg_typeof(amount)
from payment
order by 1, 2

select *
from crosstab(
	'select customer_id, payment_date, min(amount), max(amount)
	from payment
	order by 1, 2') as ct(customer_id int2, a numeric, b numeric, c numeric, d numeric, e numeric)
	
select *
from crosstab(
	'select customer_id, date_trunc(''month'', payment_date), min(amount)
	from payment
	group by customer_id, date_trunc(''month'', payment_date)
	order by 1, 2') as ct(customer_id int2, a numeric, b numeric, c numeric, d numeric, e numeric)
	
select customer_id, date_trunc('month', payment_date), min(amount)
from payment
group by customer_id, date_trunc('month', payment_date)
order by 1, 2

--https://postgrespro.ru/docs/postgresql/12/tablefunc

CREATE TABLE cth(rowid text, rowdt timestamp, attribute text, val text);
INSERT INTO cth VALUES('test1','01 March 2003','temperature','42');
INSERT INTO cth VALUES('test1','01 March 2003','test_result','PASS');
INSERT INTO cth VALUES('test1','01 March 2003','volts','2.6987');
INSERT INTO cth VALUES('test2','02 March 2003','temperature','53');
INSERT INTO cth VALUES('test2','02 March 2003','test_result','FAIL');
INSERT INTO cth VALUES('test2','02 March 2003','test_startdate','01 March 2003');
INSERT INTO cth VALUES('test2','02 March 2003','volts','3.1234');

select * from c.cth

SELECT * FROM "dvd-rental".crosstab
(
  'SELECT rowid, rowdt, attribute, val FROM cth ORDER BY 1',
  'SELECT DISTINCT attribute FROM cth ORDER BY 1'
)
AS
(
       rowid text,
       rowdt timestamp,
       temperature int4,
       test_result text,
       test_startdate timestamp,
       volts float8
);

select *
from crosstab(
	'select customer_id, date_trunc(''month'', payment_date), date_trunc(''month'', payment_date), min(amount)
	from payment
	group by customer_id, date_trunc(''month'', payment_date)
	order by 1, 2',
	'select distinct date_trunc(''month'', payment_date)
	from payment
	order by 1') as ct(customer_id int2, date_trunc timestamp, a numeric, b numeric, c numeric, d numeric)
	
	select distinct pg_typeof(date_trunc('month', payment_date))
	from payment
	order by 1
	
CREATE TABLE connectby_tree(keyid text, parent_keyid text, pos int);

INSERT INTO connectby_tree VALUES('row1',NULL, 0);
INSERT INTO connectby_tree VALUES('row2','row1', 0);
INSERT INTO connectby_tree VALUES('row3','row1', 0);
INSERT INTO connectby_tree VALUES('row4','row2', 1);
INSERT INTO connectby_tree VALUES('row5','row2', 0);
INSERT INTO connectby_tree VALUES('row6','row4', 0);
INSERT INTO connectby_tree VALUES('row7','row3', 0);
INSERT INTO connectby_tree VALUES('row8','row6', 0);
INSERT INTO connectby_tree VALUES('row9','row5', 0);

select pg_typeof(id),  pg_typeof(parent_id) 
from geo 

explain analyze
SELECT * 
FROM "dvd-rental".connectby('geo', 'id', 'parent_id', '1', 0, '~')
 AS t(keyid int, parent_keyid int, level int, branch text);
