# InnoDB Transaction Model and Locking

---------------------------------------

## Transaction Levels

### REPEATABLE READ

#### Consistent Reads

* Read the snapshot established by the first read.

#### Locking Reads

* Unique index/serach condition: Locks only the index record.
* Range-type search condition: Locks the index range scanned, using gap locks or next-key locks to block insertions by other sessions into the gaps covered by the range.

### READ COMMITTED

#### Consistent Reads

* Sets and reads its own fresh snapshot.

#### Locking Reads

* Locks only index records, not the gaps before them.
* Unique UPDATE and DELETE: Locks index record found only.
* Range-type UPDATE and DELETE: Gap locks or next-key locks.

### READ UNCOMMITTED

* "Dirty read".

### SERIALIZABLE

* Implicitly converts all plain SELECT statements to SELECT ... LOCK IN SHARE MODE if autocommit is disabled.

---------------------------------------

## Lock Models

* Shared
* Exclusive
* Intention (table locks)

---------------------------------------

## Consistent Nonlocking Reads

* Multi-versioning to present a snapshot of the database.
* Sees the changes made by transactions that committed before that point of time, and no changes made by later or uncommitted transactions.
* Sees the changes made by earlier statements within the same transaction.
* A state might never existed in the database.
* Default mode for SELECT statements in READ COMMITTED and REPEATABLE READ.
* Snapshot applies to SELECT statements, **NOT DML statement**.

---------------------------------------

## Locking Reads

* SELECT ... LOCK IN SHARE MODE
* SELECT ... FOR UPDATE

---------------------------------------

## Record, Gap, and Next-Key Locks

* Record lock: Lock on an index record.
* Gap lock: Lock on a gap between index records (or before-first/after-last).
* Next-key lock: Combination of a record lock and a gap lock before the index record.

---------------------------------------

## Locks of Different SQL Statements

* InnoDB does not remember the exact WHERE condition, but only knows which index ranges were scanned.
* InnoDB also retrieves the corresponding clustered index records and sets locks on them.
* If no indexes suitable for the statement and entrie table has to be scaned, every row of the table becomes locked.
* In locking reads, locks are acquired for scanned rows, and expected to be released for rows that do not qualify for inclusion in the result set.
* Locks might not be released immediately until the end of query execution. (UNION, etc)
* INSERT sets an exclusive lock on the inserted row. This lock is an index-record lock, NOT a next-key lock.
* INSERT ... ON DUPLICATE KEY UPDATE request an exclusive next-key lock rather than a shared lock, when a duplicate-key error occurs.
* Initializing AUTO_INCREMENT column sets an exclusive lock on the end of the index. In accessing the auto-increment counter, InnoDB uses a specific AUTO-INC table lock mode where the lock lasts only to the end of the current SQL statement, NOT to the end of the entire transaction. Other sessions cannot insert into the table while the AUTO-INC table lock is held.
* Any insert, update, or delete that requires the constraint condition to be checked sets shared record-level locks on the records that it looks at to check the constrain, even constraint fails.

---------------------------------------

## Deadlock Detection and Rollback

* InnoDB automatically detects transaction deadlocks and rolls back a transaction or transactions to break the deadlock. It tries to **pick small transactions to roll back**, where the size of a transaction is determined by the number of rows inserted, updated, or deleted.
* When InnoDB performs a complete rollback of a transaction, all locks set by the transaction are released. However, if just a single SQL statement is rolled back as a result of an error, some of the locks set by the statement **may be preserved**. This happens because InnoDB stores row locks in a format such that it cannot know afterward which lock was set by which statement.

---------------------------------------

## Cope with Deadlocks

* Operations are not really “atomic”; they automatically set locks on the (possibly several) index records of the row inserted or deleted.
* Always be prepared to re-issue a transaction if it fails due to deadlock. Deadlocks are not dangerous.
* Commit your transactions often. Small transactions are less prone to collision.
* Add well-chosen indexes to your tables. Then your queries need to scan fewer index records and consequently set fewer locks.
* Another way to serialize transactions is to create an auxiliary “semaphore” table that contains just a single row. Have each transaction update that row before accessing other tables. In that way, all transactions happen in a serial fashion.

---------------------------------------



# Multi-Versioning

---------------------------------------

* InnoDB keeps information about old versions of changed rows, to support transactional features such as concurrency and rollback. This information is stored in the tablespace in a data structure called a rollback segment.
* **Commit your transactions regularly**, including those transactions that issue only consistent reads. Otherwise, InnoDB cannot discard data from the update undo logs, and the rollback segment may grow too big, filling up your tablespace.
* If you insert and delete rows in smallish batches at about the same rate in the table, the purge thread can start to lag behind and the table can grow bigger and bigger because of all the “dead” rows, making everything disk-bound and very slow.
