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