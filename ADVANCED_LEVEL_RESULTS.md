# Advanced Level SQL Query Results & Analysis

**Last Updated:** 2025-12-25 18:04:00 UTC

---

## Table of Contents
1. [Second Highest Salary Analysis](#second-highest-salary-analysis)
2. [Common Table Expressions (CTEs)](#common-table-expressions-ctes)
3. [Window Functions](#window-functions)
4. [Duplicate Data Analysis](#duplicate-data-analysis)
5. [Database Indexing Strategy](#database-indexing-strategy)
6. [Views and Virtual Tables](#views-and-virtual-tables)
7. [DELETE vs TRUNCATE vs DROP Comparison](#delete-vs-truncate-vs-drop-comparison)
8. [Performance Optimization](#performance-optimization)

---

## Second Highest Salary Analysis

### Method 1: Using LIMIT with ORDER BY

```sql
SELECT 
    employee_id,
    employee_name,
    salary,
    department
FROM employees
ORDER BY salary DESC
LIMIT 1 OFFSET 1;
```

**Explanation:**
- `ORDER BY salary DESC` sorts employees by salary in descending order
- `LIMIT 1` retrieves one record
- `OFFSET 1` skips the first record (highest salary)
- Simple and efficient for small datasets
- **Performance:** O(n log n) due to sorting

**Results Example:**
```
employee_id | employee_name | salary  | department
------------|---------------|---------|------------
E102        | John Smith    | 95000   | Engineering
```

---

### Method 2: Using Subquery with MAX

```sql
SELECT 
    employee_id,
    employee_name,
    salary,
    department
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
    WHERE salary < (SELECT MAX(salary) FROM employees)
)
LIMIT 1;
```

**Explanation:**
- Finds the maximum salary that is less than the overall maximum
- Handles multiple employees with the same second-highest salary
- More explicit and self-documenting
- **Performance:** O(n) - requires two full table scans

---

### Method 3: Using Window Functions (RECOMMENDED)

```sql
WITH ranked_employees AS (
    SELECT 
        employee_id,
        employee_name,
        salary,
        department,
        ROW_NUMBER() OVER (ORDER BY salary DESC) as salary_rank,
        RANK() OVER (ORDER BY salary DESC) as salary_rank_with_ties,
        DENSE_RANK() OVER (ORDER BY salary DESC) as dense_salary_rank
    FROM employees
)
SELECT 
    employee_id,
    employee_name,
    salary,
    department,
    salary_rank,
    salary_rank_with_ties,
    dense_salary_rank
FROM ranked_employees
WHERE dense_salary_rank = 2;
```

**Results Example:**
```
employee_id | employee_name | salary  | department | salary_rank | salary_rank_with_ties | dense_salary_rank
------------|---------------|---------|------------|-------------|----------------------|------------------
E102        | John Smith    | 95000   | Engineering| 2           | 2                    | 2
E103        | Jane Doe      | 95000   | Sales      | 3           | 2                    | 2
E104        | Mike Johnson  | 92000   | Engineering| 4           | 4                    | 3
```

**Key Differences:**
- **ROW_NUMBER():** Assigns unique sequential numbers; gaps if ties exist
- **RANK():** Same rank for ties, skips next ranks
- **DENSE_RANK():** Same rank for ties, no gaps in ranking

**Performance:** O(n) - single pass with window function

---

### Method 4: Using OFFSET in Window Function

```sql
WITH salary_window AS (
    SELECT 
        employee_id,
        employee_name,
        salary,
        department,
        LAG(salary) OVER (ORDER BY salary DESC) as next_lower_salary
    FROM employees
)
SELECT DISTINCT
    employee_id,
    employee_name,
    salary,
    department,
    next_lower_salary
FROM salary_window
WHERE salary = next_lower_salary
   OR salary > next_lower_salary;
```

---

## Common Table Expressions (CTEs)

### What are CTEs?
Common Table Expressions (CTEs) are temporary result sets that exist only within the scope of a single query. They improve readability and support recursive queries.

### Syntax:
```sql
WITH cte_name AS (
    -- CTE definition
    SELECT ...
)
SELECT * FROM cte_name;
```

---

### Example 1: Multi-Level Salary Analysis with CTEs

```sql
WITH salary_statistics AS (
    SELECT 
        department,
        AVG(salary) as avg_salary,
        MIN(salary) as min_salary,
        MAX(salary) as max_salary,
        COUNT(*) as employee_count,
        STDDEV(salary) as salary_stddev
    FROM employees
    GROUP BY department
),
salary_outliers AS (
    SELECT 
        e.employee_id,
        e.employee_name,
        e.salary,
        e.department,
        ss.avg_salary,
        ss.salary_stddev,
        ABS(e.salary - ss.avg_salary) / NULLIF(ss.salary_stddev, 0) as z_score
    FROM employees e
    JOIN salary_statistics ss ON e.department = ss.department
)
SELECT 
    employee_id,
    employee_name,
    salary,
    department,
    avg_salary,
    salary_stddev,
    z_score,
    CASE 
        WHEN ABS(z_score) > 2 THEN 'OUTLIER'
        WHEN ABS(z_score) > 1 THEN 'UNUSUAL'
        ELSE 'NORMAL'
    END as salary_classification
FROM salary_outliers
ORDER BY z_score DESC;
```

**Results Example:**
```
employee_id | employee_name   | salary | department  | avg_salary | salary_stddev | z_score | salary_classification
------------|-----------------|--------|-------------|------------|---------------|---------|----------------------
E101        | Sarah Williams  | 120000 | Engineering | 98500      | 15000         | 1.43    | UNUSUAL
E205        | Alex Chen       | 75000  | Sales       | 85000      | 8000          | -1.25   | UNUSUAL
E310        | Pat Martinez    | 50000  | Marketing   | 72000      | 12000         | -1.83   | OUTLIER
```

**Benefits:**
- Improves query readability
- Easier to debug and maintain
- Allows reuse of intermediate results
- Can reference other CTEs

---

### Example 2: Recursive CTE - Employee Hierarchy

```sql
WITH RECURSIVE employee_hierarchy AS (
    -- Anchor: Start with employees who have no manager (root level)
    SELECT 
        employee_id,
        employee_name,
        manager_id,
        department,
        salary,
        1 as hierarchy_level,
        CAST(employee_name AS CHAR(200)) as hierarchy_path
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive: Get direct reports at each level
    SELECT 
        e.employee_id,
        e.employee_name,
        e.manager_id,
        e.department,
        e.salary,
        eh.hierarchy_level + 1,
        CONCAT(eh.hierarchy_path, ' -> ', e.employee_name)
    FROM employees e
    INNER JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
    WHERE eh.hierarchy_level < 10 -- Prevent infinite recursion
)
SELECT 
    employee_id,
    employee_name,
    manager_id,
    department,
    salary,
    hierarchy_level,
    hierarchy_path
FROM employee_hierarchy
ORDER BY hierarchy_level, employee_name;
```

**Results Example:**
```
employee_id | employee_name | manager_id | department  | salary | hierarchy_level | hierarchy_path
------------|---------------|------------|-------------|--------|-----------------|----------------------------------
E001        | CEO Name      | NULL       | Executive   | 200000 | 1               | CEO Name
E010        | VP Eng        | E001       | Engineering | 150000 | 2               | CEO Name -> VP Eng
E101        | Manager Eng   | E010       | Engineering | 120000 | 3               | CEO Name -> VP Eng -> Manager Eng
E102        | John Smith    | E101       | Engineering | 95000  | 4               | CEO Name -> VP Eng -> Manager Eng -> John Smith
```

**Use Cases:**
- Organizational hierarchies
- Bill of Materials (BOM) in manufacturing
- Category hierarchies
- Path tracking

---

## Window Functions

Window functions perform calculations across a set of rows related to the current row.

### Syntax:
```sql
function_name() OVER (
    [PARTITION BY column1, column2...]
    [ORDER BY column1 [ASC|DESC], column2...]
    [ROWS/RANGE BETWEEN ...]
)
```

---

### Example 1: Comprehensive Employee Analysis

```sql
SELECT 
    employee_id,
    employee_name,
    department,
    salary,
    hire_date,
    
    -- Ranking Functions
    ROW_NUMBER() OVER (ORDER BY salary DESC) as overall_salary_rank,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) as dept_salary_rank,
    DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) as dept_dense_rank,
    
    -- Aggregate Functions as Window Functions
    AVG(salary) OVER (PARTITION BY department) as dept_avg_salary,
    MAX(salary) OVER (PARTITION BY department) as dept_max_salary,
    MIN(salary) OVER (PARTITION BY department) as dept_min_salary,
    COUNT(*) OVER (PARTITION BY department) as dept_employee_count,
    SUM(salary) OVER (PARTITION BY department) as dept_total_salary,
    
    -- Offset Functions
    LAG(salary, 1) OVER (PARTITION BY department ORDER BY hire_date) as previous_employee_salary,
    LEAD(salary, 1) OVER (PARTITION BY department ORDER BY hire_date) as next_employee_salary,
    FIRST_VALUE(salary) OVER (PARTITION BY department ORDER BY salary DESC) as dept_highest_salary,
    LAST_VALUE(salary) OVER (PARTITION BY department ORDER BY salary DESC 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as dept_lowest_salary,
    
    -- Comparison Calculations
    salary - AVG(salary) OVER (PARTITION BY department) as salary_vs_dept_avg,
    ROUND(((salary - AVG(salary) OVER (PARTITION BY department)) / 
        AVG(salary) OVER (PARTITION BY department) * 100), 2) as percent_vs_avg,
    
    -- Running Totals (for salary in department, ordered by hire date)
    SUM(salary) OVER (PARTITION BY department ORDER BY hire_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as running_total_salary,
    
    -- Percentile Functions
    NTILE(4) OVER (PARTITION BY department ORDER BY salary DESC) as salary_quartile,
    PERCENT_RANK() OVER (PARTITION BY department ORDER BY salary) as salary_percentile_rank,
    CUME_DIST() OVER (PARTITION BY department ORDER BY salary) as salary_cumulative_dist
    
FROM employees
ORDER BY department, salary DESC;
```

**Results Example:**
```
employee_id | employee_name | department  | salary | hire_date  | overall_salary_rank | dept_salary_rank | dept_dense_rank | dept_avg_salary | dept_max_salary | dept_min_salary | dept_employee_count | salary_vs_dept_avg | percent_vs_avg | salary_quartile | salary_percentile_rank
------------|---------------|-------------|--------|------------|---------------------|------------------|-----------------|-----------------|-----------------|-----------------|---------------------|-------------------|-----------------|-----------------|--------------------
E101        | Sarah Williams| Engineering | 120000 | 2020-01-15 | 1                   | 1                | 1               | 98500           | 120000          | 75000           | 8                   | 21500             | 21.82%          | 1               | 0.857
E102        | John Smith    | Engineering | 95000  | 2020-06-20 | 3                   | 2                | 2               | 98500           | 120000          | 75000           | 8                   | -3500             | -3.55%          | 2               | 0.571
E103        | Jane Doe      | Sales       | 90000  | 2021-03-10 | 4                   | 1                | 1               | 85000           | 90000           | 78000           | 5                   | 5000              | 5.88%           | 1               | 1.000
```

---

### Example 2: Year-over-Year Salary Analysis

```sql
WITH salary_history AS (
    SELECT 
        employee_id,
        employee_name,
        salary,
        salary_effective_date,
        EXTRACT(YEAR FROM salary_effective_date) as salary_year,
        ROW_NUMBER() OVER (PARTITION BY employee_id ORDER BY salary_effective_date) as change_sequence
    FROM salary_changes
)
SELECT 
    employee_id,
    employee_name,
    salary_year,
    salary as current_salary,
    LAG(salary) OVER (PARTITION BY employee_id ORDER BY salary_year) as previous_year_salary,
    salary - LAG(salary) OVER (PARTITION BY employee_id ORDER BY salary_year) as salary_increase,
    ROUND((salary - LAG(salary) OVER (PARTITION BY employee_id ORDER BY salary_year)) / 
        LAG(salary) OVER (PARTITION BY employee_id ORDER BY salary_year) * 100, 2) as percent_increase,
    change_sequence
FROM salary_history
WHERE salary_year >= YEAR(CURDATE()) - 3
ORDER BY employee_id, salary_year;
```

---

### Example 3: Moving Average and Running Calculations

```sql
SELECT 
    employee_id,
    employee_name,
    month,
    year,
    bonus_amount,
    
    -- 3-Month Moving Average
    AVG(bonus_amount) OVER (PARTITION BY employee_id ORDER BY year, month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as moving_avg_3month,
    
    -- Year-to-Date Total
    SUM(bonus_amount) OVER (PARTITION BY employee_id, year ORDER BY month 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as ytd_bonus,
    
    -- Cumulative Average
    AVG(bonus_amount) OVER (PARTITION BY employee_id ORDER BY year, month 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as cumulative_avg,
    
    -- Comparison to Previous Month
    LAG(bonus_amount) OVER (PARTITION BY employee_id ORDER BY year, month) as previous_month_bonus,
    bonus_amount - LAG(bonus_amount) OVER (PARTITION BY employee_id ORDER BY year, month) as month_over_month_change
    
FROM bonus_history
ORDER BY employee_id, year, month;
```

---

## Duplicate Data Analysis

### Identifying Duplicates

```sql
-- Find all duplicates by email (assuming email should be unique)
WITH duplicate_check AS (
    SELECT 
        employee_id,
        employee_name,
        email,
        department,
        COUNT(*) OVER (PARTITION BY email) as email_frequency,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY employee_id) as row_num
    FROM employees
)
SELECT 
    employee_id,
    employee_name,
    email,
    department,
    email_frequency,
    row_num,
    CASE 
        WHEN email_frequency > 1 THEN 'DUPLICATE'
        ELSE 'UNIQUE'
    END as duplicate_status
FROM duplicate_check
WHERE email_frequency > 1
ORDER BY email, row_num;
```

**Results Example:**
```
employee_id | employee_name | email            | department  | email_frequency | row_num | duplicate_status
------------|---------------|------------------|-------------|-----------------|---------|------------------
E101        | Sarah Williams| sarah@company.com| Engineering | 2               | 1       | DUPLICATE
E201        | Sarah W       | sarah@company.com| Sales       | 2               | 2       | DUPLICATE
E102        | John Smith    | john.s@company.com| Engineering | 1               | 1       | UNIQUE
```

---

### Finding Complete Duplicates

```sql
-- Identify complete row duplicates
SELECT 
    employee_id,
    employee_name,
    email,
    department,
    salary,
    hire_date,
    COUNT(*) as duplicate_count,
    STRING_AGG(CAST(employee_id AS VARCHAR), ', ') as all_duplicate_ids
FROM employees
GROUP BY 
    employee_name,
    email,
    department,
    salary,
    hire_date
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
```

---

### Removing Duplicates

```sql
-- Remove duplicates, keeping only the first occurrence (by employee_id)
WITH duplicates_ranked AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY employee_id) as row_num
    FROM employees
)
DELETE FROM employees
WHERE employee_id IN (
    SELECT employee_id
    FROM duplicates_ranked
    WHERE row_num > 1
);
```

**Explanation:**
- Uses window function to identify duplicate rows
- Keeps the first occurrence (row_num = 1)
- Deletes all other occurrences

---

## Database Indexing Strategy

### Index Types and Usage

#### 1. Primary Key Index (Automatic)
```sql
-- Already created with PRIMARY KEY constraint
ALTER TABLE employees ADD PRIMARY KEY (employee_id);

-- Query performance: O(log n)
EXPLAIN SELECT * FROM employees WHERE employee_id = 'E101';
```

#### 2. Single Column Index - Most Common

```sql
-- Index for frequent searches by email
CREATE INDEX idx_employees_email ON employees(email);

-- Query benefits
EXPLAIN SELECT * FROM employees WHERE email = 'john.smith@company.com';

-- Index size check
SELECT 
    index_name,
    seq_in_index,
    column_name,
    index_type
FROM information_schema.statistics
WHERE table_name = 'employees' AND index_name = 'idx_employees_email';
```

**Use Case:** Searching, filtering
**Performance:** O(log n) lookup time

---

#### 3. Composite (Multi-Column) Index

```sql
-- Index for searches by department and salary range
CREATE INDEX idx_employees_dept_salary ON employees(department, salary);

-- Optimized query:
EXPLAIN SELECT employee_id, employee_name, salary
FROM employees
WHERE department = 'Engineering' AND salary > 100000;

-- Non-optimized query (index not used efficiently):
SELECT employee_id, employee_name, department
FROM employees
WHERE salary > 100000 AND department = 'Engineering';
```

**Rule:** Order columns by selectivity (most selective first) or query pattern
**Benefits:** 
- Covers multiple columns
- Useful for range queries
- Column order matters

---

#### 4. Unique Index

```sql
-- Ensure email uniqueness and improve lookups
CREATE UNIQUE INDEX idx_employees_email_unique ON employees(email);

-- Attempt to insert duplicate will fail
INSERT INTO employees (employee_id, email) VALUES ('E999', 'john.smith@company.com');
-- Error: Duplicate entry

-- Query performance: O(log n) with guarantee of single result
SELECT * FROM employees WHERE email = 'john.smith@company.com';
```

---

#### 5. Partial Index (Filtered Index)

```sql
-- Index only active employees
CREATE INDEX idx_employees_active_salary ON employees(salary)
WHERE status = 'ACTIVE';

-- Query using partial index:
EXPLAIN SELECT * FROM employees 
WHERE status = 'ACTIVE' AND salary > 100000;

-- Query NOT using partial index (includes inactive):
SELECT * FROM employees 
WHERE salary > 100000;
```

**Benefits:**
- Smaller index size
- Faster inserts/updates
- Better for filtered searches

---

#### 6. Full-Text Index

```sql
-- For text search in job descriptions
CREATE FULLTEXT INDEX idx_employees_skills ON employees(skills_description);

-- Full-text search query:
SELECT employee_id, employee_name, skills_description
FROM employees
WHERE MATCH(skills_description) AGAINST('+SQL +Java -Python' IN BOOLEAN MODE);

-- Natural language search:
SELECT employee_id, employee_name, skills_description
FROM employees
WHERE MATCH(skills_description) AGAINST('database programming' IN NATURAL LANGUAGE MODE);
```

---

### Index Analysis and Optimization

```sql
-- Check for unused indexes
SELECT 
    object_schema,
    object_name,
    index_handle,
    STATS_IO(index_read) as reads,
    STATS_IO(index_write) as writes,
    STATS_MEMORY(index_size) as index_size_bytes
FROM sys.dm_db_index_usage_stats
WHERE database_id = DB_ID('employee_db')
ORDER BY reads DESC;

-- Find missing indexes
SELECT 
    d.statement as table_name,
    d.equality_columns,
    d.inequality_columns,
    d.included_columns,
    s.avg_total_user_cost,
    s.avg_user_impact,
    s.user_seeks,
    s.user_scans
FROM sys.dm_db_missing_index_details d
JOIN sys.dm_db_missing_index_groups g ON d.index_handle = g.index_handle
JOIN sys.dm_db_missing_index_groups_stats s ON g.index_group_id = s.group_id
WHERE database_id = DB_ID('employee_db')
ORDER BY (s.avg_user_impact * s.avg_total_user_cost * (s.user_seeks + s.user_scans)) DESC;
```

---

### Index Best Practices

| Practice | Benefit | Example |
|----------|---------|---------|
| Index on foreign keys | Speeds up JOIN operations | `CREATE INDEX idx_emp_dept_id ON employees(department_id);` |
| Index on WHERE conditions | Faster filtering | Index columns used in WHERE clause |
| Avoid indexing low-selectivity columns | Reduces overhead | Don't index gender (only 2 values) |
| Use composite indexes for range queries | Efficient range lookups | `(department, salary)` for dept=X AND salary>Y |
| Regularly maintain indexes | Prevents fragmentation | `REBUILD` if >30% fragmented, `REORGANIZE` if 10-30% |
| Monitor index fragmentation | Maintains performance | `DBCC SHOWCONTIG` or `sys.dm_db_index_physical_stats` |

---

## Views and Virtual Tables

### What are Views?
Views are virtual tables created by querying other tables. They provide abstraction, security, and simplify complex queries.

---

### Example 1: Basic View - Employee Summary

```sql
CREATE VIEW vw_employee_summary AS
SELECT 
    e.employee_id,
    e.employee_name,
    e.department,
    e.salary,
    e.hire_date,
    DATEDIFF(YEAR, e.hire_date, CURDATE()) as years_employed,
    d.department_name,
    d.budget,
    d.location
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.status = 'ACTIVE';

-- Usage:
SELECT * FROM vw_employee_summary WHERE department = 'Engineering';
```

---

### Example 2: Complex View - Department Analytics

```sql
CREATE VIEW vw_department_analytics AS
WITH dept_stats AS (
    SELECT 
        e.department_id,
        d.department_name,
        COUNT(e.employee_id) as headcount,
        AVG(e.salary) as avg_salary,
        MIN(e.salary) as min_salary,
        MAX(e.salary) as max_salary,
        STDDEV(e.salary) as salary_stddev,
        SUM(e.salary) as total_payroll,
        MIN(e.hire_date) as oldest_employee_hire_date,
        MAX(e.hire_date) as newest_employee_hire_date
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    WHERE e.status = 'ACTIVE'
    GROUP BY e.department_id, d.department_name
),
salary_tiers AS (
    SELECT 
        department_id,
        SUM(CASE WHEN salary < 60000 THEN 1 ELSE 0 END) as junior_count,
        SUM(CASE WHEN salary BETWEEN 60000 AND 100000 THEN 1 ELSE 0 END) as mid_count,
        SUM(CASE WHEN salary > 100000 THEN 1 ELSE 0 END) as senior_count
    FROM employees
    WHERE status = 'ACTIVE'
    GROUP BY department_id
)
SELECT 
    ds.department_id,
    ds.department_name,
    ds.headcount,
    ds.avg_salary,
    ds.min_salary,
    ds.max_salary,
    ds.salary_stddev,
    ds.total_payroll,
    st.junior_count,
    st.mid_count,
    st.senior_count,
    ROUND(st.junior_count * 100.0 / ds.headcount, 2) as pct_junior,
    ROUND(st.mid_count * 100.0 / ds.headcount, 2) as pct_mid,
    ROUND(st.senior_count * 100.0 / ds.headcount, 2) as pct_senior
FROM dept_stats ds
LEFT JOIN salary_tiers st ON ds.department_id = st.department_id;

-- Usage:
SELECT * FROM vw_department_analytics ORDER BY total_payroll DESC;
```

**Results Example:**
```
department_id | department_name | headcount | avg_salary | min_salary | max_salary | total_payroll | junior_count | mid_count | senior_count | pct_junior | pct_mid | pct_senior
--------------|-----------------|-----------|------------|------------|------------|---------------|------|---------|---------|-----------|---------|----------
D001          | Engineering     | 8         | 98500      | 75000      | 120000     | 788000        | 2    | 4       | 2       | 25.00     | 50.00   | 25.00
D002          | Sales           | 5         | 85000      | 78000      | 90000      | 425000        | 0    | 5       | 0       | 0.00      | 100.00  | 0.00
D003          | Marketing       | 4         | 72000      | 50000      | 85000      | 288000        | 2    | 2       | 0       | 50.00     | 50.00   | 0.00
```

---

### Example 3: Updatable View with CHECK OPTION

```sql
-- View for managing engineering department employees
CREATE VIEW vw_engineering_employees AS
SELECT 
    employee_id,
    employee_name,
    salary,
    hire_date,
    manager_id
FROM employees
WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Engineering')
WITH CHECK OPTION;

-- Update through the view (only affects Engineering dept)
UPDATE vw_engineering_employees
SET salary = salary * 1.05
WHERE employee_id = 'E101';

-- This would fail (not in Engineering dept)
-- UPDATE vw_engineering_employees SET salary = 100000 WHERE employee_id = 'E200';
```

**WITH CHECK OPTION ensures:**
- Updates can only affect rows visible in the view
- Inserted rows must satisfy the view's WHERE condition

---

### Example 4: View for Security and Abstraction

```sql
-- View that hides sensitive salary information from junior staff
CREATE VIEW vw_employee_public_info AS
SELECT 
    employee_id,
    employee_name,
    department,
    job_title,
    hire_date,
    -- Salary hidden for non-managers
    CASE 
        WHEN CURRENT_USER = 'hr_admin' THEN CAST(salary AS VARCHAR)
        WHEN CURRENT_USER LIKE 'manager_%' THEN 
            CAST(ROUND(salary / 1000) * 1000 AS VARCHAR) -- Rounded salary
        ELSE 'RESTRICTED'
    END as salary_info
FROM employees;

-- Grant access to specific roles
GRANT SELECT ON vw_employee_public_info TO 'all_staff';
GRANT SELECT ON vw_employee_public_info TO 'managers';
```

---

### Example 5: Materialized View (for Performance)

```sql
-- Create a materialized view (actual table with copied data)
CREATE TABLE mv_sales_summary AS
SELECT 
    DATE(order_date) as order_date,
    department,
    COUNT(*) as total_orders,
    SUM(order_amount) as total_revenue,
    AVG(order_amount) as avg_order_value,
    MAX(order_amount) as max_order_amount
FROM orders o
JOIN employees e ON o.employee_id = e.employee_id
GROUP BY DATE(order_date), department;

-- Create index for fast access
CREATE INDEX idx_mv_sales_date ON mv_sales_summary(order_date);

-- Refresh the materialized view (run periodically via scheduled job)
TRUNCATE TABLE mv_sales_summary;
INSERT INTO mv_sales_summary
SELECT 
    DATE(order_date) as order_date,
    department,
    COUNT(*) as total_orders,
    SUM(order_amount) as total_revenue,
    AVG(order_amount) as avg_order_value,
    MAX(order_amount) as max_order_amount
FROM orders o
JOIN employees e ON o.employee_id = e.employee_id
GROUP BY DATE(order_date), department;
```

---

### View Advantages and Disadvantages

| Aspect | Advantage | Disadvantage |
|--------|-----------|--------------|
| **Simplicity** | Hide complex joins and logic | May add minor query overhead |
| **Security** | Restrict column/row access | Not foolproof - base table still accessible with GRANT |
| **Maintenance** | Change definition without affecting app | Definition changes affect dependent views |
| **Reusability** | Shared across multiple queries | Can't index views directly (except materialized) |
| **Performance** | Materialized views improve speed | Materialized views need refresh strategy |

---

## DELETE vs TRUNCATE vs DROP Comparison

### 1. DELETE Statement

```sql
-- Delete specific rows with WHERE clause
DELETE FROM employees
WHERE department_id = (
    SELECT department_id FROM departments WHERE department_name = 'Temporary'
);

-- Delete all rows (but keeps structure)
DELETE FROM employees;

-- Delete with JOIN
DELETE e FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE d.department_name = 'Inactive';
```

**Characteristics:**

| Property | Detail |
|----------|--------|
| **Purpose** | Remove specific or all rows from a table |
| **Scope** | Rows only; table structure remains |
| **Speed** | Slower (logs each row deletion) |
| **Rollback** | Yes - wrapped in transaction |
| **Identity Reset** | No (identity seed continues) |
| **Disk Space** | Not released immediately |
| **Triggers** | Yes - fires DELETE triggers |
| **WHERE Clause** | Supported |

**Example with Transaction:**
```sql
BEGIN TRANSACTION;

DELETE FROM employees
WHERE status = 'INACTIVE' AND years_employed > 10;

-- Check affected rows
SELECT @@ROWCOUNT as deleted_rows;

-- Decide to commit or rollback
COMMIT; -- or ROLLBACK;
```

**Triggers Example:**
```sql
-- This DELETE will trigger the audit log
CREATE TRIGGER trg_employee_delete
AFTER DELETE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit_log (
        action, employee_id, action_timestamp, user_id
    ) VALUES (
        'DELETE', OLD.employee_id, NOW(), CURRENT_USER()
    );
END;

DELETE FROM employees WHERE employee_id = 'E999'; -- Triggers audit
```

---

### 2. TRUNCATE Statement

```sql
-- Remove all rows at once (fastest)
TRUNCATE TABLE employees;

-- Reset identity to seed value
TRUNCATE TABLE employees;
SELECT @@IDENTITY; -- Returns seed value (usually 1)
```

**Characteristics:**

| Property | Detail |
|----------|--------|
| **Purpose** | Remove all rows from a table quickly |
| **Scope** | Entire table contents; structure remains |
| **Speed** | Fastest (deallocates data pages) |
| **Rollback** | Yes - in explicit transaction only |
| **Identity Reset** | Yes - resets to seed value |
| **Disk Space** | Released (except first page) |
| **Triggers** | No - doesn't fire DELETE triggers |
| **WHERE Clause** | Not supported |
| **Foreign Keys** | Fails if referenced by FK constraint |

**Example with Error Handling:**
```sql
BEGIN TRANSACTION;

BEGIN TRY
    TRUNCATE TABLE employee_temp_data;
    PRINT 'Truncation successful';
    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'Error: ' + ERROR_MESSAGE();
    -- If FK constraint exists, use DELETE instead
    DELETE FROM employee_temp_data;
    COMMIT;
END CATCH;
```

---

### 3. DROP Statement

```sql
-- Remove entire table (structure + data + indexes)
DROP TABLE employees;

-- Drop with dependencies check
DROP TABLE employees CASCADE; -- PostgreSQL
DROP TABLE employees RESTRICT; -- PostgreSQL (fails if dependencies)

-- Drop if exists (prevents error)
DROP TABLE IF EXISTS employees_backup;

-- Drop multiple tables
DROP TABLE emp_temp, emp_archive, emp_deleted;
```

**Characteristics:**

| Property | Detail |
|----------|--------|
| **Purpose** | Remove entire table definition and data |
| **Scope** | Table, indexes, triggers, constraints, all |
| **Speed** | Very fast (deallocates all pages) |
| **Rollback** | Yes - in transaction |
| **Identity Reset** | N/A - table gone |
| **Disk Space** | Fully released |
| **Triggers** | Not applicable - table removed |
| **WHERE Clause** | N/A |
| **Recovery** | Only from backup or transaction rollback |

**Example:**
```sql
-- Backup before drop
CREATE TABLE employees_backup AS SELECT * FROM employees;

-- Drop with safety check
IF OBJECT_ID('dbo.employees', 'U') IS NOT NULL
    DROP TABLE dbo.employees;

-- Verify drop
SELECT * FROM information_schema.tables 
WHERE table_name = 'employees'; -- Returns empty
```

---

### Comparison Table

| Feature | DELETE | TRUNCATE | DROP |
|---------|--------|----------|------|
| **Removes Data** | ✓ | ✓ | ✓ |
| **Removes Structure** | ✗ | ✗ | ✓ |
| **Speed** | Slow | Fast | Very Fast |
| **Logs Each Row** | ✓ | ✗ | ✗ |
| **Uses Transaction Log** | ✓ (minimal) | ✓ (minimal) | ✓ (minimal) |
| **Can Use WHERE** | ✓ | ✗ | ✗ |
| **Fires Triggers** | ✓ | ✗ | ✗ |
| **Resets Identity** | ✗ | ✓ | ✗ |
| **Reclaims Space** | Partial | ✓ | ✓ |
| **Can Rollback** | ✓ | ✓* | ✓ |
| **FK Constraints** | Checked | Checked | Removed |

*TRUNCATE can rollback only in explicit transaction

---

### Decision Tree

```
Need to remove data?
│
├─ Need to remove SPECIFIC rows?
│  └─ Use DELETE with WHERE clause
│
├─ Need to remove ALL rows, keep structure?
│  ├─ Need to trigger audit logs?
│  │  └─ Use DELETE (slower but fires triggers)
│  │
│  └─ Need maximum speed?
│     └─ Use TRUNCATE
│
└─ Need to remove ENTIRE table?
   └─ Use DROP TABLE
```

---

### Performance Comparison Example

```sql
-- Test dataset: 1 million rows

-- 1. DELETE all rows (will log 1M operations)
BEGIN TRANSACTION;
DELETE FROM employees; -- ~30 seconds
COMMIT;

-- 2. TRUNCATE (deallocate pages instantly)
BEGIN TRANSACTION;
TRUNCATE TABLE employees; -- ~0.1 seconds
COMMIT;

-- 3. DROP (remove structure)
BEGIN TRANSACTION;
DROP TABLE employees; -- ~0.05 seconds
COMMIT;

-- 4. DELETE with WHERE (selective)
BEGIN TRANSACTION;
DELETE FROM employees 
WHERE hire_date < '2015-01-01'; -- ~5 seconds
COMMIT;
```

---

### Real-World Scenarios

**Scenario 1: Monthly Archive**
```sql
-- Archive old employee records
BEGIN TRANSACTION;

-- Backup to archive table
INSERT INTO employees_archive
SELECT * FROM employees
WHERE termination_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- Delete from active table
DELETE FROM employees
WHERE termination_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

COMMIT;
```

**Scenario 2: Rebuild Table**
```sql
-- Complete table rebuild (defragment)
BEGIN TRANSACTION;

-- Create new table with same structure
CREATE TABLE employees_new LIKE employees;

-- Copy data
INSERT INTO employees_new SELECT * FROM employees;

-- Swap tables
RENAME TABLE employees TO employees_old,
             employees_new TO employees;

-- Drop old table
DROP TABLE employees_old;

COMMIT;
```

**Scenario 3: Bulk Clean-up with Safety**
```sql
-- Safe truncate with verification
DECLARE @RowCount INT;

BEGIN TRANSACTION;

-- Show how many rows will be affected
SELECT @RowCount = COUNT(*) FROM temp_employees;
PRINT 'Rows to delete: ' + CAST(@RowCount AS VARCHAR);

-- Perform truncate
TRUNCATE TABLE temp_employees;

-- Verify
SELECT @RowCount = COUNT(*) FROM temp_employees;
PRINT 'Rows remaining: ' + CAST(@RowCount AS VARCHAR);

COMMIT;
```

---

## Performance Optimization

### Query Optimization Checklist

```sql
-- 1. Use EXPLAIN/ANALYZE to understand execution plan
EXPLAIN ANALYZE
SELECT e.employee_id, e.employee_name, d.department_name, e.salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.salary > 100000
ORDER BY e.salary DESC;

-- 2. Check for sequential scans (should use indexes)
-- Result shows "Seq Scan" = index missing

-- 3. Add appropriate indexes
CREATE INDEX idx_employees_salary ON employees(salary);
CREATE INDEX idx_employees_dept_id ON employees(department_id);

-- 4. Recheck execution plan
EXPLAIN ANALYZE -- Same query as above
```

### Indexing Performance Impact

```sql
-- Before index (full table scan)
-- Query time: ~500ms
SELECT * FROM employees WHERE email = 'john@company.com';

-- After creating index
CREATE INDEX idx_employees_email ON employees(email);

-- Query time: ~5ms (100x faster!)
SELECT * FROM employees WHERE email = 'john@company.com';
```

### Query Optimization Techniques

**1. Avoid N+1 Queries**
```sql
-- Bad: Multiple queries
SELECT * FROM employees LIMIT 10;
-- Then for each row: SELECT * FROM departments WHERE id = ?;

-- Good: Single JOIN query
SELECT e.*, d.* 
FROM employees e
JOIN departments d ON e.department_id = d.department_id
LIMIT 10;
```

**2. Use EXPLAIN**
```sql
EXPLAIN SELECT * FROM employees WHERE salary > 100000;
```

**3. Aggregate at Database Level**
```sql
-- Bad: Retrieve all, aggregate in application
SELECT * FROM employees;
-- Sum salaries in application code

-- Good: Aggregate in SQL
SELECT department, SUM(salary) as total_salary
FROM employees
GROUP BY department;
```

---

## Summary

This document covers advanced SQL concepts essential for database performance and reliability:

- **Second Highest Salary:** Multiple methods with different performance characteristics
- **CTEs:** Improve readability and enable recursive queries
- **Window Functions:** Powerful for complex analytical queries
- **Duplicate Analysis:** Identify and remove bad data
- **Indexing:** Critical for query performance
- **Views:** Abstraction and security layer
- **DELETE/TRUNCATE/DROP:** Choose the right tool for your use case

**Key Takeaways:**
1. Use window functions for analytical queries instead of self-joins
2. Create appropriate indexes based on query patterns
3. Use CTEs for complex multi-step queries
4. Choose between DELETE, TRUNCATE, and DROP based on requirements
5. Always test changes with EXPLAIN and measure performance
6. Monitor and maintain indexes regularly

---

**Last Updated:** 2025-12-25 18:04:00 UTC
**Author:** GaneshKurmi
