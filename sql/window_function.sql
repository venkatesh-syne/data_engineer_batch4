use record_company

create table employee(
emp_id int,
name varchar(50),
dept_id int,
salary int
);

insert into employee values
(8,'Ramesh', 102, NULL),
(2,'sara', 101, 60000),
(3,'John', 102, 55000),
(4,'Priya', 102, 45000),
(5,'Ravi', 101, 70000);

-- Refernce https://medium.com/learning-sql/sql-window-function-visualized-fff1927f00f2

select * from employee order by salary desc

select dept_id,sum(salary) from employee
group by dept_id

select dept_id,name, salary, ROW_number() over (order by salary DESC)
as row_num,sum(salary) over(partition by dept_id) as dept_total from employee


/*
For each row,SQL:
1. Finds a window(subset of rows)
2. Applies the function in that window
3. Retutns a value for that row

So:
Each row = its own view of data
window will change depending on over()

Function(...) over (partition by..
order by..
rows/Range..)
*/

select dept_id,name, salary, DENSE_RANK() over (order by salary DESC)
as rnk ,sum(salary) over(partition by dept_id) as dept_total from employee

select dept_id,name, salary, RANK() over (order by salary ASC)
as rnk ,sum(salary) over(partition by dept_id) as dept_total from employee


-- Row number -- everyone gets unique position
-- Rank  -- ties allowed, next position is skipped
-- Dense_Rank -- ties allowed , no skipping


-- top 1 employee from each department

select *
from (select *, DENSE_RANK() over(partition by dept_id order by salary desc) as rn
from employee) t where rn =3;

select *
from (select *, row_number() over(order by salary desc) as rn
from employee) t where rn =3;

-- from -> where -> group by -> having -> window -> select -> order by

-- get the data,filter rows, make the group, filter the group, do ranking, pick columns, 
-- remove duplictes, sorting, take top rows

-- LEAD()
select *, lead(salary) over(partition by dept_id order by emp_id) as next_sal
from employee

select *, lag(salary) over(order by emp_id) as prev_sal
from employee


select name, salary,
case when salary > lag(salary) over (order by emp_id)
then 'increased'
else 'decreased'
end as status
from employee

-- Find consecutive duplicate values ? hint(using lag)
-- Running total of salary
-- Find employees earning more than department average
-- Find department earning less than department average
