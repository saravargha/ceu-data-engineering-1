use birdstrikes;
select * from birdstrikes;

-- exercise 1
create table employee
(id integer not null,
employee_name varchar(255) not null,
primary key(id));

-- excercise 2
select * from birdstrikes limit 144,1;
-- Tennessee

-- excercise 3
select distinct flight_date from birdstrikes order by flight_date desc limit 1;
-- 2000-04-18 is the  flight_date of the latest birstrike in this database

-- excercise 4
select distinct cost from birdstrikes order by cost desc limit 49,1;
-- 5345 was the cost of the 50th most expensive damage

-- excercise 5
select distinct(state) from birdstrikes where state !='' and bird_size!='';
-- Colorado

-- excercise 6 
select flight_date from birdstrikes where state='Colorado' and weekofyear(flight_date)=52;
-- 2000-01-01 is the date of the flight
select datediff('2000-01-01', now());
-- 7939 days elapsed between the current date (Sept 26 2021) and the flights happening in week 52, for incidents from Colorado







