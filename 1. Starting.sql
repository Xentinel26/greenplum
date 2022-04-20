-- Review parameters
show all;
-- Review Greenplum Version
show gp_server_version;

-- create simple schemas and table
create schema finance;
create schema rh;
create schema external;
create table finance.stock(
    id bigserial ,
    date_point date,
    low numeric(20,8),
    open numeric(20,8),
    volume numeric(20,8),
    high numeric(20,8),
    adjusted numeric(20,8),
    close numeric(20,8),
    stock varchar(50)
) distributed by (stock);



create table finance.fast_stock(
    id bigserial ,
    date_point varchar(50),
    low numeric(20,8),
    open numeric(20,8),
    volume numeric(20,8),
    high numeric(20,8),
    adjusted numeric(20,8),
    close numeric(20,8),
    stock varchar(50)
) distributed by (stock);


-- check optimizer
--- ON, gporca
-- off oldstyle postgresql
show optimizer;

-- Para greenplum 4.3 generar una consulta con el explain y revisar que el parametro optimizer es igual a ON
explain analyse
select *
from finance.stock;

vacuum analyse  finance.stock;

select id,
       date_point,
       open,
       volume,
       high,
       adjusted,
       close,
       stock
from finance.stock s;




show datestyle ;

set datestyle = DMY;

COPY finance.stock(
                  date_point,
                  low,
                  open,
                  volume,
                  high,
                  close,
                  adjusted,
                  stock
                  ) from '/home/gpadmin/AAL.csv' with header delimiter ',';

delete from finance.stock;
truncate finance.stock;

insert into finance.stock(date_point, low, open, volume, high, adjusted, close, stock)
values (now(), 0,0,0,0,0,0,'Stock');

select count(*) from finance.stock;

COPY finance.stock(
                   date_point,
                  low,
                  open,
                  volume,
                  high,
                  close,
                  adjusted,
                  stock
                  ) from '/home/gpadmin/sp500.csv' with header NULL '""' DELIMITER ',';

explain analyse
select *
from finance.stock
where stock.stock = 'AAL'
ORDER BY date_point;

vacuum analyse finance.stock;



select count(*)
    from finance.stock;


truncate finance.stock;


gpload -f sp500.yml -W -v
gpload -f sp500-fast.yml -W -v


select *
from pg_locks
;
select query, *
from pg_stat_activity;

EXPLAIN analyse verbose
select *
from finance.stock
where stock.stock = 'AAL' and
      id in( 28326489);




show all ;


select query, now() - query_start, state, *
from pg_stat_activity;





