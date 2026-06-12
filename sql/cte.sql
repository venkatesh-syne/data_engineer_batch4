-- With CTE Queries


create table emp(
emp_id int,
name varchar(50),
dept_id int,
salary int,
city varchar(50),
joining_date date
);

insert into emp values
(1,'Amit',101,50000,'Bangalore','2020-01-10'),
(2,'Sara',101,60000,'Bangalore','2021-03-15'),
(3,'John',102,55000,'Chennai','2019-07-20'),
(4,'Priya',102,45000,'Chennai','2022-06-10'),
(5,'Ravi',103,70000,'Hyderabad','2018-09-10'),
(6,'Neha',103,65000,'Hyderabad','2020-11-25'),
(7,'Kiran',101,52000,'Mumbai','2021-12-01'),
(8,'Anu',104,48000,'Mumbai','2023-01-10'),
(9,'Vikram',104,75000,'Delhi','2017-04-18'),
(10,'Pooja',105,62000,'Delhi','2019-02-14'),
(11,'Rahul',105,58000,'Pune','2022-08-30'),
(12,'Sneha',103,72000,'Pune','2022-05-05');


create table dept(
dept_id int,
dept_name varchar(20));


insert into dept values
(101,'HR'),
(102,'IT'),
(103,'Finance'),
(104,'Audit'),
(105,'Marketing');


create table sales(
sale_id int,
emp_id int,
amont int,
sale_date date
);

insert into sales values
(1,1,1000,'2024-01-01'),
(2,1,1500,'2024-01-02'),
(3,1,2000,'2024-01-01'),
(4,3,1800,'2024-01-03'),
(5,4,1200,'2024-01-02'),
(6,5,3000,'2024-01-01'),
(7,6,1100,'2024-01-04'),
(8,7,1100,'2024-01-02'),
(9,8,1700,'2024-01-03'),
(10,9,4000,'2024-01-01');



-- Total salary of each department

with avg_sal as (
select dept_id, avg(salary) avg_sal 
from emp
group by dept_id
)
select e.name, e.salary, a.avg_sal
from emp e
join avg_sal a on e.dept_id = a.dept_id
where e.salary > a.avg_sal;

-- sub query

select e.name, e.salary, a.avg_sal
from emp e
Join(select dept_id,avg(salary) as avg_sal
from emp
group by dept_id
) a
ON e.dept_id = a.dept_id
where e.salary > a.avg_sal;

-- window function

select * from(
select dept_id, name, salary, 
avg(salary) over (partition by dept_id) as avg_sal
from emp) t
where salary > avg_sal;

-- Not allowed
select dept_id, name, salary, 
avg(salary) over (partition by dept_id) as avg_sal
from emp
where salary > avg(salary) over (partition by dept_id);


-- Top 2 employees from each department
-- CTE + window

-- Subquery
select *
from(
select *, row_number() over(partition by dept_id order by salary DESC) rn
from emp) t
where rn <=2;


-- with cte

with top_emp as(
select *, row_number() over(partition by dept_id order by salary DESC) rn
from emp
)
select * from top_emp where rn <=2;