
-- .mode line
.mode box

create table d (
    n   text    not null,
    i   integer not null,
    v   integer not null,
  primary key ( n, i ) );

.print ''
.print '------------------------------------------------------------------------------------------------------------'
.print 'Current table contents'
.print ''
.print '```'

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

.print '```'
.print ''
.print '------------------------------------------------------------------------------------------------------------'
.print 'Several ways to aggregate values with `*group*()` functions, all of them working as expected:'
.print ''
.print '```'

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

.print '```'
.print ''
.print '------------------------------------------------------------------------------------------------------------'
.print 'Using several aggregate functions in the same table using the same window definition all fail, with the'
.print 'exception of the *last* aggregate and `group_concat()`, which do work as expected:'
.print ''
.print '```'

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

.print '```'
.print ''
.print '------------------------------------------------------------------------------------------------------------'
.print '`group_concat()` works even with unquoted values, even in the midst of other aggregators:'
.print ''
.print '```'

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

select distinct
    n                                                           as n,
    json_group_array( json_array( i, v ) )              over () as "json_group_array() nested",
    group_concat( '(' || i || ',' || v || ')', ', ' )   over () as "group_concat()",
    group_concat( i )                                   over () as "group_concat( i )",
    group_concat( v )                                   over () as "group_concat( v )",
    json_group_array( v )                               over () as "json_group_array() flat",
    json_group_object( i, v )                           over () as "json_group_object()"
  from d;

.print '```'
.print ''
.print '------------------------------------------------------------------------------------------------------------'
.print 'Using `json_group_array()` fails where not last in a series of aggregations:'
.print ''
.print '```'

select distinct
    n                                                           as n,
    json_group_array( i )                               over w  as "json_group_array( i ) 1",
    json_group_array( i )                               over w  as "json_group_array( i ) 2",
    json_group_array( i )                               over w  as "json_group_array( i ) 3"
  from d
  window w as ( partition by n order by i range between unbounded preceding and unbounded following );

.print '```'
.print ''
.print '------------------------------------------------------------------------------------------------------------'
.print 'Turning values into strings does not affect outcomes:'
.print ''
.print '```'

select distinct
    n                                                           as n,
    json_group_array( '(' || i || ')' )                 over w  as "json_group_array( i ) 1",
    json_group_array( '(' || i || ')' )                 over w  as "json_group_array( i ) 2",
    json_group_array( '(' || i || ')' )                 over w  as "json_group_array( i ) 3"
  from d
  window w as ( partition by n order by i range between unbounded preceding and unbounded following );

.print '```'
.print ''
.print '------------------------------------------------------------------------------------------------------------'
.print 'Using a separate but identical window definition for each aggregate does not affect outcomes:'
.print ''
.print '```'

select distinct
    n                                                           as n,
    json_group_array( json_array( i, v ) )              over w1 as "json_group_array() nested",
    group_concat( '(' || i || ',' || v || ')', ', ' )   over w2 as "group_concat()",
    json_group_array( v )                               over w3 as "json_group_array() flat",
    json_group_object( i, v )                           over w4 as "json_group_object()"
  from d
  window w1 as ( partition by n order by i range between unbounded preceding and unbounded following ),
         w2 as ( partition by n order by i range between unbounded preceding and unbounded following ),
         w3 as ( partition by n order by i range between unbounded preceding and unbounded following ),
         w4 as ( partition by n order by i range between unbounded preceding and unbounded following );

.print '```'
.print ''
.print '------------------------------------------------------------------------------------------------------------'
.print 'Aggregate function `sum()` is not affected; results show unambiguously that summing is indeed done over the'
.print 'values shown in the `group_concat()` lists, even in the midst of other aggregators:'
.print ''
.print '```'

select distinct
    n                                                           as n,
    group_concat( i )                                   over w  as "group_concat( i )",
    group_concat( v )                                   over w  as "group_concat( v )",
    sum( i )                                            over w  as "sum( i )",
    sum( v )                                            over w  as "sum( v )",
    json_group_array( i )                               over w  as "json_group_array( i )"
  from d
  window w as ( partition by n order by i range between unbounded preceding and unbounded following );

.print '```'
.print ''
.print '------------------------------------------------------------------------------------------------------------'
.print '`json_group_array()` also fails when not coming last when combined with `sum()`; observe the discrepancies'
.print 'between numbers listed and numbers summed:'
.print ''
.print '```'

select distinct
    n                                                           as n,
    json_group_array( i )                               over w  as "json_group_array( i )",
    sum( i )                                            over w  as "sum( i )",
    json_group_array( v )                               over w  as "json_group_array( v )",
    sum( v )                                            over w  as "sum( v )"
  from d
  window w as ( partition by n order by i range between unbounded preceding and unbounded following );

.print '```'


