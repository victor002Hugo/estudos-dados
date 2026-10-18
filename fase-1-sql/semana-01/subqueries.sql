1. Liste os produtos com preço acima da média geral, mostrando nome, preço, a média geral e a diferença entre o preço e a média.

SELECT
	p.product_name,
	p.unit_price,
	ROUND((SELECT 
				AVG(p2.unit_price )
			FROM products p2 )::numeric,2)AS Media_Geral,
	ROUND((p.unit_price - (SELECT 
								AVG(p2.unit_price )
							FROM products p2 ))::numeric,2) AS Dif_PrecoMedia
FROM products p 
WHERE p.unit_price >(SELECT 
						AVG(p2.unit_price )
					 FROM products p2 )
	GROUP BY p.product_id, p.product_name;


2. Liste os pedidos de clientes do Brasil usando IN, sem JOIN. Depois, reescreva usando EXISTS.

--Utilizando IN
SELECT
	o.order_id
FROM orders o 
WHERE o.ship_country IN ('Brazil');

--Utilizando o Exists
SELECT
	o.order_id 
FROM orders o 
WHERE EXISTS (SELECT 1 FROM orders o2 WHERE o2.ship_country = 'Brazil' AND o.order_id = o2.order_id );


3. Liste os funcionários que atenderam pelo menos um pedido com frete acima de 500.

SELECT
	DISTINCT
	(e.first_name ||' '||e.last_name )AS Full_Name
FROM employees e 
INNER JOIN orders o 
	ON o.employee_id = e.employee_id 
WHERE o.freight >500;


4. Preveja antes de rodar. Considere esta consulta:

SELECT company_name, region
FROM customers
WHERE region NOT IN (SELECT region FROM suppliers);

a) Antes de rodar, escreva num comentário o que você acha que vai acontecer.
	--A consulta vai trazer company_name e region de customers que não tem o region igual ao qualquer supplier (Considerando que todos os suppliers possuam region)
b) Rode e explique o resultado.
	--Existem region como null, sendo assim ele nunca da um resultado verdadeiro, trazendo uma consulta em branco
c) Reescreva com NOT EXISTS e compare.

SELECT
	c.company_name,
	c.region 
FROM customers c 
WHERE NOT EXISTS (SELECT s.region FROM suppliers s WHERE c.region = s.region );


5. Para cada cliente, mostre o seu pedido mais recente: nome da empresa, número do pedido e data. Dica: subquery correlacionada no WHERE, comparando a data do pedido com a maior data daquele cliente.

SELECT
	c.company_name,
	o.order_id,
	o.order_date 
FROM customers c 
INNER JOIN orders o ON o.customer_id = c.customer_id 
WHERE o.order_date = (SELECT MAX(o2.order_date ) FROM orders o2 WHERE o.customer_id = o2.customer_id)