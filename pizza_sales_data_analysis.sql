-- Retrieve the total number of orders placed.

select count(order_id) as total_order
from orders; 

-- calculate the total revenue generated from pizza sales.

select round(SUM(order_details.quantity * pizzas.price),2) as total_order_value
from orders
JOIN order_details
	ON orders.order_id = order_details.order_id
		JOIN pizzas
			ON order_details.pizza_id = pizzas.pizza_id
;

-- Identify the highest-priced pizza.

select pizza_types. `name`, pizzas.price
from pizza_types
JOIN pizzas
	ON pizza_types.pizza_type_id = pizzas.pizza_type_id
order by 2 desc
limit 1
;

-- Identify the most common pizza size ordered.

select pizzas.size, count(order_details.order_details_id)
from pizzas
JOIN order_details
	ON pizzas.pizza_id = order_details.pizza_id
group by 1
order by 2 desc
;

-- List the top 5 most ordered pizza types along with their quantities.

select pizza_types.`name`, SUM(order_details.quantity)
from pizza_types
JOIN pizzas
	ON pizza_types.pizza_type_id = pizzas.pizza_type_id
		JOIN order_details
			ON pizzas.pizza_id = order_details.pizza_id
group by 1
order by 2 desc
limit 5
;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category, SUM(order_details.quantity)
from pizza_types
JOIN pizzas
	ON pizza_types.pizza_type_id = pizzas.pizza_type_id
		JOIN order_details
			ON pizzas.pizza_id = order_details.pizza_id
group by 1
order by 2 desc
;

-- Determine the distribution of orders by hour of the day.

select hour(orders.`time`), SUM(order_details.quantity)
from orders
JOIN order_details 
	ON orders.order_id = order_details.order_id
group by 1
order by 2 desc
;

-- Join relevant tables to find the category-wise distribution of pizzas.

select category, count(name)
from pizza_types
group by 1
order by 2 desc;

-- Group the orders by date and calculate the average number of pizzas ordered per day.


with order_quantity as
(
select orders.`date`, SUM(order_details.quantity) as quantity
from orders
JOIN order_details 
	ON orders.order_id = order_details.order_id
group by 1
order by 2 desc
)
select round(avg(quantity),0)
from order_quantity;
;

-- Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.`name`, SUM(pizzas.price * order_details.quantity)
from pizza_types
JOIN pizzas
	ON pizza_types.pizza_type_id = pizzas.pizza_type_id
		JOIN order_details
			ON pizzas.pizza_id = order_details.pizza_id
group by 1
order by 2 desc
limit 3
;

-- Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category, round(SUM(pizzas.price * order_details.quantity)/(select round(SUM(order_details.quantity * pizzas.price),2) as total_order_value
from orders
JOIN order_details
	ON orders.order_id = order_details.order_id
		JOIN pizzas
			ON order_details.pizza_id = pizzas.pizza_id
)*100,2) as revenue
from pizza_types
JOIN pizzas
	ON pizza_types.pizza_type_id = pizzas.pizza_type_id
		JOIN order_details
			ON pizzas.pizza_id = order_details.pizza_id
group by 1
order by 2 desc
;


-- Analyze the cumulative revenue generated over time.

with revenue_daywise as
(select orders.`date`,
round(sum(pizzas.price * order_details.quantity),2) as revenue
from orders
JOIN order_details
	ON orders.order_id = order_details.order_id
		JOIN pizzas
			ON order_details.pizza_id = pizzas.pizza_id
group by 1)

select * , round(sum(revenue) over(order by revenue_daywise.date),2) as cum_revenue
from revenue_daywise
;

