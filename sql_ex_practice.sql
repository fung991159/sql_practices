--http://sql-ex.ru
--Practice 26
SELECT AVG(p)
FROM (
    SELECT pc.price as p
    FROM PC
    INNER JOIN Product pdt
    on pdt.model = PC.model
        AND pdt.maker = 'A'
    UNION ALL
    SELECT l.price
    FROM Laptop l --962.5
    INNER JOIN Product pdt
    on pdt.model = l.model
        AND pdt.maker = 'A'
) tmp

--Practice 27
SELECT maker,
       Avg(hd)
FROM product,
     pc
WHERE product.model = pc.model
    AND maker IN (
                    SELECT DISTINCT maker
                    FROM   product
                    WHERE  type = 'printer')
GROUP BY maker  

--Practice 28
SELECT 
    COUNT(*) AS qty
FROM (
	SELECT maker
	FROM product
	GROUP BY maker
	HAVING count(model) = 1
	) t
