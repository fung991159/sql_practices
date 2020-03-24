/* T-SQL Fundamentals
 * 
 * Itzik Ben-Gan - T-SQL Fundamentals-Microsoft Press (2016)
 * exercise by chapter
 * 
 */
--Q1b
 SELECT
	empid
	, DATEFROMPARTS(
		'2016'
		, '06'
		, n + 11
	) AS dt
FROM
	HR.Employees e
CROSS JOIN dbo.Nums nums
WHERE
	nums.n < 6
ORDER BY
	empid;
--Q2
SELECT
	C.custid
	, C.companyname
	, O.orderid
	, O.orderdate
FROM
	Sales.Customers AS C
INNER JOIN Sales.Orders AS O ON
	C.custid = O.custid;
--Q3 ????
 SELECT
	c.custid
	, COUNT(o.orderid) AS numorders
	, SUM(od.qty) AS totalqty
FROM
	Sales.Customers c
LEFT JOIN Sales.Orders o ON
	c.custid = o.custid
LEFT JOIN Sales.OrderDetails od ON
	o.orderid = od.orderid
GROUP BY
	c.custid
ORDER BY
	c.custid ;
--Q4 
 SELECT
	c.custid
	, c.companyname
	, o.orderid
	, orderdate
FROM
	sales.Customers c
LEFT JOIN sales.Orders o ON
	c.custid = o.custid ;
--Q5
 SELECT
	c.custid
	, c.companyname
FROM
	sales.Customers c
LEFT JOIN sales.Orders o ON
	c.custid = o.custid
where
	orderid IS NULL
--Q6
 SELECT
	c.custid
	, c.companyname
	, o.orderid
	, o.orderdate
FROM
	sales.Customers c
INNER JOIN sales.Orders o ON
	o.custid = c.custid
WHERE
	o.orderdate = '2016-02-12'
--Q7
 SELECT
	c.custid
	, c.companyname
	, o.orderid
	, o.orderdate
FROM
	sales.Customers c
LEFT JOIN sales.Orders o ON
	o.custid = c.custid
	AND o.orderdate = '2016-02-12' ;
--Q8
 SELECT
	C.custid
	, C.companyname
	, O.orderid
	, O.orderdate
FROM
	Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O ON
	O.custid = C.custid
WHERE
	O.orderdate = '20160212'
	--LEFT JOIN effect has been filtered away in where clause..
	OR O.orderid IS NULL;
--Q9
 SELECT
	c.custid
	, c.companyname
	,
	CASE WHEN orderdate IS NOT NULL THEN 'Yes'
	ELSE 'No' END AS 'HasOrderOn20160212'
FROM
	sales.Customers c
LEFT JOIN sales.Orders o ON
	o.custid = c.custid
	AND o.orderdate = '2016-02-12';
--Ch4 Subqueries

--Q1
 SELECT
	orderid
	, orderdate
	, custid
	, empid
FROM
	Sales.Orders
WHERE
	orderdate = (
		SELECT
			MAX(orderdate)
		FROM
			Sales.Orders
	);
	
--Q2
SELECT
	custid
	, orderid
	, orderdate
	, empid
FROM
	sales.Orders o
WHERE
	custid = (
		SELECT
			TOP(1) custid
		FROM
			sales.Orders o
		GROUP BY
			custid
		ORDER BY
			COUNT(custid) DESC
	);

--Q3
SELECT
	empid
	, FirstName
	, lastname
FROM
	HR.Employees e 
WHERE
	empid NOT IN (
		SELECT 
			DISTINCT empid
		FROM
			Sales.Orders
		WHERE orderdate >= '2016-05-01'

	);
	
--Q4
SELECT
	DISTINCT country
FROM
	Sales.Customers c
WHERE
	country not in (
		SELECT
			DISTINCT country
		FROM
			HR.Employees e
	);

--Q5
SELECT
	custid
	, orderid
	, orderdate
	, empid
FROM
	Sales.Orders AS o1
WHERE
	orderdate = (
		SELECT
			MAX(o2.orderdate)
		FROM
			Sales.Orders o2
		WHERE
			o2.custid = o1.custid
	)
ORDER BY custid;

--Q6
SELECT
	distinct c.custid
	, companyname
FROM
	sales.customers c
INNER JOIN Sales.Orders o ON
	o.custid = c.custid
WHERE
	(o.orderdate BETWEEN '2015-1-1' AND '2015-12-31')
	AND (
		c.custid NOT IN (
			SELECT
				distinct custid
			FROM
				Sales.Orders
			where
				orderdate BETWEEN '2016-1-1' AND '2016-12-31'
		)
	)
ORDER BY
	c.custid

--Q7
SELECT custid, companyname
FROM Sales.Customers
WHERE custid IN (
	SELECT
		custid
	FROM
		Sales.Orders o
	WHERE
		orderid IN (
			SELECT
				orderid
			FROM
				Sales.OrderDetails
			WHERE
				productid = 12
		)
)
	
--Q8
SELECT
	co1.custid
	, co1.ordermonth
	, co1.qty
	, SUM(co2.qty) AS runqty
FROM
	Sales.CustOrders co1
INNER JOIN Sales.CustOrders co2 on
	co1.custid = co2.custid
	AND co1.ordermonth >= co2.ordermonth
GROUP BY
	co1.custid
	, co1.ordermonth
	, co1.qty
ORDER BY
	co1.custid
	
--Q9
--IN statment accepts liternal value or subquery
--EXIST statment return true or false base on a select subquery, will stop once an element is found

--Q10
SELECT
	o1.custid
	, o1.orderdate
	, o1.orderid
	, DATEDIFF(day, (
		SELECT TOP(1)
			o2.orderdate 
		FROM Sales.Orders o2
		WHERE o1.custid=o2.custid AND 
		o1.orderdate > o2.orderdate 
		ORDER BY o2.orderdate desc
		), o1.orderdate )
FROM
	Sales.Orders o1
ORDER BY
	custid
	, orderdate
	, orderid

SELECT
	o1.custid
	, o1.orderdate
	, o1.orderid
	, (SELECT TOP(1)
		o2.orderdate 
	FROM Sales.Orders o2
	WHERE o1.custid=o2.custid AND 
	o1.orderdate > o2.orderdate 
	ORDER BY o2.orderdate desc)
FROM
	Sales.Orders o1
ORDER BY
	custid
	, orderdate
	, orderid
	
--Ch.5 Table expression
--Q5.1
--select statment is ran in execution later than the WHERE clause, therefore "endofyear" were not
--defined to be used in the WHERE clause

--Q5.2
WITH max_orderdate AS (
	SELECT
		empid
		, MAX(orderdate) AS maxorderdate
	FROM
		Sales.Orders
	GROUP BY
		empid
)
SELECT
	m.empid
	, m.maxorderdate AS 'orderdate'
	, o.orderid
	, o.custid
FROM
	max_orderdate m
INNER JOIN Sales.Orders o ON
	m.empid = o.empid
	AND m.maxorderdate = o.orderdate

--Q5.3
WITH orders_with_rownum AS (
	SELECT
		orderid
		, orderdate
		, custid
		, empid
		, ROW_NUMBER() OVER (ORDER BY orderdate) as rownum
	FROM
		Sales.Orders
)
SELECT
	*
FROM
	orders_with_rownum
WHERE
	rownum BETWEEN 11 AND 20
;
	
--Q5.4
WITH EmpsCTE AS
(
	SELECT empid, mgrid, firstname, lastname
	FROM HR.Employees
	WHERE empid = 9
	
	UNION ALL
	
	SELECT C.empid, C.mgrid, C.firstname, C.lastname
	FROM EmpsCTE AS P
	INNER JOIN HR.Employees AS C
		ON c.empid =  p.mgrid
)
SELECT empid, mgrid, firstname, lastname
FROM EmpsCTE;

--Q5.5-1
DROP VIEW IF EXISTS Sales.VEmpOrders;
CREATE VIEW Sales.VEmpOrders
AS (
	SELECT
		empid
		, order_year
		, SUM(qty) AS qty
	FROM
		(
			SELECT
				empid
				, YEAR(o.orderdate) AS order_year
				, qty
			FROM
				Sales.Orders o
			INNER JOIN Sales.OrderDetails od ON
				o.orderid = od.orderid
		) t
	GROUP BY
		empid
		, order_year
)
SELECT * FROM Sales.VEmpOrders ORDER BY empid, order_year;

--Q5.5-2
SELECT
	v1.empid
	, v1.order_year
	, v1.qty
	, (
		SELECT
			SUM(qty)
		FROM
			Sales.VEmpOrders v2
		WHERE
			v1.empid = v2.empid
			AND v1.order_year >= v2.order_year
	) AS runqty
FROM
	Sales.VEmpOrders v1
ORDER BY
	v1.empid
	, order_year
;
--Q5.6-1
DROP FUNCTION IF EXISTS Production.TopProducts;
CREATE FUNCTION Production.TopProducts
(@supid AS INT, @n AS INT) RETURNS TABLE
AS 
RETURN
SELECT TOP(@n) productid, productname, unitprice 
FROM Production.Products p 
WHERE supplierid = @supid
ORDER BY unitprice DESC
;
SELECT * FROM Production.TopProducts(5, 2);

--Q5.6-2
SELECT s.supplierid, s.companyname, tp.productid, tp.productname, tp.unitprice
FROM Production.Suppliers s 
CROSS APPLY Production.TopProducts(s.supplierid , 2) tp
ORDER BY s.companyname
;

--Q6.1
--UNION ALL will return duplicated row while UNION remove duplicate
--WHEN there are no duplicate in the tables then both are equivalent
--If we know there will be no duplicatein tables, USE UNION ALL will have smaller overhead

--Q6.2
SELECT 1
UNION 
SELECT 2
UNION 
SELECT 3
UNION 
SELECT 4
UNION 
SELECT 5
;
--Q6.3
SELECT custid, empid
FROM Sales.Orders 
WHERE orderdate between '2016-1-1' AND '2016-1-31'
EXCEPT 
SELECT custid, empid
FROM Sales.Orders 
WHERE orderdate between '2016-2-1' AND '2016-2-29'
;
--Q6.4
SELECT custid, empid
FROM Sales.Orders 
WHERE orderdate between '2016-1-1' AND '2016-1-31'
INTERSECT 
SELECT custid, empid
FROM Sales.Orders 
WHERE orderdate between '2016-2-1' AND '2016-2-29'
;
--Q6.5
SELECT custid, empid
FROM Sales.Orders 
WHERE orderdate between '2016-1-1' AND '2016-1-31'
INTERSECT 
SELECT custid, empid
FROM Sales.Orders 
WHERE orderdate between '2016-2-1' AND '2016-2-29'
EXCEPT 
SELECT custid, empid
FROM Sales.Orders 
WHERE orderdate between '2015-1-1' AND '2015-12-31'
;
--Q6.6
SELECT country, region, city
FROM 
(	
	SELECT country, region, city, 1 AS rs
	FROM  HR.Employees 
	UNION ALL
	SELECT country, region, city, 2 AS rs
	FROM Production.Suppliers
) t
ORDER BY rs, country, region, city
;
--Q7.1
SELECT
	custid
	, orderid
	, qty
	, RANK() OVER(
		PARTITION BY custid
		ORDER BY qty
	) AS rnk
	, DENSE_RANK() OVER(
		PARTITION BY custid
		ORDER BY qty
	) AS dense_rnk
FROM
	dbo.Orders
;
--Q7.2
SELECT
	src.val
	, SUM(cnt) OVER (
	ORDER BY val
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	) AS rownum
FROM (
	SELECT DISTINCT 
		val
		, 1 AS cnt
	FROM
		Sales.OrderValues
) src
;
--alternative using dense_rank
SELECT val, DENSE_RANK() OVER(ORDER BY val) AS rownum
FROM Sales.OrderValues
GROUP BY val
;
--Q7.3
SELECT custid, orderid, qty
	  , qty - LAG(qty)  OVER(PARTITION BY custid
	  				  ORDER BY orderdate ) AS diffprev
	  , qty - LEAD(qty)  OVER(PARTITION BY custid
	  				  ORDER BY orderdate ) AS diffnext
FROM dbo.Orders o
;
--Q7.4
--Always use table expression when working with Pivot in the FORM cluase
--Because what isn't in aggregate elmeents and spreading elements are implicitily used in group by
SELECT empid, [2014], [2015], [2016]
FROM (
	SELECT empid, orderid, YEAR(orderdate) as order_year
	FROM dbo.Orders 
	) AS D
PIVOT(
	COUNT(orderid)
	FOR order_year IN ([2014], [2015], [2016])
) AS P
;
--Q7.5
	SELECT empid, [year], qty_cnt
	FROM dbo.EmpYearOrders
		UNPIVOT(
			qty_cnt FOR [year] IN (cnt2014, cnt2015, cnt2016)
			) AS U
;
--Q7.6
SELECT
	GROUPING_ID(empid, custid, YEAR(Orderdate)) AS groupingset,
	empid
	, custid
	, YEAR(Orderdate) AS orderyear
	, SUM(qty) AS sumqty
FROM 
	dbo.Orders
GROUP BY
	GROUPING SETS (
		(empid, custid, YEAR(orderdate)),
		(empid, YEAR(orderdate)),
		(custid, YEAR(orderdate))
	)
;
--Q8.1
INSERT INTO dbo.Customers
VALUES(100, 'Coho Winery', 'USA', 'WA', 'Redmond');

INSERT INTO dbo.Customers
SELECT custid, companyname, country, region, city FROM Sales.Customers;

DROP TABLE IF EXISTS dbo.Orders
SELECT *
INTO dbo.Orders 
FROm Sales.Orders o 
WHERE orderdate BETWEEN '2014-1-1' AND '2016-12-31';

---8.2
DELETE FROM dbo.Orders 
	OUTPUT
		deleted.orderid
		, deleted.orderdate
--SELECT orderdate
--FROM dbo.Orders 
WHERE orderdate < '2014-8-1';

--8.3
DELETE 
	FROM dbo.Orders 
WHERE shipcountry = 'Brazil';
--8.4
UPDATE dbo.Customers
	SET region = '<none>'
OUTPUT 
	inserted.custid
	, inserted.region AS new_region
	, deleted.region AS old_region
WHERE region IS NULL;
--8.5
UPDATE o SET
	 shipcountry = c.country 
	, shipregion = c.region
	, shipcity = c.city
OUTPUT 
	inserted.shipcountry
	, inserted.shipregion
	, inserted. shipcity
	FROM dbo.Orders o
		INNER JOIN dbo.Customers c
			ON o.custid = c.custid 
WHERE
	o.shipregion = N'UK';

--8.6
ALTER TABLE dbo.Orders DROP CONSTRAINT DFT_Orders_freight ;
ALTER TABLE dbo.OrderDetails DROP CONSTRAINT 
	DFT_OrderDetails_unitprice
	, DFT_OrderDetails_qty
	, DFT_OrderDetails_discount
	, PK_OrderDetails
	, FK_OrderDetails_Orders
	, CHK_discount
	, CHK_qty
	, CHK_unitprice ;

TRUNCATE
	TABLE dbo.Orders;

TRUNCATE
	TABLE dbo.OrderDetails;
--Q9.1
CREATE TABLE dbo.Departments
(
	deptid int NOT NULL
		CONSTRAINT PK_Department PRIMARY KEY NONCLUSTERED
	,deptname VARCHAR(25) NOT NULL
	,mgrid INT NOT NULL
	,validfrom DATETIME2(0)
		GENERATED ALWAYS AS ROW START HIDDEN NOT NULL
	,validto DATETIME2(0)
		GENERATED ALWAYS AS ROW END HIDDEN NOT NULL
	, PERIOD FOR SYSTEM_TIME (validfrom, validto)
	, INDEX ix_Departments CLUSTERED(deptid,mgrid)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.DepartmentsHistory));
--Q9.2
INSERT INTO dbo.Departments
VALUES (1, 'HR', 7),
		(2, 'IT', 5),
		(3, 'Sales', 11),
		(4, 'Marketing', 13);

UPDATE dbo.Departments
SET deptname = 'Sales and Marketing'
WHERE deptname = 'Sales';
DELETE dbo.Departments
WHERE deptid = 4;

UPDATE dbo.Departments
SET mgrid = 13
WHERE deptid = 3;

--Q9.3
SELECT * FROM Departments;
SELECT * FROM Departments 
FOR SYSTEM_TIME AS OF '2020-03-22 07:39:28';


SELECT deptid, deptname, mgrid, validfrom, validto FROM Departments
FOR SYSTEM_TIME FROM  '2020-03-22 07:23:23' TO  '2020-03-22 07:39:29';
--FOR SYSTEM_TIME;

IF OBJECT_ID(N'dbo.Departments', N'U') IS NOT NULL
BEGIN
	IF OBJECTPROPERTY(OBJECT_ID(N'dbo.Departments', N'U'), N'TableTemporalType') = 2
	ALTER TABLE dbo.Departments SET ( SYSTEM_VERSIONING = OFF );
	DROP TABLE IF EXISTS dbo.DepartmentsHistory, dbo.Departments;
END;

--Q10
/* There is no exercise for Ch.10 but some brief explanation on how the transaction locks works
 * Isolation levels
 * 1. READ UNCOMMITTED (dirty read) - doesn't require a shared lock and read whatever in the database
 * 2. READ COMMITTED (default by SQL server) - if other connection is in transaction then must wait for it to close in order to read the data. 
 * 		But the read is "not repeatable" as update operation can still be done after read
 * 3. Repeatable read - doesn't allow update operation once transaction begin, hence the fetch value stay the same in the transaction. 
 * 		But this only lock existing rows but not non-existing/future/newly added rows (i.e. phantoms read) 
 * 4. Seralizable - repeatable read + future proof. will block all attempts made by other transaction that add rows that qualify query filter.
 * 
 * Azure SQL database instead use row versioning tech.
 * 	Advantage:
 *		- No need to obtain share lock for read, if the rows are block, it will look for older version in tempDB, SELECT related statment hence run much faster
 * 	Disadvantage:
 * 		- INSERT, DELETE, UPDATE are going to be much slower because of needing to keep a copy in tempDB
 *
 * Isolation levels
 * 1. SNAPSHOT: pretty much like SERIALIZABLE, but when blocked it will not wait, instead go for older version of the data
 * 2. READ COMMITTED SNAPSHOT: like READ COMMITTED 
 *
 * deadlock: when transacstions are access each other resource
 * to mitigate: 
 * 		1. keep transactions as short as possible
 * 		2. Avoid deadly embrace deadlock: logical operations that run in reverse order
 *		3. choice of isloations levels: use read commited snapshot instead of read commited as it doesn't required shared locks.
 **/
	


SELECT orderid, productid, unitprice, qty, discount
FROM Sales.OrderDetails
WHERE orderid = 10249;