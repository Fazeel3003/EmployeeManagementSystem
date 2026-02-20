/* =========================================================
   EMPLOYEE MANAGEMENT SYSTEM - ADVANCED REPORTING QUERIES
   Author: Fazeel
   Description: Complex analytical queries for reporting
   ========================================================= */

/* ---------------------------------------------------------
   1. SECOND HIGHEST SALARY (Handles ties)
   --------------------------------------------------------- */
SELECT e.emp_id,
       e.first_name,
       e.last_name,
       sh.salary_amount
FROM Employees e
JOIN Salary_History sh 
    ON e.emp_id = sh.emp_id
WHERE sh.salary_amount = (
    SELECT DISTINCT salary_amount
    FROM Salary_History
    ORDER BY salary_amount DESC
    LIMIT 1 OFFSET 1
);
/* ---------------------------------------------------------
   2. HIGHEST PAID EMPLOYEE PER DEPARTMENT
   --------------------------------------------------------- */
   SELECT d.dept_name,
       e.first_name,
       e.last_name,
       sh.salary_amount
FROM Departments d
JOIN Employees e ON d.dept_id = e.dept_id
JOIN Salary_History sh ON e.emp_id = sh.emp_id
WHERE sh.salary_amount = (
    SELECT MAX(sh2.salary_amount)
    FROM Employees e2
    JOIN Salary_History sh2 ON e2.emp_id = sh2.emp_id
    WHERE e2.dept_id = d.dept_id
);

/* ---------------------------------------------------------
   3. Total Salary Expense Per Department
   --------------------------------------------------------- */
   SELECT d.dept_name,
       SUM(sh.salary_amount) AS total_salary_expense
FROM Departments d
JOIN Employees e ON d.dept_id = e.dept_id
JOIN Salary_History sh ON e.emp_id = sh.emp_id
GROUP BY d.dept_name
ORDER BY total_salary_expense DESC;


   /* ---------------------------------------------------------
   4. Employees Working on More Than One Project
   --------------------------------------------------------- */
   SELECT e.emp_id,
       e.first_name,
       e.last_name,
       COUNT(ep.project_id) AS total_projects
FROM Employees e
JOIN Employee_Projects ep ON e.emp_id = ep.emp_id
GROUP BY e.emp_id
HAVING COUNT(ep.project_id) > 1;


   /* ---------------------------------------------------------
   5. Department With Highest Average Salary
   --------------------------------------------------------- */
   SELECT d.dept_name,
       AVG(sh.salary_amount) AS avg_salary
FROM Departments d
JOIN Employees e ON d.dept_id = e.dept_id
JOIN Salary_History sh ON e.emp_id = sh.emp_id
GROUP BY d.dept_name
ORDER BY avg_salary DESC
LIMIT 1;


   /* ---------------------------------------------------------
   6. Employees Earning More Than Their Manager
   --------------------------------------------------------- */
   SELECT e.first_name AS employee,
       m.first_name AS manager,
       sh.salary_amount AS employee_salary,
       msh.salary_amount AS manager_salary
FROM Employees e
JOIN Employees m ON e.manager_id = m.emp_id
JOIN Salary_History sh ON e.emp_id = sh.emp_id
JOIN Salary_History msh ON m.emp_id = msh.emp_id
WHERE sh.salary_amount > msh.salary_amount;


   /* ---------------------------------------------------------
   7. Projects Over Budget (Based on Total Allocated Salary)
   --------------------------------------------------------- */
   SELECT p.project_name,
       p.budget,
       SUM(sh.salary_amount * (ep.allocation_percent/100)) AS estimated_cost
FROM Projects p
JOIN Employee_Projects ep ON p.project_id = ep.project_id
JOIN Salary_History sh ON ep.emp_id = sh.emp_id
GROUP BY p.project_id
HAVING estimated_cost > p.budget;


   /* ---------------------------------------------------------
   8. Employees With No Project Assigned
   --------------------------------------------------------- */
   SELECT e.emp_id,
       e.first_name,
       e.last_name
FROM Employees e
LEFT JOIN Employee_Projects ep ON e.emp_id = ep.emp_id
WHERE ep.project_id IS NULL;
/* ---------------------------------------------------------
   9. Monthly Attendance Percentage Per Employee
   --------------------------------------------------------- */
   SELECT e.emp_id,
       e.first_name,
       COUNT(CASE WHEN a.attendance_status = 'Present' THEN 1 END) * 100.0 /
       COUNT(*) AS attendance_percentage
FROM Employees e
JOIN Attendance a ON e.emp_id = a.emp_id
GROUP BY e.emp_id;


   /* ---------------------------------------------------------
   10. Employees Who Took Most Leave Days
   --------------------------------------------------------- */
   SELECT e.emp_id,
       e.first_name,
       SUM(DATEDIFF(l.end_date, l.start_date) + 1) AS total_leave_days
FROM Employees e
JOIN Leave_Requests l ON e.emp_id = l.emp_id
WHERE l.approval_status = 'Approved'
GROUP BY e.emp_id
ORDER BY total_leave_days DESC
LIMIT 1;


