
-- 2 - DDL
create database new_database;

-- Clonar una base de datos

create database cloned_database TEMPLATE "greenplum-course";

-- Listar las bases de datos
SELECT datname from pg_database;

-- eliminar una base de datos

drop database cloned_database;

-- Crear una carpeta en multiples nodos
-- gpssh -f hostfile_exkeys -e 'mkdir /home/gpadmin/ssd/'
-- gpssh -f hostfile_exkeys -e 'mkdir /home/gpadmin/ssd/gpdb'


-- Crear un tablespace

create tablespace fast_ssd_ts  LOCATION '/home/gpadmin/ssd/gpdb';


create table finance.tabla_ejemplo_ts (
    id bigserial
) tablespace fast_ssd_ts;

select *
from finance.tabla_ejemplo_ts;

--- Verificar que el TS esta funcionando
--  gpssh -f hostfile_exkeys -e 'ls -lah /home/gpadmin/ssd/gpdb/'

-- borrar un TS
drop tablespace fast_ssd_ts;

--- Revisar objetos en el TS  --OID 16468
SELECT oid, * FROM pg_tablespace ;

-- Encontrar tablas en un TS
select *
from pg_tables
where tablespace = 'fast_ssd_ts';mo

drop table finance.tabla_ejemplo_ts;

drop tablespace fast_ssd_ts;

-- create table

create table finance.empleado(
    id bigserial ,
    nombre varchar(60),
    apellido_paterno varchar(60),
    apellido_materno varchar(60),
    fecha_nacimiento date,
    pais    varchar(90),
    -- Constraint Unique como un super conjunto de la llave de distribucion
    unique (id, nombre, pais)
) distributed by (id, nombre);


drop table if exists finance.empleado;

create table finance.empleado(
    id bigserial ,
    -- Unique Constraint coincide con la llave de distribución
    rfc_homoclave varchar(60) unique,
    nombre varchar(60),
    apellido_paterno varchar(60),
    apellido_materno varchar(60),
    fecha_nacimiento date,
    pais    varchar(90) check ( pais in ('MX', 'BOL') )
) distributed by (rfc_homoclave);


drop table if exists finance.empleado;

create table finance.empleado(
    id bigserial ,
    nombre varchar(60) not null,
    apellido_paterno varchar(60),
    apellido_materno varchar(60),
    fecha_nacimiento date,
    pais    varchar(90),
    -- Constraint Unique como un super conjunto de la llave de distribucion
    unique (id, nombre, pais)
) distributed by (id, nombre);

drop table if exists finance.empleado;
-- Foreign keys
create table finance.empleado(
    id bigserial unique ,
    nombre varchar(60) not null,
    apellido_paterno varchar(60),
    apellido_materno varchar(60),
    fecha_nacimiento date,
    pais    varchar(90),
    id_jefe bigint references finance.empleado(id)
) distributed by (id);

select *
from finance.empleado
;
 -- Not enforcing foreign key
INSERT INTO finance.empleado (id, nombre, apellido_paterno, apellido_materno, fecha_nacimiento, pais, id_jefe)
VALUES (1, 'Julio', 'Romero', 'Perez', '1992-04-02', 'México', 1);
INSERT INTO finance.empleado (id, nombre, apellido_paterno, apellido_materno, fecha_nacimiento, pais, id_jefe)
VALUES (2, 'Alejandra', 'González', 'Hernández', '1992-05-14', 'México', 3);


show gp_create_table_random_default_distribution;

-- Modelo de almacenamiento,
-- tabla heap
create table finance.foo(
    a int,
    b text
)
distributed by (a);

drop table if exists finance.foo;
-- Append optimized table
create table finance.foo(
    a int,
    b text
)
with (appendonly = true)
distributed by (a);

drop table if exists finance.foo;
---  Append optimized new way
create table finance.foo(
    a int,
    b text
)
with (appendoptimized = true, orientation = column )
distributed by (a);


select *
from finance.foo;

select pg_size_pretty (pg_total_relation_size('finance.stock'));

create table finance.stock_compressed(
    id bigserial ,
    date_point date,
    low numeric(20,8),
    open numeric(20,8),
    volume numeric(20,8),
    high numeric(20,8),
    adjusted numeric(20,8) encoding (compresstype = rle_type, compresslevel = 9),
    close numeric(20,8) encoding (compresstype = ZSTD, compresslevel = 19),
    stock varchar(50) encoding (compresstype = ZLIB , compresslevel = 9)
)
with (appendonly = true, orientation = column  )
distributed by (stock);

insert into  finance.stock_compressed
(id, date_point, low, open, volume, high, adjusted, close, stock)
select stock.id,
       stock.date_point,
       stock.low,
       stock.open,
       stock.volume,
       stock.high,
       stock.adjusted,
       stock.close,
       stock.stock
from finance.stock;

select pg_size_pretty (pg_total_relation_size('finance.stock_compressed'));

-- Time comparison 58s 657ms
select *
from finance.stock
;

--- 56s 481ms
select *
from finance.stock_compressed;

---- Column level time comparison 11s 500 ms
select stock.stock
from finance.stock
;

--- column level time comparison 10s 874ms
select stock
from finance.stock_compressed
;


---- 465ms
select distinct stock
from finance.stock_compressed
;

-- 625ms
select distinct stock
from finance.stock
;


---- 569ms
select avg(open)
from finance.stock_compressed
;

-- 641ms
select avg(open)
from finance.stock
;




create table finance.stock_full_compressed(
    id bigserial ,
    date_point date,
    low numeric(20,8),
    open numeric(20,8),
    volume numeric(20,8),
    high numeric(20,8),
    adjusted numeric(20,8) encoding (compresstype = rle_type, compresslevel = 4),
    close numeric(20,8) encoding (compresstype = ZSTD, compresslevel = 19),
    stock varchar(50) encoding (compresstype = ZLIB , compresslevel = 9)
)
with (appendonly = true, orientation = column, compresstype =zlib , compresslevel = 9)
distributed by (stock);

insert into  finance.stock_full_compressed
(id, date_point, low, open, volume, high, adjusted, close, stock)
select stock.id,
       stock.date_point,
       stock.low,
       stock.open,
       stock.volume,
       stock.high,
       stock.adjusted,
       stock.close,
       stock.stock
from finance.stock;

-- Time 52s 521ms
select *
from finance.stock_full_compressed;
-- Size
select pg_size_pretty (pg_total_relation_size('finance.stock_full_compressed'));



CREATE TABLE finance.T3
(
    c1     int ENCODING (compresstype = zlib),
    c2     char ENCODING (compresstype = zlib ),
    c3     text,
    COLUMN c3 ENCODING (compresstype = RLE_TYPE)
)
    WITH (appendonly = true, orientation = column)
    PARTITION BY RANGE (c3)
        (
        START ('1900-01-01'::DATE) END ('2018-12-31'::DATE),
        COLUMN c3 ENCODING (compresstype=zlib),
        start ('2019-01-01'::date) end ('2100-12-31'::date)
        );


-- Partición por día
CREATE TABLE finance.sales (id int, date date, amt decimal(10,2))
DISTRIBUTED BY (id)
PARTITION BY RANGE (date)
(
   START (date '2016-01-01') INCLUSIVE
   END (date '2017-01-01') EXCLUSIVE
   EVERY (INTERVAL '1 day')
);

--- Partición por año

CREATE TABLE rank (
                      id    int,
                      rank  int,
                      year  int,
                      gender char(1),
                      count int)
DISTRIBUTED BY (id)
PARTITION BY RANGE (year)
(
  START (2006)
  END (2016)
  EVERY (1),
  DEFAULT PARTITION extra
);


CREATE TABLE finance.list_partition (
                      id    int,
                      rank  int,
                      year  int,
                      gender char(1),
                      count int
                  )
DISTRIBUTED BY (id)
PARTITION BY LIST (gender)
(
  PARTITION girls VALUES ('F'),
  PARTITION boys VALUES ('M'),
  DEFAULT PARTITION other
);

-- Multilevel

CREATE TABLE finance.sales (
                               trans_id int,
                               date     date,
                               amount decimal(9, 2),
                               region   text
                           )
DISTRIBUTED BY (trans_id)
PARTITION BY RANGE (date)
SUBPARTITION BY LIST (region)
SUBPARTITION TEMPLATE
(
    SUBPARTITION usa VALUES ('usa'),
    SUBPARTITION asia VALUES ('asia'),
    SUBPARTITION europe VALUES ('europe'),
    DEFAULT SUBPARTITION other_regions
)
(
    START (date '2011-01-01') INCLUSIVE
    END (date '2012-01-01') EXCLUSIVE
    EVERY (INTERVAL '1 month'),
   DEFAULT PARTITION outlying_dates
);