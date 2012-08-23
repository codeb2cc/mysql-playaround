# Table and Index Structures

---------------------------------------

## Clustered and Secondary Indexes

### Clustered index (primary key index)

* If you define a PRIMARY KEY on your table, InnoDB uses it as the clustered index.
* If you do not define a PRIMARY KEY for your table, MySQL locates the first UNIQUE index where all the key columns are NOT NULL and InnoDB uses it as the clustered index.
* If the table has no PRIMARY KEY or suitable UNIQUE index, InnoDB internally generates a hidden clustered index on a synthetic column containing row ID values.

Accessing a row through the clustered index is fast because the row data is on the same page where the index search leads.

### Secondary index (other index)

Each record in a secondary index contains the primary key columns for the row, as well as the columns specified for the secondary index.

---------------------------------------

## Physical Structure of Index

* B-trees. The default size of an index page is 16KB. When new records are inserted, InnoDB tries to leave 1/16 of the page free for future insertions and updates of the index records.
* If index records are inserted in a sequential order (ascending or descending), the resulting index pages are about 15/16 full. If records are inserted in a random order, the pages are from 1/2 to 15/16 full. If the fill factor of an index page drops below 1/2, InnoDB tries to contract the index tree to free the page.

---------------------------------------

## Insert Buffering

* When an index record is inserted, marked for deletion, or deleted from a nonunique secondary index, if secondary index page is in the buffer pool, InnoDB applies the change directly to the index page, otherwise InnoDB records the change in a special structure known as the insert buffer, and periodically merged it into the secondary index trees in the database.

---------------------------------------

## Adaptive Hash Indexes

* InnoDB has a mechanism that monitors index searches made to the indexes defined for a table. If that queries could benefit from a hash index, InnoDB builds one.  A hash index can be **partial**. InnoDB builds hash indexes on demand for those pages of the index that are often accessed.

---------------------------------------

## Physical Row Structure

* The physical row structure for an InnoDB table depends on the row format specified when the table was created.

### COMPACT Format

### REDUNDANT Format
