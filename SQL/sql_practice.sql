create database batch4;
#SQL Practice questions and solutions

#############################################################################################
#Scenario 1: Second Highest Salary
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

Use batch4;

CREATE TABLE employees(

	emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    salary DECIMAL (10,2)
);

INSERT INTO employees VALUES
(1,'John', 50000),
(2,'Mary',80000),
(3,'David',70000),
(4,'Sara',80000),
(5,'Tom',60000);

SELECT * FROM employees;

## 1st way of splving

SELECT DISTINCT Salary
FROM employees
ORDER BY salary DESC
LIMIT 1 OFFSET 1;

## approach 2
select max(salary) AS second_highest_salary
FROM employees
WHERE salary <(SELECT max(salary) FROM employees);

## Approach 3 windows function

SELECT salary
FROM (
	SELECT salary,
    dense_rank() OVER (ORDER BY salary DESC) AS rnk
	FROM employees
) t
where rnk=2

##usind cte
WITH salary_rank AS
(
	SELECT salary,
    DENSE_RANK() OVER(ORDER BY salary DESC) as rnk
    FROM employees
)
SELECT salary
FROM salary_rank
where rnk=2;


###########################################################################

#Scenario 2: Highest Salary Per Department
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

SELECT * FROM employees

ALTER TABLE employees
ADD COLUMN dept_id INT;

DESC employees;

UPDATE employees
SET dept_id = 10
WHERE emp_id IN (1,2);

UPDATE employees
SET dept_id = 20
WHERE emp_id IN (3,4);

UPDATE employees
SET dept_id = 30
WHERE emp_id = 5;

INSERT INTO employees
VALUES
(6,'Alice',60000,30);

#Approach 1 Highest salary only
SELECT dept_id, MAX(salary) as highest_salary
FROM employees
GROUP BY dept_id;

#if they need employee name also
SELECT e.*
FROM employees e
JOIN
(
	SELECT dept_id, max(salary) AS max_salary
    FROM employees
    GROUP BY dept_id

) d
ON e.dept_id = d.dept_id
AND e.salary=d.max_salary

#using windows function
WITH max_salry AS(
	SELECT *,
	DENSE_RANK() OVER(PARTITION BY dept_id ORDER BY salary DESC) as rnk
	FROM employees
)
SELECT *
FROM max_salry
WHERE rnk=1;

EXPLAIN
SELECT dept_id,
       MAX(salary)
FROM employees
GROUP BY dept_id;


#########################################################################################################

#Scenario 3: Latest Order Per Customer
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.


CREATE TABLE orders(
	order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10,2)
);

INSERT INTO orders VALUES
(101,1,'2025-01-10',500),
(102,1,'2025-03-15',700),
(103,2,'2025-02-01',300),
(104,2,'2025-04-20',900),
(105,3,'2025-01-05',200);

##Only latest order date --suppose
SELECT customer_id,
MAX(order_date) AS latest_order
FROM orders
GROUP BY customer_id


#approach 2

SELECT o.*
FROM orders o
JOIN(
	SELECT customer_id,
    MAX(order_date) AS latest_order
    FROM orders
    GROUP BY customer_id
) x
ON o.customer_id=x.customer_id
AND o.order_date=x.latest_order

#Using Windows function
WITH latest_order AS(
	SELECT *,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date DESC) as rn
    FROM orders
)
SELECT *
FROM latest_order
WHERE rn=1

##use row_number if only one latest row i needed if business wants all latest orders sharing same date use DENSE_RANK
##Latest order per customer
#Latest login per user
#Latest transaction per account
#Latest status per employee
#Most recent event per device------------------- these are all patterns

#performance consideration

#Create composite index on customer_id and order date  coz query frequently uses group by customer_id and MAX(order date)
CREATE INDEX idx_customer_date
ON orders(customer_id, order_date);

EXPLAIN
SELECT customer_id,
       MAX(order_date)
FROM orders
GROUP BY customer_id;

# from data engineering perspective create separate fact table or use partion by this reduces data scanned

######################################################################################

#4 Scenario 4: Duplicate Records
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

INSERT INTO employees
(emp_id, emp_name, salary, dept_id)
VALUES
(7,'John',50000,10),
(8,'Mary',80000,10);

SELECT * FROM employees


#Approach 1

SELECT emp_name, salary,dept_id, COUNT(*) as cnt
FROM employees
GROUP BY emp_name, salary, dept_id
HAVING count(*) >1;

##we are not using where here coz where filters rows and having filters grous

#approach 2

SELECT *
FROM employees
WHERE (emp_name, salary, dept_id) IN
(
    SELECT emp_name,
           salary,
           dept_id
    FROM employees
    GROUP BY emp_name,
             salary,
             dept_id
    HAVING COUNT(*) > 1
);

#approach 3 windows

SELECT *
FROM
(
	SELECT *, 
    ROW_NUMBER() OVER (PARTITION BY emp_name, salary,dept_id ORDER BY emp_id) as rn
    FROM employees
) t
where rn>1;

#####################################################################

#Scenario 5: Missing Numbers
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

#Approach 1 -- suppose data is consecutive only one numbers are missing

CREATE TABLE numbers (
    num INT
);

INSERT INTO numbers VALUES
(1),
(2),
(3),
(5),
(6),
(8),
(9);

SELECT n1.num+1 AS missing_number
FROM numbers n1
LEFT JOIN numbers n2
ON n1.num+1 = n2.num
WHERE n2.num IS NULL;

# here 1 2 5 that case wont be handled

#Approach 2
WITH RECURSIVE seq AS(
SELECT 1 as n

UNION ALL

SELECT n+1
FROM seq
WHERE n <(SELECT MAX(num) FROM numbers)
)
SELECT n
FROM seq 
WHERE n NOT IN
(
	SELECT num 
    FROM numbers
);
###################################################################

#Running Total. Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.


SELECT *
FROM orders
ORDER BY order_date

SELECT order_id,
	order_date,
	amount,
	SUM(amount) OVER (ORDER BY order_date) AS running_total
FROM orders

#Show cumulative spending for each customer.
SELECT order_id,
       customer_id,
       order_date,
       amount,
       SUM(amount) OVER
       (
           PARTITION BY customer_id
           ORDER BY order_date
       ) AS running_total
FROM orders;

#performance consideration

CREATE INDEX idx_order_date
ON orders(order_date);

EXPLAIN
SELECT amount,
       SUM(amount) OVER
       (
           ORDER BY order_date
       )
FROM orders;

######################################################################
#Scenario 7: Month-over-Month Comparison
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

SELECT month,
       monthly_sales,
       LAG(monthly_sales) OVER
       (
           ORDER BY month
       ) AS previous_month_sales,
       monthly_sales -
       LAG(monthly_sales) OVER
       (
           ORDER BY month
       ) AS difference
FROM
(
    SELECT DATE_FORMAT(order_date,'%Y-%m') AS month,
           SUM(amount) AS monthly_sales
    FROM orders
    GROUP BY DATE_FORMAT(order_date,'%Y-%m')
) t;


#####################################################################
#Scenario 8: Customers Without Orders
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50)
);

INSERT INTO customers VALUES
(1,'Alice'),
(2,'Bob'),
(3,'Charlie'),
(4,'David'),
(5,'Emma');

#Approach 1: LEFT JOIN + IS NULL
SELECT c.*
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;

#Approach 2: NOT EXISTS (Production Favorite)
SELECT *
FROM customers c
WHERE NOT EXISTS
(
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);

EXPLAIN
SELECT c.*
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;

############################################################
#Scenario 9: Top 5 Customers
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

#Approach 1: GROUP BY + ORDER BY

SELECT customer_id,
       SUM(amount) AS total_spent
FROM orders
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 5;

#Approach 2: DENSE_RANK()
SELECT *
FROM
(
    SELECT customer_id,
           SUM(amount) AS total_spent,
           DENSE_RANK() OVER
           (
               ORDER BY SUM(amount) DESC
           ) AS rnk
    FROM orders
    GROUP BY customer_id
) t
WHERE rnk <= 5;
####################################################################
#Scenario 10: SCD Type 2 Validation
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

#Slowly Changing Dimension Type 2
###########################################################################

#Scenario 11: Data Quality Check
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.
#####################################

#Scenario 12: Consecutive Login Days
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

CREATE TABLE user_logins (
    user_id INT,
    login_date DATE
);


INSERT INTO user_logins VALUES
(1,'2025-01-01'),
(1,'2025-01-02'),
(1,'2025-01-03'),
(1,'2025-01-05'),
(1,'2025-01-06'),

(2,'2025-01-01'),
(2,'2025-01-03'),
(2,'2025-01-04');


SELECT user_id,
       MIN(login_date) AS streak_start,
       MAX(login_date) AS streak_end,
       COUNT(*) AS streak_days
FROM
(
    SELECT user_id,
           login_date,
           DATE_SUB(
               login_date,
               INTERVAL ROW_NUMBER() OVER
               (
                   PARTITION BY user_id
                   ORDER BY login_date
               ) DAY
           ) AS grp
    FROM user_logins
) t
GROUP BY user_id, grp;

#############################################################

#Scenario 13: Employee-Manager Hierarchy
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.


ALTER TABLE employees
ADD manager_id INT;

UPDATE employees
SET manager_id = NULL
WHERE emp_id = 1;

UPDATE employees
SET manager_id = 1
WHERE emp_id IN (2,3);

UPDATE employees
SET manager_id = 2
WHERE emp_id IN (4,5);

UPDATE employees
SET manager_id = 3
WHERE emp_id IN (6,7,8);


#Approach 1: Employee and Manager Name (Self Join)

SELECT e.emp_id,
       e.emp_name,
       m.emp_name AS manager_name
FROM employees e
LEFT JOIN employees m
ON e.manager_id = m.emp_id;

#Approach 2: Complete Hierarchy (Recursive CTE)

WITH RECURSIVE emp_hierarchy AS
(
    SELECT emp_id,
           emp_name,
           manager_id,
           1 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.emp_id,
           e.emp_name,
           e.manager_id,
           h.level + 1
    FROM employees e
    JOIN emp_hierarchy h
    ON e.manager_id = h.emp_id
)
SELECT *
FROM emp_hierarchy;

#Approach 3: Find All Employees Under Manager 2

WITH RECURSIVE team AS
(
    SELECT emp_id,
           emp_name,
           manager_id
    FROM employees
    WHERE emp_id = 2

    UNION ALL

    SELECT e.emp_id,
           e.emp_name,
           e.manager_id
    FROM employees e
    JOIN team t
    ON e.manager_id = t.emp_id
)
SELECT *
FROM team;

###################################################

#Scenario 14: Department Average Salary
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

#Approach 1: GROUP BY + AVG()
SELECT dept_id,
       AVG(salary) AS avg_salary
FROM employees
GROUP BY dept_id;

#Approach B: Window Function (Preferred)
SELECT emp_id,
       emp_name,
       dept_id,
       salary,
       AVG(salary) OVER
       (
           PARTITION BY dept_id
       ) AS dept_avg
FROM employees;

########################################################

#Scenario 15: Most Recent Transaction
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

 #Approach 1: MAX() + JOIN
SELECT o.*
FROM orders o
JOIN
(
    SELECT customer_id,
           MAX(order_date) AS latest_date
    FROM orders
    GROUP BY customer_id
) t
ON o.customer_id = t.customer_id
AND o.order_date = t.latest_date;


#Approach 2: ROW_NUMBER() (Preferred)

SELECT *
FROM
(
    SELECT o.*,
           ROW_NUMBER() OVER
           (
               PARTITION BY customer_id
               ORDER BY order_date DESC
           ) AS rn
    FROM orders o
) t
WHERE rn = 1;

###########################################################

#Scenario 16: Banking Transactions Balance
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

CREATE TABLE bank_transactions (
    txn_id INT PRIMARY KEY,
    account_id INT,
    txn_date DATE,
    txn_type VARCHAR(10),
    amount DECIMAL(10,2)
);



INSERT INTO bank_transactions VALUES
(1,101,'2025-01-01','CREDIT',1000),
(2,101,'2025-01-02','DEBIT',200),
(3,101,'2025-01-03','CREDIT',500),
(4,101,'2025-01-04','DEBIT',100),

(5,102,'2025-01-01','CREDIT',2000),
(6,102,'2025-01-02','DEBIT',300);


#Approach 1: Running Balance Using SUM() OVER()

SELECT account_id,
       txn_date,
       txn_type,
       amount,
       SUM(
           CASE
               WHEN txn_type='CREDIT' THEN amount
               ELSE -amount
           END
       ) OVER
       (
           PARTITION BY account_id
           ORDER BY txn_date, txn_id
       ) AS running_balance
FROM bank_transactions;

#Approach 2: Current Balance Per Account


SELECT *
FROM
(
    SELECT account_id,
           txn_date,
           SUM(
               CASE
                   WHEN txn_type='CREDIT'
                   THEN amount
                   ELSE -amount
               END
           ) OVER
           (
               PARTITION BY account_id
               ORDER BY txn_date, txn_id
           ) AS balance,
           ROW_NUMBER() OVER
           (
               PARTITION BY account_id
               ORDER BY txn_date DESC, txn_id DESC
           ) AS rn
    FROM bank_transactions
) t
WHERE rn = 1;

##############################################################

#Scenario 17: Rolling 7-Day Average
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

#Approach 1: Window Function (Preferred)

SELECT order_date,
       daily_sales,
       AVG(daily_sales) OVER
       (
           ORDER BY order_date
           ROWS BETWEEN 6 PRECEDING
           AND CURRENT ROW
       ) AS rolling_7_day_avg
FROM
(
    SELECT order_date,
           SUM(amount) AS daily_sales
    FROM orders
    GROUP BY order_date
) t;

############################################################################
#Scenario 18: Detect Data Skew
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

#####################################################################

#Scenario 19: Late Arriving Data
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

ALTER TABLE orders
ADD load_date DATE;

#Find records that arrived late.

SELECT *
FROM orders
WHERE load_date > order_date;


SET SQL_SAFE_UPDATES = 0;

UPDATE orders
SET load_date = order_date
WHERE load_date IS NULL;

SET SQL_SAFE_UPDATES = 1;

SELECT AVG(
       DATEDIFF(load_date, order_date)
       ) AS avg_delay
FROM orders;

#####################################################################

#Scenario 20: Product Sales Ranking
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.


SELECT product_id,
       total_sales,
       DENSE_RANK() OVER (
           ORDER BY total_sales DESC
       ) AS sales_rank
FROM
(
    SELECT product_id,
           SUM(sale_amount) AS total_sales
    FROM product_sales
    GROUP BY product_id
) t;


##############################################################

#Scenario 21: Find Gaps Between Orders
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

INSERT INTO orders
(order_id, customer_id, order_date, amount, load_date)
VALUES
(301,1,'2025-01-01',100,'2025-01-01'),
(302,1,'2025-01-05',200,'2025-01-05'),
(303,1,'2025-01-12',150,'2025-01-12'),

(304,2,'2025-01-02',300,'2025-01-02'),
(305,2,'2025-01-20',400,'2025-01-20');


SELECT customer_id,
       order_id,
       order_date,
       LAG(order_date) OVER
       (
           PARTITION BY customer_id
           ORDER BY order_date
       ) AS previous_order_date,
       DATEDIFF(
           order_date,
           LAG(order_date) OVER
           (
               PARTITION BY customer_id
               ORDER BY order_date
           )
       ) AS gap_days
FROM orders;

#######################################
#Scenario 22: Daily Active Users
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

CREATE TABLE user_activity (
    activity_id INT PRIMARY KEY,
    user_id INT,
    activity_date DATE
);

INSERT INTO user_activity
VALUES
(1,101,'2025-01-01'),
(2,102,'2025-01-01'),
(3,101,'2025-01-01'),

(4,101,'2025-01-02'),
(5,103,'2025-01-02'),
(6,104,'2025-01-02'),

(7,101,'2025-01-03'),
(8,102,'2025-01-03'),
(9,103,'2025-01-03');

SELECT activity_date,
       COUNT(DISTINCT user_id) AS daily_active_users
FROM user_activity
GROUP BY activity_date
ORDER BY activity_date;

#######################################################

#Scenario 23: Monthly Revenue
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

INSERT INTO orders
(order_id, customer_id, order_date, amount, load_date)
VALUES
(401,101,'2025-01-05',500,'2025-01-05'),
(402,102,'2025-01-20',300,'2025-01-20'),
(403,101,'2025-02-10',700,'2025-02-10'),
(404,103,'2025-02-15',400,'2025-02-15'),
(405,102,'2025-03-01',900,'2025-03-01');

SELECT DATE_FORMAT(order_date,'%Y-%m') AS revenue_month,
       SUM(amount) AS total_revenue
FROM orders
GROUP BY DATE_FORMAT(order_date,'%Y-%m')
ORDER BY revenue_month;

###############################################################

#Scenario 24: Repeat Customers
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

INSERT INTO orders
(order_id, customer_id, order_date, amount, load_date)
VALUES
(501,101,'2025-01-01',100,'2025-01-01'),
(502,101,'2025-01-10',200,'2025-01-10'),

(503,102,'2025-01-05',300,'2025-01-05'),

(504,103,'2025-01-07',400,'2025-01-07'),
(505,103,'2025-01-15',500,'2025-01-15'),
(506,103,'2025-01-20',600,'2025-01-20');

#Approach 1
SELECT customer_id,
       COUNT(*) AS order_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 1;

# approach 2
SELECT DISTINCT customer_id
FROM
(
    SELECT customer_id,
           COUNT(*) OVER
           (
               PARTITION BY customer_id
           ) AS order_count
    FROM orders
) t
WHERE order_count > 1;

#################################################################

#Scenario 25: CDC Validation
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

#Source table
CREATE TABLE customer_source (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50),
    last_updated DATETIME
);

#Target table

CREATE TABLE customer_target (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50),
    last_updated DATETIME
);

INSERT INTO customer_source
VALUES
(1,'John','Bangalore','2025-01-01 10:00:00'),
(2,'Mary','Mumbai','2025-01-01 10:00:00'),
(3,'David','Delhi','2025-01-01 10:00:00'),
(4,'Smith','Chennai','2025-01-01 10:00:00');

INSERT INTO customer_target
VALUES
(1,'John','Bangalore','2025-01-01 10:00:00'),
(2,'Mary','Pune','2025-01-01 10:00:00'),
(4,'Smith','Chennai','2025-01-01 10:00:00'),
(5,'Alex','Hyderabad','2025-01-01 10:00:00');


#Final Query 1: Record Count Validation
SELECT
    (SELECT COUNT(*) FROM customer_source) AS source_count,
    (SELECT COUNT(*) FROM customer_target) AS target_count;

#Final Query 2: Missing Records

SELECT s.*
FROM customer_source s
LEFT JOIN customer_target t
ON s.customer_id = t.customer_id
WHERE t.customer_id IS NULL;


#Final Query 3: Data Mismatch Validation

SELECT s.customer_id,
       s.customer_name AS source_name,
       t.customer_name AS target_name,
       s.city AS source_city,
       t.city AS target_city
FROM customer_source s
JOIN customer_target t
ON s.customer_id = t.customer_id
WHERE s.customer_name <> t.customer_name
   OR s.city <> t.city;
   
   
######################################################
#Scenario 26: Top N Per Group
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.


SELECT *
FROM
(
    SELECT emp_id,
           emp_name,
           salary,
           dept_id,
           ROW_NUMBER() OVER
           (
               PARTITION BY dept_id
               ORDER BY salary DESC
           ) AS rn
    FROM employees
) t
WHERE rn <= 2;


#################################################################

#Scenario 27: Remove Duplicates Using Window Functions
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.


CREATE TABLE customer_orders (
    order_id INT,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10,2)
);

INSERT INTO customer_orders
VALUES
(1,101,'2025-01-01',500),

(2,102,'2025-01-02',300),
(2,102,'2025-01-02',300),

(3,103,'2025-01-03',700),
(3,103,'2025-01-03',700),
(3,103,'2025-01-03',700),

(4,104,'2025-01-04',400);

SELECT *
FROM
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY order_id
               ORDER BY order_id
           ) AS rn
    FROM customer_orders
) t
WHERE rn > 1;

###############################################################

#Scenario 28: Partition Pruning Validation
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

CREATE TABLE orders_partitioned (
    order_id INT,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10,2)
)
PARTITION BY RANGE (YEAR(order_date))
(
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION pmax  VALUES LESS THAN MAXVALUE
);

INSERT INTO orders_partitioned
VALUES
(1,101,'2023-05-10',500),
(2,102,'2024-03-15',700),
(3,103,'2025-01-20',900),
(4,104,'2025-02-15',600);

SELECT *
FROM orders_partitioned
WHERE order_date >= '2025-01-01'
  AND order_date < '2026-01-01';



#####################################################################

#Scenario 29: BigQuery Optimization
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.

#################################################################

#Scenario 30: Production Support SQL Scenario
#Describe the SQL approach, write the query, explain performance considerations, and discuss how you would handle this in a production Data Engineering environment.




