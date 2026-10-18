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
					 FROM products p2 );


2. Liste os pedidos de clientes do Brasil usando IN, sem JOIN. Depois, reescreva usando EXISTS.

--Utilizando IN
SELECT
	o.order_id 
FROM orders o 
WHERE o.customer_id IN (SELECT c.customer_id 
						FROM customers c 
						WHERE c.country = 'Brazil');

--Utilizando o Exists
SELECT
	o.order_id 
FROM orders o 
WHERE EXISTS (SELECT c.customer_id 
				FROM customers c 
			  WHERE o.customer_id = c.customer_id 
				AND c.country = 'Brazil');


3. Liste os funcionários que atenderam pelo menos um pedido com frete acima de 500.

SELECT
	(e.first_name || ' ' ||e.last_name) AS Full_Name
FROM employees e 
WHERE EXISTS (SELECT 1 FROM orders o 
				WHERE o.freight >500
				AND o.employee_id = e.employee_id );


4. Preveja antes de rodar. Considere esta consulta:

SELECT company_name, region
FROM customers
WHERE region NOT IN (SELECT region FROM suppliers);

a) Antes de rodar, escreva num comentário o que você acha que vai acontecer.
	--A consulta vai trazer company_name e region de customers que não tem o region igual ao qualquer supplier (Considerando que todos os suppliers possuam region)
b) Rode e explique o resultado.
	--Existem region como null, sendo assim ele nunca da um resultado verdadeiro, trazendo uma consulta em branco
c) Reescreva com NOT EXISTS e compare.
-- NOT IN: 0 linhas. A lista de regiões dos fornecedores tem NULL, e aí o NOT IN nunca dá verdadeiro.
-- NOT EXISTS: 86 linhas. Os clientes com região NULL entram porque NULL nunca é igual a nada
-- (nem a outro NULL), então não existe fornecedor correspondente e o NOT EXISTS dá verdadeiro.

SELECT
	c.company_name,
	c.region 
FROM customers c 
WHERE NOT EXISTS (SELECT 1 FROM suppliers s WHERE c.region = s.region );


5. Para cada cliente, mostre o seu pedido mais recente: nome da empresa, número do pedido e data. Dica: subquery correlacionada no WHERE, comparando a data do pedido com a maior data daquele cliente.

SELECT
	c.company_name,
	o.order_id,
	o.order_date 
FROM customers c 
INNER JOIN orders o ON o.customer_id = c.customer_id 
WHERE o.order_date = (SELECT MAX(o2.order_date ) FROM orders o2 WHERE o.customer_id = o2.customer_id);

6. Desafio: liste as categorias cuja receita total é maior que a média de receita entre as categorias, mostrando o nome da categoria e a receita.

SELECT
	c.category_id ,
	c.category_name,
ROUND(((SELECT SUM((od.unit_price*od.quantity *(1-od.discount ) ))FROM order_details od )/
(SELECT COUNT(DISTINCT P.category_id )FROM order_details od2 INNER JOIN products p ON od2.product_id = p.product_id ))::numeric,2) AS MEDIA_VALOR,
ROUND(PrecoCateg.total_preco::numeric,2) AS Preco_Categ
FROM categories c 
INNER JOIN (
			SELECT 
			p.category_id,
			SUM((od.unit_price *od.quantity )*(1-od.discount )) AS Total_Preco
			FROM order_details od 
			INNER JOIN products p
				ON od.product_id = p.product_id 
			GROUP BY P.category_id 	
				)PrecoCateg ON c.category_id = PrecoCateg.category_id 
WHERE PrecoCateg.total_preco > (SELECT SUM((od.unit_price*od.quantity *(1-od.discount ) ))FROM order_details od )/
(SELECT COUNT(DISTINCT P.category_id )FROM order_details od2 INNER JOIN products p ON od2.product_id = p.product_id );

-- Média calculada apenas entre categorias com vendas.
-- Optei por não contar a partir de categories para não incluir
-- categorias sem venda, que entrariam como zero e reduziriam a média.

7. Sem código. Para cada pergunta, diga qual tipo de subquery (ou JOIN) você usaria, e por quê:

a) Clientes que não fizeram nenhum pedido em 1998
	--Utilizaria um NOT EXISTS no where, trazendo os clientes que compraram em 1998
	--Assim eu teria uma lista de quem comprou, para cada linha haveria uma comparação, não sei se existe uma forma mais performatica
b) Produtos mais caros que o produto mais caro da categoria Condiments
	--Utilizaria uma subquerie no Where, nela eu traria o valor do produto mais caro dessa categoria e faria uma comparação
	--Assim eu teria na esquerda a lista de produtos e na comparação o valor do produto vs o valor max do produto da categoria Condiments
c) Receita total por funcionário, mostrando o nome dele
	--Como o exercicio não pede o 0, poderia começar no employees e depois um inner join, a subconsulta ficaria no inner que traria a receita total por funcionario
d) Pedidos cujo frete é maior que a média de frete do país de entrega
	--Coluna calculada no select mesmo, trazendo a média de valor do frete por pais, depois uma comparação entre o frete de order e a coluna calculada fazendo a media