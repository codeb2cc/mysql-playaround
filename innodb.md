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
