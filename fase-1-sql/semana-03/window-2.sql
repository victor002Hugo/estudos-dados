
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
FROM receita_mensal_97 rc
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