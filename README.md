<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Some Surprising Results from SQLite Aggregate Functions](#some-surprising-results-from-sqlite-aggregate-functions)
  - [Description](#description)
  - [Result](#result)
  - [Comparsion with Behavior of PostgreSQL (v14)](#comparsion-with-behavior-of-postgresql-v14)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->





# Some Surprising Results from SQLite Aggregate Functions

* tested with `sqlite3 -version` `3.31.1 2020-01-27 19:55:54
  3bfa9cc97da10598521b342961df8f5f68c7388fa117345eeb516eaa837balt1` (current version on Linux Mint 20.3)
* tested with current
  [https://sqlite.org/2022/sqlite-autoconf-3380200.tar.gz](https://sqlite.org/2022/sqlite-autoconf-3380200.tar.gz),
  compiled on Linux Mint 20.3 using `./configure && make` (`sqlite3 -version` `./3.38.2 2022-03-26 13:51:10
  d33c709cc0af66bc5b6dc6216eba9f1f0b40960b9ae83694c986fbf4c1d6f08f`)

## Description

* SQLite has a number of aggregate functions such as `sum()`, `group_concat()`, `json_array()` and so on;
* these are typically used in conjunction with a window definition

```sql
select distinct
    n                                                           as n,
    json_group_array( json_array( i, v ) )              over w  as "json_group_array() nested",
    group_concat( '(' || i || ',' || v || ')', ', ' )   over w  as "group_concat()",
    group_concat( i )                                   over w  as "group_concat( i )",
    group_concat( v )                                   over w  as "group_concat( v )",
    json_group_array( v )                               over w  as "json_group_array() flat",
    json_group_object( i, v )                           over w  as "json_group_object()"
  from d
  window w as ( partition by n order by i range between unbounded preceding and unbounded following );
```

## Result

[The output of running `./sqlite3 < demo.sql > sqlite-output.md` can be seen here](./sqlite-output.md).

## Comparsion with Behavior of PostgreSQL (v14)

```bash
psql -f demo-postgresql-14.sql # may want to add user, db, host as the case may be
```

PostgreSQL has aggregate functions that are very similar to those offered by SQLite; using the exact same
table definition and `insert` statements, the following:

```sql
select distinct
    n                                                           as n,
    jsonb_agg( i )                                      over w  as "jsonb_agg( i )",
    jsonb_agg( v )                                      over w  as "jsonb_agg( v )",
    jsonb_object_agg( i, v )                            over w  as "jsonb_object_agg( i, v )",
    array_agg( i )                                      over w  as "array_agg( i )",
    array_agg( v )                                      over w  as "array_agg( v )"
  from d
  window w as ( partition by n order by i range between unbounded preceding and unbounded following );
```

works as expected:

```
 n | jsonb_agg( i ) |  jsonb_agg( v )  |       jsonb_object_agg( i, v )       | array_agg( i ) | array_agg( v )
---+----------------+------------------+--------------------------------------+----------------+----------------
 a | [1, 2, 3]      | [11, 21, 31]     | {"1": 11, "2": 21, "3": 31}          | {1,2,3}        | {11,21,31}
 b | [1, 2]         | [12, 22]         | {"1": 12, "2": 22}                   | {1,2}          | {12,22}
 c | [1, 2, 3, 4]   | [13, 23, 33, 43] | {"1": 13, "2": 23, "3": 33, "4": 43} | {1,2,3,4}      | {13,23,33,43}
```

