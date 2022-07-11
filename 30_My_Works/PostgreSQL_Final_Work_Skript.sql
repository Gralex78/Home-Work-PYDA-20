
-- ИТОГОВАЯ РАБОТА --

-- ЗАДАНИЕ 1 --
-- В каких городах больше одного аэропорта? 

select city
from airports a 
group by city
having count(airport_code) > 1





-- ЗАДАНИЕ 2 --
-- В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета? 
-- (Подзапрос)

select a.airport_name 
from airports a
join flights f on a.airport_code = f.departure_airport
join aircrafts a2 using(aircraft_code)
where a2."range" = (select max("range") 
				    from aircrafts a)
group by a.airport_name





-- ЗАДАНИЕ 3 --
-- Вывести 10 рейсов с максимальным временем задержки вылета 
-- (Оператор LIMIT)

select t.flight_no, t.delay
from (
	select (actual_departure - scheduled_departure) as delay, flight_no 
	from flights f) t
where t.delay is not null
order by t.delay desc
limit 10





-- ЗАДАНИЕ 4 --
-- Были ли брони, по которым не были получены посадочные талоны? 
-- (Верный тип JOIN)

select b.book_ref, t.ticket_no, bp.boarding_no 
from bookings b
left join tickets t using(book_ref)
left join ticket_flights tf using(ticket_no)
left join boarding_passes bp using(ticket_no)
where boarding_no is null
group by b.book_ref, t.ticket_no, bp.boarding_no
order by b.book_ref 

-- Ответ: ДА, были





-- ЗАДАНИЕ 5 --
-- Найдите свободные места для каждого рейса, их % отношение к общему количеству мест в самолете.
-- Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день. 
-- Т.е. в этом столбце должна отражаться накопительная сумма - сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах за день.
-- (Оконная функция, Подзапросы или cte)

with cte_1 as ( 
	select flight_id, aircraft_code, actual_departure, departure_airport 
	from flights),
cte_2 as (
	select flight_id, count(seat_no) as quantity_seats_use
	from boarding_passes
	group by flight_id),
cte_3 as (
	select aircraft_code, count(seat_no) as quantity_seats_total  
 	from seats
 	group by aircraft_code),
cte_4 as (
	select airport_name, airport_code 
	from airports a3)
select c1.flight_id, c3.quantity_seats_total, c2.quantity_seats_use, (c3.quantity_seats_total - c2.quantity_seats_use) as vocant_seats,
	((c3.quantity_seats_total - c2.quantity_seats_use) * 100 / c3.quantity_seats_total) as "proportion, %", c4.airport_name, 
	date_trunc('day', c1.actual_departure) as day_departure,
	sum(c2.quantity_seats_use) over (partition by c4.airport_name, date_trunc('day', c1.actual_departure) order by c4.airport_name, c1.actual_departure)
from cte_1 c1
join cte_2 c2 on c2.flight_id = c1.flight_id
join cte_3 c3 on c3.aircraft_code = c1.aircraft_code
join cte_4 c4 on c1.departure_airport = c4.airport_code
group by c1.flight_id, c4.airport_name, c2.quantity_seats_use, c3.quantity_seats_total, c1.actual_departure
order by c4.airport_name, day_departure

-- Таблицу flights обогащаю данными по количеству мест в соответствующих самолетах из таблицы seats, 
-- затем обогащаю данными по количеству мест, на которые выданы посадочные талоны из таблицы boarding_passes,
-- в основном select, отдельной колонкой (vocant_seats), считаю разницу и получаю количество свободных мест,
-- затем в колонке "proportion, %" вывожу отношение свободных мест к общему количеству мест в самолетах,
-- с помощью оконной функции добавляю столбец sum с накоплением количества вывезенных пассажиров из каждого аэропорта на каждый день 





-- ЗАДАНИЕ 6 --
-- Найдите процентное соотношение перелетов по типам самолетов от общего количества. 
-- (Подзапрос, Оператор ROUND)

select a.model,  
	round(t.quantity_of_bords * 100 / sum(t.quantity_of_bords) over ()) as "proportion, %"
from (
	select aircraft_code, count(aircraft_code) as quantity_of_bords  
	from flights f 
	group by aircraft_code
	order by aircraft_code) t
	join aircrafts a on t.aircraft_code = a.aircraft_code 
order by "proportion, %"

-- Подзапросом вычисляю общие количества перелетов самолетов по типам,
-- в select, отдельным столбцом (proportion, %), вычисляю их отночение к общему количеству перелетов  





-- ЗАДАНИЕ 7 --
-- Были ли города, в которые можно добраться бизнес-классом дешевле, чем эконом-классом в рамках перелета? 
-- (CTE)

with cte_1 as ( 
	select city, airport_name, airport_code
	from airports),
cte_2 as (
	select arrival_airport, flight_id, flight_no
	from flights),
cte_3 as (
	select flight_id, fare_conditions, amount, rn  
 	from (
		select flight_id, fare_conditions, amount,
			row_number() over (partition by flight_id order by amount desc) as rn
		from ticket_flights tf
		group by flight_id, fare_conditions, amount) t
	where fare_conditions = 'Business' and rn != 1
	group by flight_id, fare_conditions, amount, rn)
select c1.city, c1.airport_name
from cte_1 c1
join cte_2 c2 on c2.arrival_airport = c1.airport_code
join cte_3 c3 on c3.flight_id = c2.flight_id

-- Ответ: НЕТ, не было таких городов

-- Подзапросом в CTE_3 помечаю наибольшие стоимости билетов по перелетам,
-- с помощью where фильтрую строки со значением бизнес-класс.




-- ЗАДАНИЕ 8 --
-- Между какими городами нет прямых рейсов? 
-- (Декартово произведение в предложении FROM, Самостоятельно созданные представления, Оператор EXCEPT)

select a.city as dep_city, b.city as arr_city
from airports a 
cross join airports b
where a.city < b.city
except
select departure_city, arrival_city 
from routes r
group by departure_city, arrival_city

-- В первом запросе, декартовым произведением, формирую пары городов, в которых есть аэропорты,
-- во втором - города, между которыми есть прямые рейсы,
-- вичитаю из первого запроса второй и получаю города между которыми нет прямых рейсов.


create view no_direct_flights as
select a.city as dep_city, b.city as arr_city
from airports a 
cross join airports b
where a.city < b.city
except
select departure_city, arrival_city 
from routes r
group by departure_city, arrival_city

select * from no_direct_flights

create materialized view city_no_direct_flights as
select a.city as dep_city, b.city as arr_city
from airports a 
cross join airports b
where a.city < b.city
except
select departure_city, arrival_city 
from routes r
group by departure_city, arrival_city
with data

refresh materialized view city_no_direct_flights

select * from city_no_direct_flights





-- ЗАДАНИЕ 9 --
-- Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной дальностью перелетов в самолетах, обслуживающих эти рейсы *
-- (Оператор RADIANS или использование sind/cosd, CASE)

select t.departure_airport_name, t.arrival_airport_name, 
	round(acos(sin(radians(t.latitude)) * sin(radians(a.latitude)) + cos(radians(t.latitude)) * cos(radians(a.latitude)) * 
		cos(radians(t.longitude) - radians(a.longitude))) * 6371) as "distance, km",
	a2.model, a2."range",
		case
			when round(acos(sin(radians(t.latitude)) * sin(radians(a.latitude)) + cos(radians(t.latitude)) * cos(radians(a.latitude)) * 
				cos(radians(t.longitude) - radians(a.longitude))) * 6371) < a2."range" then 'В пределах нормы'
			when round(acos(sin(radians(t.latitude)) * sin(radians(a.latitude)) + cos(radians(t.latitude)) * cos(radians(a.latitude)) * 
				cos(radians(t.longitude) - radians(a.longitude))) * 6371) = a2."range" then 'Критично'
			else 'Не допустимо'
		end
from (
	select r.flight_no, r.departure_airport_name, r.departure_airport, a.longitude, a.latitude, r.arrival_airport_name, r.arrival_airport 
	from routes r
	join airports a on a.airport_code = r.departure_airport) t
	join airports a on a.airport_code = t.arrival_airport
	join flights f on t.flight_no = f.flight_no 
	join aircrafts a2 on f.aircraft_code = a2.aircraft_code
where departure_airport_name < arrival_airport_name
group by t.departure_airport_name, t.longitude, t.latitude, t.arrival_airport_name, a.longitude, a.latitude, a2.model, a2."range"


-- Подзапросом обогощаю данные таблицы routes координатами аэропортов отправления из таблицы airports,
-- затем с помощью join обогощаю данные кооординаты аэропортов прибытия из той же таблицы airports,
-- затем с помощью join обогщаю данные всеми перелетами из таблицы flights и типами самолетов 
-- и их максимальными дальностями перелетов из таблицы aircrafts,
-- в основном select столбцом "distance, km" считаю расстояние между аэропортами,
-- с помощью оператора case сравниваю с допустимой максимальной дальностью перелетов в самолетах, обслуживающих эти рейсы 






