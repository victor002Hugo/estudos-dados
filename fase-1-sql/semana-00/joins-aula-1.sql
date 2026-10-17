1. Liste os pedidos de 1997 com número do pedido, data, nome da empresa cliente e nome completo do funcionário que atendeu.

SELECT
	o.order_id ,
	o.order_date ,
	c.company_name ,
	CONCAT(e.first_name ,' ',e.last_name )AS NOME_COMPLETO
FROM orders o 
INNER JOIN customers c 
	ON c.customer_id = o.customer_id 
INNER JOIN employees e 
	ON e.employee_id = o.employee_id 
WHERE o.order_date <'1998-01-01' AND o.order_date >='1997-01-01';



2. Mostre a quantidade de pedidos e o frete total por transportadora (nome da transportadora).

SELECT 
	s.company_name,
	COUNT(o.order_id ) AS QTD_PEDIDOS,
	ROUND(SUM(o.freight)::numeric,2 ) AS SOMA_FRETE
FROM orders o 
INNER JOIN shippers s 
	ON s.shipper_id = o.ship_via
GROUP BY s.shipper_id,s.company_name ;


3. Liste todos os funcionários e quantos pedidos cada um atendeu em 1998, incluindo quem atendeu zero. Use LEFT JOIN.

SELECT
	e.first_name || ' '|| e.last_name AS NAME_COMPLETO,
	COUNT(o.employee_id) AS QTD_PEDIDOS
FROM employees e 
LEFT JOIN orders o 
	ON o.employee_id = e.employee_id
	AND o.order_date <'1999-01-01'
	AND o.order_date >='1998-01-01'
GROUP BY e.employee_id,e.first_name,e.last_name;


4. Liste os pedidos que têm mais de 5 produtos diferentes, mostrando número do pedido, nome da empresa cliente e quantidade de produtos.

SELECT
	o.order_id ,
	c.company_name ,
	COUNT(od.product_id ) AS QTD_PRODUTOS
FROM orders o 
INNER JOIN order_details od 
	ON od.order_id = o.order_id 
INNER JOIN customers c 
	ON c.customer_id = o.customer_id 
GROUP BY o.order_id ,
		 c.company_name 
HAVING COUNT(od.product_id ) >5;

5. Liste os clientes que fizeram pedido em 1996 mas não fizeram nenhum em 1998. Use EXISTS e NOT EXISTS.

SELECT
	c.company_name 
FROM customers c 
WHERE 
EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id AND o.order_date <'1997-01-01' AND o.order_date >='1996-01-01')
AND NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id AND o.order_date <'1999-01-01' AND o.order_date >='1998-01-01');


6. Desafio: mostre, por país do cliente (customers.country), a quantidade de clientes cadastrados e a quantidade de clientes que fizeram pelo menos um pedido. Dica: pense em qual COUNT usar para cada coluna.

SELECT
    c.country,
    COUNT(DISTINCT c.customer_id) AS qtd_clientes,
    COUNT(DISTINCT o.customer_id) AS qtd_compraram
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.country
ORDER BY qtd_clientes DESC;


7. Ache o erro. A consulta abaixo deveria mostrar todos os clientes e quantos pedidos fizeram em 1998, mas tem dois problemas. Explique cada um e corrija.

-- 1- Estava contando todas as linhas no count, mesmo sem o valor do customer_id
-- 2- O filtro estava incompleto e estava no where ao inves do ON

SELECT 
	c.company_name, 
	COUNT(o.customer_id ) AS pedidos_1998
FROM customers c
LEFT JOIN orders o 
	ON o.customer_id = c.customer_id 
	AND o.order_date <'1999-01-01' 
	AND o.order_date >='1998-01-01'
GROUP BY c.customer_id, c.company_name;


8. Mostre todas as transportadoras e quantos pedidos cada uma entregou com atraso em 1997 (shipped_date maior que required_date), incluindo as que tiveram zero atrasos.


SELECT
	s.company_name ,
	COUNT(o.ship_via ) AS QTD_PEDIDOS
FROM shippers s 
LEFT JOIN orders o 
	ON o.ship_via = s.shipper_id 
	AND o.shipped_date <'1998-01-01' 
	AND o.shipped_date >='1997-01-01'
	AND o.shipped_date > o.required_date
GROUP BY s.shipper_id ,s.company_name ;


9. Liste os clientes que compraram pelo menos um produto da categoria Seafood. Use EXISTS. Dica: a subquery do EXISTS também pode ter JOINs dentro dela.

SELECT
	c.company_name 
FROM customers c 
WHERE EXISTS (
	SELECT
	1
	FROM orders o 
	INNER JOIN order_details od 
		ON od.order_id = o.order_id 
	INNER JOIN products p 
		ON p.product_id = od.product_id 
	INNER JOIN categories cat 
		ON cat.category_id = p.category_id 
	WHERE c.customer_id = o.customer_id 
		AND cat.category_name = 'Seafood'
);


10. Desafio difícil. Liste todos os produtos e a quantidade total vendida para clientes da França, incluindo os produtos que não venderam nada para lá (que devem aparecer com 0). Pense bem em quantas tabelas o caminho precisa e onde cada filtro deve ficar. Se travar, lembre da conversa de ontem sobre agregar antes de juntar.

SELECT
	p.product_name ,
	COALESCE(fr.qtd_produtos,0) AS QTD_VENDIDO
FROM products p 
LEFT JOIN (
	SELECT
	od.product_id ,
	SUM(od.quantity ) AS QTD_PRODUTOS
	FROM order_details od 
	INNER JOIN orders o ON o.order_id = od.order_id 
	INNER JOIN customers c ON c.customer_id = o.customer_id 
	WHERE c.country = 'France'
	GROUP BY od.product_id 
)fr ON p.product_id = fr.product_id 
ORDER BY QTD_VENDIDO DESC;