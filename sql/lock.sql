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
SELECT * FROM lock_test WHERE value > 8;    -- Still no result
DELETE FROM lock_test WHERE value > 8;      -- 1 row affected !!
ROLLBACK;
---- The same but use a locking read
START TRANSACTION;
SELECT * FROM lock_test WHERE value > 10;    -- No result
SELECT * FROM lock_test WHERE value > 10 LOCK IN SHARE MODE;    -- Surprise !
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
--- Client A
---- Test 1
START TRANSACTION;
SELECT * FROM lock_test WHERE value > 5 FOR UPDATE;     -- Next-key lock(gap, 8 ... max, gap)
ROLLBACK;
---- Test 2
START TRANSACTION;
SELECT * FROM lock_test WHERE id > 5 FOR UPDATE;
ROLLBACK;

--- Client B
---- Test 1
START TRANSACTION;
SELECT * FROM lock_test;
---- After Client A SELECT ... FOR UPDATE statement
UPDATE lock_test SET message = 'Ops' WHERE value = 9;      -- Record lock in Next-key lock
INSERT INTO lock_test (value, message) VALUES(6, 'Ops');   -- Gap lock in Next-key lock
INSERT INTO lock_test (value, message) VALUES(4, 'Ops');   -- Gap lock?
INSERT INTO lock_test (value, message) VALUES(2, 'Ops');   -- Lock too and why?
ROLLBACK;
---- Test 2
START TRANSACTION;
INSERT INTO lock_test (value, message) VALUES(2, 'Ops');   -- Lock
INSERT INTO lock_test (id, value, message) VALUES(2, 2, 'Bingo');   -- Success !
INSERT INTO lock_test (id, value, message) VALUES(7, 2, 'Ops');   -- Failed
---- Next-key lock ON id INDEX !!
ROLLBACK;

-------------------------------------------------------------------------------

-- Duplicate-key error and deadlock
--- Client A
START TRANSACTION;
INSERT INTO lock_test (id, value, message) VALUES(20, 13, 'Exclusive');     -- Acquire an exclusive lock
ROLLBACK;   -- Exclusive lock released

--- Client B
START TRANSACTION;
INSERT INTO lock_test (id, value, message) VALUES(20, 13, 'Exclusive');     -- Duplicate-key error then request a shared lock
---- After Client A rollback, deadlock happends. Client B succeeds
ROLLBACK;

--- Client C
START TRANSACTION;
INSERT INTO lock_test (id, value, message) VALUES(20, 13, 'Exclusive');     -- Duplicate-key error then request a shared lock
---- After Client A rollback, deadlock happends. Client C fails
ROLLBACK;

-------------------------------------------------------------------------------
