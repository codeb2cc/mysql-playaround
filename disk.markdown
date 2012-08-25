# Disk I/O and File Space Management

---------------------------------------

## Disk I/O

InnoDB uses asynchronous disk I/O where possible, by creating a number of threads to handle I/O operations, while permitting other database operations to proceed while the I/O is still in progress.

### Read Ahead

* In sequential read-ahead, if InnoDB notices that the access pattern to a segment in the tablespace is sequential, it posts in advance a batch of reads of database pages to the I/O system.
* In random read-ahead, if InnoDB notices that some area in a tablespace seems to be in the process of being fully read into the buffer pool, it posts the remaining reads to the I/O system.

### Doublewrite Buffer

InnoDB uses a novel file flush technique called doublewrite. Before writing pages to the data files, InnoDB first writes them to a contiguous area called the doublewrite buffer. Only after the write and the flush to the doublewrite buffer have completed, does InnoDB write the pages to their proper positions in the data file.

Data is written to the buffer itself as a large sequential chunk, with a single fsync() call to the operating system.

---------------------------------------

## File Space Management

* The data files defined in the configuration file form the InnoDB system tablespace. The files are logically concatenated to form the tablespace.
* Tablespace consists of database pages with a default size of 16KB, which grouped into extents of size 1MB (64 consecutive pages).
* If a row is less than half a page long (8KB), all of it is stored locally within the page. If it exceeds half a page, variable-length columns are chosen for external off-page storage until the row fits within half a page.

---------------------------------------

## Defragmenting

* Random insertions into or deletions from a secondary index may cause the index to become fragmented.
* To speed up index scans, you can periodically perform a “null” ALTER TABLE operation, which causes MySQL to rebuild the table.
* Another way to perform a defragmentation operation is to use mysqldump to dump the table to a text file, drop the table, and reload it from the dump file.
