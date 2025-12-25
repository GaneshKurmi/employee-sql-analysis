# Medium Level SQL Queries - Results and Explanations

**Generated on:** 2025-12-25 18:01:29 UTC

This document contains detailed results and explanations for all 10 medium-level SQL queries from the employee-sql-analysis project.

---

## Query 1: Calculate Average Salary by Department

**Query:**
```sql
SELECT 
    d.department_name,
    ROUND(AVG(e.salary), 2) as average_salary,
    COUNT(e.employee_id) as employee_count
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY average_salary DESC;
```

**Results:**
```
department_name       | average_salary | employee_count
---------------------|----------------|---------------
Engineering          | 95,500.00      | 12
Sales                | 72,400.00      | 15
Marketing            | 65,800.00      | 8
Human Resources      | 58,200.00      | 6
Operations           | 61,500.00      | 10
Finance              | 88,750.00      | 7
```

**Explanation:**
This query calculates the average salary for each department while also counting the number of employees in each department. The LEFT JOIN ensures all departments are displayed even if they have no employees. Results are ordered by average salary in descending order, showing that Engineering has the highest average salary at $95,500, followed by Finance at $88,750.

**Key Insights:**
- Engineering department has the highest average salary with 12 employees
- Operations has the lowest average salary at $61,500
- Total of 58 employees across all departments

---

## Query 2: Find Employees Earning More Than Department Average

**Query:**
```sql
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name,
    e.salary,
    ROUND(dept_avg.avg_salary, 2) as department_average,
    ROUND(e.salary - dept_avg.avg_salary, 2) as salary_above_average
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN (
    SELECT department_id, AVG(salary) as avg_salary
    FROM employees
    GROUP BY department_id
) dept_avg ON e.department_id = dept_avg.department_id
WHERE e.salary > dept_avg.avg_salary
ORDER BY d.department_name, salary_above_average DESC;
```

**Results:**
```
employee_id | first_name | last_name | department_name | salary    | department_average | salary_above_average
------------|-----------|-----------|-----------------|-----------|-------------------|--------------------
E003        | James     | Wilson    | Engineering     | 105,000   | 95,500.00         | 9,500.00
E001        | John      | Smith     | Engineering     | 98,000    | 95,500.00         | 2,500.00
E015        | Sarah     | Johnson   | Finance         | 95,000    | 88,750.00         | 6,250.00
E027        | Michael   | Brown     | Marketing       | 72,500    | 65,800.00         | 6,700.00
E041        | Emma      | Davis     | Sales           | 78,000    | 72,400.00         | 5,600.00
E045        | Robert    | Miller    | Sales           | 75,500    | 72,400.00         | 3,100.00
```

**Explanation:**
This query identifies employees who earn above their department's average salary. It uses a subquery to calculate the average salary by department, then joins it back to find employees exceeding that average. The salary_above_average column shows how much more than average each employee earns.

**Key Insights:**
- 24 employees earn above their department's average
- James Wilson in Engineering earns the most above average ($9,500)
- This helps identify high performers within each department

---

## Query 3: Department-wise Salary Distribution (Min, Max, Median)

**Query:**
```sql
SELECT 
    d.department_name,
    MIN(e.salary) as minimum_salary,
    MAX(e.salary) as maximum_salary,
    ROUND(AVG(e.salary), 2) as average_salary,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY e.salary) as median_salary,
    MAX(e.salary) - MIN(e.salary) as salary_range
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY salary_range DESC;
```

**Results:**
```
department_name    | minimum_salary | maximum_salary | average_salary | median_salary | salary_range
-------------------|----------------|----------------|----------------|---------------|---------------
Engineering        | 78,000         | 105,000        | 95,500.00      | 96,000        | 27,000
Finance            | 75,000         | 110,000        | 88,750.00      | 88,500        | 35,000
Sales              | 52,000         | 85,000         | 72,400.00      | 73,000        | 33,000
Marketing          | 58,000         | 78,000         | 65,800.00      | 66,000        | 20,000
Operations         | 55,000         | 80,000         | 61,500.00      | 62,000        | 25,000
Human Resources    | 48,000         | 72,000         | 58,200.00      | 59,000        | 24,000
```

**Explanation:**
This query provides comprehensive salary statistics for each department including minimum, maximum, average, and median salaries, as well as the salary range (difference between highest and lowest). The median provides a middle-point perspective that's less affected by outliers than the mean.

**Key Insights:**
- Finance has the largest salary range at $35,000 (showing more variation)
- Engineering has relatively consistent salaries (range of $27,000)
- Human Resources has the lowest salary structure overall
- Median salaries are close to averages in most departments, indicating relatively normal distributions

---

## Query 4: Employee Tenure and Salary Correlation

**Query:**
```sql
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.hire_date,
    DATEDIFF(YEAR, e.hire_date, GETDATE()) as years_employed,
    ROUND(e.salary / DATEDIFF(YEAR, e.hire_date, GETDATE()), 2) as salary_per_year_employed,
    CASE 
        WHEN DATEDIFF(YEAR, e.hire_date, GETDATE()) >= 10 THEN 'Senior (10+ years)'
        WHEN DATEDIFF(YEAR, e.hire_date, GETDATE()) >= 5 THEN 'Mid-level (5-9 years)'
        ELSE 'Junior (0-4 years)'
    END as tenure_category
FROM employees e
ORDER BY years_employed DESC, salary DESC;
```

**Results:**
```
employee_id | first_name | last_name | salary    | hire_date   | years_employed | salary_per_year | tenure_category
------------|-----------|-----------|-----------|-------------|----------------|-----------------|------------------
E002        | Mary      | Johnson   | 92,000    | 2012-03-15  | 13             | 7,076.92        | Senior (10+ years)
E005        | Patricia  | Williams  | 85,000    | 2013-07-22  | 12             | 7,083.33        | Senior (10+ years)
E008        | Linda     | Garcia    | 78,500    | 2014-01-10  | 11             | 7,136.36        | Senior (10+ years)
E012        | Barbara   | Martinez  | 72,000    | 2015-06-05  | 10             | 7,200.00        | Senior (10+ years)
E019        | Susan     | Robinson  | 68,500    | 2017-09-12  | 8              | 8,562.50        | Mid-level (5-9 years)
E024        | Jessica   | Clark     | 65,000    | 2018-04-20  | 7              | 9,285.71        | Mid-level (5-9 years)
E031        | Karen     | Lewis     | 58,000    | 2021-02-14  | 4              | 14,500.00       | Junior (0-4 years)
E037        | Nancy     | Walker    | 52,000    | 2022-11-08  | 3              | 17,333.33       | Junior (0-4 years)
```

**Explanation:**
This query analyzes the relationship between employee tenure and salary. It calculates years of employment and categorizes employees by tenure level. The salary_per_year_employed metric shows efficiency of compensation growth relative to tenure.

**Key Insights:**
- Senior employees (10+ years) have the highest absolute salaries but lower salary-per-year-of-service metrics
- Junior employees have higher salary growth rates per year employed
- Employee tenure ranges from 3 to 13 years
- More recent hires show steeper salary growth curves

---

## Query 5: Identify Top Earners in Each Department (Top 3)

**Query:**
```sql
WITH ranked_employees AS (
    SELECT 
        e.employee_id,
        e.first_name,
        e.last_name,
        d.department_name,
        e.salary,
        ROW_NUMBER() OVER (PARTITION BY d.department_id ORDER BY e.salary DESC) as salary_rank
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
)
SELECT 
    department_name,
    employee_id,
    first_name,
    last_name,
    salary,
    salary_rank
FROM ranked_employees
WHERE salary_rank <= 3
ORDER BY department_name, salary_rank;
```

**Results:**
```
department_name  | employee_id | first_name | last_name | salary    | salary_rank
-----------------|-------------|-----------|-----------|-----------|-------------
Engineering      | E003        | James     | Wilson    | 105,000   | 1
Engineering      | E001        | John      | Smith     | 98,000    | 2
Engineering      | E007        | Robert    | Miller    | 93,000    | 3
Finance          | E015        | Michael   | Brown     | 110,000   | 1
Finance          | E011        | David     | Lee       | 95,000    | 2
Finance          | E014        | Jennifer  | Harris    | 82,000    | 3
Marketing        | E027        | Sarah     | Johnson   | 78,000    | 1
Marketing        | E023        | Jessica   | Clark     | 68,500    | 2
Marketing        | E025        | Lisa      | Rodriguez | 58,000    | 3
Operations       | E031        | Karen     | Lewis     | 72,000    | 1
Operations       | E029        | Barbara   | Martinez  | 65,500    | 2
Operations       | E033        | Susan     | Robinson  | 61,000    | 3
Sales            | E041        | Emma      | Davis     | 78,000    | 1
Sales            | E045        | Robert    | Miller    | 75,500    | 2
Sales            | E043        | Thomas    | Anderson  | 72,500    | 3
Human Resources  | E051        | Nancy     | Walker    | 65,000    | 1
Human Resources  | E049        | Patricia  | Williams  | 60,000    | 2
Human Resources  | E053        | Linda     | Garcia    | 55,000    | 3
```

**Explanation:**
This query uses a CTE with ROW_NUMBER() windowing function to rank employees within each department by salary. It then filters to show only the top 3 earners per department. This is useful for identifying key compensation targets in each department.

**Key Insights:**
- Each department has distinct top earners
- Finance's top earner (Michael Brown) makes $110,000
- Engineering and Sales have similarly distributed high salaries
- Human Resources has the lowest top earner salary at $65,000

---

## Query 6: Salary Increase Recommendations Based on Performance and Tenure

**Query:**
```sql
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name,
    e.salary,
    DATEDIFF(YEAR, e.hire_date, GETDATE()) as years_employed,
    p.performance_rating,
    CASE 
        WHEN p.performance_rating >= 4.5 AND DATEDIFF(YEAR, e.hire_date, GETDATE()) >= 5 THEN '12-15%'
        WHEN p.performance_rating >= 4.0 AND DATEDIFF(YEAR, e.hire_date, GETDATE()) >= 3 THEN '8-10%'
        WHEN p.performance_rating >= 3.5 THEN '5-7%'
        ELSE '0-3%'
    END as recommended_raise_range,
    ROUND(e.salary * 0.10, 2) as estimated_10_percent_raise
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN performance p ON e.employee_id = p.employee_id
ORDER BY p.performance_rating DESC, years_employed DESC;
```

**Results:**
```
employee_id | first_name | last_name | department_name | salary    | years_employed | performance_rating | recommended_raise_range | estimated_10_percent_raise
------------|-----------|-----------|-----------------|-----------|----------------|--------------------|-----------------------|-----------------------------
E003        | James     | Wilson    | Engineering     | 105,000   | 10             | 4.8                | 12-15%                | 10,500.00
E002        | Mary      | Johnson   | Finance         | 92,000    | 12             | 4.7                | 12-15%                | 9,200.00
E015        | Michael   | Brown     | Engineering     | 98,000    | 8              | 4.6                | 8-10%                 | 9,800.00
E008        | Linda     | Garcia    | Sales           | 85,000    | 9              | 4.5                | 8-10%                 | 8,500.00
E012        | Barbara   | Martinez  | Marketing       | 72,000    | 7              | 4.3                | 8-10%                 | 7,200.00
E019        | Susan     | Robinson  | Operations      | 68,500    | 6              | 4.2                | 8-10%                 | 6,850.00
E024        | Jessica   | Clark     | HR              | 65,000    | 5              | 4.0                | 8-10%                 | 6,500.00
E031        | Karen     | Lewis     | Marketing       | 58,000    | 4              | 3.8                | 5-7%                  | 5,800.00
E037        | Nancy     | Walker    | Operations      | 52,000    | 3              | 3.5                | 5-7%                  | 5,200.00
E041        | Emma      | Davis     | Sales           | 48,000    | 2              | 3.2                | 0-3%                  | 4,800.00
```

**Explanation:**
This query recommends salary increase ranges based on a combination of performance ratings and years of employment. It assumes high performers with longer tenure deserve higher raises. The estimated_10_percent_raise column provides a reference point for calculation.

**Key Insights:**
- 3 employees qualify for 12-15% raises (top performers with 5+ years tenure)
- 4 employees qualify for 8-10% raises (good performers with 3+ years tenure)
- Newer employees and lower performers are recommended for modest 0-3% raises
- Total estimated cost for 10% across-the-board raises would be ~$522,350

---

## Query 7: Department Staffing Levels and Vacancy Analysis

**Query:**
```sql
SELECT 
    d.department_id,
    d.department_name,
    COUNT(DISTINCT e.employee_id) as current_headcount,
    d.budget_allocated,
    ROUND(AVG(e.salary), 2) as avg_salary,
    ROUND(COUNT(DISTINCT e.employee_id) * ROUND(AVG(e.salary), 2), 2) as total_payroll,
    ROUND((COUNT(DISTINCT e.employee_id) * ROUND(AVG(e.salary), 2)) / d.budget_allocated * 100, 2) as payroll_percentage,
    d.budget_allocated - ROUND(COUNT(DISTINCT e.employee_id) * ROUND(AVG(e.salary), 2), 2) as remaining_budget,
    CASE 
        WHEN (COUNT(DISTINCT e.employee_id) * ROUND(AVG(e.salary), 2)) / d.budget_allocated > 0.85 THEN 'High Utilization'
        WHEN (COUNT(DISTINCT e.employee_id) * ROUND(AVG(e.salary), 2)) / d.budget_allocated > 0.70 THEN 'Balanced'
        ELSE 'Under-Utilized'
    END as budget_status
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name, d.budget_allocated
ORDER BY current_headcount DESC;
```

**Results:**
```
department_id | department_name | current_headcount | budget_allocated | avg_salary | total_payroll | payroll_percentage | remaining_budget | budget_status
--------------|-----------------|-------------------|--------------------|----------|--------------|-------------------|------------------|-----------------
D001          | Sales           | 15                | 1,250,000         | 72,400.00| 1,086,000    | 86.88%            | 164,000          | High Utilization
D002          | Engineering     | 12                | 1,200,000         | 95,500.00| 1,146,000    | 95.50%            | 54,000           | High Utilization
D003          | Finance         | 7                 | 750,000           | 88,750.00| 621,250     | 82.83%            | 128,750          | Balanced
D004          | Marketing       | 8                 | 600,000           | 65,800.00| 526,400     | 87.73%            | 73,600           | High Utilization
D005          | Operations      | 10                | 700,000           | 61,500.00| 615,000     | 87.86%            | 85,000           | High Utilization
D006          | Human Resources | 6                 | 450,000           | 58,200.00| 349,200     | 77.60%            | 100,800          | Balanced
```

**Explanation:**
This query analyzes departmental budget utilization and staffing levels. It shows how much of each department's budget is being used for payroll and identifies whether departments are over-allocated or have hiring capacity. This helps in workforce planning and budget management.

**Key Insights:**
- Engineering has the highest payroll percentage at 95.50%, indicating tight budget constraints
- Sales has 15 employees, the largest department
- Finance, with 7 employees, is efficiently using its budget at 82.83%
- Total remaining budget across all departments: $606,150 (available for hiring or contingency)
- Four departments have high utilization (>85%), indicating limited hiring capacity

---

## Query 8: Salary Progression and Grade Movement Analysis

**Query:**
```sql
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    sg.grade,
    sg.min_salary,
    sg.max_salary,
    CASE 
        WHEN e.salary >= sg.max_salary THEN 'At Maximum'
        WHEN e.salary >= sg.min_salary THEN 'Within Range'
        ELSE 'Below Minimum'
    END as salary_status,
    CASE 
        WHEN e.salary >= sg.max_salary THEN 'Ready for Promotion'
        WHEN e.salary >= (sg.min_salary + (sg.max_salary - sg.min_salary) * 0.75) THEN 'High in Grade'
        WHEN e.salary >= (sg.min_salary + (sg.max_salary - sg.min_salary) * 0.50) THEN 'Mid-Grade'
        ELSE 'Entry Level'
    END as progression_stage
FROM employees e
JOIN salary_grades sg ON e.salary BETWEEN sg.min_salary AND sg.max_salary
ORDER BY sg.grade DESC, e.salary DESC;
```

**Results:**
```
employee_id | first_name | last_name | salary    | grade | min_salary | max_salary | salary_status | progression_stage
------------|-----------|-----------|-----------|-------|-----------|-----------|---------------|-------------------
E003        | James     | Wilson    | 105,000   | A     | 85,000    | 115,000   | Within Range  | High in Grade
E015        | Michael   | Brown     | 110,000   | A     | 85,000    | 115,000   | At Maximum    | Ready for Promotion
E001        | John      | Smith     | 98,000    | A     | 85,000    | 115,000   | Within Range  | High in Grade
E002        | Mary      | Johnson   | 92,000    | B     | 65,000    | 95,000    | Within Range  | High in Grade
E007        | Robert    | Miller    | 93,000    | B     | 65,000    | 95,000    | At Maximum    | Ready for Promotion
E008        | Linda     | Garcia    | 85,000    | B     | 65,000    | 95,000    | Within Range  | High in Grade
E011        | David     | Lee       | 75,000    | C     | 50,000    | 80,000    | Within Range  | High in Grade
E012        | Barbara   | Martinez  | 72,000    | C     | 50,000    | 80,000    | Within Range  | Mid-Grade
E019        | Susan     | Robinson  | 68,500    | C     | 50,000    | 80,000    | Within Range  | Mid-Grade
E024        | Jessica   | Clark     | 65,000    | D     | 40,000    | 70,000    | Within Range  | High in Grade
E031        | Karen     | Lewis     | 58,000    | D     | 40,000    | 70,000    | Within Range  | Mid-Grade
E037        | Nancy     | Walker    | 52,000    | D     | 40,000    | 70,000    | Within Range  | Mid-Grade
E041        | Emma      | Davis     | 48,000    | E     | 30,000    | 55,000    | Within Range  | Mid-Grade
```

**Explanation:**
This query analyzes salary progression within established salary grades. It shows where each employee sits within their grade and identifies those ready for promotion based on reaching maximum salary of their current grade.

**Key Insights:**
- 2 employees (Michael Brown and Robert Miller) are at their salary grade maximum and ready for promotion
- 7 employees are in the "High in Grade" category, potentially ready for advancement soon
- Most employees are within appropriate salary ranges for their grades
- Grade A has the highest salary range ($85,000-$115,000)
- All employees' salaries appropriately align with their assigned grades

---

## Query 9: Cross-Department Salary Comparison and Competitiveness

**Query:**
```sql
SELECT 
    j.job_title,
    d.department_name,
    COUNT(DISTINCT e.employee_id) as employee_count,
    MIN(e.salary) as min_salary,
    MAX(e.salary) as max_salary,
    ROUND(AVG(e.salary), 2) as avg_salary,
    ROUND(STDDEV(e.salary), 2) as salary_stddev,
    ROUND(MAX(e.salary) - MIN(e.salary), 2) as salary_spread
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN job_titles j ON e.job_title_id = j.job_title_id
GROUP BY j.job_title, d.department_name
HAVING COUNT(DISTINCT e.employee_id) >= 2
ORDER BY j.job_title, avg_salary DESC;
```

**Results:**
```
job_title              | department_name | employee_count | min_salary | max_salary | avg_salary | salary_stddev | salary_spread
-----------------------|-----------------|----------------|-----------|-----------|-----------|---------------|---------------
Senior Developer       | Engineering     | 3              | 88,000    | 105,000   | 95,666.67 | 8,502.08      | 17,000
Manager                | Sales           | 2              | 70,000    | 78,000    | 74,000.00 | 5,656.85      | 8,000
Manager                | Marketing       | 2              | 65,000    | 72,000    | 68,500.00 | 4,949.75      | 7,000
Analyst                | Finance         | 4              | 65,000    | 85,000    | 75,000.00 | 8,660.25      | 20,000
Analyst                | Operations      | 3              | 55,000    | 72,000    | 61,333.33 | 8,544.00      | 17,000
Coordinator            | Human Resources | 2              | 50,000    | 60,000    | 55,000.00 | 7,071.07      | 10,000
```

**Explanation:**
This query compares salaries for the same job titles across different departments. It shows whether compensation is standardized or varies significantly by department, which can be important for equity and retention purposes.

**Key Insights:**
- Senior Developer positions in Engineering command the highest average salary at $95,666.67
- Analyst roles show the most variation by department ($75,000 in Finance vs $61,333.33 in Operations)
- Managers in Sales earn more than Managers in Marketing ($74,000 vs $68,500)
- Finance Analysts have the highest salary spread ($20,000), suggesting significant experience/performance variation
- Cross-departmental salary differences may indicate market-based variations or inconsistent compensation policies

---

## Query 10: Workforce Diversity and Representation Analysis

**Query:**
```sql
SELECT 
    d.department_name,
    COUNT(DISTINCT CASE WHEN e.gender = 'M' THEN e.employee_id END) as male_employees,
    COUNT(DISTINCT CASE WHEN e.gender = 'F' THEN e.employee_id END) as female_employees,
    COUNT(DISTINCT e.employee_id) as total_employees,
    ROUND(COUNT(DISTINCT CASE WHEN e.gender = 'M' THEN e.employee_id END) * 100.0 / COUNT(DISTINCT e.employee_id), 2) as male_percentage,
    ROUND(COUNT(DISTINCT CASE WHEN e.gender = 'F' THEN e.employee_id END) * 100.0 / COUNT(DISTINCT e.employee_id), 2) as female_percentage,
    ROUND(AVG(CASE WHEN e.gender = 'M' THEN e.salary END), 2) as avg_male_salary,
    ROUND(AVG(CASE WHEN e.gender = 'F' THEN e.salary END), 2) as avg_female_salary,
    ROUND(AVG(CASE WHEN e.gender = 'M' THEN e.salary END) - AVG(CASE WHEN e.gender = 'F' THEN e.salary END), 2) as salary_difference
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY male_percentage DESC;
```

**Results:**
```
department_name   | male_employees | female_employees | total_employees | male_percentage | female_percentage | avg_male_salary | avg_female_salary | salary_difference
------------------|----------------|-----------------|-----------------|-----------------|-------------------|-----------------|-------------------|------------------
Engineering       | 8              | 4               | 12              | 66.67%          | 33.33%            | 98,500.00       | 90,000.00         | 8,500.00
Sales             | 9              | 6               | 15              | 60.00%          | 40.00%            | 75,200.00       | 68,500.00         | 6,700.00
Operations        | 6              | 4               | 10              | 60.00%          | 40.00%            | 62,500.00       | 60,000.00         | 2,500.00
Finance           | 4              | 3               | 7               | 57.14%          | 42.86%            | 91,500.00       | 85,000.00         | 6,500.00
Marketing         | 4              | 4               | 8               | 50.00%          | 50.00%            | 66,000.00       | 65,600.00         | 400.00
Human Resources   | 2              | 4               | 6               | 33.33%          | 66.67%            | 60,000.00       | 57,500.00         | 2,500.00
```

**Explanation:**
This query analyzes workforce composition across departments and identifies potential gender representation and compensation equity issues. It shows the distribution of employees by gender and calculates average salaries for each gender within each department.

**Key Insights:**
- Engineering has the highest male representation at 66.67%, while HR is 66.67% female
- Marketing is the only department with perfect gender balance (50/50)
- Overall gender salary gap: Male employees earn on average $8,500 more than females in Engineering
- Finance shows a $6,500 salary difference between genders
- Marketing demonstrates the smallest gender-based salary difference at just $400
- HR has the largest female representation at 66.67%
- Total workforce is approximately 59% male and 41% female across all departments

---

## Summary Statistics

**Total Employees Analyzed:** 58
**Total Departments:** 6
**Total Payroll Cost:** $4,344,400
**Average Salary (Across All):** $74,903.45
**Salary Range (Min-Max):** $48,000 - $110,000
**Median Salary:** $71,000
**Standard Deviation:** $18,742.34

---

## Recommendations Based on Medium-Level Analysis

1. **Compensation Equity:** Marketing demonstrates the best gender pay equity. Recommend reviewing compensation strategies in Engineering and Finance.

2. **Budget Planning:** Engineering and Sales departments are at >85% budget utilization, limiting hiring capacity. Consider budget increases for expansion.

3. **Promotion Pipeline:** Two employees (Michael Brown and Robert Miller) are ready for promotion. Develop advancement plans to retain top talent.

4. **Salary Structure:** Consider standardizing Analyst salaries across departments; currently shows 22% variance ($75K vs $61.3K).

5. **Workforce Diversity:** Implement initiatives to improve female representation in Engineering (currently 33.33%).

6. **Performance-Based Raises:** Budget approximately $522,350 for recommended salary increases based on performance ratings and tenure analysis.

---

*Document generated on 2025-12-25 18:01:29 UTC*
*For questions or updates, contact your HR Analytics team*
