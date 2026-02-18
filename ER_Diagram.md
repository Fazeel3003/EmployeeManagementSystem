# Employee Management System - ER Diagram

## Database Overview
This Employee Management System is designed as a comprehensive, enterprise-grade database solution for managing all aspects of employee lifecycle, from recruitment to training and project assignments.

## Entity Relationship Diagram

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│   Departments   │       │    Positions    │       │    Employees    │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ dept_id (PK)    │◄──────│ dept_id (FK)    │◄──────│ dept_id (FK)    │
│ dept_code       │       │ position_id (PK)│       │ emp_id (PK)     │
│ dept_name       │       │ position_code   │       │ employee_number │
│ description     │       │ title           │       │ first_name      │
│ manager_id (FK) │──────►│ description     │       │ last_name       │
│ location        │       │ min_salary      │       │ email           │
│ budget          │       │ max_salary      │       │ phone           │
│ is_active       │       │ is_active       │       │ hire_date       │
│ created_at      │       │ created_at      │       │ termination_date│
│ updated_at      │       │ updated_at      │       │ birth_date      │
│ created_by      │       └─────────────────┘       │ gender          │
└─────────────────┘                                 │ marital_status  │
         │                                          │ nationality     │
         │                                          │ status          │
         │                                          │ employment_type │
         │                                          │ position_id (FK)│
         │                                          │ manager_id (FK) │
         │                                          │ created_at      │
         │                                          │ updated_at      │
         │                                          └─────────────────┘
         │                                                     │
         │                                                     │
         │                                                     │
         │                                            ┌─────────────────┐
         │                                            │ Employee_Addr   │
         │                                            ├─────────────────┤
         │                                            │ address_id (PK) │
         └────────────────────────────────────────────│ emp_id (FK)     │
                                                      │ address_type    │
                                                      │ street_address  │
                                                      │ city            │
                                                      │ state           │
                                                      │ postal_code     │
                                                      │ country         │
                                                      │ is_primary      │
                                                      │ created_at      │
                                                      │ updated_at      │
                                                      └─────────────────┘
         │
         │
         │
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│   Projects      │       │ Employee_Proj   │       │ Salary_History  │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ project_id (PK) │◄──────│ project_id (FK) │       │ salary_id (PK)  │
│ project_code    │       │ emp_id (FK)     │◄──────│ emp_id (FK)     │
│ project_name    │       │ assignment_id(PK)│      │ base_salary     │
│ description     │       │ role            │       │ bonus_amount    │
│ client_name     │       │ hourly_rate     │       │ overtime_rate   │
│ start_date      │       │ allocation_%    │       │ effective_date  │
│ end_date        │       │ start_date      │       │ end_date        │
│ planned_end_date│       │ end_date        │       │ salary_type     │
│ budget          │       │ is_active       │       │ reason          │
│ actual_cost     │       │ created_at      │       │ approved_by (FK)│
│ status          │       │ updated_at      │       │ approval_date   │
│ priority        │       └─────────────────┘       │ created_at      │
│ project_mgr(FK) │              │                  └─────────────────┘
│ created_at      │              │
│ updated_at      │              │
└─────────────────┘              │
         │                       │
         │                       │
         │                       │
         │              ┌─────────────────┐
         │              │ Performance_Rev │
         │              ├─────────────────┤
         └──────────────│ review_id (PK)  │
                        │ emp_id (FK)     │
                        │ reviewer_id (FK)│
                        │ review_period_s │
                        │ review_period_e │
                        │ review_date     │
                        │ overall_rating  │
                        │ tech_skills_rt  │
                        │ comm_rating     │
                        │ teamwork_rating │
                        │ leadership_rt   │
                        │ strengths       │
                        │ areas_improve   │
                        │ goals           │
                        │ comments        │
                        │ status          │
                        │ created_at      │
                        │ updated_at      │
                        └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│ Training_Progs  │       │ Employee_Train  │
├─────────────────┤       ├─────────────────┤
│ training_id (PK)│◄──────│ training_id (FK)│
│ program_code    │       │ emp_id (FK)     │
│ program_name    │       │ record_id (PK)  │
│ description     │       │ enrollment_date │
│ category        │       │ completion_date │
│ duration_days   │       │ status          │
│ duration_hours  │       │ score           │
│ cost            │       │ max_score       │
│ provider        │       │ grade           │
│ is_internal     │       │ certificate_iss │
│ is_active       │       │ certificate_url │
│ created_at      │       │ notes           │
│ updated_at      │       │ cost_to_company │
└─────────────────┘       │ created_at      │
                          │ updated_at      │
                          └─────────────────┘

┌─────────────────┐
│   Audit_Log     │
├─────────────────┤
│ log_id (PK)     │
│ table_name      │
│ record_id       │
│ action          │
│ old_values      │
│ new_values      │
│ changed_by (FK) │
│ changed_at      │
│ ip_address      │
│ user_agent      │
└─────────────────┘
```

## Table Relationships

### Core Entity Relationships

1. **Departments ↔ Employees**
   - One-to-Many: One department can have many employees
   - Self-referencing: Department manager is also an employee

2. **Positions ↔ Employees** 
   - One-to-Many: One position can be held by many employees
   - Positions belong to departments

3. **Employees (Self-referencing)**
   - One-to-Many: One manager can have many direct reports
   - Recursive relationship for organizational hierarchy

### Supporting Entity Relationships

4. **Employees ↔ Employee_Addresses**
   - One-to-Many: One employee can have multiple addresses
   - Different address types (Home, Work, Mailing, Emergency)

5. **Employees ↔ Salary_History**
   - One-to-Many: One employee can have multiple salary records
   - Temporal tracking for complete compensation history

6. **Employees ↔ Performance_Reviews**
   - One-to-Many: One employee can have multiple performance reviews
   - Reviews are conducted by other employees (managers)

7. **Projects ↔ Employees (Many-to-Many)**
   - Implemented through Employee_Projects junction table
   - One employee can work on multiple projects
   - One project can have multiple employees

8. **Training_Programs ↔ Employees (Many-to-Many)**
   - Implemented through Employee_Training junction table
   - One employee can enroll in multiple training programs
   - One training program can have multiple employees

### Audit Relationship

9. **Employees ↔ Audit_Log**
   - One-to-Many: One employee can trigger multiple audit entries
   - Tracks all data changes for compliance

## Cardinality Summary

| Relationship | Cardinality | Description |
|--------------|-------------|-------------|
| Departments → Employees | 1:N | One department has many employees |
| Positions → Employees | 1:N | One position held by many employees |
| Employees → Employees | 1:N | One manager manages many employees |
| Employees → Addresses | 1:N | One employee has multiple addresses |
| Employees → Salary History | 1:N | One employee has multiple salary records |
| Employees → Performance Reviews | 1:N | One employee has multiple reviews |
| Employees ↔ Projects | M:N | Many employees work on many projects |
| Employees ↔ Training | M:N | Many employees attend many training programs |
| Employees → Audit Log | 1:N | One employee makes many changes |


## Key Design Features

### Normalization
- **1NF**: All attributes are atomic
- **2NF**: No partial dependencies on composite keys
- **3NF**: No transitive dependencies between non-key attributes

### Data Integrity
- **Foreign Key Constraints**: Maintain referential integrity
- **CHECK Constraints**: Validate data ranges and formats
- **UNIQUE Constraints**: Prevent duplicate records
- **NOT NULL Constraints**: Ensure required data is present

### Performance Optimization
- **Strategic Indexing**: Foreign keys, frequently queried columns
- **Composite Indexes**: Multi-column query optimization
- **Covering Indexes**: Include commonly accessed columns

### Business Logic Implementation
- **Stored Procedures**: Encapsulate complex operations
- **Triggers**: Automatic audit trail creation
- **Views**: Simplify complex reporting queries
- **Constraints**: Enforce business rules at database level

## Schema Flexibility

The design supports:
- **Scalability**: Can handle growing employee base
- **Extensibility**: Easy to add new features and tables
- **Maintainability**: Clear structure with comprehensive documentation
- **Performance**: Optimized for common query patterns
- **Security**: Audit trails and proper access patterns

This ER diagram represents a production-ready database that can serve as the foundation for a comprehensive HR management system.
