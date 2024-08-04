-- 1. What is the total amount each customer spent at the restaurant?
select  customer_id, sum(price) as price
	from sales s 
	join menu m on s.product_id = m.product_id
	group by customer_id
	order by customer_id; 

-- 2. How many days has each customer visited the restaurant?
select customer_id, count(order_date)
	from sales
	group by customer_id
	order by customer_id;

-- 3. What was the first item from the menu purchased by each customer?
select customer_id, order_date,product_name
	from sales s join menu m
	on s.product_id = m.product_id
	where order_date = (select min(order_date) from sales);

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select top 1 m.product_name,s.product_id, count(s.product_id) as counts 
	from sales as s join menu as m
	on s.product_id = m.product_id
	group by s.product_id,m.product_name
	order by counts desc;
	
-- 5. Which item was the most popular for each customer?
with CTE as
(
	select m.product_name,
	s.customer_id, 
	s.product_id,
	count(s.product_id) as counts,
	rank() over(partition by customer_id order by count(s.product_id) desc) as rnk
	from sales as s join menu as m on s.product_id = m.product_id
	group by m.product_name,s.customer_id,s.product_id
	)
select product_name,customer_id from CTE 
where rnk =1;

-- 6. Which item was purchased first by the customer after they became a member?
with CTE as
(
	select s.customer_id,m.product_name,mm.join_date,s.order_date,
	rank()over(partition by s.customer_id order by s.order_date) as rnk
	from members as mm
	join sales as s on mm.customer_id = s.customer_id
	join menu as m on s.product_id = m.product_id
	where mm.join_date < s.order_date
	)
select * from CTE where rnk = 1;

-- 7. Which item was purchased just before the customer became a member?
with CTE as
(
	select s.customer_id,m.product_name,mm.join_date,s.order_date,
	rank()over(partition by s.customer_id order by s.order_date desc) as rnk 
	from members as mm
	join sales as s on mm.customer_id = s.customer_id
	join menu as m on s.product_id = m.product_id
	where mm.join_date > s.order_date
	)
select * from CTE where rnk = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
select s.customer_id,count(s.product_id) as products_count,sum(m.price) as total_amt_spent
	from members as mm
	join sales as s on mm.customer_id = s.customer_id
	join menu as m on s.product_id = m.product_id
	where mm.join_date > s.order_date
	group by s.customer_id
	order by s.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with CTE as
(
	select s.customer_id,s.order_date,s.product_id,m.product_name,m.price,
	case
	when product_name = 'sushi' then price*10*2
	else price*10
	end as points
	from sales s 
	join menu m 
	on s.product_id = m.product_id
	)
	select customer_id, sum(points) as total_points from CTE
	group by customer_id
	order by customer_id;

-- 10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
--    not just sushi - how many points do customer A and B have at the end of January?
with CTE as
(
	select s.customer_id, mm.join_date, s.order_date, m.price, 
	case
	when s.order_date between mm.join_date and DATEADD(DAY, 6, mm.join_date) then price*10*2
	when product_name = 'sushi' then price*10*2
	else price*10
	end as points
	from sales as s 
	join menu as m on s.product_id = m.product_id
	join members as mm on s.customer_id = mm.customer_id
	where s.order_date between '2021-01-01' and '2021-01-31'
	)
select customer_id , sum(points) as Points from CTE
	where customer_id = 'A' or  customer_id = 'B'
	group by customer_id;