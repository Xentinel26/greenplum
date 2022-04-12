
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
where tablespace = 'fast_ssd_ts'

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

