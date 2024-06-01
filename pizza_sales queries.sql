CREATE DATABASE pizzahut;
USE pizzahut;
 
CREATE TABLE orders(
order_id INT NOT NULL PRIMARY KEY ,
order_date DATE NOT NULL,
order_time TIME NOT NULL );

CREATE TABLE order_details(
order_details_id INT NOT NULL PRIMARY KEY,
order_id INT NOT NULL,
pizza_id TEXT NOT NULL,
quantity INT NOT NULL);

-- Retrieve the total number of orders placed. --
SELECT COUNT(order_id) AS total_orders
FROM orders;



-- Calculate the total revenue generated from pizza sales.--
 SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
 
 -- Identify the highest-priced pizza.--
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;
 
 -- Identify the most common pizza size ordered.--
 SELECT pizzas.size , COUNT(order_details.order_details_id) AS order_count
 FROM pizzas
 JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
 GROUP BY pizzas.size
 ORDER BY order_count DESC;
 
 -- List the top 5 most ordered pizza types along with their quantities.-- 
SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS order_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY order_quantity DESC
LIMIT 5;
 
 -- Join the necessary tables to find the total quantity of each pizza category ordered.--
 SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC
LIMIT 4;

-- Determine the distribution of orders by hour of the day.--
SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time);

 -- Join relevant tables to find the category-wise distribution of pizzas.--
 SELECT 
    COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the  number of pizzas ordered per day.--
SELECT 
    orders.order_date, SUM(order_details.quantity)
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
GROUP BY orders.order_date ;
 
 -- Determine the top 3 most ordered pizza types based on revenue.-- 
 SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;
 
 -- Calculate the  contribution of each pizza type to total revenue.--
 SELECT pizza_types.category, SUM(order_details.quantity*pizzas.price)  AS revenue
 FROM pizza_types 
 JOIN pizzas
 ON pizza_types.pizza_type_id = pizzas.pizza_type_id
 JOIN order_details
 ON order_details.pizza_id = pizzas.pizza_id
 GROUP BY pizza_types.category 
 ORDER BY revenue desc;
 
 -- Analyze the cumulative revenue generated over time.--
 SELECT order_date,
 SUM(revenue) OVER (order by order_date) AS cum_revenue
 FROM
 (SELECT orders.order_date,
 SUM(order_details.quantity * pizzas.price) AS revenue
 FROM order_details 
 JOIN pizzas
 ON order_details.pizza_id = pizzas.pizza_id
 JOIN orders
 ON orders.order_id =order_details.order_id
 GROUP BY orders.order_date ) AS sales;
 
 -- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
 SELECT name ,revenue 
 FROM 
(SELECT 
    category, 
    name, 
    revenue,
    RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
FROM (
    SELECT 
        pizza_types.category,
        pizza_types.name,
        SUM(order_details.quantity) * pizzas.price AS revenue
    FROM 
        pizza_types 
    JOIN 
        pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN 
        order_details ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY 
        pizza_types.category, 
        pizza_types.name, 
        pizzas.price
) AS a) AS b
WHERE rn <= 3;  -- First I found out the whole value, secondly we gave ranking since we cant use ranking directly so make a subquery -- 
