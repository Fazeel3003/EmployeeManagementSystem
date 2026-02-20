-- 1) Departments
CREATE TABLE Departments (
    dept_id INT AUTO_INCREMENT PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100),
    budget DECIMAL(12,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_department_budget CHECK (budget >= 0)
);

-- 2) Positions
CREATE TABLE Positions (
    position_id INT AUTO_INCREMENT PRIMARY KEY,
    position_title VARCHAR(100) NOT NULL,
    min_salary DECIMAL(10,2) DEFAULT 0,
    max_salary DECIMAL(10,2) DEFAULT 0,
    dept_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_position_salary CHECK (min_salary >= 0 AND max_salary >= min_salary),
    CONSTRAINT fk_position_department 
        FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
        ON DELETE SET NULL
);

-- 3) Employees
CREATE TABLE Employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_code VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    status ENUM('Active', 'On Leave', 'Resigned') DEFAULT 'Active',
    dept_id INT,
    position_id INT,
    manager_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_employee_email CHECK (email LIKE '%@%.%'),
    CONSTRAINT fk_employee_department 
        FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_employee_position 
        FOREIGN KEY (position_id) REFERENCES Positions(position_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_employee_manager 
        FOREIGN KEY (manager_id) REFERENCES Employees(emp_id)
        ON DELETE SET NULL
);

-- 4) Salary History
CREATE TABLE Salary_History (
    salary_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    salary_amount DECIMAL(10,2) NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    change_reason VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_salary_positive CHECK (salary_amount > 0),
    CONSTRAINT chk_salary_dates CHECK (effective_to IS NULL OR effective_to >= effective_from),
    CONSTRAINT fk_salary_employee 
        FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
        ON DELETE CASCADE
);

-- 5) Projects
CREATE TABLE Projects (
    project_id INT AUTO_INCREMENT PRIMARY KEY,
    project_name VARCHAR(150) NOT NULL,
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12,2) DEFAULT 0,
    status ENUM('Planned', 'In Progress', 'Completed', 'Cancelled') DEFAULT 'Planned',
    project_manager_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_project_budget CHECK (budget >= 0),
    CONSTRAINT chk_project_dates CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT fk_project_manager 
        FOREIGN KEY (project_manager_id) REFERENCES Employees(emp_id)
        ON DELETE SET NULL
);

-- 6) Employee Projects
CREATE TABLE Employee_Projects (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    project_id INT NOT NULL,
    role_name VARCHAR(80) NOT NULL,
    allocation_percent DECIMAL(5,2) DEFAULT 100,
    assigned_on DATE NOT NULL,
    released_on DATE,
    CONSTRAINT chk_allocation_percent CHECK (allocation_percent BETWEEN 0 AND 100),
    CONSTRAINT chk_assignment_dates CHECK (released_on IS NULL OR released_on >= assigned_on),
    CONSTRAINT uq_employee_project UNIQUE (emp_id, project_id),
    CONSTRAINT fk_assignment_employee 
        FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_assignment_project 
        FOREIGN KEY (project_id) REFERENCES Projects(project_id)
        ON DELETE CASCADE
);

-- 7) Attendance
CREATE TABLE Attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    check_in TIME,
    check_out TIME,
    attendance_status ENUM('Present', 'Absent', 'Leave', 'Half Day') DEFAULT 'Present',
    CONSTRAINT uq_attendance_emp_day UNIQUE (emp_id, attendance_date),
    CONSTRAINT fk_attendance_employee 
        FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
        ON DELETE CASCADE
);

-- 8) Leave Requests
CREATE TABLE Leave_Requests (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    leave_type ENUM('Sick', 'Casual', 'Earned', 'Maternity', 'Paternity', 'Unpaid') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason VARCHAR(255),
    approval_status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    approved_by INT,
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_leave_dates CHECK (end_date >= start_date),
    CONSTRAINT fk_leave_employee 
        FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_leave_approver 
        FOREIGN KEY (approved_by) REFERENCES Employees(emp_id)
        ON DELETE SET NULL
); 