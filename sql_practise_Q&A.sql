use practisedb;
-- Second highest salary
select * from employee
select * from
(select *,dense_rank() over(order by salary desc) as rn from employee ) e where rn=2;

-- Highest Salary Per Department
select * from
(select *,row_number() over(partition by dept order by salary desc) as rn from employee) e where rn=1;

-- Latest order per customer
select * from orders
select * from order_date
with latest_order as
(select *,row_number() over
(partition by customer_id order by order_date desc) as rn from order_date)
select * from latest_order where rn=1

-- Duplicate Records
select * from orders
with dup as
(select customer_id,count(*) as cnt from orders
group by customer_id
having cnt > 1)
select * from dup 

-- Employee manager hierarchy
select * from employee
select  e.emp_id,e.emp_name, m.emp_name as manager_name,e.dept from employee e left join employee m
on e.manager_id = m.emp_id

-- Average salary per department
Select avg(salary) as average_sal, deptid from emp group by deptid;

-- Product sales ranking
select * from orders 
with cust_sale as 
(
select customer_id, sum(amount) total_sales from orders
group by customer_id
),
high_value_sales as
(
select * from cust_sale where total_sales >= 2000
),

rank_cust as
(
select *,  DENSE_RANK() over (order by total_sales DESC) rn 
from high_value_sales
)
select * from rank_cust

-- Top N per group 
Select * from
(Select *, row_number() over (partition by dept order by salary desc) as rn from employee) e where rn=1;

-- Top 5 customers
select * from orders
select *,row_number() over (order by amount desc) as rn from orders limit 5; --  First come first serve type, duplicate values but gives next rank
select *,rank() over (order by amount desc) as rn from orders limit 5; --  Gives exact rank but skips next rank
select *,dense_rank() over (order by amount desc) as rn from orders limit 5; --  Gives exact rank and do not skip next rank

select * from customer
select * from department
select * from emp

-- Repeated customer
select customer_name,count(*) from customer group by customer_name;

-- Remove Duplicates
with rem_dup as
(select *,row_number() over(partition by customer_id,customer_name,country order by customer_id) as rn from customer )
select * from rem_dup
delete from rem_dup where rn > 1;

-- Running total 
select * from orders
select *,SUM(amount) OVER (ORDER BY customer_id, order_id) AS running_total
FROM orders;

-- Customers without orders
select * from orders where order_id is null
select c.*,o.* from customer c left join orders o ON c.customer_id= o.customer_id where o.order_id is null; 
select * from customer
select * from orders

