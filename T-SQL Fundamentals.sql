
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


