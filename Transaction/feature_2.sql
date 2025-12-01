USE mydatabase;

# # # # # # # # # # # # # # # Statements That Cannot Be Rolled Back # # # # # # # # # # # # # # #
SET autocommit = 0;
START TRANSACTION;

-- DDL: Cannot ROLLBACK because this command is implicit committed
CREATE TABLE demo_table (
    id INT PRIMARY KEY
);
ROLLBACK;
SHOW TABLES;

-- DML: Can ROLLBACK because this command is implicit committed
INSERT INTO demo_table VALUES (1);
ROLLBACK;
SELECT * FROM demo_table;
