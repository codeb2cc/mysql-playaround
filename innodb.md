# InnoDB Transaction Model and Locking 

* * *

## REPEATABLE READ

### Consistent Reads

* Read the snapshot established by the first read.

### Locking Reads

* Unique index/serach condition: Locks only the index record.
* Range-type search condition: Locks the index range scanned, using gap locks or next-key locks to block insertions by other sessions into the gaps covered by the range.

## READ COMMITTED

### Consistent Reads

* Sets and reads its own fresh snapshot.

### Locking Reads

* Locks only index records, not the gaps before them.
* Unique UPDATE and DELETE: Locks index record found only.
* Range-type UPDATE and DELETE: Gap locks or next-key locks.

## READ UNCOMMITTED

* "Dirty read".

## SERIALIZABLE

* Implicitly converts all plain SELECT statements to SELECT ... LOCK IN SHARE MODE if autocommit is disabled.
