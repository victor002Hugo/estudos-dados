1. Exercício extra: comparação justa

Refaça o desafio 6 de ontem comparando o mesmo período nos dois anos: de 1º de janeiro a 6 de maio de 1997 contra o mesmo intervalo em 1998.

Para cada funcionário, mostre a receita de 1997, a receita de 1998 e a variação percentual entre os dois anos. Use uma CTE para cada ano.

Depois, num comentário:

Compare os percentuais com os de ontem. O que mudou?
Quantos funcionários cresceram de fato?

Dica: a data final é 6 de maio, então o filtro precisa incluir esse dia. Lembre da regra do < no dia seguinte.


WITH Receita_por_funcionario_1997 AS(
SELECT
	o.employee_id,
	SUM(od.unit_price * od.quantity * (1-od.discount ))AS Receita_1997
FROM order_details od 
INNER JOIN orders o 
	ON o.order_id = od.order_id 
WHERE o.order_date <'1997-05-07' AND o.order_date >='1997-01-01'
GROUP BY o.employee_id
),
Receita_por_funcionario_1998 AS(
SELECT
	o.employee_id,
	SUM(od.unit_price * od.quantity *(1-od.discount))AS Receita_1998
FROM order_details od 
INNER JOIN orders o 
	ON o.order_id = od.order_id 
WHERE o.order_date <'1998-05-07' AND o.order_date >='1998-01-01'
GROUP BY o.employee_id
)
SELECT
	e.employee_id,
	e.first_name,
	ROUND((rec97.receita_1997)::numeric,2)AS  Receita_1997,
	ROUND((rec98.receita_1998)::numeric,2) AS Receita_1998,
	ROUND(((rec98.receita_1998 - rec97.receita_1997) / NULLIF(rec97.receita_1997 ,0)*100)::numeric,2)AS Pecentual_varicacao
FROM employees e 
LEFT JOIN Receita_por_funcionario_1997 rec97 
	ON rec97.employee_id = e.employee_id 
LEFT JOIN Receita_por_funcionario_1998 rec98 
	ON rec98.employee_id = e.employee_id 
ORDER BY Pecentual_varicacao DESC;


--Comparando mesmo periodo, temos crescimento em 8 funcionarios, sendo apenas 1 fora do aumento.
--Isso é um cenario completamente diferente do de ontem, onde havia crescimento de apenas 2 funcionarios.


1. Ticket médio por cliente. Para cada cliente, calcule em 1997 a receita total, a quantidade de pedidos e o ticket médio (receita ÷ quantidade de pedidos). Mostre os 10 com maior ticket médio.
Atenção: pense bem em como contar os pedidos depois de juntar orders com order_details.


WITH Receita_clientes_1997 AS(
SELECT
	o.customer_id ,
	SUM((od.unit_price * od.quantity *(1-od.discount )))AS ReceitaTotal
FROM order_details od 
INNER JOIN orders o 
	ON o.order_id = od.order_id 
WHERE o.order_date >='1997-01-01' AND o.order_date < '1998-01-01'
GROUP BY o.customer_id
),
Quantidade_pedidos_por_cliente_1997 AS(
SELECT
	o.customer_id,
	COUNT(o.order_id )AS QTD_pedidos
FROM orders o 
WHERE o.order_date >='1997-01-01' AND o.order_date < '1998-01-01'
GROUP BY o.customer_id 
)
SELECT
	c.customer_id ,
	c.company_name ,
	ROUND((rec97.receitatotal)::numeric,2)AS Receita_total ,
	ped97.qtd_pedidos ,
	ROUND((rec97.receitatotal / ped97.qtd_pedidos)::numeric,2) AS Ticket_medio
FROM customers c
INNER JOIN Receita_clientes_1997 rec97 
	ON rec97.customer_id = c.customer_id 
INNER JOIN Quantidade_pedidos_por_cliente_1997 ped97 
	ON ped97.customer_id = c.customer_id 
ORDER BY ticket_medio DESC LIMIT 10;



2. Participação por país. Para cada país do cliente, mostre a receita de 1997 e a participação percentual desse país na receita total do ano. Ordene da maior para a menor participação.
Sanity check: a soma das participações precisa dar 100%.


WITH Receita_por_pais_1997 AS(
SELECT
	c.country,
	SUM(od.unit_price * od.quantity * (1-od.discount ))AS Receita
FROM order_details od 
INNER JOIN orders o 
	ON o.order_id = od.order_id
INNER JOIN customers c 
	ON c.customer_id = o.customer_id 
WHERE o.order_date >='1997-01-01' AND o.order_date <'1998-01-01'
GROUP BY c.country
),
Receita_total_1997 AS (
SELECT
SUM(od.unit_price * od.quantity *(1-od.discount)) AS Receita
FROM order_details od 
INNER JOIN orders o 
	ON o.order_id = od.order_id 
WHERE o.order_date >='1997-01-01' AND o.order_date <'1998-01-01'
)
SELECT
	rec97.country ,
	ROUND((rec97.receita)::numeric,2)AS Receita_1997 ,
	ROUND(((rec97.receita / rect97.receita)*100)::numeric,2) AS Pecentual
FROM Receita_por_pais_1997 rec97
CROSS JOIN Receita_total_1997 rect97
ORDER BY pecentual DESC;

--Sanity Check realizado transformando minha ultima consulta em uma CTE e fazendo um SUM de Percentual
--receita_total AS (
  --  SELECT SUM(receita) AS receita
  --  FROM receita_por_pais_1997
--)

3. Clientes inativos. Uma pergunta muito comum em CRM: quais clientes estão há muito tempo sem comprar?

Use como data de referência a data do último pedido do banco (calcule com uma CTE, não digite a data)
Para cada cliente, encontre a data da última compra
Calcule há quantos dias ele não compra
Liste os clientes sem comprar há mais de 90 dias, do mais antigo para o mais recente
Dica: no PostgreSQL, subtrair uma data de outra dá o número de dias entre elas.


WITH Data_ultima_compra AS(
SELECT
	MAX(o.order_date )AS data_referencia
FROM orders o
),
Data_ultima_compra_cliente AS(
SELECT
o.customer_id ,
c.company_name,
MAX(o.order_date ) AS Ultima_Compra
FROM orders o 
INNER JOIN customers c 
	ON c.customer_id = o.customer_id 
GROUP BY o.customer_id , c.company_name
)
SELECT
	dtc.customer_id ,
	dtc.company_name ,
	dtc.ultima_compra,
	(dtcu.data_referencia - dtc.ultima_compra) AS Dias_Sem_Comprar
FROM Data_ultima_compra_cliente dtc
CROSS JOIN Data_ultima_compra dtcu
WHERE (dtcu.data_referencia - dtc.ultima_compra) >90
ORDER BY dias_sem_comprar DESC;

4. Desafio: pedidos fora da curva do próprio cliente. Liste os pedidos cujo valor é maior que o dobro do valor médio dos pedidos daquele cliente. Mostre o cliente, o número do pedido, o valor do pedido e o valor médio dos pedidos do cliente.
Dica: pense nas etapas antes de escrever. Primeiro o valor de cada pedido, depois a média por cliente, depois a comparação.


WITH Valor_do_pedido AS (
SELECT
	o.order_id ,
	o.customer_id ,
	SUM(od.unit_price * od.quantity * (1-od.discount )) AS Valor
FROM order_details od 
INNER JOIN orders o 
	ON o.order_id  = od.order_id
GROUP BY o.order_id,o.customer_id 
),
Media_por_cliente AS(
SELECT
	pedido.customer_id ,
	AVG(pedido.valor )AS Media_Cliente
FROM Valor_do_pedido pedido
GROUP BY pedido.customer_id 
)
SELECT
	c.customer_id ,
	c.company_name ,
	pedido.order_id ,
	ROUND((pedido.valor)::numeric,2) AS Valor_pedido ,
	ROUND((md.media_cliente )::numeric,2) AS Media_valor
FROM customers c 
INNER JOIN Valor_do_pedido pedido 
	ON pedido.customer_id  = c.customer_id 
INNER JOIN Media_por_cliente md 
	ON md.customer_id = c.customer_id 
WHERE pedido.valor  > (md.media_cliente *2)
ORDER BY (md.media_cliente *2) - pedido.valor DESC;


