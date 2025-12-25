# Easy Level Query Results

## 1. Display all records from employee_detail
```
SELECT * FROM employee_detail;
```

**Result:** Returns all 51 employee records with columns: emp_id, emp_name, department, age, salary, emp_exp, mail_id

---

## 2. Show only emp_name, department, and salary
```
SELECT emp_name,department,salary FROM employee_detail;
```

**Result:** 51 rows with 3 columns showing employee names, departments, and salaries

---

## 3. Find employees working in IT department (HR Executive)
```
SELECT * from employee_detail
WHERE department ='HR Executive';
```

**Result:**
| emp_id | emp_name | department | age | salary | emp_exp | mail_id |
|--------|----------|-----------|-----|--------|---------|---------|
| 4 | Neha Verma | HR Executive | 26 | 42000 | 3 | neha.verma@gmail.com |
| 12 | Ritu Malhotra | HR Executive | 28 | 44000 | 5 | ritu.malhotra@gmail.com |
| 19 | Neha Verma | HR Executive | 26 | 42000 | 3 | neha.verma@gmail.com |
| 37 | Ritu Malhotra | HR Executive | 28 | 44000 | 5 | ritu.malhotra@gmail.com |

**Count:** 4 employees

---

## 4. Get employees whose salary is greater than 50,000
```
SELECT emp_name,salary FROM employee_detail
WHERE salary>50000;
```

**Result:** 27 employees with salaries exceeding 50,000

---

## 5. List employees where age is NULL
```
SELECT emp_name, age FROM employee_detail
WHERE age IS NULL;
```

**Result:** No records (All employees have age values)

---

## 6. Count total employees
```
SELECT COUNT(emp_name) as Total_emp_count FROM employee_detail;
```

**Result:**
| Total_emp_count |
|-----------------|
| 51 |

---

## 7. Display distinct departments
```
SELECT DISTINCT(department) as Distinct_department FROM employee_detail;
```

**Result:** 24 unique departments:
- Business Analyst
- Cloud Engineer
- Content Strategist
- Data Analyst
- Data Engineer
- Data Scientist
- Database Admin
- DevOps Engineer
- Finance Analyst
- HR Executive
- HR Manager
- Marketing Analyst
- Network Engineer
- Operations Lead
- Product Analyst
- Product Owner
- Project Engineer
- Project Manager
- QA Engineer
- QA Lead
- Recruiter
- Sales Executive
- Security Analyst
- Software Engineer
- Support Engineer
- System Admin
- Tech Lead
- UI Designer

---

## 8. Sort employees by salary in descending order
```
SELECT * FROM employee_detail
ORDER BY salary DESC;
```

**Result:** 51 employees sorted from highest to lowest salary
**Top 3 by Salary:**
1. Ajay Kulkarni - 92,000
2. Manoj Singh - 90,000
3. Harsh Vardhan - 85,000

---

## 9. Find employees with experience more than 5 years
```
SELECT emp_name,emp_exp FROM employee_detail
WHERE emp_exp>5;
```

**Result:** 17 employees with more than 5 years of experience

---

## 10. Find employees whose name starts with 'S'
```
SELECT emp_name FROM employee_detail
WHERE emp_name LIKE 'S%';
```

**Result:** 7 employees:
- Suresh Yadav (appears 3 times)
- Sunita Rao
- Sanjay Das
- Saurabh Pandey
- Shalini Bose
- Sonal Arora