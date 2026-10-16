SELECT 
	p.product_name ,
	p.unit_price  
FROM products p 
WHERE p.unit_price >50
ORDER BY p.unit_price DESC;

SELECT 
	c.company_name ,
	c.city ,
	c.country 
FROM customers c 
WHERE c.country IN ('Brazil','Mexico')
ORDER BY c.country , c.city ;


SELECT 
	COUNT(*) AS QTD_PEDIDOS 
FROM orders o 
WHERE o.order_date >='1997-01-01' 
	AND o.order_date <='1997-12-31' 
	AND o.shipped_date IS NULL;



SELECT 
	COUNT(o.order_id )AS QTD_ENTREGAS
FROM orders o 
GROUP BY o.ship_country 
HAVING COUNT(o.order_id )>50
ORDER BY COUNT(o.order_id ) DESC;



SELECT 
	p.product_name 
FROM order_details od 
LEFT JOIN products p ON od.product_id = p.product_id 
GROUP BY p.product_name
ORDER BY SUM(od.unit_price * od.quantity * (1-od.discount )) DESC
LIMIT 5;

SELECT
CONCAT(e.first_name,' ',e.last_name) AS NOME_COMPLETO,
COUNT(o.order_id)AS QTD_PEDIDOS
FROM employees e 
LEFT JOIN orders o ON e.employee_id = o.employee_id
GROUP BY CONCAT(e.first_name,' ',e.last_name)
ORDER BY COUNT(o.order_id) DESC;



