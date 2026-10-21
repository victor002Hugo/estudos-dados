1. Liste os produtos com preço acima da média geral, mostrando nome, preço, a média geral e a diferença entre o preço e a média.

WITH media_geral AS(
SELECT
	AVG(p.unit_price ) AS media_geral
FROM products p 
)
SELECT
	p.product_name,
	ROUND((p.unit_price)::numeric,2)AS preco,
	ROUND((md.media_geral)::numeric,2) AS preco_medio,
	ROUND((p.unit_price - md.media_geral)::numeric,2) AS Dif_preco
FROM products p 
CROSS JOIN media_geral md
WHERE p.unit_price > md.media_geral
ORDER BY dif_preco DESC;


7.d) Pedidos cujo frete é maior que a média de frete do país de entrega

WITH media_frete_pais AS(
SELECT
	o.ship_country,
	AVG(o.freight ) AS Media_Frete
FROM orders o 
GROUP BY o.ship_country 
)
SELECT
	o.order_id,
	o.ship_country,
	o.freight,
	ROUND((md.media_frete)::numeric,2)AS Media_Frete,
	ROUND((o.freight - md.media_frete)::numeric, 2)  AS diferenca
FROM orders o 
INNER JOIN media_frete_pais md 
	ON md.ship_country = o.ship_country 
WHERE o.freight > md.media_frete 
ORDER BY md.media_frete DESC;

3. Usando CTEs encadeadas:
Passo 1: receita de cada cliente em 1997
Passo 2: classifique cada cliente em uma faixa com CASE: Alta (acima de 10.000), Média (de 2.000 a 10.000) e Baixa (abaixo de 2.000)
Resultado final: quantidade de clientes e receita total por faixa

WITH receita_clientes_1997 AS(
SELECT
	o.customer_id,
	SUM(od.quantity * od.unit_price * (1-od.discount )) AS Receita
FROM order_details od 
INNER JOIN orders o 
	ON o.order_id = od.order_id 
WHERE o.order_date <'1998-01-01' AND o.order_date >='1997-01-01'
GROUP BY o.customer_id 
),
classificacao AS (
	SELECT
	r.customer_id ,
	r.receita ,
		CASE 
		WHEN r.receita > 10000 THEN 'Alta'
		WHEN r.receita >= 2000 THEN 'Media'
		ELSE 'Baixa'
		END AS FAIXA
	FROM receita_clientes_1997 r
)
SELECT
	cf.faixa ,
	COUNT(cf.customer_id ) AS QTD_Clientes,
	ROUND(SUM(cf.receita )::numeric,2) AS RECEITA_POR_FAIXA
FROM classificacao cf
GROUP BY cf.faixa
ORDER BY receita_por_faixa DESC;
-- Sanity check: receita total 1997 = 617085.20 (bateu com a soma das faixas)
-- clientes em 1997 = 86 (bateu com a soma de qtd_clientes)


-- Sanity Check da soma da receita
SELECT 
	SUM(od.quantity * od.unit_price * (1-od.discount ))AS Soma_valor
FROM order_details od 
INNER JOIN orders o 
	ON o.order_id = od.order_id 
WHERE o.order_date <'1998-01-01' AND o.order_date >='1997-01-01';


--Sanity Check da quantidade de clientes que compraram em 1997
SELECT
	COUNT(DISTINCT o.customer_id )AS Qtd_Clientes
FROM order_details od 
INNER JOIN orders o 
	ON od.order_id = o.order_id 
WHERE o.order_date <'1998-01-01' AND o.order_date >='1997-01-01';




4. Usando UNION, liste todos os países em que existem clientes ou fornecedores, sem repetição.


SELECT c.country FROM customers c
UNION
SELECT s.country FROM suppliers s ;


5. Usando UNION ALL, mostre por país a quantidade de clientes e de fornecedores, num formato como este:

WITH clientes_por_pais AS(
SELECT
	c.country,
	'Cliente' AS Tipo,
	COUNT(c.customer_id )AS Quantidade
FROM customers c 
GROUP BY c.country
),
fornecedores_por_pais AS(
SELECT
	s.country,
	'Fornecedor' AS Tipo,
	COUNT(s.supplier_id ) AS Quantidade
FROM suppliers s 
GROUP BY s.country
)
SELECT cl.country ,cl.tipo , cl.quantidade FROM clientes_por_pais cl
UNION ALL
SELECT fr.country , fr.tipo , fr.quantidade FROM fornecedores_por_pais fr
ORDER BY country ;


6. Desafio: para cada funcionário, mostre a receita de 1997, a receita de 1998 e a variação percentual entre os dois anos. Use uma CTE para cada ano.


WITH receita_func_1997 AS(
SELECT
	o.employee_id,
	SUM(od.quantity * od.unit_price * (1-od.discount ))AS Soma_Receita
FROM order_details od 
INNER JOIN orders o 
	ON o.order_id = od.order_id
WHERE o.order_date <'1998-01-01' AND o.order_date >='1997-01-01'
GROUP BY o.employee_id
),
receita_func_1998 AS(
SELECT
	o.employee_id,
	SUM(od.quantity * od.unit_price * (1-od.discount ))AS Soma_Receita
FROM order_details od 
INNER JOIN orders o 
	ON o.order_id = od.order_id
WHERE o.order_date <'1999-01-01' AND o.order_date >='1998-01-01'
GROUP BY o.employee_id
)
SELECT
	e.employee_id,
	e.first_name ,
	ROUND((rc97.soma_receita)::numeric,2)AS Receita_1997 ,
	ROUND((rc98.soma_receita)::numeric,2) AS Receita_1998,
	ROUND(((rc98.soma_receita - rc97.soma_receita )/ NULLIF(rc97.soma_receita,0)*100)::numeric,2)AS Variacao_ano
FROM employees e 
LEFT JOIN receita_func_1997 rc97 
	ON rc97.employee_id = e.employee_id 
LEFT JOIN receita_func_1998 rc98 
	ON rc98.employee_id = e.employee_id 
ORDER BY variacao_ano DESC;

-- 1998 só tem pedidos até 06/05 (pouco mais de 4 meses), contra 12 meses de 1997.
-- Por isso, a variação calculada não mede crescimento real: quase todos aparecem com queda.
-- Uma comparação justa usaria o mesmo período nos dois anos (jan a 06/05).
