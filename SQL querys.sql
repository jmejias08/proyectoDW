-- Tabla de dimenciones de transportista


create table dim_transportista (
    transportista_key int identity(1,1) constraint  pk_transportista primary key,
    transportistaId int,
    nombre_transportista nvarchar(100),
    telefono nvarchar(20)
);


CREATE VIEW v_dim_transportista
AS
SELECT ShipperID as transportistaId,
		CompanyName as nombre_transportista,
		Phone as telefono
FROM staging.dbo.SHIPPERS
UNION ALL
SELECT 4 AS transportistaId, 
       'Transporte Jardineria' AS nombre_transportista, 
       '(506) 8724-6262' AS telefono;



INSERT INTO dim_transportista
SELECT *
FROM v_dim_transportista;




--========================================================================================
-- Tablas de dimenciones de producto

create table dim_producto (
    producto_key int identity(1,1) constraint  pk_prodcuto primary key,
    productoId int,
    nombre_producto nvarchar(100),
    categoria nvarchar(20),
	proveedor_key int,
    cantidad_por_unidad nvarchar(50),
    precio_unitario decimal(10,2),
    unidades_en_stock int,
    unidades_en_orden int
);


CREATE VIEW v_dim_producto
AS
SELECT 
	CAST(P.ProductID AS varchar(10)) as productoId,
    P.ProductName AS nombre_producto,
	CASE 
        WHEN C.CategoryName = 'Beverages' THEN 'Bebidas'
        WHEN C.CategoryName = 'Condiments' THEN 'Condimentos'
        WHEN C.CategoryName = 'Confections' THEN 'Confites'
        WHEN C.CategoryName = 'Dairy Products' THEN 'Productos Lácteos'
        WHEN C.CategoryName = 'Grains/Cereals' THEN 'Granos/Cereales'
        WHEN C.CategoryName = 'Meat/Poultry' THEN 'Carne/Aves'
        WHEN C.CategoryName = 'Produce' THEN 'Producir'
        WHEN C.CategoryName = 'Seafood' THEN 'Mariscos'
        ELSE C.CategoryName 
    END AS categoria,
    P.UnitPrice AS precio_unitario,
    P.UnitsInStock AS unidades_en_stock,
    S.CompanyName AS proveedor
FROM 
    staging.dbo.PRODUCTS P
INNER JOIN 
    staging.dbo.CATEGORIES C ON P.CategoryID = C.CategoryID
INNER JOIN 
    staging.dbo.suppliers S ON S.SupplierID = P.SupplierID
UNION
SELECT  
	P.CODIGO_PRODUCTO AS productoId,
    P.NOMBRE AS nombre_producto,
    P.GAMA AS categoria,
    P.PRECIO_VENTA AS precio_unitario,
    P.CANTIDAD_EN_STOCK AS unidades_en_stock,
    P.PROVEEDOR AS proveedor
FROM 
    Staging.DBO.producto P;


--- se eliminan las siguientes columnas por falta de informacion
ALTER TABLE dim_producto
DROP COLUMN cantidad_por_unidad;

ALTER TABLE dim_producto
DROP COLUMN unidades_en_orden;

ALTER TABLE dim_producto
DROP CONSTRAINT fk_producto_proveedor;

ALTER TABLE dim_producto
DROP COLUMN proveedor_key;

ALTER TABLE dim_producto
ADD proveedor varchar(50); -- se anade para solo nombrar el nombre del proveedor

ALTER TABLE dim_producto
ALTER COLUMN productoId nvarchar(10); -- se pasa para que puedan ser valores alfanumericos


INSERT INTO dim_producto
SELECT *
FROM v_dim_producto;

select * from dim_producto;


-- ====================================================================================================
-- Tablas de dimenciones de empleado

create table dim_empleado (
    empleado_key int identity(1,1) constraint pk_empleado primary key,
    empleadoId int,
    nombre_empleado nvarchar(100),
    puesto nvarchar(50),
    fecha_contratacion date,
    país nvarchar(50),
    ciudad nvarchar(50),
    jefatura varchar(80),
    salario numeric(25,2)
);


CREATE VIEW v_dim_empleado
AS
SELECT 
	CONCAT('JD_',CODIGO_EMPLEADO) AS empleadoId, --- se usa un prefijo para identifar de donde viene y que no hayan coincidencias en las ids
    CONCAT(E.Nombre, ' ', E.Apellido1, ' ', E.Apellido2) AS nombre_empleado,
    E.puesto AS puesto,
    '2020-01-01' AS fecha_contratacion,  -- se establace la primera fecha como predeterminada
    'CR' AS pais,                -- Costa rica como pais predeterminado
    'San Jose' AS ciudad               -- San José como ciudad predeterminada
FROM 
    staging.dbo.empleado E
UNION
SELECT  
	CONCAT('NW_', EmployeeID) AS empleadoId,
    CONCAT(e.FirstName, ' ', e.LastName) AS nombre_empleado,
    CASE
        WHEN e.Title = 'Inside Sales Coordinator' THEN 'Director Oficina'
        WHEN e.Title = 'Sales Manager' THEN 'Director General'
        WHEN e.Title = 'Sales Representative' THEN 'Representante Ventas'
        WHEN e.Title = 'Vice President, Sales' THEN 'Subdirector Ventas'
        ELSE e.Title 
    END AS puesto,
    e.HireDate AS fecha_contratacion,
    e.Country AS pais,
    e.City AS ciudad
FROM 
    Staging.DBO.employees e;


ALTER TABLE dim_empleado
DROP COLUMN jefatura;

ALTER TABLE dim_empleado
DROP COLUMN salario;

ALTER TABLE dim_empleado
ALTER COLUMN empleadoId nvarchar(10); -- se pasa para que puedan ser valores alfanumericos

INSERT INTO dim_empleado
SELECT *
FROM v_dim_empleado;


--======================================================================= 
-- tabla de dimenciones cliente


create table dim_cliente (
    cliente_key int identity(1,1) constraint  pk_cliente primary key,
    clienteId nvarchar(5),
    nombre_cliente nvarchar(100),
	sexo varchar(15),
	fecha_nacimiento date,
    pais nvarchar(50),
    ciudad nvarchar(50),
    codigo_postal nvarchar(10),
    telefono nvarchar(20),
	categoria nvarchar(20),
	asesor  nvarchar(80)
);


CREATE VIEW v_dim_cliente
AS
select CustomerID as clienteId,
  c.CompanyName as nombre_cliente,
  CASE 
        WHEN c.Country = 'USA' THEN 'US' 
        ELSE c.Country 
    END AS pais,
  c.City as ciudad,
  c.PostalCode as codigo_postal,
  c.Phone as telefono
from staging.dbo.CUSTOMERS c
union all
select cast(c.CODIGO_CLIENTE as varchar(10)) as clienteId,
  c.NOMBRE_CLIENTE as nombre_cliente,
  CASE 
        WHEN c.PAIS = 'USA' THEN 'US' 
        ELSE c.PAIS 
    END AS pais,
  c.CIUDAD as ciudad,
  c.CODIGO_POSTAL as codigo_postal,
  c.TELEFONO as telefono
from staging.dbo.CLIENTE c;


-- se eliminan las siguientes columnas por inexistencia de datos:
ALTER TABLE dim_cliente
DROP COLUMN sexo;

ALTER TABLE dim_cliente
DROP COLUMN fecha_nacimiento;

ALTER TABLE dim_cliente
DROP COLUMN categoria;

ALTER TABLE dim_cliente
DROP COLUMN asesor;


-- se inserta la informacion
INSERT INTO dim_cliente
SELECT *
FROM v_dim_cliente;



--=======================================================================
-- Tabla de dimensiones proveedor

-- Se elimina la tabla de proveedor debido a que en jardineria no existe la tabla (solamente existe una columna con el nombre en la tabla producto)
-- Por lo que, se opta por eliminarla y solo poner el nombre del proveedor en la tabla de dim_producto

-- Se elimina la llave foranea
ALTER TABLE fact_ventas
DROP CONSTRAINT fk_ventas_proveedor;

-- Se elimina la columna de referencia en la tabla fact_ventas
ALTER TABLE fact_ventas
DROP COLUMN proveedor_key;

-- Se elimina la tabla proveedor
DROP TABLE dim_proveedor;


--==================================
-- Prueba de la informacion de las tablas

select * from dim_cliente; 
select * from dim_empleado; -- puesto
select * from dim_producto; -- categoria
select * from dim_tiempo;
select * from dim_transportista;


create table fact_ventas(
    venta_id int identity(1,1) constraint pk_fac_ventas primary key,
    fecha_key int,
    cliente_key int,
    producto_key int,
    empleado_key int,
	proveedor_key int,
    transportista_key int,
    cantidad int,
    precio_unitario decimal(10,2),
    descuento decimal(5,2),
    total_venta decimal(12,2)
);




alter table fact_ventas add constraint    fk_ventas_tiempo	   foreign key (fecha_key) references dim_tiempo(fecha_key);
alter table fact_ventas add constraint   fk_ventas_cliente     foreign key (cliente_key) references dim_cliente(cliente_key);
alter table fact_ventas add constraint  fk_ventas_producto     foreign key (producto_key) references dim_producto(producto_key);
alter table fact_ventas add constraint  fk_ventas_empleado     foreign key (empleado_key) references dim_empleado(empleado_key);
--alter table fact_ventas add constraint fk_ventas_proveedor     foreign key (proveedor_key) references dim_proveedor(proveedor_key);
alter table fact_ventas add constraint fk_ventas_transportista foreign key (transportista_key) references dim_transportista(transportista_key);

alter table fact_ventas drop column proveedor_key; 


CREATE VIEW v_fact_ventas
AS
select 
    (select fecha_key from dim_tiempo where fecha_completa = dateadd(year, 24, cast(o.orderdate as date))) fecha_key,
    (select cliente_key from dim_cliente where clienteId = o.customerid) cliente_key,
	(select producto_key from dim_producto where isnumeric(producto_key)=1  
	and cast(producto_key as varchar(10)) = cast(od.productid as varchar(10)))producto_key, 
	(select empleado_key from dim_empleado where substring(empleadoId,4,3) = CAST(o.employeeid AS varchar(10))
	and substring(empleadoId,1,3)='NW_') as empleado_key,
    (select transportista_key from dim_transportista where transportista_key = o.shipvia) transportista_key,
	od.quantity as cantidad,
    od.unitprice as precio_unitario,
    od.discount as descuento,
    od.quantity * od.unitprice * (1 - od.discount) as total_venta
from staging.dbo.orders o
inner join staging.dbo.[orderdetails] od on o.orderid = od.orderid -- se cambiar a orderdetails
inner join staging.dbo.products p on od.productid = p.productid
union all 
select 
	(select fecha_key from dim_tiempo where fecha_completa = p.fecha_pedido)fecha_key,
    (select cliente_key from dim_cliente where clienteId = CAST(p.codigo_cliente AS VARCHAR(10))) AS cliente_key, -- Se ajustan las referencias y se castea a varchar para que sean compatibles
	(select producto_key from dim_producto where --isnumeric(producto_key)=0 and 
	productoId = dp.codigo_producto)producto_key,	 -- se ajustan las referencias
		(select empleado_key from dim_empleado 	where substring(empleadoId,4,3) = cl.codigo_empleado_rep_ventas -- se adapto para que funcionara con string y los prefijos
	and substring(empleadoId,1,3)='JD_')empleado_key,
    4 transportista_key,
	dp.cantidad,
    dp.precio_unidad,
    0 as descuento,
    dp.cantidad * dp.precio_unidad as total_venta
from staging.dbo.pedido p
inner join staging.dbo.detalle_pedido dp 
on p.codigo_pedido=dp.codigo_pedido
left join staging.dbo.cliente cl 
on cl.codigo_cliente=p.codigo_cliente;

INSERT INTO fact_ventas
SELECT *
FROM v_fact_ventas;

