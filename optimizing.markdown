# Optimizing for InnoDB Tables

-----------------------------------------------------------

## Storage Layout

* *OPTIMIZE TABLE* statement reorganize the table and compact any wasted space.
* The primary key value for a row is duplicated in all the secondary index records.
* Use the VARCHAR data type instead of CHAR to store variable-length strings or for columns with many NULL values.

-----------------------------------------------------------

## Transaction Management

* Where practical, wrap several related DML operations into a single transaction.
* Avoid performing rollbacks after inserting, updating, or deleting huge numbers of rows.
* When rows are modified or deleted, the rows and associated undo logs are not physically removed immediately, or even immediately after the transaction commits. The old data is preserved until transactions that started earlier or concurrently are finished, so that those transactions can access the previous state of modified or deleted rows. Thus, a long-running transaction can prevent InnoDB from purging data that was changed by a different transaction.
* When rows are modified or deleted within a long-running transaction, other transactions using the READ COMMITTED and REPEATABLE READ isolation levels have to do more work to reconstruct the older data if they read those same rows.
* When a long-running transaction modifies a table, queries against that table from other transactions do not make use of the covering index technique. Queries that normally could retrieve all the result columns from a secondary index, instead look up the appropriate values from the table data.

-----------------------------------------------------------

## Logging

* Make log files big. Small log files cause many unnecessary disk writes. Historically big log files caused lengthy recovery times.
* Make the log buffer quite large as well (on the order of 8MB).

-----------------------------------------------------------

## Bulk Data Loading

* If you have UNIQUE constraints on secondary keys, you can speed up table imports by temporarily turning off the uniqueness checks during the import session. For big tables, this saves a lot of disk I/O because InnoDB can use its insert buffer to write secondary index records in a batch. Be certain that the data contains **no duplicate keys**.
* If you have FOREIGN KEY constraints in your tables, you can speed up table imports by turning off the foreign key checks for the duration of the import session.
* Use the multiple-row INSERT syntax to reduce communication overhead between the client and the server.

-----------------------------------------------------------

## Query

* InnoDB table has a primary key whether you request one or not. Specify a set of primary key columns for each table, columns that are used in the most important and time-critical queries.
* Do not specify too many or too long columns in the primary key, because these column values are duplicated in each secondary index.
* Do not create a separate secondary index for each column, because **each query can only make use of one index**.
* If an indexed column cannot contain any NULL values, declare it as NOT NULL when you create the table.
* If you often have recurring queries for tables that are not updated frequently, enable the query cache.
