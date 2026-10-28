
--Aprendendo a utilizar o DATE_TRUNC()


WITH receita_mensal AS(
SELECT
	DATE_TRUNC('month',o.order_date )::date AS Mes,
	SUM(od.quantity * od.unit_price * (1-od.discount ))AS Receita
FROM orders o 
INNER JOIN order_details od 
	ON od.order_id = o.order_id 
GROUP BY DATE_TRUNC('month',o.order_date )
ORDER BY mes
)
SELECT
	r.mes ,
	r.receita,
	LAG(r.receita) OVER(ORDER BY r.mes) AS Receita_mes_anterior
FROM receita_mensal r;


1. Evolução mensal. Para cada mês de 1997, mostre a receita, a receita do mês anterior e a variação percentual. Num comentário, diga qual mês teve o maior crescimento e qual teve a maior queda.

WITH receita_mensal AS (
SELECT
	DATE_TRUNC('month',o.order_date )::date AS Mes,
	SUM(od.quantity * od.unit_price * (1-od.discount ))AS Receita
FROM orders o 
INNER JOIN order_details od ON od.order_id = o.order_id 
GROUP BY DATE_TRUNC('month',o.order_date )
),
receita_com_anterior AS (
SELECT
	rc.mes,
	rc.receita ,
	LAG(rc.receita ) OVER(ORDER BY rc.mes )AS Receita_Mes_Anterior
FROM receita_mensal rc
)
SELECT
	rca97.mes ,
	rca97.receita ,
	rca97.receita_mes_anterior,
	ROUND(((rca97.receita - rca97.receita_mes_anterior) / NULLIF((rca97.receita_mes_anterior),0) *100)::numeric,2) AS Percentual
FROM receita_com_anterior rca97
WHERE rca97.mes >= '1997-01-01' AND rca97.mes < '1998-01-01'
ORDER BY rca97.mes;

--Mês de maior crescimento foi 12/1997 e o de maior queda foi 02/1997

2. Intervalo entre compras.

Parte A: para cada pedido, mostre o cliente, a data e quantos dias se passaram desde o pedido anterior do mesmo cliente.
Parte B: para cada cliente, calcule o intervalo médio entre compras, em dias.
Num comentário, explique como essa informação poderia ser usada numa ação de CRM.


--Parte A
WITH pedidos_data_A AS(
SELECT
o.customer_id ,
o.order_id ,
o.order_date ,
LAG(o.order_date) OVER (
	PARTITION BY o.customer_id 
	ORDER BY o.order_date ,o.order_id )AS data_pedido_anterior
FROM orders o 
)
SELECT
	pd.customer_id ,
	pd.order_id ,
	pd.order_date ,
	pd.data_pedido_anterior ,
	pd.order_date - pd.data_pedido_anterior AS dias_desde_pedido_anterior
FROM pedidos_data_A pd;

--Parte B
WITH pedidos_data_B AS(
SELECT
	o.customer_id ,
	o.order_id ,
	o.order_date - LAG(o.order_date ) OVER (
	PARTITION BY o.customer_id 
	ORDER BY o.order_date ,o.order_id ) AS dias_sem_compra
FROM orders o 
)
SELECT 
	pdb.customer_id ,
	ROUND(AVG(pdb.dias_sem_compra ),1)AS intervalo_media_dias
FROM pedidos_data_B pdb
GROUP BY pdb.customer_id
ORDER BY intervalo_media_dias DESC NULLS LAST;

--Essa informação poderia ser utilizada para ativação de quem tem uma media longa de dias até a compra, entender se com talvez um desconto ele faça compras mais recorrentes, ou até mesmo tentar vender uma quantidade maior para quem compra toda semana.




3. Receita acumulada. Para cada mês de todo o período, mostre a receita do mês, o acumulado desde o início e o acumulado do ano (que recomeça em janeiro).
Sanity check: o acumulado do ano em dezembro de 1997 precisa dar 617.085,20. E o acumulado desde o início, no último mês, precisa ser igual à receita total do banco.

WITH receita_mensal AS(
SELECT 
	DATE_TRUNC('month',o.order_date)::date AS mes ,
	SUM(od.unit_price * od.quantity * (1-od.discount ))AS receita
FROM order_details od 
INNER JOIN orders o 
	ON o.order_id = od.order_id 
GROUP BY DATE_TRUNC('month',o.order_date)
)
SELECT
	rc.mes ,
	rc.receita ,
	SUM(rc.receita ) OVER (ORDER BY rc.mes ) AS acumulado_total,
	SUM(rc.receita) OVER (PARTITION BY DATE_TRUNC('year',rc.mes )ORDER BY rc.mes ) AS acumulado_ano
FROM receita_mensal rc
ORDER BY mes;

--sanity check 1 
WITH receita_mensal AS(
SELECT 
	DATE_TRUNC('month',o.order_date)::date AS mes ,
	SUM(od.unit_price * od.quantity * (1-od.discount ))AS receita
FROM order_details od 
INNER JOIN orders o 
	ON o.order_id = od.order_id 
GROUP BY DATE_TRUNC('month',o.order_date)
),
resultado AS(
SELECT
	rc.mes ,
	rc.receita ,
	SUM(rc.receita ) OVER (ORDER BY rc.mes ) AS acumulado_total,
	SUM(rc.receita) OVER (PARTITION BY DATE_TRUNC('year',rc.mes )ORDER BY rc.mes ) AS acumulado_ano
FROM receita_mensal rc
ORDER BY mes
)
SELECT
	rs.mes ,
	rs.acumulado_ano 
FROM resultado rs
WHERE rs.mes = '1997-12-01'

--sanity check 2
WITH receita_mensal AS(
SELECT 
	DATE_TRUNC('month',o.order_date)::date AS mes ,
	SUM(od.unit_price * od.quantity * (1-od.discount ))AS receita
FROM order_details od 
INNER JOIN orders o 
	ON o.order_id = od.order_id 
GROUP BY DATE_TRUNC('month',o.order_date)
),
resultado AS(
SELECT
	rc.mes ,
	rc.receita ,
	SUM(rc.receita ) OVER (ORDER BY rc.mes ) AS acumulado_total,
	SUM(rc.receita) OVER (PARTITION BY DATE_TRUNC('year',rc.mes )ORDER BY rc.mes ) AS acumulado_ano
FROM receita_mensal rc
ORDER BY mes
)
SELECT
SUM(rs.receita ) AS RECEITA,
(SELECT SUM(od.unit_price * od.quantity * (1 - od.discount)) FROM order_details od)
FROM resultado rs;

-- Check 1: acumulado_ano em dez/1997 = 617.085,20 (bateu)
-- Check 2: soma das receitas mensais = 1265793.0386533642; total direto em order_details = 1265793.038653364 (bateu)

4. Média móvel. Para cada mês de todo o período, mostre a receita e a média móvel de 3 meses. Num comentário, explique o que acontece com a média móvel nos dois primeiros meses.


WITH receita_mensal AS(
SELECT 
	DATE_TRUNC('month',o.order_date)::date AS mes ,
	SUM(od.unit_price * od.quantity * (1-od.discount ))AS receita
FROM order_details od 
INNER JOIN orders o 
	ON o.order_id = od.order_id 
GROUP BY DATE_TRUNC('month',o.order_date)
)
SELECT
	rc.mes,
	rc.receita,
CASE
    WHEN ROW_NUMBER() OVER (ORDER BY rc.mes) < 3 THEN NULL
    ELSE AVG(rc.receita) OVER (ORDER BY rc.mes ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
END AS media_movel_3m
FROM receita_mensal rc
ORDER BY rc.mes ;

-- Nos dois primeiros meses não há meses anteriores o suficiente para entrar a média de 3 meses
--deixei em branco porque a média desses meses usaria menos de 3 meses e não seria comparável com as demais.


