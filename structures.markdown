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

