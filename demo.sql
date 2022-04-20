
-- .mode line
.mode box

create table d (
    n   text    not null,
    i   integer not null,
    v   integer not null,
  primary key ( n, i ) );

.print ''
.print '------------------------------------------------------------------------------------------------------------'
.print 'current table contents'
.print ''

insert into d ( n, i, v ) values
  ( 'a', 1, 11 ),
  ( 'a', 2, 21 ),
  ( 'a', 3, 31 ),
  ( 'b', 1, 12 ),
  ( 'b', 2, 22 ),
  ( 'c', 1, 13 ),
  ( 'c', 2, 23 ),
  ( 'c', 3, 33 ),
  ( 'c', 4, 43 );

select * from d order by n, i;

.print ''
.print '------------------------------------------------------------------------------------------------------------'
.print 'several ways to aggregate values with `*group*()` functions, all of them working as expected:'
.print ''

select distinct
    n                                                           as n,
    json_group_array( json_array( i, v ) )              over w  as "json_group_array() nested"
  from d
  window w as ( partition by n order by i range between unbounded preceding and unbounded following );

select distinct
    n                                                           as n,
    json_group_object( i, v )                           over w  as "json_group_object()"
  from d
  window w as ( partition by n order by i range between unbounded preceding and unbounded following );

select distinct
    n                                                           as n,
    json_group_array( v )                               over w  as "json_group_array() flat"
  from d
  window w as ( partition by n order by i range between unbounded preceding and unbounded following );

select distinct
    n                                                           as n,
    group_concat( '(' || i || ',' || v || ')', ', ' )   over w  as "group_concat()"
  from d
  window w as ( partition by n order by i range between unbounded preceding and unbounded following );

.print ''
.print '------------------------------------------------------------------------------------------------------------'
.print 'using several aggregate functions in the same table using the same window definition all fail, with the'
.print 'exception of the *last* aggregate and `group_concat()`, which do work as expected:'
.print ''

select distinct
    n                                                           as n,
    json_group_array( json_array( i, v ) )              over w  as "json_group_array() nested",
    json_group_object( i, v )                           over w  as "json_group_object()",
    json_group_array( v )                               over w  as "json_group_array() flat",
    group_concat( '(' || i || ',' || v || ')', ', ' )   over w  as "group_concat()"
  from d
  window w as ( partition by n order by i range between unbounded preceding and unbounded following );

select distinct
    n                                                           as n,
    json_group_array( json_array( i, v ) )              over w  as "json_group_array() nested",
    json_group_object( i, v )                           over w  as "json_group_object()",
    group_concat( '(' || i || ',' || v || ')', ', ' )   over w  as "group_concat()",
    json_group_array( v )                               over w  as "json_group_array() flat"
  from d
  window w as ( partition by n order by i range between unbounded preceding and unbounded following );

select distinct
    n                                                           as n,
    json_group_array( json_array( i, v ) )              over w  as "json_group_array() nested",
    group_concat( '(' || i || ',' || v || ')', ', ' )   over w  as "group_concat()",
    json_group_object( i, v )                           over w  as "json_group_object()",
    json_group_array( v )                               over w  as "json_group_array() flat"
  from d
  window w as ( partition by n order by i range between unbounded preceding and unbounded following );

select distinct
    n                                                           as n,
    json_group_array( json_array( i, v ) )              over w  as "json_group_array() nested",
    group_concat( '(' || i || ',' || v || ')', ', ' )   over w  as "group_concat()",
    json_group_array( v )                               over w  as "json_group_array() flat",
    json_group_object( i, v )                           over w  as "json_group_object()"
  from d
  window w as ( partition by n order by i range between unbounded preceding and unbounded following );

.print ''
.print '------------------------------------------------------------------------------------------------------------'
.print '`group_concat()` works even with unquoted values, even in the midst of other aggregators:'
.print ''

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

.print ''
.print '------------------------------------------------------------------------------------------------------------'
.print 'using `json_group_array()` fails where not last in a series of aggregations:'
.print ''

select distinct
    n                                                           as n,
    json_group_array( i )                               over w  as "json_group_array( i ) 1",
    json_group_array( i )                               over w  as "json_group_array( i ) 2",
    json_group_array( i )                               over w  as "json_group_array( i ) 3"
  from d
  window w as ( partition by n order by i range between unbounded preceding and unbounded following );

.print ''
.print '------------------------------------------------------------------------------------------------------------'
.print 'turning values into strings does not affect outcomes:'
.print ''

select distinct
    n                                                           as n,
    json_group_array( '(' || i || ')' )                 over w  as "json_group_array( i ) 1",
    json_group_array( '(' || i || ')' )                 over w  as "json_group_array( i ) 2",
    json_group_array( '(' || i || ')' )                 over w  as "json_group_array( i ) 3"
  from d
  window w as ( partition by n order by i range between unbounded preceding and unbounded following );





