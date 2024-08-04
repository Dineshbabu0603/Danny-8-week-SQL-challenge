--How many pizzas were ordered?
select count(*) from customer_orders;

--How many unique customer orders were made?
select  count(distinct order_id) from customer_orders;

--How many successful orders were delivered by each runner?
select r.runner_id,count(distinct c.order_id)
	from customer_orders c
	join runner_orders r
	on c.order_id = r.order_id
	where r.pickup_time != 'null'
	group by r.runner_id;

--How many of each type of pizza was delivered?
select c.pizza_id,pn.pizza_name,count(c.order_id)
	from customer_orders c
	join runner_orders r
	on c.order_id = r.order_id
	join pizza_names pn
	on c.pizza_id = pn.pizza_id
	where r.pickup_time != 'null'
	group by c.pizza_id,pn.pizza_name;

--How many Vegetarian and Meatlovers were ordered by each customer?
select c.customer_id, pn.pizza_name, count(c.pizza_id) as pizza_ordered
	from customer_orders as c 
	inner join pizza_names as pn
	on c.pizza_id = pn.pizza_id
	group by c.customer_id, pn.pizza_name 
	order by c.customer_id;

--What was the maximum number of pizzas delivered in a single order?
select c.order_id,count(c.order_id)
	from customer_orders c
	join runner_orders r
	on c.order_id = r.order_id
	join pizza_names pn
	on c.pizza_id = pn.pizza_id
	where r.pickup_time != 'null'
	group by c.order_id
	order by count(c.order_id) desc
	limit 1;

--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select
	sum(case when exclusions is not null or extras is not null then 1 else 0 end) as changes,
	sum(case when exclusions is null and extras is null then 1 else 0 end) as no_changes
	from customer_orders c 
	inner join runner_orders r 
	on c.order_id = r.order_id
	where r.pickup_time != 'null';

--How many pizzas were delivered that had both exclusions and extras?
select pizza_id,
	sum(case when exclusions is not null and extras is not null then 1 else 0 end) as No_of_pizzas
	from customer_orders c 
	inner join runner_orders r 
	on c.order_id = r.order_id
	where r.pickup_time != 'null' and exclusions <> 'null' AND extras <> 'null'
	group by pizza_id;

--What was the total volume of pizzas ordered for each hour of the day?
select order_time,date_part('hour', order_time) as hour_sale, count(pizza_id) 
	from customer_orders
	group by order_time,hour_sale
	order by order_time;

--What was the volume of orders for each day of the week?
select date_part('dow', order_time) as day,
	TO_CHAR(order_time, 'Day') AS day_name,
	count(pizza_id)
	from customer_orders
	group by day,day_name
	order by day;




