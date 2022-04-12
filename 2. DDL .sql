
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