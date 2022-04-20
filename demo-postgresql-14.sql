

begin transaction;

create table d (
    n   text    not null,
    i   integer not null,
    v   integer not null,
  primary key ( n, i ) );

\echo ''
\echo '------------------------------------------------------------------------------------------------------------'
\echo 'current table contents'
\echo ''

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


\echo ''
\echo '------------------------------------------------------------------------------------------------------------'
\echo 'several ways to aggregate values with `*group*()` functions, all of them working as expected:'
\echo ''

select distinct
    n                                                           as n,
    jsonb_agg( i )                                      over w  as "jsonb_agg( i )",
    jsonb_agg( v )                                      over w  as "jsonb_agg( v )",
    jsonb_object_agg( i, v )                            over w  as "jsonb_object_agg( i, v )",
    array_agg( i )                                      over w  as "array_agg( i )",
    array_agg( v )                                      over w  as "array_agg( v )"
  from d
  window w as ( partition by n order by i range between unbounded preceding and unbounded following );

-- #########################################################################################################
rollback; \quit
-- #########################################################################################################
