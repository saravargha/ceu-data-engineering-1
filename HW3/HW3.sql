use birdstrikes;

-- excercise 1 --> there are two IFs!!!!!
select aircraft, airline, speed,
	if (speed<100 or speed is null, 'LOW SPEED', 'HIGH SPEED') as speed_category
from birdstrikes
order by speed_category;

-- exercise 2
select count(distinct aircraft) from birdstrikes;
-- 3

-- excercise 3
select min(speed), aircraft from birdstrikes where aircraft like "h%";
-- 9

-- excercise 4 Which phase_of_flight has the least of incidents?
select phase_of_flight, count(*) as count_incidents from birdstrikes group by phase_of_flight order by count_incidents asc limit 1;
-- taxi 2

-- excercise 5 What is the rounded highest average cost by phase_of_flight?
select phase_of_flight, round(avg(cost)) as avg_cost from birdstrikes group by phase_of_flight order by avg_cost desc limit 1;
-- climb 54673

-- excercise 6 What the highest AVG speed of the states with names less than 5 characters?
select avg(speed) as avg_speed, state from birdstrikes where length(state)<5 group by state order by avg_speed desc limit 1;
-- 2862.5 from iowa