1. Liste todos os clientes da Alemanha e a receita total que cada um gerou em 1997, incluindo os que não compraram nada nesse ano (com 0). Receita = unit_price * quantity * (1 - discount).

SELECT
	c.company_name ,
	COALESCE(ROUND(SUM(od.unit_price * od.quantity * (1-od.discount ))::numeric,2),0) AS Receita
FROM customers c 
LEFT JOIN orders o 
	ON o.customer_id = c.customer_id
	AND o.order_date <'1998-01-01'
	AND o.order_date >='1997-01-01'
LEFT JOIN order_details od 
	ON od.order_id = o.order_id
WHERE c.country = 'Germany'
GROUP BY c.customer_id , c.company_name
ORDER BY Receita DESC;

--Este exercicio não precisa de subquery pois seu filtro esta na tabela da esquerda, diferente do exercicio 10 que o filtro esta na tabela da direita, o exercicio 10 requer uma subquery pelo relacionamento que deve ser realizado até chegar no momento do filtro

2. Para cada pedido de 1998, mostre: número do pedido, frete, valor total dos itens e o percentual que o frete representa sobre o valor dos itens. Atenção à pegadinha que vimos na quinta.

SELECT
	o.order_id ,
	o.freight ,
	ROUND((total.valor_total)::numeric,2) ,
	ROUND(((o.freight /total.valor_total) * 100)::numeric,2) AS Percentual_Frete
FROM orders o 
LEFT JOIN (
			SELECT
				od.order_id ,
				SUM(od.quantity *od.unit_price )AS Valor_Total
			FROM order_details od 
			GROUP BY od.order_id 
			)total ON o.order_id = total.order_id 
WHERE o.order_date <'1999-01-01' AND o.order_date >='1998-01-01';

--Sobre este caso, eu quase refiz o filtro da data na subquery, mas para isso eu teria que relacionar novamente com orders, então deixei.. eu sei que não vou ter problemas pois como é uma ligação vai dar false para os registros que são de outro ano pois o order_id não vai existir na primeira consulta
--Mesmo assim fiquei com duvidas.. em uma tabela grande por exemplo, valeria a pena refazer o filtro ?

3. Faça um sanity check do exercício 2: a soma da coluna de frete do seu resultado precisa bater com uma consulta simples que some o frete direto da tabela orders, filtrando 1998. Escreva as duas consultas e confira se os totais são iguais.

SELECT 
	SUM(o.freight)
FROM orders o 
WHERE o.order_date <'1999-01-01' AND o.order_date >='1998-01-01';

SELECT 
SUM(conferencia.freight )
FROM(
SELECT
	o.order_id ,
	o.freight ,
	total.valor_total ,
	ROUND(((o.freight /total.valor_total) * 100)::numeric,2) AS Percentual_Frete
FROM orders o 
LEFT JOIN (
			SELECT
				od.order_id ,
				ROUND(SUM(od.quantity *od.unit_price )::numeric,2)AS Valor_Total
			FROM order_details od 
			GROUP BY od.order_id 
			)total ON o.order_id = total.order_id 
WHERE o.order_date <='1999-01-01' AND o.order_date >='1998-01-01') AS conferencia;

-- Não podemos esquecer que a nossa primeira consulta esta filtrada.. você não mencionou isso no exercicio 3, mas eu inclui o filtro na consulta

4. Liste os clientes que nunca compraram nenhum produto da categoria Beverages.

SELECT
	c.customer_id ,
	c.company_name 
FROM customers c 
WHERE NOT EXISTS (
					SELECT
						1
					FROM orders o 
					INNER JOIN order_details od 
						ON od.order_id = o.order_id 
					INNER JOIN products p 
						ON p.product_id = od.product_id 
					INNER JOIN categories cat 
						ON cat.category_id = p.category_id 
					WHERE cat.category_name = 'Beverages'
						AND c.customer_id = o.customer_id 
					);

5. Desafio: liste os produtos cujo preço é maior que o preço médio da própria categoria, mostrando produto, categoria e preço. Dica: é uma subquery no WHERE que compara com um valor, como no guia de ontem, mas a média muda conforme a categoria de cada produto. Pense em como ligar a subquery à linha de fora.


SELECT
	p.product_name,
	c.category_name,
	p.unit_price
FROM products p 
LEFT JOIN (
			SELECT
				p2.category_id,
				AVG(p2.unit_price )AS Media_Preco
			FROM products p2 
			GROUP BY p2.category_id)PrecoCateg 
				ON PrecoCateg.category_id  = p.category_id
LEFT JOIN categories c 
	ON c.category_id = p.category_id
WHERE p.unit_price > PrecoCateg.media_preco ;