-- ========================================
-- Employee Management System - Complex SQL Queries
-- ========================================
-- This file contains 10 complex SQL queries showcasing advanced MySQL skills
-- including joins, subqueries, window functions, CTEs, aggregations, and more

-- ========================================
-- Query 1: Employee Salary Analysis with Department Comparison
-- Description: Shows each employee's current salary, department average, and salary rank within department
-- Skills: Window functions, CTEs, JOINs, subqueries
-- ========================================
WITH CurrentSalaries AS (
    SELECT 
        e.emp_id,
        e.first_name,
        e.last_name,
        d.dept_name,
        s.amount AS current_salary,
        AVG(s.amount) OVER (PARTITION BY d.dept_id) AS dept_avg_salary,
        RANK() OVER (PARTITION BY d.dept_id ORDER BY s.amount DESC) AS salary_rank_in_dept,
        COUNT(*) OVER (PARTITION BY d.dept_id) AS total_employees_in_dept
    FROM Employees e
    INNER JOIN Departments d ON e.dept_id = d.dept_id
    INNER JOIN Salaries s ON e.emp_id = s.emp_id
    WHERE s.effective_date = (
        SELECT MAX(effective_date) 
        FROM Salaries s2 
        WHERE s2.emp_id = e.emp_id
    )
)
SELECT 
    first_name,
    last_name,
    dept_name,
    current_salary,
    ROUND(dept_avg_salary, 2) AS department_average,
    salary_rank_in_dept,
    total_employees_in_dept,
    CASE 
        WHEN current_salary > dept_avg_salary THEN 'Above Average'
        WHEN current_salary < dept_avg_salary THEN 'Below Average'
        ELSE 'At Average'
    END AS salary_status
FROM CurrentSalaries
ORDER BY dept_name, salary_rank_in_dept;

-- ========================================
-- Query 2: Performance Trend Analysis with Training Impact
-- Description: Analyzes employee performance ratings and correlates with training completion
-- Skills: Multiple JOINs, subqueries, aggregation, CASE statements
-- ========================================
SELECT 
    e.emp_id,
    e.first_name,
    e.last_name,
    d.dept_name,
    pr.rating AS latest_performance_rating,
    pr.review_date AS latest_review_date,
    COUNT(DISTINCT et.training_id) AS training_programs_completed,
    AVG(et.score) AS average_training_score,
    COUNT(DISTINCT ep.project_id) AS projects_worked_on,
    CASE 
        WHEN pr.rating >= 4 AND COUNT(DISTINCT et.training_id) >= 3 THEN 'High Performer with Training'
        WHEN pr.rating >= 4 AND COUNT(DISTINCT et.training_id) < 3 THEN 'High Performer - Needs Training'
        WHEN pr.rating <= 2 AND COUNT(DISTINCT et.training_id) >= 3 THEN 'Needs Improvement Despite Training'
        WHEN pr.rating <= 2 AND COUNT(DISTINCT et.training_id) < 3 THEN 'Needs Improvement - Requires Training'
        ELSE 'Moderate Performer'
    END AS performance_category
FROM Employees e
INNER JOIN Departments d ON e.dept_id = d.dept_id
LEFT JOIN PerformanceReviews pr ON e.emp_id = pr.emp_id
    AND pr.review_date = (
        SELECT MAX(review_date) 
        FROM PerformanceReviews pr2 
        WHERE pr2.emp_id = e.emp_id
    )
LEFT JOIN Employee_Training et ON e.emp_id = et.emp_id AND et.status = 'Completed'
LEFT JOIN Employee_Projects ep ON e.emp_id = ep.emp_id
GROUP BY e.emp_id, e.first_name, e.last_name, d.dept_name, pr.rating, pr.review_date
ORDER BY pr.rating DESC, COUNT(DISTINCT et.training_id) DESC;

-- ========================================
-- Query 3: Department Budget Analysis with Project Allocation
-- Description: Calculates total department costs including salaries and project budgets
-- Skills: Window functions, complex aggregations, subqueries
-- ========================================
WITH DepartmentCosts AS (
    SELECT 
        d.dept_id,
        d.dept_name,
        m.first_name AS manager_name,
        m.last_name AS manager_lastname,
        COUNT(DISTINCT e.emp_id) AS employee_count,
        SUM(CASE WHEN s.effective_date = (
            SELECT MAX(effective_date) FROM Salaries s2 WHERE s2.emp_id = e.emp_id
        ) THEN s.amount ELSE 0 END) AS total_salary_cost,
        SUM(p.budget) AS total_project_budget,
        COUNT(DISTINCT p.project_id) AS active_projects
    FROM Departments d
    LEFT JOIN Employees m ON d.manager_id = m.emp_id
    LEFT JOIN Employees e ON d.dept_id = e.dept_id
    LEFT JOIN Salaries s ON e.emp_id = s.emp_id
    LEFT JOIN Employee_Projects ep ON e.emp_id = ep.emp_id
    LEFT JOIN Projects p ON ep.project_id = p.project_id AND p.status IN ('In Progress', 'Planning')
    GROUP BY d.dept_id, d.dept_name, m.first_name, m.last_name
)
SELECT 
    dept_name,
    manager_name,
    manager_lastname,
    employee_count,
    ROUND(total_salary_cost, 2) AS total_salary_cost,
    ROUND(total_project_budget, 2) AS total_project_budget,
    ROUND(total_salary_cost + total_project_budget, 2) AS total_department_cost,
    ROUND((total_salary_cost + total_project_budget) / employee_count, 2) AS cost_per_employee,
    ROUND(total_salary_cost / employee_count, 2) AS avg_salary_per_employee,
    CASE 
        WHEN total_project_budget > total_salary_cost THEN 'Project Intensive'
        WHEN total_project_budget < total_salary_cost * 0.5 THEN 'Salary Dominated'
        ELSE 'Balanced'
    END AS cost_structure
FROM DepartmentCosts
ORDER BY total_department_cost DESC;

-- ========================================
-- Query 4: Employee Tenure and Retention Analysis
-- Description: Analyzes employee tenure, salary growth, and retention patterns
-- Skills: Date functions, subqueries, window functions, aggregations
-- ========================================
SELECT 
    e.emp_id,
    e.first_name,
    e.last_name,
    d.dept_name,
    p.title AS position,
    TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) AS years_with_company,
    TIMESTAMPDIFF(MONTH, e.hire_date, CURDATE()) AS months_with_company,
    -- Salary growth calculation
    (
        SELECT MAX(amount) 
        FROM Salaries s_current 
        WHERE s_current.emp_id = e.emp_id
    ) AS current_salary,
    (
        SELECT MIN(amount) 
        FROM Salaries s_initial 
        WHERE s_initial.emp_id = e.emp_id
    ) AS initial_salary,
    ROUND(
        (
            (SELECT MAX(amount) FROM Salaries s_current WHERE s_current.emp_id = e.emp_id) -
            (SELECT MIN(amount) FROM Salaries s_initial WHERE s_initial.emp_id = e.emp_id)
        ) / 
        (SELECT MIN(amount) FROM Salaries s_initial WHERE s_initial.emp_id = e.emp_id) * 100, 
        2
    ) AS salary_growth_percentage,
    -- Performance metrics
    COUNT(DISTINCT pr.review_id) AS performance_reviews,
    AVG(pr.rating) AS avg_performance_rating,
    -- Training and project involvement
    COUNT(DISTINCT et.training_id) AS training_programs_completed,
    COUNT(DISTINCT ep.project_id) AS total_projects,
    -- Leave patterns
    COUNT(DISTINCT lr.leave_id) AS leave_requests,
    SUM(CASE WHEN lr.status = 'Approved' THEN 1 ELSE 0 END) AS approved_leaves
FROM Employees e
INNER JOIN Departments d ON e.dept_id = d.dept_id
INNER JOIN Positions p ON e.position_id = p.position_id
LEFT JOIN PerformanceReviews pr ON e.emp_id = pr.emp_id
LEFT JOIN Employee_Training et ON e.emp_id = et.emp_id AND et.status = 'Completed'
LEFT JOIN Employee_Projects ep ON e.emp_id = ep.emp_id
LEFT JOIN Leave_Requests lr ON e.emp_id = lr.emp_id
GROUP BY e.emp_id, e.first_name, e.last_name, d.dept_name, p.title, e.hire_date
ORDER BY years_with_company DESC, salary_growth_percentage DESC;

-- ========================================
-- Query 5: Project Resource Allocation and Cost Analysis
-- Description: Analyzes project resource allocation, costs, and completion status
-- Skills: Complex JOINs, subqueries, aggregations, window functions
-- ========================================
WITH ProjectMetrics AS (
    SELECT 
        p.project_id,
        p.project_name,
        p.start_date,
        p.end_date,
        p.budget,
        p.status,
        COUNT(DISTINCT ep.emp_id) AS team_size,
        COUNT(DISTINCT CASE WHEN ep.end_date IS NOT NULL THEN ep.emp_id END) AS completed_assignments,
        SUM(
            CASE 
                WHEN s.effective_date = (
                    SELECT MAX(effective_date) FROM Salaries s2 WHERE s2.emp_id = ep.emp_id
                ) THEN s.amount 
                ELSE 0 
            END
        ) AS current_team_salary_cost,
        AVG(pr.rating) AS avg_team_performance,
        COUNT(DISTINCT et.training_id) AS team_training_count
    FROM Projects p
    LEFT JOIN Employee_Projects ep ON p.project_id = ep.project_id
    LEFT JOIN Employees e ON ep.emp_id = e.emp_id
    LEFT JOIN Salaries s ON e.emp_id = s.emp_id
    LEFT JOIN PerformanceReviews pr ON e.emp_id = pr.emp_id
        AND pr.review_date = (
            SELECT MAX(review_date) FROM PerformanceReviews pr2 WHERE pr2.emp_id = e.emp_id
        )
    LEFT JOIN Employee_Training et ON e.emp_id = et.emp_id AND et.status = 'Completed'
    GROUP BY p.project_id, p.project_name, p.start_date, p.end_date, p.budget, p.status
)
SELECT 
    project_name,
    start_date,
    end_date,
    status,
    budget,
    team_size,
    ROUND(current_team_salary_cost, 2) AS team_salary_cost,
    ROUND(budget / team_size, 2) AS budget_per_team_member,
    ROUND(current_team_salary_cost / team_size, 2) AS avg_salary_per_team_member,
    ROUND(avg_team_performance, 2) AS avg_team_performance_rating,
    team_training_count,
    CASE 
        WHEN status = 'Completed' AND end_date <= p.end_date THEN 'On Time'
        WHEN status = 'Completed' AND end_date > p.end_date THEN 'Delayed'
        WHEN status = 'In Progress' AND CURDATE() > p.end_date THEN 'Overdue'
        WHEN status = 'In Progress' AND CURDATE() <= p.end_date THEN 'On Schedule'
        ELSE 'Planning'
    END AS timeline_status,
    CASE 
        WHEN current_team_salary_cost > budget THEN 'Over Budget'
        WHEN current_team_salary_cost < budget * 0.8 THEN 'Under Budget'
        ELSE 'On Budget'
    END AS budget_status
FROM ProjectMetrics pm
JOIN Projects p ON pm.project_id = p.project_id
ORDER BY budget DESC, team_size DESC;

-- ========================================
-- Query 6: Training ROI Analysis
-- Description: Calculates training return on investment based on performance improvements
-- Skills: Window functions, subqueries, aggregations, complex calculations
-- ========================================
WITH TrainingROI AS (
    SELECT 
        tp.training_id,
        tp.program_name,
        tp.cost AS training_cost,
        tp.duration_days,
        COUNT(DISTINCT et.emp_id) AS participants_count,
        AVG(et.score) AS avg_training_score,
        -- Pre-training performance (simplified - using earliest review)
        AVG(
            CASE 
                WHEN pr.review_date = (
                    SELECT MIN(review_date) 
                    FROM PerformanceReviews pr_min 
                    WHERE pr_min.emp_id = et.emp_id
                ) THEN pr.rating 
                ELSE NULL 
            END
        ) AS avg_pre_training_performance,
        -- Post-training performance (simplified - using latest review)
        AVG(
            CASE 
                WHEN pr.review_date = (
                    SELECT MAX(review_date) 
                    FROM PerformanceReviews pr_max 
                    WHERE pr_max.emp_id = et.emp_id
                ) THEN pr.rating 
                ELSE NULL 
            END
        ) AS avg_post_training_performance,
        -- Salary impact
        AVG(
            CASE 
                WHEN s.effective_date = (
                    SELECT MAX(effective_date) 
                    FROM Salaries s_max 
                    WHERE s_max.emp_id = et.emp_id
                ) THEN s.amount 
                ELSE NULL 
            END
        ) AS avg_current_salary
    FROM Training_Programs tp
    INNER JOIN Employee_Training et ON tp.training_id = et.training_id AND et.status = 'Completed'
    INNER JOIN Employees e ON et.emp_id = e.emp_id
    LEFT JOIN PerformanceReviews pr ON e.emp_id = pr.emp_id
    LEFT JOIN Salaries s ON e.emp_id = s.emp_id
    GROUP BY tp.training_id, tp.program_name, tp.cost, tp.duration_days
)
SELECT 
    program_name,
    duration_days,
    participants_count,
    training_cost,
    ROUND(training_cost / participants_count, 2) AS cost_per_participant,
    ROUND(avg_training_score, 2) AS average_training_score,
    ROUND(avg_pre_training_performance, 2) AS avg_pre_training_rating,
    ROUND(avg_post_training_performance, 2) AS avg_post_training_rating,
    ROUND(avg_post_training_performance - avg_pre_training_performance, 2) AS performance_improvement,
    ROUND(avg_current_salary, 2) AS avg_participant_salary,
    -- ROI calculation (simplified - based on performance improvement)
    CASE 
        WHEN avg_post_training_performance - avg_pre_training_performance > 0.5 THEN 'High ROI'
        WHEN avg_post_training_performance - avg_pre_training_performance > 0 THEN 'Positive ROI'
        ELSE 'Low ROI'
    END AS roi_category
FROM TrainingROI
ORDER BY performance_improvement DESC, avg_training_score DESC;

-- ========================================
-- Query 7: Leave Pattern Analysis and Impact
-- Description: Analyzes leave patterns and their correlation with performance
-- Skills: Date functions, aggregations, subqueries, CASE statements
-- ========================================
SELECT 
    e.emp_id,
    e.first_name,
    e.last_name,
    d.dept_name,
    COUNT(DISTINCT lr.leave_id) AS total_leave_requests,
    SUM(CASE WHEN lr.leave_type = 'Sick' THEN 1 ELSE 0 END) AS sick_leaves,
    SUM(CASE WHEN lr.leave_type = 'Vacation' THEN 1 ELSE 0 END) AS vacation_leaves,
    SUM(CASE WHEN lr.leave_type = 'Personal' THEN 1 ELSE 0 END) AS personal_leaves,
    SUM(CASE WHEN lr.leave_type IN ('Maternity', 'Paternity') THEN 1 ELSE 0 END) AS parental_leaves,
    SUM(CASE WHEN lr.status = 'Approved' THEN DATEDIFF(lr.end_date, lr.start_date) + 1 ELSE 0 END) AS total_approved_leave_days,
    SUM(CASE WHEN lr.status = 'Rejected' THEN 1 ELSE 0 END) AS rejected_leaves,
    -- Performance correlation
    AVG(pr.rating) AS avg_performance_rating,
    -- Salary correlation
    (
        SELECT MAX(amount) 
        FROM Salaries s 
        WHERE s.emp_id = e.emp_id
    ) AS current_salary,
    -- Leave approval rate
    ROUND(
        COUNT(CASE WHEN lr.status = 'Approved' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(lr.leave_id), 0), 
        2
    ) AS leave_approval_rate,
    -- Leave pattern category
    CASE 
        WHEN COUNT(DISTINCT lr.leave_id) > 10 THEN 'Frequent Leave Taker'
        WHEN COUNT(DISTINCT lr.leave_id) BETWEEN 5 AND 10 THEN 'Moderate Leave Taker'
        WHEN COUNT(DISTINCT lr.leave_id) < 5 THEN 'Infrequent Leave Taker'
        ELSE 'No Leave History'
    END AS leave_pattern_category
FROM Employees e
INNER JOIN Departments d ON e.dept_id = d.dept_id
LEFT JOIN Leave_Requests lr ON e.emp_id = lr.emp_id
LEFT JOIN PerformanceReviews pr ON e.emp_id = pr.emp_id
GROUP BY e.emp_id, e.first_name, e.last_name, d.dept_name
ORDER BY total_leave_requests DESC, avg_performance_rating DESC;

-- ========================================
-- Query 8: Manager Effectiveness Analysis
-- Description: Evaluates manager performance based on team metrics
-- Skills: Subqueries, aggregations, window functions, complex JOINs
-- ========================================
WITH ManagerMetrics AS (
    SELECT 
        m.emp_id AS manager_id,
        m.first_name AS manager_first_name,
        m.last_name AS manager_last_name,
        d.dept_name,
        COUNT(DISTINCT e.emp_id) AS team_size,
        AVG(pr.rating) AS avg_team_performance,
        MAX(pr.rating) AS best_team_performance,
        MIN(pr.rating) AS lowest_team_performance,
        COUNT(DISTINCT ep.project_id) AS team_projects,
        COUNT(DISTINCT CASE WHEN p.status = 'Completed' THEN ep.project_id END) AS completed_projects,
        AVG(
            CASE 
                WHEN s.effective_date = (
                    SELECT MAX(effective_date) FROM Salaries s2 WHERE s2.emp_id = e.emp_id
                ) THEN s.amount 
                ELSE NULL 
            END
        ) AS avg_team_salary,
        COUNT(DISTINCT et.training_id) AS team_training_count,
        AVG(et.score) AS avg_team_training_score,
        SUM(CASE WHEN lr.status = 'Approved' THEN 1 ELSE 0 END) AS team_approved_leaves
    FROM Employees m
    INNER JOIN Departments d ON m.emp_id = d.manager_id
    LEFT JOIN Employees e ON d.dept_id = e.dept_id AND e.emp_id != m.emp_id
    LEFT JOIN PerformanceReviews pr ON e.emp_id = pr.emp_id
    LEFT JOIN Employee_Projects ep ON e.emp_id = ep.emp_id
    LEFT JOIN Projects p ON ep.project_id = p.project_id
    LEFT JOIN Salaries s ON e.emp_id = s.emp_id
    LEFT JOIN Employee_Training et ON e.emp_id = et.emp_id AND et.status = 'Completed'
    LEFT JOIN Leave_Requests lr ON e.emp_id = lr.emp_id
    GROUP BY m.emp_id, m.first_name, m.last_name, d.dept_name
)
SELECT 
    manager_first_name,
    manager_last_name,
    dept_name,
    team_size,
    ROUND(avg_team_performance, 2) AS avg_team_performance,
    best_team_performance,
    lowest_team_performance,
    ROUND(best_team_performance - lowest_team_performance, 2) AS performance_range,
    team_projects,
    completed_projects,
    ROUND(completed_projects * 100.0 / NULLIF(team_projects, 0), 2) AS project_completion_rate,
    ROUND(avg_team_salary, 2) AS avg_team_salary,
    team_training_count,
    ROUND(avg_team_training_score, 2) AS avg_team_training_score,
    team_approved_leaves,
    -- Manager effectiveness score (weighted)
    ROUND(
        (avg_team_performance * 0.4) + 
        (completed_projects * 100.0 / NULLIF(team_projects, 0) * 0.3) + 
        (avg_team_training_score / 100 * 0.2) + 
        (CASE WHEN team_size > 0 THEN 1 ELSE 0 END * 0.1), 
        2
    ) AS manager_effectiveness_score,
    CASE 
        WHEN avg_team_performance >= 4.5 AND completed_projects * 100.0 / NULLIF(team_projects, 0) >= 80 THEN 'Exceptional Manager'
        WHEN avg_team_performance >= 4.0 AND completed_projects * 100.0 / NULLIF(team_projects, 0) >= 70 THEN 'Strong Manager'
        WHEN avg_team_performance >= 3.5 AND completed_projects * 100.0 / NULLIF(team_projects, 0) >= 60 THEN 'Good Manager'
        WHEN avg_team_performance >= 3.0 THEN 'Average Manager'
        ELSE 'Needs Development'
    END AS manager_performance_category
FROM ManagerMetrics
ORDER BY manager_effectiveness_score DESC;

-- ========================================
-- Query 9: Cross-Department Collaboration Analysis
-- Description: Identifies collaboration patterns between departments through projects
-- Skills: Window functions, subqueries, aggregations, complex JOINs
-- ========================================
WITH DepartmentCollaboration AS (
    SELECT 
        d1.dept_name AS dept1_name,
        d2.dept_name AS dept2_name,
        p.project_name,
        COUNT(DISTINCT CASE WHEN e.dept_id = d1.dept_id THEN ep.emp_id END) AS dept1_participants,
        COUNT(DISTINCT CASE WHEN e.dept_id = d2.dept_id THEN ep.emp_id END) AS dept2_participants,
        p.budget,
        p.status,
        -- Performance of cross-department teams
        AVG(pr.rating) AS avg_collaboration_performance
    FROM Projects p
    INNER JOIN Employee_Projects ep ON p.project_id = ep.project_id
    INNER JOIN Employees e ON ep.emp_id = e.emp_id
    INNER JOIN Departments d1 ON e.dept_id = d1.dept_id
    INNER JOIN Departments d2 ON (
        EXISTS (
            SELECT 1 
            FROM Employee_Projects ep2 
            INNER JOIN Employees e2 ON ep2.emp_id = e2.emp_id 
            WHERE ep2.project_id = p.project_id 
            AND e2.dept_id != d1.dept_id
        )
    )
    LEFT JOIN PerformanceReviews pr ON e.emp_id = pr.emp_id
    WHERE d1.dept_id != d2.dept_id
    GROUP BY d1.dept_name, d2.dept_name, p.project_name, p.budget, p.status
)
SELECT 
    dept1_name,
    dept2_name,
    COUNT(DISTINCT project_name) AS collaboration_projects,
    SUM(dept1_participants) AS total_dept1_participants,
    SUM(dept2_participants) AS total_dept2_participants,
    ROUND(AVG(budget), 2) AS avg_project_budget,
    SUM(budget) AS total_collaboration_budget,
    ROUND(AVG(avg_collaboration_performance), 2) AS avg_collaboration_performance,
    COUNT(CASE WHEN status = 'Completed' THEN 1 END) AS completed_projects,
    ROUND(COUNT(CASE WHEN status = 'Completed' THEN 1 END) * 100.0 / COUNT(*), 2) AS collaboration_success_rate
FROM DepartmentCollaboration
GROUP BY dept1_name, dept2_name
ORDER BY collaboration_projects DESC, collaboration_success_rate DESC;

-- ========================================
-- Query 10: Comprehensive Employee Dashboard
-- Description: Complete employee profile with all metrics and KPIs
-- Skills: Multiple subqueries, window functions, aggregations, complex calculations
-- ========================================
SELECT 
    e.emp_id,
    e.first_name,
    e.last_name,
    e.email,
    e.phone,
    d.dept_name,
    p.title AS position,
    m.first_name AS manager_first_name,
    m.last_name AS manager_last_name,
    -- Basic employment info
    e.hire_date,
    TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) AS years_with_company,
    TIMESTAMPDIFF(MONTH, e.hire_date, CURDATE()) AS months_with_company,
    -- Current salary and compensation
    (
        SELECT MAX(amount) 
        FROM Salaries s 
        WHERE s.emp_id = e.emp_id
    ) AS current_salary,
    (
        SELECT MIN(amount) 
        FROM Salaries s 
        WHERE s.emp_id = e.emp_id
    ) AS initial_salary,
    ROUND(
        (
            (SELECT MAX(amount) FROM Salaries s WHERE s.emp_id = e.emp_id) -
            (SELECT MIN(amount) FROM Salaries s WHERE s.emp_id = e.emp_id)
        ) / 
        (SELECT MIN(amount) FROM Salaries s WHERE s.emp_id = e.emp_id) * 100, 
        2
    ) AS salary_growth_percentage,
    -- Performance metrics
    (
        SELECT rating 
        FROM PerformanceReviews pr 
        WHERE pr.emp_id = e.emp_id 
        ORDER BY review_date DESC 
        LIMIT 1
    ) AS latest_performance_rating,
    (
        SELECT AVG(rating) 
        FROM PerformanceReviews pr 
        WHERE pr.emp_id = e.emp_id
    ) AS avg_performance_rating,
    COUNT(DISTINCT pr.review_id) AS total_performance_reviews,
    -- Training and development
    COUNT(DISTINCT et.training_id) AS training_programs_completed,
    ROUND(AVG(et.score), 2) AS avg_training_score,
    SUM(tp.cost) AS total_training_cost,
    -- Project involvement
    COUNT(DISTINCT ep.project_id) AS total_projects,
    COUNT(DISTINCT CASE WHEN p.status = 'Completed' THEN ep.project_id END) AS completed_projects,
    ROUND(COUNT(DISTINCT CASE WHEN p.status = 'Completed' THEN ep.project_id END) * 100.0 / 
          NULLIF(COUNT(DISTINCT ep.project_id), 0), 2) AS project_completion_rate,
    -- Leave and attendance
    COUNT(DISTINCT lr.leave_id) AS total_leave_requests,
    SUM(CASE WHEN lr.status = 'Approved' THEN 1 ELSE 0 END) AS approved_leaves,
    SUM(CASE WHEN lr.status = 'Rejected' THEN 1 ELSE 0 END) AS rejected_leaves,
    -- Address information
    a.street,
    a.city,
    a.state,
    a.zip_code,
    -- Overall employee score
    ROUND(
        (
            COALESCE((SELECT AVG(rating) FROM PerformanceReviews pr WHERE pr.emp_id = e.emp_id), 0) * 0.3 +
            COALESCE(COUNT(DISTINCT et.training_id) * 20, 0) * 0.2 +
            COALESCE(COUNT(DISTINCT ep.project_id) * 10, 0) * 0.2 +
            COALESCE(
                (SELECT MAX(amount) FROM Salaries s WHERE s.emp_id = e.emp_id) / 1000, 0
            ) * 0.15 +
            COALESCE(TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) * 5, 0) * 0.15
        ), 2
    ) AS overall_employee_score,
    -- Employee category
    CASE 
        WHEN (SELECT AVG(rating) FROM PerformanceReviews pr WHERE pr.emp_id = e.emp_id) >= 4.5 
             AND COUNT(DISTINCT et.training_id) >= 5 
             AND COUNT(DISTINCT ep.project_id) >= 3 THEN 'Top Performer'
        WHEN (SELECT AVG(rating) FROM PerformanceReviews pr WHERE pr.emp_id = e.emp_id) >= 4.0 
             AND COUNT(DISTINCT et.training_id) >= 3 THEN 'High Performer'
        WHEN (SELECT AVG(rating) FROM PerformanceReviews pr WHERE pr.emp_id = e.emp_id) >= 3.5 THEN 'Solid Performer'
        WHEN (SELECT AVG(rating) FROM PerformanceReviews pr WHERE pr.emp_id = e.emp_id) >= 3.0 THEN 'Meets Expectations'
        ELSE 'Needs Improvement'
    END AS performance_category
FROM Employees e
INNER JOIN Departments d ON e.dept_id = d.dept_id
INNER JOIN Positions p ON e.position_id = p.position_id
LEFT JOIN Employees m ON d.manager_id = m.emp_id
LEFT JOIN Addresses a ON e.emp_id = a.emp_id
LEFT JOIN PerformanceReviews pr ON e.emp_id = pr.emp_id
LEFT JOIN Employee_Training et ON e.emp_id = et.emp_id AND et.status = 'Completed'
LEFT JOIN Training_Programs tp ON et.training_id = tp.training_id
LEFT JOIN Employee_Projects ep ON e.emp_id = ep.emp_id
LEFT JOIN Projects p ON ep.project_id = p.project_id
LEFT JOIN Leave_Requests lr ON e.emp_id = lr.emp_id
GROUP BY e.emp_id, e.first_name, e.last_name, e.email, e.phone, d.dept_name, p.title, 
         m.first_name, m.last_name, e.hire_date, a.street, a.city, a.state, a.zip_code
ORDER BY overall_employee_score DESC;