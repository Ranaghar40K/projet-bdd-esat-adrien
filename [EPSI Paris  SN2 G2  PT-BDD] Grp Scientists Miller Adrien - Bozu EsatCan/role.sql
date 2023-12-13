USE mydb;
GO

-- Create roles
CREATE ROLE Role_Administrator;
CREATE ROLE Role_DataEngineer;
CREATE ROLE Role_DataAnalyst;
CREATE ROLE Role_DataScientist;
CREATE ROLE Role_BusinessUser;
GO

-- Create users and assign them to roles with example passwords (you should use secure passwords)
-- Administrator users
CREATE LOGIN AdminUser1 WITH PASSWORD = 'Password123!';
CREATE USER AdminUser1 FOR LOGIN AdminUser1;
ALTER ROLE Role_Administrator ADD MEMBER AdminUser1;

CREATE LOGIN AdminUser2 WITH PASSWORD = 'Password123!';
CREATE USER AdminUser2 FOR LOGIN AdminUser2;
ALTER ROLE Role_Administrator ADD MEMBER AdminUser2;

-- Data Engineer users
CREATE LOGIN DataEngineerUser1 WITH PASSWORD = 'Password123!';
CREATE USER DataEngineerUser1 FOR LOGIN DataEngineerUser1;
ALTER ROLE Role_DataEngineer ADD MEMBER DataEngineerUser1;

CREATE LOGIN DataEngineerUser2 WITH PASSWORD = 'Password123!';
CREATE USER DataEngineerUser2 FOR LOGIN DataEngineerUser2;
ALTER ROLE Role_DataEngineer ADD MEMBER DataEngineerUser2;

-- Data Analyst users
CREATE LOGIN DataAnalystUser1 WITH PASSWORD = 'Password123!';
CREATE USER DataAnalystUser1 FOR LOGIN DataAnalystUser1;
ALTER ROLE Role_DataAnalyst ADD MEMBER DataAnalystUser1;

CREATE LOGIN DataAnalystUser2 WITH PASSWORD = 'Password123!';
CREATE USER DataAnalystUser2 FOR LOGIN DataAnalystUser2;
ALTER ROLE Role_DataAnalyst ADD MEMBER DataAnalystUser2;

-- Data Scientist users
CREATE LOGIN DataScientistUser1 WITH PASSWORD = 'Password123!';
CREATE USER DataScientistUser1 FOR LOGIN DataScientistUser1;
ALTER ROLE Role_DataScientist ADD MEMBER DataScientistUser1;

CREATE LOGIN DataScientistUser2 WITH PASSWORD = 'Password123!';
CREATE USER DataScientistUser2 FOR LOGIN DataScientistUser2;
ALTER ROLE Role_DataScientist ADD MEMBER DataScientistUser2;

-- Business User users
CREATE LOGIN BusinessUser1 WITH PASSWORD = 'Password123!';
CREATE USER BusinessUser1 FOR LOGIN BusinessUser1;
ALTER ROLE Role_BusinessUser ADD MEMBER BusinessUser1;

CREATE LOGIN BusinessUser2 WITH PASSWORD = 'Password123!';
CREATE USER BusinessUser2 FOR LOGIN BusinessUser2;
ALTER ROLE Role_BusinessUser ADD MEMBER BusinessUser2;
GO

-- Assign permissions to roles (these are examples and could be tailored to your actual needs)
-- Administrator role permissions
GRANT CONTROL ON DATABASE::mydb TO Role_Administrator;

-- Data Engineer role permissions
GRANT CREATE TABLE, ALTER, DELETE, INSERT, UPDATE, CREATE VIEW TO Role_DataEngineer;

-- Data Analyst role permissions
GRANT SELECT ON SCHEMA::dbo TO Role_DataAnalyst;

-- Data Scientist role permissions
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE TABLE, CREATE VIEW TO Role_DataScientist;

-- Business User role permissions
GRANT SELECT ON SCHEMA::dbo TO Role_BusinessUser;
GO