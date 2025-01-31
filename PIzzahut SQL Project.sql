create database pizzahut;

create table orders_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id));


-- Question Begineer Basic
-- Retrive the total number of orders placed.
select count(order_id) from orders;


-- Calculate total revenue generated from pizza sales
SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;
    
    
-- Identify the highest priced pizza
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- identify most common pizza size ordered
SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;


-- list the top 5 most ordered pizza type along with their quantities
SELECT 
    pizza_types.name, SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

SELECT 
    pizzas.pizza_type_id,
    COUNT(orders_details.order_id) order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_type_id
ORDER BY order_count DESC
LIMIT 5;

-- Intermediate 
-- use join to calculate total quantity of each pizza category ordered
SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;


-- Determine the distribution of orders by hour of the days
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hour;


-- event tables to find the category wise distribution of pizzas
SELECT 
    pizza_types.category AS category, COUNT(pizza_type_id)
FROM
    pizza_types
GROUP BY category;


-- group the orders by date and calculate the average number of pizzas ordered per day
SELECT 
    ROUND(AVG(quantity), 2) AS avg_quantity
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quantity) AS quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
    
-- determine top 3 most ordered pizza types based on revenue
SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- Advance
-- calculate the percentage contribution of each pizza type to total revenue
SELECT 
    pizza_types.category,
    ROUND(SUM(orders_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(orders_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    orders_details
                        JOIN
                    pizzas ON orders_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;


-- Analyse cumulative revenue genenrated over time
select order_date,
sum(revenue) over (order by order_date)as cum_revenue
from
(select orders.order_date, 
sum(orders_details.quantity*pizzas.price) as revenue
from orders_details join pizzas
on orders_details.pizza_id=pizzas.pizza_id
join orders
on orders.order_id=orders_details.order_id
group by orders.order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category
select category,name, revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc)as rn
from
(select pizza_types.category, pizza_types.name, 
sum(orders_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id=pizzas.pizza_id
group by pizza_types.category,pizza_types.name) as a) as b
where rn<=3;