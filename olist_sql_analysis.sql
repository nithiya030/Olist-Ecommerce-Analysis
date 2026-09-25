-- =====================================================================
-- Olist E-Commerce Dataset: SQL Analysis
-- Schema setup, data quality checks, and business question queries
-- =====================================================================

-- =====================================================================
-- SCHEMA SETUP
-- =====================================================================

CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);

CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

select * from  customers limit 5;
select * from  orders limit 5;

CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2)
);

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);

CREATE TABLE payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value NUMERIC(10,2)
);

DROP TABLE reviews;

CREATE TABLE reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);
select * from reviews limit 5;

CREATE TABLE category_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);

SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM sellers;
SELECT COUNT(*) FROM payments;
SELECT COUNT(*) FROM reviews;
SELECT COUNT(*) FROM category_translation;

-- =====================================================================
-- DATA QUALITY CHECKS
-- =====================================================================

-- Duplicate primary keys

-- Customers Table
SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Orders Table
select order_id,count(*) 
from orders
group by(order_id)
having count(*)>1

-- Products Table
SELECT product_id, COUNT(*)
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Sellers Table
SELECT seller_id, COUNT(*)
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

SELECT
    order_id,
    payment_sequential,
    COUNT(*)
FROM payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

SELECT
    order_id,
    order_item_id,
    COUNT(*)
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

SELECT
    review_id,
    order_id,
    COUNT(*)
FROM reviews
GROUP BY review_id, order_id
HAVING COUNT(*) > 1;

SELECT
    product_category_name,
    COUNT(*)
FROM category_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;

-- check null values in orders table

select
count(*) filter (where customer_id is null) as customer, 
count(*) filter (where order_purchase_timestamp is null) as purchase_date,
count(*) filter (where order_status is null) as status,
count(*) filter (where order_approved_at is null) as approved_date,
count(*) filter (where order_delivered_customer_date is null) as delivered_date
from orders;

SELECT
    order_status,
    COUNT(*)
FROM orders
WHERE order_approved_at IS NULL
GROUP BY order_status;

select * from orders where order_approved_at is null and order_status='delivered';

select 
count(*) filter(where order_id is null) as order_id,
count(*) filter(where payment_value is null) as payment
from payments;

select o.order_id,o.order_status,p.payment_value
from orders o
left join payments p
on o.order_id=p.order_id
where order_status='canceled';

select distinct order_status from orders;

-- =====================================================================
-- BUSINESS QUESTIONS: SALES & REVENUE
-- =====================================================================

-- How has monthly revenue changed over time? Is the business growing steadily?

select date(date_trunc('month',o.order_purchase_timestamp)) as months, sum(p.payment_value) as monthly_revenue
from orders o
inner join payments p
on o.order_id=p.order_id
where o.order_status='delivered'
group by(date_trunc('month',o.order_purchase_timestamp))
order by months;

-- Which product categories contribute the most revenue?
with category_ranking as (
select ct.product_category_name_english as category,sum(oi.price) as total_revenue,rank() over(order by sum(oi.price) desc) as rnk
from order_items oi
inner join products prd
on oi.product_id=prd.product_id
inner join category_translation ct
on prd.product_category_name=ct.product_category_name
group by ct.product_category_name_english)

select category,total_revenue from category_ranking where rnk=1;

-- Revenue percentage of each category

with category_revenue as(
select ct.product_category_name_english as category,sum(oi.price) as total_revenue
from order_items oi
inner join products prd
on oi.product_id=prd.product_id
inner join category_translation ct
on prd.product_category_name=ct.product_category_name
group by ct.product_category_name_english
order by sum(oi.price) desc
)
, total_category_revenue as(
select category,total_revenue,sum(total_revenue) over () as total from category_revenue
)
select category, total_revenue, round(total_revenue/total*100,2) as revenue_percentage from total_category_revenue;

-- Average order value and number of orders per month

select date(date_trunc('month',o.order_purchase_timestamp)) as months,sum(p.payment_value) as monthly_revenue,count(distinct o.order_id) as no_of_orders,round(sum(p.payment_value)/count(distinct o.order_id),3) as average_order_value
from orders o
inner join payments p
on o.order_id=p.order_id
where o.order_status='delivered'
group by(date_trunc('month',o.order_purchase_timestamp))
order by date_trunc('month',o.order_purchase_timestamp);

-- Which states generate the highest revenue?

select c.customer_state as state, sum(p.payment_value) as revenue
from customers c
inner join orders o
on c.customer_id=o.customer_id
inner join payments p
on o.order_id=p.order_id
WHERE o.order_status = 'delivered'
group by (c.customer_state)
order by revenue desc;

-- Average customer order value for each state

select c.customer_state as state, sum(p.payment_value) as revenue,count(distinct c.customer_unique_id) as No_of_customers, sum(p.payment_value)/count(distinct c.customer_unique_id) as avg_customer_order_value
from customers c
inner join orders o
on c.customer_id=o.customer_id
inner join payments p
on o.order_id=p.order_id
WHERE o.order_status = 'delivered'
group by (c.customer_state)
order by revenue desc;

-- Running (cumulative) revenue

with revenue as(
select date(date_trunc('month',o.order_purchase_timestamp)) as months,sum(p.payment_value) as monthly_revenue
from orders o
inner join payments p
on o.order_id=p.order_id
WHERE o.order_status = 'delivered'
group by date_trunc('month',o.order_purchase_timestamp)
order by months)

select *,sum(monthly_revenue)over(order by months) as running_revenue
from revenue

-- How did revenue change compared to the previous month?

with revenue as(
select date(date_trunc('month',o.order_purchase_timestamp)) as months,sum(p.payment_value) as monthly_revenue
from orders o
inner join payments p
on o.order_id=p.order_id
WHERE o.order_status = 'delivered'
group by date_trunc('month',o.order_purchase_timestamp)
)

select *,lag(monthly_revenue)over(order by months) as prev_revenue, round((monthly_revenue-lag(monthly_revenue)over(order by months))/lag(monthly_revenue)over(order by months)*100,2) as growth
from revenue

-- =====================================================================
-- BUSINESS QUESTIONS: CUSTOMERS
-- =====================================================================

-- Top 10 customers by revenue
-- FIX: previously grouped by customer_id while selecting customer_unique_id.
-- Since one customer_unique_id can have multiple customer_id values (Olist assigns
-- a new customer_id per address), that split a single customer's revenue across
-- multiple rows. Now grouping by customer_unique_id combines it correctly.
with customer_revenue as (
select c.customer_unique_id,sum(p.payment_value) as total_revenue
from customers c
inner join orders o
on c.customer_id=o.customer_id
inner join payments p
on o.order_id=p.order_id
where o.order_status='delivered'
group by c.customer_unique_id)
, customer_ranking as (
select *,rank()over(order by total_revenue desc) as rnk from customer_revenue
)

select customer_unique_id,total_revenue
from customer_ranking
where rnk<=10;

-- Find purchase_months for every customer
select c.customer_unique_id,count(distinct date_trunc('month',o.order_purchase_timestamp))
from customers c
inner join orders o
on c.customer_id=o.customer_id
where o.order_status = 'delivered'
group by c.customer_unique_id

-- Find customers who purchased in more than 1 distinct month
having count(distinct date_trunc('month',o.order_purchase_timestamp))>1
-- Result: 109 customers

-- Customers active across more than 5 distinct months (a stricter loyalty threshold)
-- Re-run the same CTE above with HAVING count(...) > 5
-- Result: 4 customers

-- Do customers who spend more give higher ratings?

with total_customer_revenue as(
select c.customer_unique_id,sum(p.payment_value) as total_revenue
from customers c
inner join orders o
on c.customer_id=o.customer_id
inner join payments p
on o.order_id=p.order_id
where o.order_status='delivered'
group by c.customer_unique_id
), 

percentile_total_revenue as (
select percentile_cont(0.25) within group(order by total_revenue) as q1,percentile_cont(0.50) within group(order by total_revenue) as mean,
percentile_cont(0.75) within group(order by total_revenue) as q3 from total_customer_revenue),

customer_spending_bucket as (
select 
     t.customer_unique_id,t.total_revenue,
     case 
	     when t.total_revenue<q1 then 'Low'
		 when t.total_revenue between q1 and q3 then 'Medium'
		 else 'High'
     end as spending_bucket
from total_customer_revenue t
cross join percentile_total_revenue r
),

customer_avg_review as (
select cu.customer_unique_id,avg(re.review_score) as review
from customers cu
inner join orders ord
on cu.customer_id=ord.customer_id
inner join reviews re
on ord.order_id=re.order_id
group by(cu.customer_unique_id)
)
select spending_bucket, round(avg(review),1) as avg_review
from total_customer_revenue as tc
inner join customer_avg_review as ca
on tc.customer_unique_id=ca.customer_unique_id
inner join customer_spending_bucket cs
on ca.customer_unique_id=cs.customer_unique_id
group by spending_bucket

-- Among repeat customers (more than one delivered order), what is the average number of orders they place?
with repeat_customer_orders as (
select c.customer_unique_id,count(distinct order_id) as no_of_orders
from customers c
inner join orders o
on c.customer_id=o.customer_id
where o.order_status = 'delivered'
group by c.customer_unique_id
having count(distinct order_id)>1
)
select round(avg(no_of_orders),2) as avg_orders from repeat_customer_orders;

-- What percentage of total revenue comes from one-time customers vs repeat customers?

with customer_orders as (
select c.customer_unique_id,count(distinct o.order_id) as no_of_orders,sum(p.payment_value) as total_revenue
from customers c
inner join orders o
on c.customer_id=o.customer_id
inner join payments p
on o.order_id=p.order_id
where o.order_status = 'delivered'
group by c.customer_unique_id
),
customer_type as (
select customer_unique_id,total_revenue,
       case when no_of_orders>1 then 'Repeat'
	   else 'One-Time'
	   end as customer_types
from customer_orders
)

select customer_types,count(customer_unique_id) as customers, sum(total_revenue) as revenue,round(sum(total_revenue)/sum(sum(total_revenue)) over()*100,2) as revenue_percentage
from customer_type 
group by customer_types

-- How many new customers did we acquire each month?

with first_order_date as(
select c.customer_unique_id,min(o.order_purchase_timestamp) as first_order
from customers c
inner join orders o
on c.customer_id=o.customer_id
group by c.customer_unique_id
)
select date(date_trunc('month',first_order)) as months,count(customer_unique_id)
from first_order_date
group by date_trunc('month',first_order)
order by months

-- =====================================================================
-- BUSINESS QUESTIONS: PRODUCTS & SELLERS
-- =====================================================================

-- Top 10 sellers contributing the highest revenue

with seller_revenue as(
select seller_id,sum(price) as revenue
from order_items 
group by seller_id
)

, seller_revenue_ranking as (
select *,dense_rank()over(order by revenue desc) as rnk from seller_revenue
)
 select rnk,seller_id,revenue from seller_revenue_ranking where rnk<=10; 

-- Do the sellers who generate the highest revenue also receive good review scores?
-- CAVEAT: reviews are recorded per order, not per seller/item. If an order contains
-- items from multiple sellers, that single review joins to all of them, which can
-- inflate/skew both revenue and avg_review_score for sellers who frequently co-occur
-- in multi-seller orders. Fine for a directional view, but worth flagging in write-up
-- rather than presenting as a precise per-seller figure.
with seller_review_avg as (
select oi.seller_id,sum(oi.price) as revenue,round(avg(r.review_score),1) as avg_review_score
from order_items oi
inner join reviews r
on oi.order_id=r.order_id
group by oi.seller_id)

, seller_revenue_ranking as (
select *,dense_rank()over(order by revenue desc) as rnk from seller_review_avg
)

 select rnk,seller_id,revenue,avg_review_score from seller_revenue_ranking where rnk<=10; 

-- =====================================================================
-- BUSINESS QUESTIONS: DELIVERY & LOGISTICS
-- =====================================================================

-- What is the average delivery time (in days)?
select round(avg(extract (days from order_delivered_customer_date-order_purchase_timestamp))) as avg_delivery_time from orders
WHERE order_status = 'delivered';

-- Order approval time
select round(avg(extract(epoch from order_approved_at-order_purchase_timestamp))/3600,2) as avg_approval_time from orders WHERE order_status = 'delivered';

-- After the order is approved, how long does the seller take to hand it over to the logistics partner?
select round(avg(extract(epoch from order_delivered_carrier_date-order_approved_at))/86400,2)  as avg_carrier_delivery_time from orders
WHERE order_status = 'delivered';

-- How long does the logistics partner take to deliver the order after picking it up?
select round(avg(extract(epoch from order_delivered_customer_date-order_delivered_carrier_date))/86400,2)  as avg_carrier_delivery_time from orders
WHERE order_status = 'delivered';

-- =====================================================================
-- BUSINESS QUESTIONS: REVIEWS & SATISFACTION
-- =====================================================================

-- What is the distribution of review scores?
with total_reviewers as (
select distinct review_score, count(*)over(partition by review_score) as total_no_of_reviews, count(*)over() as total_reviewers
from reviews)
select review_score, total_no_of_reviews , round(total_no_of_reviews::numeric/total_reviewers * 100,2) as total_reviewers_percentage
from total_reviewers;

-- Do customers who receive deliveries late give lower review scores?
with late_order_reviews as (
select o.order_id,r.review_score
from orders o
inner join reviews r
on o.order_id=r.order_id
where order_delivered_customer_date>order_estimated_delivery_date)

select review_score,count(*)
from late_order_reviews
group by review_score;

-- Average rating of late deliveries vs on-time deliveries
-- NOTE: this does not filter to order_status = 'delivered' first, so non-delivered
-- orders (with a NULL delivery date) are silently counted as 'On Time'. Filtering
-- to delivered orders first would give a more accurate split.

with order_delivery_status as (
select 
    order_id,
    case 
	    when order_delivered_customer_date>order_estimated_delivery_date then 'Late'
		else 'On Time'
	end as Delivery_Status
from orders)

select o.delivery_status,count(*) as no_of_orders,round(avg(r.review_score),1)
from order_delivery_status o
inner join reviews r
on o.order_id=r.order_id
group by o.delivery_status;
