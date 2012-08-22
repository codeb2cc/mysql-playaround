-- Initialization
CREATE TABLE lock_test (
    id INTEGER AUTO_INCREMENT PRIMARY KEY,
    value SMALLINT,
    message CHAR(255)
);

CREATE INDEX lock_value ON lock_test (value);

START TRANSACTION;
INSERT INTO lock_test (value, message) VALUES
    (1, 'Hello'),
    (3, 'World'),
    (4, 'Foo'),
    (5, 'Bar');
COMMIT;

-------------------------------------------------------------------------------

-- Deadlock example
--- Client A
START TRANSACTION;
SELECT * FROM lock_test WHERE value = 3 LOCK IN SHARE MODE;
---- After Client B delete query
DELETE FROM lock_test WHERE value = 3;      -- Deadlock happends
---- Client A succeeds but Client B failed
ROLLBACK;

--- Client B
START TRANSACTION;
DELETE FROM lock_test WHERE value = 3;      -- Record locked. Query waits
---- ERROR: Deadlock found
ROLLBACK;

-------------------------------------------------------------------------------

-- Consistent read example
--- Client A
START TRANSACTION;
SELECT * FROM lock_test WHERE value = 3;
---- After Client B delete record and commit
SELECT * FROM lock_test WHERE value = 3;    -- Record still here
ROLLBACK;
---- DML
START TRANSACTION;
---- Before Client B insert new record
SELECT * FROM lock_test WHERE value > 8;    -- No result
---- After Client B commit
SELECT * FROM lock_test;
DELETE FROM lock_test WHERE value > 8;      -- 1 row affected !!
ROLLBACK;
---- The same but use a locking read
START TRANSACTION;
SELECT * FROM lock_test WHERE value > 10;    -- No result
SELECT * FROM lock_test WHERE value > 10 LOCK IN SHARE MODE;    -- Surprise
ROLLBACK;

--- Client B
START TRANSACTION;
---- After Client A first select
DELETE FROM lock_test WHERE value = 3;
COMMIT;
---- DML
START TRANSACTION;
INSERT INTO lock_test (value, message) VALUES (9, 'Daddy');
COMMIT;
---- Add another record
START TRANSACTION;
INSERT INTO lock_test (value, message) VALUES (11, 'Mommy');
COMMIT;

-------------------------------------------------------------------------------

-- Next-key lock example
-- Client A
START TRANSACTION;
SELECT * FROM lock_test WHERE value > 8 FOR UPDATE;     -- Next-key lock
ROLLBACK;

-- Client B
START TRANSACTION;
---- After Client A query
INSERT INTO lock_test (value, message) VALUES(8, 'Ops');  -- Lock timeout
ROLLBACK;

-------------------------------------------------------------------------------
