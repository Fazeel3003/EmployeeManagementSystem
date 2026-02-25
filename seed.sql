INSERT INTO Departments (dept_name, location, budget) VALUES
('Human Resources', 'New York', 150000),
('IT', 'San Francisco', 500000),
('Finance', 'Chicago', 500000),
('Marketing', 'Los Angeles', 300000),
('Operations', 'Houston', 250000);


INSERT INTO Positions (position_title, min_salary, max_salary, dept_id) VALUES
('HR Manager', 60000, 90000, 1),
('Software Developer', 70000, 120000, 2),
('System Administrator', 65000, 100000, 2),
('Accountant', 55000, 85000, 3),
('Marketing Specialist', 50000, 80000, 4),
('Operations Manager', 65000, 95000, 5);


INSERT INTO Employees 
(employee_code, first_name, last_name, email, phone, hire_date, status, dept_id, position_id, manager_id)
VALUES
('EMP001', 'John', 'Smith', 'john.smith@company.com', '1234567890', '2022-01-10', 'Active', 2, 2, NULL),
('EMP002', 'Sarah', 'Johnson', 'sarah.johnson@company.com', '1234567891', '2021-03-15', 'Active', 1, 1, NULL),
('EMP003', 'David', 'Lee', 'david.lee@company.com', '1234567892', '2023-06-01', 'Active', 2, 3, 1),
('EMP004', 'Emily', 'Brown', 'emily.brown@company.com', '1234567893', '2020-11-20', 'Active', 3, 4, NULL),
('EMP005', 'Michael', 'Davis', 'michael.davis@company.com', '1234567894', '2022-09-05', 'On Leave', 4, 5, NULL),
('EMP006', 'Laura', 'Wilson', 'laura.wilson@company.com', '1234567895', '2021-07-18', 'Active', 5, 6, NULL),
('EMP007', 'Daniel', 'Martinez', 'daniel.m@company.com', '1234567896', '2022-04-12', 'Active', 2, 2, 1),
('EMP008', 'Sophia', 'Anderson', 'sophia.a@company.com', '1234567897', '2023-02-01', 'Active', 2, 2, 1),
('EMP009', 'James', 'Taylor', 'james.t@company.com', '1234567898', '2021-09-10', 'Active', 3, 4, 4),
('EMP010', 'Olivia', 'Thomas', 'olivia.t@company.com', '1234567899', '2020-05-25', 'Active', 4, 5, 5);


INSERT INTO Salary_History (emp_id, salary_amount, effective_from, change_reason) VALUES
(1, 90000, '2022-01-10', 'Initial Hiring'),
(2, 80000, '2021-03-15', 'Initial Hiring'),
(3, 75000, '2023-06-01', 'Initial Hiring'),
(4, 70000, '2020-11-20', 'Initial Hiring'),
(5, 65000, '2022-09-05', 'Initial Hiring'),
(6, 85000, '2021-07-18', 'Initial Hiring'),
(7, 95000, '2022-04-12', 'Initial Hiring'),
(8, 95000, '2023-02-01', 'Initial Hiring'),
(9, 72000, '2021-09-10', 'Initial Hiring'),
(10, 68000, '2020-05-25', 'Initial Hiring');


INSERT INTO Projects (project_name, start_date, end_date, budget, status, project_manager_id) VALUES
('Website Redesign', '2024-01-01', NULL, 100000, 'In Progress', 1),
('HR System Upgrade', '2024-03-01', NULL, 80000, 'In Progress', 2),
('Financial Audit 2025', '2025-01-01', NULL, 120000, 'Planned', 4);


INSERT INTO Employee_Projects 
(emp_id, project_id, role_name, allocation_percent, assigned_on)
VALUES
(1, 1, 'Project Lead', 100, '2024-01-01'),
(3, 1, 'Backend Developer', 80, '2024-01-01'),
(2, 2, 'HR Lead', 100, '2024-03-01'),
(4, 3, 'Financial Analyst', 100, '2025-01-01'),
(7, 1, 'Frontend Developer', 70, '2024-01-01'),
(8, 1, 'UI Developer', 60, '2024-01-01'),
(1, 2, 'Technical Advisor', 40, '2024-03-01'),
(9, 3, 'Audit Support', 100, '2025-01-01');


INSERT INTO Attendance (emp_id, attendance_date, check_in, check_out, attendance_status) VALUES
(1, '2026-02-18', '09:00:00', '17:00:00', 'Present'),
(2, '2026-02-18', '09:15:00', '17:05:00', 'Present'),
(3, '2026-02-18', NULL, NULL, 'Leave'),
(4, '2026-02-18', '08:55:00', '16:50:00', 'Present'),
(7, '2026-02-18', '09:05:00', '17:10:00', 'Present'),
(8, '2026-02-18', '09:20:00', '17:00:00', 'Present'),
(9, '2026-02-18', NULL, NULL, 'Absent'),
(10, '2026-02-18', '08:50:00', '16:45:00', 'Present');



INSERT INTO Leave_Requests 
(emp_id, leave_type, start_date, end_date, reason, approval_status, approved_by)
VALUES
(3, 'Sick', '2026-02-18', '2026-02-20', 'Flu recovery', 'Approved', 1),
(5, 'Casual', '2026-03-05', '2026-03-07', 'Family event', 'Pending', NULL);


