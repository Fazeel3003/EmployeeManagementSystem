-- ========================================
-- Employee Management System - Professional Edition
-- Designed for enterprise use with 10 core tables
-- Author: Fazeel
-- Created: 2025-02-18
-- Version: 1.0
-- ========================================

-- Create database with proper character set and collation for international support
CREATE DATABASE IF NOT EXISTS EmployeeManagementSystem 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE EmployeeManagementSystem;

-- ========================================
-- TABLE 1: DEPARTMENTS
-- Purpose: Organizational structure and hierarchy
-- ========================================
CREATE TABLE Departments (
    dept_id INT AUTO_INCREMENT PRIMARY KEY,
    dept_code VARCHAR(10) UNIQUE NOT NULL COMMENT 'Unique department code for reporting',
    dept_name VARCHAR(100) NOT NULL COMMENT 'Department name',
    description TEXT COMMENT 'Department description and responsibilities',
    manager_id INT COMMENT 'Foreign key to Employees table - department head',
    location VARCHAR(255) COMMENT 'Physical office location',
    budget DECIMAL(15,2) COMMENT 'Annual department budget',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'Active status for soft delete',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
    created_by INT COMMENT 'User who created this record',
    
    INDEX idx_dept_code (dept_code),
    INDEX idx_dept_name (dept_name),
    INDEX idx_manager_id (manager_id),
    INDEX idx_active (is_active),
    
    CONSTRAINT chk_dept_budget CHECK (budget >= 0)
) COMMENT 'Department information and organizational structure';

-- ========================================
-- TABLE 2: POSITIONS
-- Purpose: Job roles and position definitions
-- ========================================
CREATE TABLE Positions (
    position_id INT AUTO_INCREMENT PRIMARY KEY,
    position_code VARCHAR(10) UNIQUE NOT NULL COMMENT 'Unique position code',
    title VARCHAR(100) NOT NULL COMMENT 'Job title',
    description TEXT COMMENT 'Job description and responsibilities',
    department_id INT COMMENT 'Primary department for this position',
    min_salary DECIMAL(10,2) COMMENT 'Minimum salary for this position',
    max_salary DECIMAL(10,2) COMMENT 'Maximum salary for this position',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (department_id) REFERENCES Departments(dept_id) ON DELETE SET NULL,
    
    INDEX idx_position_code (position_code),
    INDEX idx_title (title),
    INDEX idx_department_id (department_id),
    INDEX idx_active (is_active),
    
    CONSTRAINT chk_salary_range CHECK (min_salary <= max_salary AND min_salary >= 0)
) COMMENT 'Job positions and roles within the organization';

-- ========================================
-- TABLE 3: EMPLOYEES
-- Purpose: Core employee information and records
-- ========================================
CREATE TABLE Employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_number VARCHAR(20) UNIQUE NOT NULL COMMENT 'Unique employee ID number',
    first_name VARCHAR(50) NOT NULL COMMENT 'First name',
    last_name VARCHAR(50) NOT NULL COMMENT 'Last name',
    middle_name VARCHAR(50) COMMENT 'Middle name or initial',
    email VARCHAR(100) UNIQUE NOT NULL COMMENT 'Company email address',
    phone VARCHAR(20) COMMENT 'Primary phone number',
    mobile VARCHAR(20) COMMENT 'Mobile phone number',
    hire_date DATE NOT NULL COMMENT 'Date of employment',
    termination_date DATE COMMENT 'Date of employment termination',
    birth_date DATE COMMENT 'Date of birth',
    gender ENUM('Male', 'Female', 'Other', 'Prefer not to say') COMMENT 'Gender identity',
    marital_status ENUM('Single', 'Married', 'Divorced', 'Widowed') COMMENT 'Marital status',
    nationality VARCHAR(50) COMMENT 'Country of citizenship',
    status ENUM('Active', 'On Leave', 'Terminated', 'Retired') DEFAULT 'Active' COMMENT 'Current employment status',
    employment_type ENUM('Full-time', 'Part-time', 'Contract', 'Intern', 'Consultant') COMMENT 'Type of employment',
    dept_id INT COMMENT 'Current department assignment',
    position_id INT COMMENT 'Current position assignment',
    manager_id INT COMMENT 'Direct manager/supervisor',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id) ON DELETE SET NULL,
    FOREIGN KEY (position_id) REFERENCES Positions(position_id) ON DELETE SET NULL,
    FOREIGN KEY (manager_id) REFERENCES Employees(emp_id) ON DELETE SET NULL,
    
    INDEX idx_employee_number (employee_number),
    INDEX idx_email (email),
    INDEX idx_name (last_name, first_name),
    INDEX idx_dept_id (dept_id),
    INDEX idx_position_id (position_id),
    INDEX idx_manager_id (manager_id),
    INDEX idx_status (status),
    INDEX idx_hire_date (hire_date),
    
    CONSTRAINT chk_email_format CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_hire_date CHECK (hire_date <= CURDATE()),
    CONSTRAINT chk_termination_date CHECK (termination_date IS NULL OR termination_date >= hire_date)
) COMMENT 'Master employee table with all personal and employment information';

-- ========================================
-- TABLE 4: EMPLOYEE_ADDRESSES
-- Purpose: Employee contact and address information
-- ========================================
CREATE TABLE Employee_Addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL COMMENT 'Foreign key to Employees table',
    address_type ENUM('Home', 'Work', 'Mailing', 'Emergency') NOT NULL COMMENT 'Type of address',
    street_address VARCHAR(255) NOT NULL COMMENT 'Street address line 1',
    city VARCHAR(100) NOT NULL COMMENT 'City name',
    state VARCHAR(50) NOT NULL COMMENT 'State or province',
    postal_code VARCHAR(20) NOT NULL COMMENT 'Postal or ZIP code',
    country VARCHAR(50) DEFAULT 'USA' COMMENT 'Country name',
    is_primary BOOLEAN DEFAULT FALSE COMMENT 'Primary address flag',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id) ON DELETE CASCADE,
    
    INDEX idx_emp_id (emp_id),
    INDEX idx_address_type (address_type),
    INDEX idx_primary (is_primary),
    
    UNIQUE KEY unique_emp_address_type (emp_id, address_type)
) COMMENT 'Employee addresses with support for multiple address types';

-- ========================================
-- TABLE 5: SALARY_HISTORY
-- Purpose: Complete salary history and compensation tracking
-- ========================================
CREATE TABLE Salary_History (
    salary_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL COMMENT 'Foreign key to Employees table',
    base_salary DECIMAL(10,2) NOT NULL COMMENT 'Base annual salary',
    bonus_amount DECIMAL(10,2) DEFAULT 0 COMMENT 'Annual bonus amount',
    overtime_rate DECIMAL(5,2) DEFAULT 0 COMMENT 'Overtime pay rate multiplier',
    effective_date DATE NOT NULL COMMENT 'Date when salary becomes effective',
    end_date DATE COMMENT 'Date when salary ends (for history tracking)',
    salary_type ENUM('Base', 'Promotion', 'Adjustment', 'Annual Review') NOT NULL COMMENT 'Type of salary change',
    reason TEXT COMMENT 'Reason for salary change',
    approved_by INT COMMENT 'Manager who approved salary change',
    approval_date DATE COMMENT 'Date of approval',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES Employees(emp_id) ON DELETE SET NULL,
    
    INDEX idx_emp_id (emp_id),
    INDEX idx_effective_date (effective_date),
    INDEX idx_salary_type (salary_type),
    INDEX idx_approved_by (approved_by),
    
    CONSTRAINT chk_salary_amount CHECK (base_salary >= 0 AND bonus_amount >= 0),
    CONSTRAINT chk_overtime_rate CHECK (overtime_rate >= 0),
    CONSTRAINT chk_effective_date CHECK (end_date IS NULL OR end_date >= effective_date)
) COMMENT 'Complete salary history with approval tracking';

-- ========================================
-- TABLE 6: PERFORMANCE_REVIEWS
-- Purpose: Employee performance evaluation system
-- ========================================
CREATE TABLE Performance_Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL COMMENT 'Employee being reviewed',
    reviewer_id INT NOT NULL COMMENT 'Manager conducting review',
    review_period_start DATE NOT NULL COMMENT 'Start date of review period',
    review_period_end DATE NOT NULL COMMENT 'End date of review period',
    review_date DATE NOT NULL COMMENT 'Date of review completion',
    overall_rating DECIMAL(3,2) CHECK (overall_rating BETWEEN 1 AND 5) COMMENT 'Overall performance rating (1-5)',
    technical_skills_rating DECIMAL(3,2) CHECK (technical_skills_rating BETWEEN 1 AND 5) COMMENT 'Technical skills rating',
    communication_rating DECIMAL(3,2) CHECK (communication_rating BETWEEN 1 AND 5) COMMENT 'Communication skills rating',
    teamwork_rating DECIMAL(3,2) CHECK (teamwork_rating BETWEEN 1 AND 5) COMMENT 'Teamwork rating',
    leadership_rating DECIMAL(3,2) CHECK (leadership_rating BETWEEN 1 AND 5) COMMENT 'Leadership rating',
    strengths TEXT COMMENT 'Employee strengths and achievements',
    areas_for_improvement TEXT COMMENT 'Areas needing improvement',
    goals TEXT COMMENT 'Goals for next review period',
    comments TEXT COMMENT 'Additional comments',
    status ENUM('Draft', 'Submitted', 'Reviewed', 'Approved') DEFAULT 'Draft' COMMENT 'Review workflow status',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id) ON DELETE CASCADE,
    FOREIGN KEY (reviewer_id) REFERENCES Employees(emp_id) ON DELETE CASCADE,
    
    INDEX idx_emp_id (emp_id),
    INDEX idx_reviewer_id (reviewer_id),
    INDEX idx_review_period (review_period_start, review_period_end),
    INDEX idx_status (status),
    INDEX idx_review_date (review_date),
    
    CONSTRAINT chk_review_period CHECK (review_period_end >= review_period_start),
    CONSTRAINT chk_review_date CHECK (review_date >= review_period_end)
) COMMENT 'Employee performance reviews with detailed ratings and feedback';

-- ========================================
-- TABLE 7: PROJECTS
-- Purpose: Project management and tracking
-- ========================================
CREATE TABLE Projects (
    project_id INT AUTO_INCREMENT PRIMARY KEY,
    project_name VARCHAR(200) NOT NULL COMMENT 'Project name',
    project_code VARCHAR(20) UNIQUE NOT NULL COMMENT 'Unique project code',
    description TEXT COMMENT 'Project description and objectives',
    client_name VARCHAR(100) COMMENT 'Client or customer name',
    start_date DATE COMMENT 'Planned start date',
    end_date DATE COMMENT 'Planned end date',
    planned_end_date DATE COMMENT 'Original planned end date',
    budget DECIMAL(15,2) COMMENT 'Project budget',
    actual_cost DECIMAL(15,2) DEFAULT 0 COMMENT 'Actual cost incurred',
    status ENUM('Planning', 'In Progress', 'On Hold', 'Completed', 'Cancelled') DEFAULT 'Planning' COMMENT 'Current project status',
    priority ENUM('Low', 'Medium', 'High', 'Critical') DEFAULT 'Medium' COMMENT 'Project priority level',
    project_manager_id INT COMMENT 'Project manager assignment',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (project_manager_id) REFERENCES Employees(emp_id) ON DELETE SET NULL,
    
    INDEX idx_project_code (project_code),
    INDEX idx_project_name (project_name),
    INDEX idx_status (status),
    INDEX idx_priority (priority),
    INDEX idx_project_manager (project_manager_id),
    INDEX idx_start_date (start_date),
    
    CONSTRAINT chk_project_dates CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT chk_project_budget CHECK (budget >= 0 AND actual_cost >= 0)
) COMMENT 'Project management with budget and timeline tracking';

-- ========================================
-- TABLE 8: EMPLOYEE_PROJECTS
-- Purpose: Many-to-many relationship between employees and projects
-- ========================================
CREATE TABLE Employee_Projects (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL COMMENT 'Employee assigned to project',
    project_id INT NOT NULL COMMENT 'Project assignment',
    role VARCHAR(100) NOT NULL COMMENT 'Role on project (e.g., Developer, Analyst)',
    hourly_rate DECIMAL(8,2) COMMENT 'Hourly rate for this project',
    allocation_percentage DECIMAL(5,2) DEFAULT 100 COMMENT 'Time allocation percentage',
    start_date DATE NOT NULL COMMENT 'Assignment start date',
    end_date DATE COMMENT 'Assignment end date',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'Active assignment status',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id) ON DELETE CASCADE,
    FOREIGN KEY (project_id) REFERENCES Projects(project_id) ON DELETE CASCADE,
    
    INDEX idx_emp_id (emp_id),
    INDEX idx_project_id (project_id),
    INDEX idx_role (role),
    INDEX idx_active (is_active),
    INDEX idx_start_date (start_date),
    
    UNIQUE KEY unique_emp_project_active (emp_id, project_id, is_active),
    CONSTRAINT chk_allocation CHECK (allocation_percentage BETWEEN 0 AND 100),
    CONSTRAINT chk_assignment_dates CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT chk_hourly_rate CHECK (hourly_rate IS NULL OR hourly_rate >= 0)
) COMMENT 'Employee project assignments with role and time tracking';

-- ========================================
-- TABLE 9: TRAINING_PROGRAMS
-- Purpose: Training and development programs catalog
-- ========================================
CREATE TABLE Training_Programs (
    training_id INT AUTO_INCREMENT PRIMARY KEY,
    program_name VARCHAR(200) NOT NULL COMMENT 'Training program name',
    program_code VARCHAR(20) UNIQUE NOT NULL COMMENT 'Unique program code',
    description TEXT COMMENT 'Program description and objectives',
    category VARCHAR(50) COMMENT 'Training category (e.g., Technical, Soft Skills)',
    duration_days INT COMMENT 'Duration in days',
    duration_hours DECIMAL(5,2) COMMENT 'Duration in hours',
    cost DECIMAL(10,2) COMMENT 'Cost per participant',
    provider VARCHAR(100) COMMENT 'Training provider or vendor',
    is_internal BOOLEAN DEFAULT FALSE COMMENT 'Internal or external training',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'Program availability status',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_program_code (program_code),
    INDEX idx_program_name (program_name),
    INDEX idx_category (category),
    INDEX idx_active (is_active),
    INDEX idx_provider (provider),
    
    CONSTRAINT chk_training_duration CHECK (duration_days > 0 AND duration_hours > 0),
    CONSTRAINT chk_training_cost CHECK (cost >= 0)
) COMMENT 'Training programs catalog with cost and duration information';

-- ========================================
-- TABLE 10: EMPLOYEE_TRAINING
-- Purpose: Employee training enrollment and completion tracking
-- ========================================
CREATE TABLE Employee_Training (
    training_record_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL COMMENT 'Employee enrolled in training',
    training_id INT NOT NULL COMMENT 'Training program',
    enrollment_date DATE NOT NULL COMMENT 'Date of enrollment',
    completion_date DATE COMMENT 'Date of completion',
    status ENUM('Enrolled', 'In Progress', 'Completed', 'Failed', 'Dropped', 'Cancelled') DEFAULT 'Enrolled' COMMENT 'Training status',
    score DECIMAL(5,2) COMMENT 'Achieved score',
    max_score DECIMAL(5,2) COMMENT 'Maximum possible score',
    grade VARCHAR(5) COMMENT 'Grade achieved',
    certificate_issued BOOLEAN DEFAULT FALSE COMMENT 'Certificate issuance status',
    certificate_url VARCHAR(500) COMMENT 'Certificate file location',
    notes TEXT COMMENT 'Additional notes',
    cost_to_company DECIMAL(10,2) COMMENT 'Cost incurred by company',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id) ON DELETE CASCADE,
    FOREIGN KEY (training_id) REFERENCES Training_Programs(training_id) ON DELETE CASCADE,
    
    INDEX idx_emp_id (emp_id),
    INDEX idx_training_id (training_id),
    INDEX idx_status (status),
    INDEX idx_enrollment_date (enrollment_date),
    INDEX idx_completion_date (completion_date),
    
    CONSTRAINT chk_training_score CHECK (score IS NULL OR (score >= 0 AND max_score IS NOT NULL AND score <= max_score)),
    CONSTRAINT chk_training_cost CHECK (cost_to_company >= 0),
    CONSTRAINT chk_completion_date CHECK (completion_date IS NULL OR completion_date >= enrollment_date)
) COMMENT 'Employee training records with enrollment, completion, and performance tracking';

-- ========================================
-- ADD FOREIGN KEY CONSTRAINT FOR DEPARTMENT MANAGER
-- This must be added after Employees table is created
-- ========================================
ALTER TABLE Departments 
ADD CONSTRAINT fk_dept_manager 
FOREIGN KEY (manager_id) REFERENCES Employees(emp_id) ON DELETE SET NULL;

-- ========================================
-- VIEWS FOR COMMON BUSINESS QUERIES
-- Purpose: Simplify complex queries and improve performance
-- ========================================

-- View: Current Employee Details
-- Provides comprehensive employee information for reporting
CREATE VIEW v_Employee_Details AS
SELECT 
    e.emp_id,
    e.employee_number,
    e.first_name,
    e.last_name,
    e.email,
    e.phone,
    e.hire_date,
    e.status,
    e.employment_type,
    d.dept_name,
    d.location as dept_location,
    p.title as position_title,
    s.base_salary as current_salary,
    m.first_name as manager_first_name,
    m.last_name as manager_last_name,
    TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) as years_of_service,
    CASE 
        WHEN e.termination_date IS NULL THEN 'Active'
        ELSE 'Terminated'
    END as employment_status
FROM Employees e
LEFT JOIN Departments d ON e.dept_id = d.dept_id
LEFT JOIN Positions p ON e.position_id = p.position_id
LEFT JOIN Salary_History s ON e.emp_id = s.emp_id 
    AND s.effective_date = (SELECT MAX(effective_date) FROM Salary_History WHERE emp_id = e.emp_id AND end_date IS NULL)
LEFT JOIN Employees m ON e.manager_id = m.emp_id
WHERE e.status = 'Active';

-- View: Department Summary
-- Provides department-level metrics and statistics
CREATE VIEW v_Department_Summary AS
SELECT 
    d.dept_id,
    d.dept_name,
    d.location,
    d.budget,
    COUNT(e.emp_id) as employee_count,
    AVG(s.base_salary) as avg_salary,
    SUM(s.base_salary) as total_salary_cost,
    m.first_name as manager_first_name,
    m.last_name as manager_last_name
FROM Departments d
LEFT JOIN Employees e ON d.dept_id = e.dept_id AND e.status = 'Active'
LEFT JOIN Salary_History s ON e.emp_id = s.emp_id 
    AND s.effective_date = (SELECT MAX(effective_date) FROM Salary_History WHERE emp_id = e.emp_id AND end_date IS NULL)
LEFT JOIN Employees m ON d.manager_id = m.emp_id
GROUP BY d.dept_id, d.dept_name, d.location, d.budget, m.first_name, m.last_name;

-- ========================================
-- STORED PROCEDURES FOR COMMON OPERATIONS
-- Purpose: Encapsulate business logic and ensure data consistency
-- ========================================

DELIMITER //

-- Procedure: Hire New Employee
-- Purpose: Complete employee onboarding with salary assignment
CREATE PROCEDURE sp_HireEmployee(
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_phone VARCHAR(20),
    IN p_hire_date DATE,
    IN p_dept_id INT,
    IN p_position_id INT,
    IN p_salary DECIMAL(10,2),
    IN p_manager_id INT,
    OUT p_emp_id INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_message = CONCAT('Error hiring employee: ', SQLSTATE, ' - ', SQLERRM);
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Validate hire date
    IF p_hire_date > CURDATE() THEN
        SET p_result_message = 'Hire date cannot be in the future';
        ROLLBACK;
    ELSE
        -- Insert employee record
        INSERT INTO Employees (first_name, last_name, email, phone, hire_date, dept_id, position_id, manager_id)
        VALUES (p_first_name, p_last_name, p_email, p_phone, p_hire_date, p_dept_id, p_position_id, p_manager_id);
        
        SET p_emp_id = LAST_INSERT_ID();
        
        -- Generate employee number
        UPDATE Employees 
        SET employee_number = CONCAT('EMP', LPAD(p_emp_id, 6, '0'))
        WHERE emp_id = p_emp_id;
        
        -- Insert initial salary record
        INSERT INTO Salary_History (emp_id, base_salary, effective_date, salary_type, reason)
        VALUES (p_emp_id, p_salary, p_hire_date, 'Base', 'Initial hire salary');
        
        COMMIT;
        SET p_result_message = CONCAT('Employee hired successfully. Employee ID: ', p_emp_id);
    END IF;
END //

-- Procedure: Update Employee Salary
-- Purpose: Process salary changes with proper history tracking
CREATE PROCEDURE sp_UpdateSalary(
    IN p_emp_id INT,
    IN p_new_salary DECIMAL(10,2),
    IN p_effective_date DATE,
    IN p_salary_type VARCHAR(50),
    IN p_reason TEXT,
    IN p_approved_by INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_message = CONCAT('Error updating salary: ', SQLSTATE, ' - ', SQLERRM);
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Validate employee exists
    IF NOT EXISTS (SELECT 1 FROM Employees WHERE emp_id = p_emp_id) THEN
        SET p_result_message = 'Employee not found';
        ROLLBACK;
    -- Validate effective date
    ELSEIF p_effective_date > CURDATE() THEN
        SET p_result_message = 'Effective date cannot be in the future';
        ROLLBACK;
    ELSE
        -- End previous salary record
        UPDATE Salary_History 
        SET end_date = DATE_SUB(p_effective_date, INTERVAL 1 DAY)
        WHERE emp_id = p_emp_id AND end_date IS NULL;
        
        -- Insert new salary record
        INSERT INTO Salary_History (emp_id, base_salary, effective_date, salary_type, reason, approved_by, approval_date)
        VALUES (p_emp_id, p_new_salary, p_effective_date, p_salary_type, p_reason, p_approved_by, CURDATE());
        
        COMMIT;
        SET p_result_message = 'Salary updated successfully';
    END IF;
END //

DELIMITER ;

-- ========================================
-- TRIGGERS FOR AUDITING AND BUSINESS LOGIC
-- Purpose: Automatic data validation and audit trail creation
-- ========================================

DELIMITER //

-- Trigger: Employee Audit Log
-- Purpose: Track all employee record changes for compliance
CREATE TRIGGER tr_Employees_Audit
AFTER INSERT ON Employees
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (table_name, record_id, action, new_values, changed_by)
    VALUES ('Employees', NEW.emp_id, 'INSERT', JSON_OBJECT(
        'emp_id', NEW.emp_id,
        'employee_number', NEW.employee_number,
        'first_name', NEW.first_name,
        'last_name', NEW.last_name,
        'email', NEW.email,
        'hire_date', NEW.hire_date,
        'dept_id', NEW.dept_id,
        'position_id', NEW.position_id
    ), NEW.emp_id);
END //

-- Trigger: Salary History Audit
-- Purpose: Track all salary changes for financial compliance
CREATE TRIGGER tr_Salary_History_Audit
AFTER INSERT ON Salary_History
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (table_name, record_id, action, new_values, changed_by)
    VALUES ('Salary_History', NEW.salary_id, 'INSERT', JSON_OBJECT(
        'emp_id', NEW.emp_id,
        'base_salary', NEW.base_salary,
        'effective_date', NEW.effective_date,
        'salary_type', NEW.salary_type,
        'approved_by', NEW.approved_by
    ), NEW.approved_by);
END //

DELIMITER ;

-- ========================================
-- CREATE AUDIT LOG TABLE (for triggers)
-- ========================================
CREATE TABLE IF NOT EXISTS Audit_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    record_id INT NOT NULL,
    action ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    old_values JSON,
    new_values JSON,
    changed_by INT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent TEXT,
    
    FOREIGN KEY (changed_by) REFERENCES Employees(emp_id) ON DELETE SET NULL,
    
    INDEX idx_table_record (table_name, record_id),
    INDEX idx_action (action),
    INDEX idx_changed_by (changed_by),
    INDEX idx_changed_at (changed_at)
) COMMENT 'System audit log for tracking data changes';

-- ========================================
-- SAMPLE DATA INSERTION
-- Purpose: Provide realistic test data for development and demonstration
-- ========================================

-- Insert sample departments
INSERT INTO Departments (dept_code, dept_name, description, location, budget) VALUES
('IT', 'Information Technology', 'Technology infrastructure and software development', 'Building A, Floor 3', 1500000.00),
('HR', 'Human Resources', 'Employee relations and talent management', 'Building A, Floor 2', 800000.00),
('FIN', 'Finance', 'Financial planning and accounting', 'Building B, Floor 1', 1200000.00),
('MKT', 'Marketing', 'Brand management and customer acquisition', 'Building B, Floor 2', 1000000.00),
('OPS', 'Operations', 'Business operations and logistics', 'Building C, Floor 1', 900000.00);

-- Insert sample positions
INSERT INTO Positions (position_code, title, description, department_id, min_salary, max_salary) VALUES
('SE1', 'Software Engineer I', 'Entry-level software development', 1, 60000.00, 80000.00),
('SE2', 'Software Engineer II', 'Mid-level software development', 1, 75000.00, 95000.00),
('SE3', 'Senior Software Engineer', 'Senior-level software development', 1, 90000.00, 120000.00),
('HR1', 'HR Specialist', 'Human resources specialist', 2, 50000.00, 70000.00),
('HR2', 'HR Manager', 'Human resources manager', 2, 70000.00, 90000.00),
('FIN1', 'Accountant', 'Financial accounting', 3, 55000.00, 75000.00),
('FIN2', 'Finance Manager', 'Financial management', 3, 80000.00, 110000.00),
('MKT1', 'Marketing Specialist', 'Marketing specialist', 4, 50000.00, 70000.00),
('MKT2', 'Marketing Manager', 'Marketing management', 4, 75000.00, 100000.00),
('OPS1', 'Operations Specialist', 'Operations specialist', 5, 45000.00, 65000.00);

-- Insert sample employees (will be updated with manager relationships after all employees are inserted)
INSERT INTO Employees (first_name, last_name, email, phone, hire_date, dept_id, position_id) VALUES
('John', 'Smith', 'john.smith@company.com', '555-0101', '2022-01-15', 1, 3),
('Jane', 'Johnson', 'jane.johnson@company.com', '555-0102', '2022-02-20', 2, 5),
('Michael', 'Williams', 'michael.williams@company.com', '555-0103', '2021-06-10', 1, 2),
('Sarah', 'Brown', 'sarah.brown@company.com', '555-0104', '2022-03-15', 3, 7),
('David', 'Jones', 'david.jones@company.com', '555-0105', '2021-09-01', 4, 9),
('Lisa', 'Garcia', 'lisa.garcia@company.com', '555-0106', '2022-04-20', 5, 10),
('Robert', 'Miller', 'robert.miller@company.com', '555-0107', '2022-05-10', 1, 1),
('Emily', 'Davis', 'emily.davis@company.com', '555-0108', '2022-06-01', 2, 4),
('James', 'Rodriguez', 'james.rodriguez@company.com', '555-0109', '2021-11-15', 3, 6),
('Jennifer', 'Martinez', 'jennifer.martinez@company.com', '555-0110', '2022-07-01', 4, 8);

-- Set manager relationships
UPDATE Employees SET manager_id = 1 WHERE emp_id IN (3, 7);  -- John manages Michael and Robert
UPDATE Employees SET manager_id = 2 WHERE emp_id IN (8);     -- Jane manages Emily
UPDATE Employees SET manager_id = 4 WHERE emp_id IN (10);    -- Sarah manages Jennifer
UPDATE Departments SET manager_id = 1 WHERE dept_id = 1;    -- John manages IT
UPDATE Departments SET manager_id = 2 WHERE dept_id = 2;    -- Jane manages HR
UPDATE Departments SET manager_id = 4 WHERE dept_id = 4;    -- Sarah manages Marketing

-- Insert sample addresses
INSERT INTO Employee_Addresses (emp_id, address_type, street_address, city, state, postal_code, is_primary) VALUES
(1, 'Home', '123 Main St', 'New York', 'NY', '10001', TRUE),
(2, 'Home', '456 Oak Ave', 'Boston', 'MA', '02101', TRUE),
(3, 'Home', '789 Pine Rd', 'Chicago', 'IL', '60601', TRUE),
(4, 'Home', '321 Elm Dr', 'Los Angeles', 'CA', '90210', TRUE),
(5, 'Home', '654 Cedar Ln', 'Houston', 'TX', '77001', TRUE),
(6, 'Home', '987 Maple Blvd', 'Phoenix', 'AZ', '85001', TRUE),
(7, 'Home', '147 Birch Ct', 'Philadelphia', 'PA', '19101', TRUE),
(8, 'Home', '258 Spruce Way', 'San Antonio', 'TX', '78201', TRUE),
(9, 'Home', '369 Willow Dr', 'San Diego', 'CA', '92101', TRUE),
(10, 'Home', '741 Aspen Ave', 'Dallas', 'TX', '75201', TRUE);

-- Insert sample salary history
INSERT INTO Salary_History (emp_id, base_salary, effective_date, salary_type, reason) VALUES
(1, 95000.00, '2022-01-15', 'Base', 'Initial hire salary'),
(2, 80000.00, '2022-02-20', 'Base', 'Initial hire salary'),
(3, 80000.00, '2021-06-10', 'Base', 'Initial hire salary'),
(4, 100000.00, '2022-03-15', 'Base', 'Initial hire salary'),
(5, 90000.00, '2021-09-01', 'Base', 'Initial hire salary'),
(6, 55000.00, '2022-04-20', 'Base', 'Initial hire salary'),
(7, 70000.00, '2022-05-10', 'Base', 'Initial hire salary'),
(8, 60000.00, '2022-06-01', 'Base', 'Initial hire salary'),
(9, 65000.00, '2021-11-15', 'Base', 'Initial hire salary'),
(10, 65000.00, '2022-07-01', 'Base', 'Initial hire salary');

-- Insert sample performance reviews
INSERT INTO Performance_Reviews (emp_id, reviewer_id, review_period_start, review_period_end, review_date, overall_rating, technical_skills_rating, communication_rating, teamwork_rating, leadership_rating, status) VALUES
(1, 1, '2022-01-01', '2022-12-31', '2022-12-15', 4.5, 4.8, 4.2, 4.5, 4.6, 'Approved'),
(2, 2, '2022-02-01', '2022-12-31', '2022-12-20', 4.2, 4.0, 4.5, 4.1, 4.3, 'Approved'),
(3, 1, '2021-06-01', '2022-05-31', '2022-06-15', 4.0, 4.2, 3.8, 4.1, 3.9, 'Approved'),
(4, 4, '2022-03-01', '2022-12-31', '2022-12-25', 4.7, 4.5, 4.8, 4.6, 4.9, 'Approved'),
(5, 5, '2021-09-01', '2022-08-31', '2022-09-15', 4.3, 4.1, 4.4, 4.3, 4.4, 'Approved');

-- Insert sample projects
INSERT INTO Projects (project_name, project_code, description, start_date, end_date, budget, status, priority, project_manager_id) VALUES
('Website Redesign', 'PROJ001', 'Complete overhaul of company website', '2023-01-01', '2023-06-30', 75000.00, 'Completed', 'High', 1),
('Mobile App Development', 'PROJ002', 'Develop company mobile application', '2023-03-01', '2023-12-31', 150000.00, 'In Progress', 'High', 1),
('Financial System Upgrade', 'PROJ003', 'Upgrade financial management system', '2023-02-01', '2023-08-31', 100000.00, 'In Progress', 'Medium', 4),
('Marketing Campaign Q3', 'PROJ004', 'Third quarter marketing campaign', '2023-07-01', '2023-09-30', 50000.00, 'Planning', 'Medium', 5),
('HR System Implementation', 'PROJ005', 'Implement new HR management system', '2023-05-01', '2023-11-30', 80000.00, 'On Hold', 'Low', 2);

-- Insert sample employee project assignments
INSERT INTO Employee_Projects (emp_id, project_id, role, hourly_rate, allocation_percentage, start_date, end_date) VALUES
(1, 1, 'Project Manager', 75.00, 100, '2023-01-01', '2023-06-30'),
(3, 1, 'Senior Developer', 60.00, 100, '2023-01-01', '2023-06-30'),
(7, 1, 'Developer', 45.00, 100, '2023-01-01', '2023-06-30'),
(1, 2, 'Project Manager', 75.00, 100, '2023-03-01', NULL),
(3, 2, 'Senior Developer', 60.00, 100, '2023-03-01', NULL),
(7, 2, 'Developer', 45.00, 100, '2023-03-01', NULL),
(4, 3, 'Project Manager', 80.00, 100, '2023-02-01', NULL),
(9, 3, 'Finance Analyst', 50.00, 100, '2023-02-01', NULL);

-- Insert sample training programs
INSERT INTO Training_Programs (program_name, program_code, description, category, duration_days, duration_hours, cost, provider, is_internal) VALUES
('Advanced SQL', 'TRG001', 'Advanced SQL query optimization and database design', 'Technical', 5, 40.0, 1500.00, 'Tech Training Inc', FALSE),
('Leadership Excellence', 'TRG002', 'Leadership skills and team management', 'Soft Skills', 3, 24.0, 2000.00, 'Leadership Institute', FALSE),
('Project Management Professional', 'TRG003', 'PMP certification preparation course', 'Management', 10, 80.0, 3000.00, 'PM Institute', FALSE),
('Communication Skills', 'TRG004', 'Professional communication and presentation skills', 'Soft Skills', 2, 16.0, 800.00, 'Internal Training', TRUE),
('Financial Analysis', 'TRG005', 'Advanced financial analysis and modeling', 'Technical', 4, 32.0, 1800.00, 'Finance Academy', FALSE);

-- Insert sample employee training records
INSERT INTO Employee_Training (emp_id, training_id, enrollment_date, completion_date, status, score, max_score, grade, certificate_issued, cost_to_company) VALUES
(1, 1, '2023-01-15', '2023-01-20', 'Completed', 92.5, 100.0, 'A', TRUE, 1500.00),
(2, 2, '2023-02-01', '2023-02-04', 'Completed', 88.0, 100.0, 'B+', TRUE, 2000.00),
(3, 1, '2023-03-10', '2023-03-15', 'Completed', 95.0, 100.0, 'A', TRUE, 1500.00),
(4, 5, '2023-04-05', '2023-04-09', 'Completed', 87.5, 100.0, 'B+', TRUE, 1800.00),
(5, 4, '2023-05-01', '2023-05-03', 'Completed', 91.0, 100.0, 'A-', TRUE, 800.00);

-- ========================================
-- SUCCESS MESSAGE
-- ========================================
SELECT 'Employee Management System - Professional Edition created successfully!' as status,
       '10 tables with sample data, views, stored procedures, and triggers installed.' as details,
       'System is ready for use and demonstration.' as message;