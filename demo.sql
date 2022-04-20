
.mode column
.mode

create table d (
    n   text    not null,
    i   integer not null,
    v   integer not null,
  primary key ( n, i ) );

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









