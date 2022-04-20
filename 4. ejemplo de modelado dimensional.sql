
create schema tiendas_dwh;

Create table tiendas_dwh.producto(
    ---DWH
    id_producto serial,
    -- ID operacional
    numero_producto varchar(50),
    descripcion_producto varchar(250),
    marca varchar(50),
    subcategoria varchar(50),
    categoria varchar(50),
    categoriadepartamento varchar(50)
) distributed by (numero_producto)
;


create table tiendas_dwh.tiempo(
    id_tiempo serial,
    fecha date,
    dia_semana int,
    semestre int,
    bimestre int,
    trimestre int,
    quatrimestre int,
    anio int ,
    mes int check ( mes > 0 and mes <13 ),
    dia int check ( dia>  1 and dia <31 ),
    dia_habil bool
);

create table tiendas_dwh.tienda(
    id_tienda serial,
    numero_tienda varchar(50),
    nombre_tienda varchar(50),
    calle text,
    ciudad varchar(50),
    pais varchar(50),
    estado varchar(50),
    zip_code varchar(50),
    manager varchar(50),
    region varchar(50)
);

create table tiendas_dwh.promocion(
    id_promocion serial,
    codigo_promocion varchar(50),
    nombre_promocion varchar(90),
    tipo_reduccion_precio varchar(50),
    fecha_inicio_promocion date,
    fecha_fin_promocion date
);

create table tiendas_dwh.cajero(
    id_cajero serial,
    numero_cajero varchar(50),
    nombre varchar(50),
    apellido_paterno varchar(50),
    apellido_materno varchar(50),
    fecha_nacimiento date
) distributed by(numero_cajero);

create table tiendas_dwh.metodo_pago(
    id_metodo_pago serial,
    descripcion_metodo_pago varchar(50),
    grupo_metodo_pago varchar(50)
);


create table tiendas_dwh.venta(
    -- ID DWH
    id_venta bigserial,
    id_cajero integer  not null ,
    id_metodo_pago integer not null,
    id_producto integer not null,
    id_promocion integer not null,
    id_tiempo integer not null,
    numero_transaccion integer,
    precio_unitario_descuento numeric(12,2),
    precio_unitario numeric(12,2),
    cantidad_venta integer check ( cantidad_venta > 0 ),
    monto_neto numeric(12,2)
);

select query,query_start- now(), pid ,*
from pg_stat_activity;

select *
from pg_cancel_backend(2932);

select *
from pg_terminate_backend(2932);


create table tiendas_dwh.venta_anual_cocacola(
    -- ID DWH
    id_venta bigserial,
    id_cajero integer  not null ,
    id_metodo_pago integer not null,
    id_producto integer not null,
    id_promocion integer not null,
    id_tiempo integer not null,
    numero_transaccion integer,
    precio_unitario_descuento numeric(12,2),
    precio_unitario numeric(12,2),
    cantidad_venta integer check ( cantidad_venta > 0 ),
    monto_neto numeric(12,2)
);

create table tiendas_dwh.venta_mensual(
    -- ID DWH
    id_venta bigserial,
    id_cajero integer  not null ,
    id_metodo_pago integer not null,
    id_producto integer not null,
    id_promocion integer not null,
    anio integer,
    mes integer,
    cantidad_venta integer check ( cantidad_venta > 0 ),
    monto_neto numeric(12,2)
);
create table tiendas_dwh.venta_anual(
    -- ID DWH
    id_venta bigserial,
    id_cajero integer  not null ,
    id_metodo_pago integer not null,
    id_producto integer not null,
    id_promocion integer not null,
    anio integer,
    cantidad_venta integer check ( cantidad_venta > 0 ),
    monto_neto numeric(12,2)
);
create table tiendas_dwh.envio_paquete(
    -- ID DWH
    id_paquete bigserial,
    id_cliente integer  not null ,
    id_producto integer not null,
    fecha_compra timestamp,
    fecha_empacado timestamp,
    fecha_envio timestamp,
    fecha_recepcion  timestamp,
    monto_neto numeric(12,2)
);
drop table tiendas_dwh.envio_paquete;
select *
from tiendas_dwh.envio_paquete;