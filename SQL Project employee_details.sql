--Create employee_detial table
CREATE TABLE employee_detail
(emp_id INT PRIMARY KEY,
emp_name VARCHAR(20),
department VARCHAR(20) NOT NULL,
age INT,
salary INT,
emp_exp INT,
mail_id VARCHAR(50) UNIQUE
)

--Show table structure
SELECT * FROM employee_detail;

--Change mail_id from unique to any value
SELECT conname
FROM pg_constraint
WHERE conrelid = 'employee_detail'::regclass
AND contype = 'u';
ALTER TABLE employee_detail
DROP CONSTRAINT employee_detail_mail_id_key;


--Insert data in table
INSERT INTO employee_detail
VALUES
(1,'Suresh Yadav','Project Engineer',26,52000,6,'suresh.yadav@gmail.com'),
(2,'Ramesh Kumar','Software Engineer',27,48000,4,'ramesh.kumar@gmail.com'),
(3,'Amit Sharma','Data Analyst',29,60000,6,'amit.sharma@gmail.com'),
(4,'Neha Verma','HR Executive',26,42000,3,'neha.verma@gmail.com'),
(5,'Pooja Singh','Project Engineer',28,54000,5,'pooja.singh@gmail.com'),
(6,'Rahul Mehta','Business Analyst',31,70000,8,'rahul.mehta@gmail.com'),
(7,'Anjali Gupta','Software Engineer',25,46000,2,'anjali.gupta@gmail.com'),
(8,'Vikas Yadav','System Admin',30,58000,7,'vikas.yadav@gmail.com'),
(9,'Suresh Yadav','Project Engineer',26,52000,6,'suresh.yadav@gmail.com'),
(10,'Kiran Patel','QA Engineer',27,49000,4,'kiran.patel@gmail.com'),
(11,'Deepak Mishra','DevOps Engineer',32,75000,9,'deepak.mishra@gmail.com'),
(12,'Ritu Malhotra','HR Executive',28,44000,5,'ritu.malhotra@gmail.com'),
(13,'Manoj Singh','Project Manager',35,90000,12,'manoj.singh@gmail.com'),
(14,'Amit Sharma','Data Analyst',29,60000,6,'amit.sharma@gmail.com'),
(15,'Sunita Rao','Finance Analyst',31,68000,8,'sunita.rao@gmail.com'),
(16,'Arjun Nair','Software Engineer',26,47000,3,'arjun.nair@gmail.com'),
(17,'Priya Iyer','Data Scientist',30,82000,7,'priya.iyer@gmail.com'),
(18,'Rohit Jain','Sales Executive',28,45000,4,'rohit.jain@gmail.com'),
(19,'Neha Verma','HR Executive',26,42000,3,'neha.verma@gmail.com'),
(20,'Sanjay Das','Support Engineer',29,43000,5,'sanjay.das@gmail.com'),
(21,'Kunal Shah','Product Owner',34,88000,10,'kunal.shah@gmail.com'),
(22,'Meena Joshi','QA Engineer',27,50000,4,'meena.joshi@gmail.com'),
(23,'Pankaj Tiwari','Database Admin',33,77000,9,'pankaj.tiwari@gmail.com'),
(24,'Ayesha Khan','UI Designer',26,48000,3,'ayesha.khan@gmail.com'),
(25,'Nitin Agarwal','System Admin',31,59000,7,'nitin.agarwal@gmail.com'),
(26,'Ravi Prakash','Network Engineer',32,61000,8,'ravi.prakash@gmail.com'),
(27,'Pooja Singh','Project Engineer',28,54000,5,'pooja.singh@gmail.com'),
(28,'Alok Verma','Business Analyst',30,67000,6,'alok.verma@gmail.com'),
(29,'Sneha Kulkarni','Data Analyst',27,55000,4,'sneha.k@gmail.com'),
(30,'Mohit Bansal','Software Engineer',25,45000,2,'mohit.bansal@gmail.com'),
(31,'Ramesh Kumar','Software Engineer',27,48000,4,'ramesh.kumar@gmail.com'),
(32,'Divya Chawla','HR Manager',34,78000,10,'divya.chawla@gmail.com'),
(33,'Saurabh Pandey','Cloud Engineer',29,72000,6,'saurabh.p@gmail.com'),
(34,'Isha Kapoor','Marketing Analyst',28,53000,5,'isha.kapoor@gmail.com'),
(35,'Vivek Malviya','Security Analyst',31,76000,8,'vivek.m@gmail.com'),
(36,'Ankit Rawat','Support Engineer',26,41000,3,'ankit.rawat@gmail.com'),
(37,'Ritu Malhotra','HR Executive',28,44000,5,'ritu.malhotra@gmail.com'),
(38,'Farhan Ali','UI Designer',27,49000,4,'farhan.ali@gmail.com'),
(39,'Shalini Bose','Content Strategist',30,56000,6,'shalini.b@gmail.com'),
(40,'Gaurav Saxena','Automation Tester',29,64000,5,'gaurav.saxena@gmail.com'),
(41,'Kavita Deshpande','Finance Analyst',32,70000,9,'kavita.d@gmail.com'),
(42,'Harsh Vardhan','Operations Lead',35,85000,11,'harsh.v@gmail.com'),
(43,'Naveen Reddy','Data Engineer',31,78000,7,'naveen.reddy@gmail.com'),
(44,'Amit Sharma','Data Analyst',29,60000,6,'amit.sharma@gmail.com'),
(45,'Sonal Arora','Recruiter',26,43000,3,'sonal.arora@gmail.com'),
(46,'Ajay Kulkarni','Tech Lead',36,92000,13,'ajay.k@gmail.com'),
(47,'Nikhil Sood','Software Engineer',28,51000,5,'nikhil.sood@gmail.com'),
(48,'Preeti Mishra','QA Lead',33,73000,9,'preeti.m@gmail.com'),
(49,'Suresh Yadav','Project Engineer',26,52000,6,'suresh.yadav@gmail.com'),
(50,'Varun Khanna','Product Analyst',30,69000,6,'varun.khanna@gmail.com'),
(51,'Karthik Rao','Data Scientist',32,85000,8,'karthik.rao@gmail.com');

                        -----EASY LEVEL-------
--1.Display all records from employee_detail
SELECT * FROM employee_detail;

--2.Show only emp_name, department, and salary.
SELECT emp_name,department,salary FROM employee_detail;

--3.Find employees working in IT department.
SELECT * from employee_detail
WHERE department ='HR Executive';

--4.Get employees whose salary is greater than 50,000.
SELECT emp_name,salary FROM employee_detail
WHERE salary>50000

--5.List employees where age is NULL.
SELECT emp_name, age FROM employee_detail
WHERE age IS NULL;

--6. Count total employees.
SELECT COUNT(emp_name) as Total_emp_count FROM employee_detail;

--7.Display distinct departments.
SELECT DISTINCT(department) as Distinct_department FROM employee_detail;

--8.Sort employees by salary in descending order.
SELECT * FROM employee_detail
ORDER BY salary DESC;

--Find employees with experience more than 5 years.
SELECT emp_name,emp_exp FROM employee_detail
WHERE emp_exp>5;

--Find employees whose name starts with 'S'.
SELECT emp_name FROM employee_detail
WHERE emp_name LIKE 'S%';
                       -----MEDIAM LEVEL -----
					   
--1.Find average salary of all employees.
SELECT AVG(salary) AS Average_of_Salary FROM employee_detail;

--2.Display max and min salary.
SELECT MIN(salary) AS Minimum_Salary , MAX(salary) AS Maximum_Salary FROM employee_detail;

--3.Count employees per department.
SELECT department , COUNT(emp_name) as employee_count 
FROM employee_detail
GROUP BY department;

--4.Find departments having more than 2 employees.
SELECT department , COUNT(emp_name) as employee_count 
FROM employee_detail
GROUP BY department
HAVING COUNT(emp_name)>2;

--5.Find employees with salary between 40,000 and 70,000.
SELECT emp_name , salary 
FROM employee_detail
WHERE salary BETWEEN 40000 AND 70000;

--6.Find employees whose department is not NULL.
SELECT emp_name , department
FROM employee_detail
WHERE department IS NOT NULL;

--7.Get top 3 highest paid employees.
SELECT emp_name , salary 
FROM employee_detail
ORDER BY salary DESC
LIMIT 3;

--8.Find employees whose mail_id contains '@gmail.com'.
SELECT emp_name , mail_id FROM employee_detail
WHERE mail_id LIKE '%@gmail.com%';

--9.Find duplicate mail_id values.
SELECT mail_id, COUNT(mail_id) as Duplicate_mail_id FROM employee_detail
GROUP BY mail_id
HAVING COUNT(mail_id)>=2;

--10.Increase salary by 5% for employees with experience > 5 years.
SELECT emp_name,emp_exp, salary,
       CASE
           WHEN emp_exp >= 5 THEN salary * 1.05
           ELSE salary
       END AS hiked_salary
FROM employee_detail;

                       -----ADVANCED LEVEL -----
					   
--1.Find second highest salary.
SELECT * FROM employee_detail
ORDER BY salary
DESC LIMIT 1
OFFSET 1;


--2.Delete employees whose mail_id is NULL.
DELETE FROM employee_detail
WHERE mail_id IS NULL











