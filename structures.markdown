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
* Records in the clustered index contain fields for all user-defined columns. In addition, there is a 6-byte transaction ID field and a 7-byte roll pointer field.
* If no primary key was defined for a table, each clustered index record also contains a 6-byte row ID field.
* Internally, InnoDB stores fixed-length character columns such as CHAR(10) in a fixed-length format. InnoDB does not truncate trailing spaces from VARCHAR columns.

### COMPACT Format

* Each index record contains a 5-byte header that may be preceded by a variable-length header. The header is used to link together consecutive records, and also in row-level locking.
* The variable-length part of the record header contains a bit vector for indicating NULL columns. If the number of columns in the index that can be NULL is N, the bit vector occupies CEILING(N/8) bytes. Columns that are NULL do not occupy space other than the bit in this vector. The variable-length part of the header also contains the lengths of variable-length columns. Each length takes one or two bytes, depending on the maximum length of the column. If all columns in the index are NOT NULL and have a fixed length, the record header has no variable-length part.
* For each non-NULL variable-length field, the record header contains the length of the column in one or two bytes. Two bytes will only be needed if part of the column is stored externally in overflow pages or the maximum length exceeds 255 bytes and the actual length exceeds 127 bytes. For an externally stored column, the 2-byte length indicates the length of the internally stored part plus the 20-byte pointer to the externally stored part. The internal part is 768 bytes, so the length is 768+20. The 20-byte pointer stores the true length of the column.
* The record header is followed by the data contents of the non-NULL columns.
* Each secondary index record also contains all the primary key fields defined for the clustered index key that are not in the secondary index. If any of these primary key fields are variable length, the record header for each secondary index will have a variable-length part to record their lengths, even if the secondary index is defined on fixed-length columns.
* Internally, InnoDB attempts to store UTF-8 CHAR(N) columns in N bytes by trimming trailing spaces. (With REDUNDANT row format, such columns occupy 3 × N bytes.) Reserving the minimum space N in many cases enables column updates to be done in place without causing fragmentation of the index page.

### REDUNDANT Format

* Each index record contains a 6-byte header. The header is used to link together consecutive records, and also in row-level locking.
* Each secondary index record also contains all the primary key fields defined for the clustered index key that are not in the secondary index.
* A record contains a pointer to each field of the record. If the total length of the fields in a record is less than 128 bytes, the pointer is one byte; otherwise, two bytes. The array of these pointers is called the record directory. The area where these pointers point is called the data part of the record.
* An SQL NULL value reserves one or two bytes in the record directory. Besides that, an SQL NULL value reserves zero bytes in the data part of the record if stored in a variable length column. In a fixed-length column, it reserves the fixed length of the column in the data part of the record. Reserving the fixed space for NULL values enables an update of the column from NULL to a non-NULL value to be done in place without causing fragmentation of the index page.
