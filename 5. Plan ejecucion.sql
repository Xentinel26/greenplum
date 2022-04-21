create database dwh;
create schema dimension;
create schema fact;

select query,
       now() - query_start,
       state,
       * from pg_stat_activity;



CREATE TABLE dimension.city
(
    City_Key                   INT			NOT NULL,
    WWI_City_ID                INT			NOT NULL,
    City                       varchar (50)	NOT NULL,
    State_Province             varchar (50)	NOT NULL,
    Country                    varchar (60)	NOT NULL,
    Continent                  varchar (30)	NOT NULL,
    Sales_Territory            varchar (50)	NOT NULL,
    Region                     varchar (30)	NOT NULL,
    Subregion                  varchar (30)	NOT NULL,
    Latest_Recorded_Population BIGINT			NOT NULL,
    Valid_From                 timestamp	NOT NULL,
    Valid_To                   timestamp	NOT NULL,
    Lineage_Key                INT			NOT NULL
)
distributed replicated;




CREATE TABLE Dimension.Customer
(
	Customer_Key		INT				NOT NULL,
	WWI_Customer_ID	INT				NOT NULL,
	Customer			VARCHAR(100)	NOT NULL,
	Bill_To_Customer	VARCHAR(100)	NOT NULL,
	Category			VARCHAR(50)	NOT NULL,
	Buying_Group		VARCHAR(50)	NOT NULL,
	Primary_Contact	VARCHAR(50)	NOT NULL,
	Postal_Code		VARCHAR(10)	NOT NULL,
	Valid_From		timestamp	NOT NULL,
	Valid_To			timestamp	NOT NULL,
	Lineage_Key		INT				NOT NULL
);

select count(*)
from dimension.customer;

drop table dimension.date;
CREATE TABLE Dimension.Date
(
	date						DATE			NOT NULL unique ,
	Day_Number				INT				NOT NULL,
	Day						VARCHAR(10)	NOT NULL,
	Month						VARCHAR(10)	NOT NULL,
	Short_Month				VARCHAR(3)		NOT NULL,
	Calendar_Month_Number		INT				NOT NULL,
	Calendar_Month_Label		VARCHAR(20)	NOT NULL,
	Calendar_Year				INT				NOT NULL,
	Calendar_Year_Label		VARCHAR(10)	NOT NULL,
	Fiscal_Month_Number		INT				NOT NULL,
	Fiscal_Month_Label		VARCHAR(20)	NOT NULL,
	Fiscal_Year				INT				NOT NULL,
	Fiscal_Year_Label			VARCHAR(10)	NOT NULL
) distributed by (Date);


update dimension.date
set day_number = extract(day from date),
    day = extract(day from date),
    month = extract(month from date),
    calendar_month_number = extract(month from date),
    calendar_year = extract(year from date)
;

select extract(month from date), count(*)
from dimension.date
where calendar_year = 2022
group by extract(month from date);

select count(*)
from dimension.date
where calendar_year = 2022 ;


CREATE TABLE Dimension.Employee
(
	Employee_Key		INT				NOT NULL,
	WWI_Employee_ID	INT				NOT NULL,
	Employee			VARCHAR(50)	NOT NULL,
	Preferred_Name	VARCHAR(50)	NOT NULL,
	Is_Salesperson	boolean				NOT NULL,
	Photo				bytea	NULL,
	Valid_From		timestamp	NOT NULL,
	Valid_To			timestamp	NOT NULL,
	Lineage_Key		INT				NOT NULL
);

select *
from dimension.employee;

CREATE TABLE Dimension.Payment_Method
(
	Payment_Method_Key		INT				NOT NULL,
	WWI_Payment_Method_ID		INT				NOT NULL,
	Payment_Method			VARCHAR(50)	NOT NULL,
	Valid_From				timestamp	NOT NULL,
	Valid_To					timestamp	NOT NULL,
	Lineage_Key				INT				NOT NULL
);

select *
from dimension.stock_item;
drop table dimension.stock_item;
CREATE TABLE Dimension.Stock_Item
(
	Stock_Item_Key			INT				NOT NULL,
	WWI_Stock_Item_ID			INT				NOT NULL,
	Stock_Item				text	NOT NULL,
	color						text	NOT NULL,
	Selling_Package			text	NOT NULL,
	Buying_Package			text	NOT NULL,
	Brand						text	NOT NULL,
	Size						text	NOT NULL,
	Lead_Time_Days			INT				NOT NULL,
	Quantity_Per_Outer		INT				NOT NULL,
	Is_Chiller_Stock			boolean				NOT NULL,
	Barcode					text	NULL,
	Tax_Rate					DECIMAL(18, 3)	NOT NULL,
	Unit_Price				DECIMAL(18, 2)	NOT NULL,
	Recommended_Retail_Price	DECIMAL(18, 2)	NULL,
	Typical_Weight_Per_Unit	DECIMAL(18, 3)	NOT NULL,
	Photo						bytea	NULL,
	Valid_From				timestamp	NOT NULL,
	Valid_To					timestamp	NOT NULL,
	Lineage_Key				INT				NOT NULL
);


CREATE TABLE Dimension.Supplier
(
	Supplier_Key			INT				NOT NULL,
	WWI_Supplier_ID		INT				NOT NULL,
	Supplier				VARCHAR(100)	NOT NULL,
	Category				VARCHAR(50)	NOT NULL,
	Primary_Contact		VARCHAR(50)	NOT NULL,
	Supplier_Reference	VARCHAR(20)	NULL,
	Payment_Days			INT				NOT NULL,
	Postal_Code			VARCHAR(10)	NOT NULL,
	Valid_From			timestamp	NOT NULL,
	Valid_To				timestamp	NOT NULL,
	Lineage_Key			INT				NOT NULL
);

CREATE TABLE Dimension.Transaction_Type
(
	Transaction_Type_Key		INT				NOT NULL,
	WWI_Transaction_Type_ID	INT				NOT NULL,
	Transaction_Type			VARCHAR(50)	NOT NULL,
	Valid_From				timestamp	NOT NULL,
	Valid_To					timestamp	NOT NULL,
	Lineage_Key				INT				NOT NULL
) ;



CREATE TABLE Fact.Movement
(
	Movement_Key						bigserial	NOT NULL,
	Date_Key							DATE					NOT NULL,
	Stock_Item_Key					INT						NOT NULL,
	Customer_Key						INT						NULL,
	Supplier_Key						INT						NULL,
	Transaction_Type_Key				INT						NOT NULL,
	WWI_Stock_Item_Transaction_ID		INT						NOT NULL,
	WWI_Invoice_ID					INT						NULL,
	WWI_Purchase_Order_ID				INT						NULL,
	Quantity							INT						NOT NULL,
	Lineage_Key						INT						NOT NULL
) ;

CREATE TABLE Fact.Order
(
	Order_Key				bigserial	NOT NULL,
	City_Key				INT						NOT NULL,
	Customer_Key			INT						NOT NULL,
	Stock_Item_Key		INT						NOT NULL,
	Order_Date_Key		DATE					NOT NULL,
	Picked_Date_Key		DATE					NULL,
	Salesperson_Key		INT						NOT NULL,
	Picker_Key			INT						NULL,
	WWI_Order_ID			INT						NOT NULL,
	WWI_Backorder_ID		INT						NULL,
	Description			VARCHAR(100)			NOT NULL,
	Package				VARCHAR(50)			NOT NULL,
	Quantity				INT						NOT NULL,
	Unit_Price			DECIMAL(18, 2)			NOT NULL,
	Tax_Rate				DECIMAL(18, 3)			NOT NULL,
	Total_Excluding_Tax	DECIMAL(18, 2)			NOT NULL,
	Tax_Amount			DECIMAL(18, 2)			NOT NULL,
	Total_Including_Tax	DECIMAL(18, 2)			NOT NULL,
	Lineage_Key			INT						NOT NULL
) ;


CREATE TABLE Fact.Purchase
(
	Purchase_Key				bigserial	NOT NULL,
	Date_Key					DATE					NOT NULL,
	Supplier_Key				INT						NOT NULL,
	Stock_Item_Key			INT						NOT NULL,
	WWI_Purchase_Order_ID		INT						NULL,
	Ordered_Outers			INT						NOT NULL,
	Ordered_Quantity			INT						NOT NULL,
	Received_Outers			INT						NOT NULL,
	Package					VARCHAR(50)			NOT NULL,
	Is_Order_Finalized		boolean						NOT NULL,
	Lineage_Key				INT						NOT NULL
) ;


CREATE TABLE Fact.Sale
(
	Sale_Key					bigserial	NOT NULL,
	City_Key					INT						NOT NULL,
	Customer_Key				INT						NOT NULL,
	Bill_To_Customer_Key		INT						NOT NULL,
	Stock_Item_Key			INT						NOT NULL,
	Invoice_Date_Key			DATE					NOT NULL,
	Delivery_Date_Key			DATE					NULL,
	Salesperson_Key			INT						NOT NULL,
	WWI_Invoice_ID			INT						NOT NULL,
	Description				VARCHAR(100)			NOT NULL,
	Package					VARCHAR(50)			NOT NULL,
	Quantity					INT						NOT NULL,
	Unit_Price				DECIMAL(18, 2)			NOT NULL,
	Tax_Rate					DECIMAL(18, 3)			NOT NULL,
	Total_Excluding_Tax		DECIMAL(18, 2)			NOT NULL,
	Tax_Amount				DECIMAL(18, 2)			NOT NULL,
	Profit					DECIMAL(18, 2)			NOT NULL,
	Total_Including_Tax		DECIMAL(18, 2)			NOT NULL,
	Total_Dry_Items			INT						NOT NULL,
	Total_Chiller_Items		INT						NOT NULL,
	Lineage_Key				INT						NOT NULL
);


CREATE TABLE Fact.Stock_Holding
(
	Stock_Holding_Key				bigserial	NOT NULL,
	Stock_Item_Key				INT						NOT NULL,
	Quantity_On_Hand				INT						NOT NULL,
	Bin_Location					VARCHAR(20)			NOT NULL,
	Last_Stocktake_Quantity		INT						NOT NULL,
	Last_Cost_Price				DECIMAL(18, 2)			NOT NULL,
	Reorder_Level					INT						NOT NULL,
	Target_Stock_Level			INT						NOT NULL,
	Lineage_Key					INT						NOT NULL
);



CREATE TABLE Fact.Transaction
(
	Transaction_Key				bigserial	NOT NULL,
	Date_Key						DATE					NOT NULL,
	Customer_Key					INT						NULL,
	Bill_To_Customer_Key			INT						NULL,
	Supplier_Key					INT						NULL,
	Transaction_Type_Key			INT						NOT NULL,
	Payment_Method_Key			INT						NULL,
	WWI_Customer_Transaction_ID	INT						NULL,
	WWI_Supplier_Transaction_ID	INT						NULL,
	WWI_Invoice_ID				INT						NULL,
	WWI_Purchase_Order_ID			INT						NULL,
	Supplier_Invoice_Number		VARCHAR(20)			NULL,
	Total_Excluding_Tax			DECIMAL(18, 2)			NOT NULL,
	Tax_Amount					DECIMAL(18, 2)			NOT NULL,
	Total_Including_Tax			DECIMAL(18, 2)			NOT NULL,
	Outstanding_Balance			DECIMAL(18, 2)			NOT NULL,
	Is_Finalized					boolean						NOT NULL,
	Lineage_Key					INT					NOT NULL
);

CREATE TABLE fact.Sale
(
	Sale_Key					bigserial	NOT NULL,
	City_Key					INT						NOT NULL,
	Customer_Key				INT						NOT NULL,
	Bill_To_Customer_Key		INT						NOT NULL,
	Stock_Item_Key			INT						NOT NULL,
	Invoice_Date_Key			DATE					NOT NULL,
	Delivery_Date_Key			DATE					NULL,
	Salesperson_Key			INT						NOT NULL,
	WWI_Invoice_ID			INT						NOT NULL,
	Description				VARCHAR(100)			NOT NULL,
	Package					VARCHAR(50)			NOT NULL,
	Quantity					INT						NOT NULL,
	Unit_Price				DECIMAL(18, 2)			NOT NULL,
	Tax_Rate					DECIMAL(18, 3)			NOT NULL,
	Total_Excluding_Tax		DECIMAL(18, 2)			NOT NULL,
	Tax_Amount				DECIMAL(18, 2)			NOT NULL,
	Profit					DECIMAL(18, 2)			NOT NULL,
	Total_Including_Tax		DECIMAL(18, 2)			NOT NULL,
	Total_Dry_Items			INT						NOT NULL,
	Total_Chiller_Items		INT						NOT NULL,
	Lineage_Key				INT						NOT NULL
);






















explain analyse
select *
from dimension.stock_item



SELECT 'stock_compressed'                     AS "Table Name",
       max(c)                             AS "Max Seg Rows",
       min(c)                             AS "Min Seg Rows",
       (max(c) - min(c)) * 100.0 / max(c) AS "Percentage Difference Between Max & Min"
FROM (SELECT count(*) c, gp_segment_id FROM dimension.stock_item GROUP BY 2) AS a;


SELECT gp_segment_id, count(*)
FROM dimension.stock_item
GROUP BY gp_segment_id
order by 1;



select skcoid, skcnamespace, skcrelname, skccoeff as coeficiente_variacion
  --- Valores mas pequeños mejor
from gp_toolkit.gp_skew_coefficients
where skcnamespace = 'finance';



select sifoid,
       sifnamespace,
       sifrelname,
       (siffraction * 100)::numeric(12, 2) as porcentaje_ocioso_ts
from gp_toolkit.gp_skew_idle_fractions
order by 4 desc;

drop resource queue reporting;

create resource queue reporting with (active_statements = 10, memory_limit = '3GB', priority = MAX);
create resource queue etl with (active_statements = 90, memory_limit = '1GB', priority = HIGH );
create resource queue development with (active_statements = 50, memory_limit = '500MB', priority = medium);

alter role usuario resource queue development;
alter role usuario with superuser ;
create user etl_user with login encrypted password 'etl_user_pass' resource queue etl;
create user bi_user with login encrypted password 'bi_user_pass' resource queue reporting;




SELECT *
FROM gp_toolkit.gp_resqueue_status;


SELECT *
FROM gp_toolkit.gp_locks_on_resqueue
WHERE lorwaiting = 'true';


select query, query_start - now(), state, waiting,  *
from pg_stat_activity
;


SELECT locktype,
       database,
       c.relname, 
       l.relation,
       l.transactionid,
       l.pid, 
       l.mode,
       l.granted,
       a.query
FROM pg_locks l, 
     pg_class c, 
     pg_stat_activity a
WHERE l.relation = c.oid
  AND l.pid = a.pid
ORDER BY c.relname;

select *
from pg_locks;

show gp_vmem_protect_limit;

explain (ANALYZE, COSTS, VERBOSE, BUFFERS,FORMAT TEXT) SELECT *
FROM pg_locks l,
     pg_class c,
     pg_stat_activity a
WHERE l.relation = c.oid
  AND l.pid = a.pid
ORDER BY c.relname;


select *
from pg_locks
;

explain (ANALYZE, COSTS, VERBOSE, BUFFERS, FORMAT text) select
    c."City", sum(s.profit)
from fact.sale s
inner join
    dimension.city c
on s.city_key = c."City Key"
inner join
    dimension.employee e
on s.salesperson_key = e.employee_key
group by c."City";



explain (ANALYZE, COSTS, VERBOSE, BUFFERS, FORMAT text) select stock_item.stock_item, selling_package, color
from dimension.stock_item
where brand in( 'Ames Walker')
limit 10
    ;


create index idx_stock_itm
    on dimension.stock_item(brand, barcode)
    include(selling_package);

analyse dimension.Stock_Item;
-- CANDADOS
vacuum freeze dimension.stock_item;

show all;
explain analyse
    --- common table expressions
with brand as (
    select distinct brand
    from dimension.stock_item
    --- where .......
)
select *
from fact.sale s
inner join
    brand b
on s.Description = b.brand