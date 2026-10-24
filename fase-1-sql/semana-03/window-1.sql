1. Para cada produto, mostre nome, categoria (o nome), preço, o preço médio da categoria e a diferença entre os dois. Use window function.

WITH media_categoria AS(
SELECT
	p.product_name ,
	p.category_id ,
	p.unit_price ,
	AVG(p.unit_price) OVER(PARTITION BY p.category_id )AS Media_categoria
FROM products p 
)
SELECT
	md.product_name ,
	c.category_name ,
	ROUND((md.unit_price)::numeric,2)AS Preco_produto ,
	ROUND((md.media_categoria)::numeric,2) AS Media_categoria,
	ROUND((md.unit_price - md.media_categoria)::numeric,2) AS Diferenca
FROM media_categoria md
INNER JOIN categories c 
	ON c.category_id = md.category_id 
ORDER BY diferenca DESC;


Exercício 2. Mostre os 3 produtos mais caros de cada categoria, com a posição no ranking. Use RANK.
Num comentário, diga se alguma categoria trouxe mais de 3 produtos e por quê.
Tabelas: products (product_name, unit_price, category_id) e categories (category_id, category_name).

WITH preco_por_categoria AS (
SELECT
	c.category_name ,
	RANK()OVER (
		PARTITION BY p.category_id 
		ORDER BY p.unit_price DESC 
		) AS Ranking,
	p.product_name ,
	p.unit_price 
FROM products p 
INNER JOIN categories c 
	ON c.category_id = p.category_id
)
SELECT
	pc.category_name ,
	pc.ranking ,
	pc.product_name ,
	pc.unit_price 
FROM preco_por_categoria pc
WHERE pc.ranking <4;

--Nenhuma categoria trouxe mais de 3 resultados pois não houve empate no terceiro colocado para as categorias.


Exercício 3. Reescreva o exercício do pedido mais recente de cada cliente usando ROW_NUMBER, mostrando o nome da empresa, o número do pedido e a data.
O resultado precisa ter exatamente uma linha por cliente, mesmo que ele tenha dois pedidos na mesma data.
Tabelas: orders (order_id, customer_id, order_date) e customers (customer_id, company_name).

WITH ultimo_pedido_customer AS(
SELECT
	c.company_name ,
	o.order_id ,
	o.order_date ,
	ROW_NUMBER() OVER (
		PARTITION BY o.customer_id 
		ORDER BY o.order_date DESC ,o.order_id DESC
		) AS Ultimo_pedido
FROM orders o 
INNER JOIN customers c 
	ON o.customer_id = c.customer_id
)
SELECT
	up.company_name ,
	up.order_id ,
	up.order_date
FROM ultimo_pedido_customer up
WHERE up.ultimo_pedido = 1;



Exercício 4. Reescreva o exercício 2 de quarta: para cada país do cliente, mostre a receita de 1997 e a participação percentual desse país na receita total do ano, da maior para a menor.
Use SUM(...) OVER () para obter o total, sem uma CTE separada para ele.
Dica: calcule a receita por país numa CTE e aplique o SUM(...) OVER () na consulta final. Ou, numa consulta só, use SUM(SUM(receita)) OVER (), uma window function aplicada sobre a agregação.
Sanity check: a soma das participações precisa dar 100%. Desta vez, anote o valor encontrado!


WITH receita_1997_por_pais AS (
SELECT
	c.country ,
	SUM((od.unit_price * od.quantity * (1-od.discount )))AS Receita
FROM order_details od 
INNER JOIN orders o 
	ON o.order_id = od.order_id 
INNER JOIN customers c 
	ON c.customer_id = o.customer_id 
WHERE o.order_date >='1997-01-01' AND o.order_date <'1998-01-01'
GROUP BY c.country 
)
SELECT
	rc97.country,
	ROUND((rc97.receita)::numeric,2)AS Receita_1997 ,
	ROUND(((rc97.receita / SUM(rc97.receita )OVER())*100)::numeric,2) AS Percentual
FROM receita_1997_por_pais rc97
ORDER BY percentual DESC;

-- Eu ja sei pq vc pediu para anotar o valor... só pq deu 100.03 rsrsrs, esse valor foi por conta do arrendondamento em 2 casas, como não coloquei isso em uma CTE não consegui mudar só na visão do usuario.

--Sanity Check , transformar a consulta final em uma CTE resultado, e executar SELECT SUM(r.percentual) FROM resultado r;

-- Sanity check 1: soma das receitas por país = 617.085,20 (bateu com o total de 1997)
-- Sanity check 2: soma dos percentuais = 100,03 (diferença de arredondamento;
--                 somando o percentual sem ROUND, dá exatamente 100)
