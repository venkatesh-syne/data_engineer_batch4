use practisedb;
create table emp(empid int primary key,empname varchar(50), deptid int, salary int, hikecycle date);
show tables;
create table department(deptid int primary key,deptname varchar(50));
insert into emp values
insert into emp values
(1,"Venkat",104,102000,"2026-02-01"),
(2, "Santosh",101, 105000,"2009-05-14"),
(3, "Naveen",100, 110000,"2010-06-13"),
(4, "Roshini",101, 120000,"2011-08-09"),
(5, "Pramod",102, 150000,"2012-01-30"),
(6, "Gautaum",103, 90000,"2015-09-23");
select * from emp
drop table department
insert into department values
(100, "Facility"),
(101, "Sales"),
(102, "IT"),
(103, "Finance"),
(104,"Infra");
select * from department
insert into project values
(201, "PlanetEarth","2015-04-12",1),
(202, "Tiger","2018-02-19",2),
(203, "Lion","2022-02-23",2),
(204, "Cloud","2016-07-28",4),
(205, "Cloud","2021-02-23",5);
select * from project
Select * from emp order by salary desc;
select * from emp
Select * from emp order by salary desc limit 1;
Select distinct(deptid) from emp;
Select deptid, count(*) as total_employees from emp group by deptid;
select deptid,count(*) as employee_total from emp group by deptid;
select e.empname,d.deptname from emp e inner join department d ON e.deptid=d.deptid
select e.empname,d.deptname from emp e left join department d ON e.deptid=d.deptid
Select e.empname, d.deptname from emp  e right join department d ON e.deptid = d.deptid
Select e.empname, d.deptname from emp  e right join department d ON e.deptid = d.deptid
Select * from emp where deptid in (100, 101) or deptid=106;
Select * from emp where deptid in (100, 101) and deptid=106;
Select * from emp where empname like '%sh%';
Select empid, empname,salary from emp where salary = (Select max(Salary) from emp where salary < (Select max(salary) from emp));
Select e.empid, e.empname, d.deptid, d.deptname, p.project_name from emp e inner join department d ON e.deptid=d.deptid
inner join
project p ON e.empid = p.empid;


Select deptid, sum(salary),
case 
	when  sum(salary) >= 200000 then 'High'
    when  sum(salary) between 150000 and 200000 then 'Medium'
    else 'low'
end as Salary_category from emp group by deptid;

Select empname, salary, 
case 
	when salary >= 120000 then 'High'
    when salary between 100000 and 120000 then 'Medium'
    else 'low'
end as Salary_category from emp;



