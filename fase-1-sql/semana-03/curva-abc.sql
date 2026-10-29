O desafio
Calcule a receita total de cada produto
Ordene do maior para o menor e calcule a participação acumulada de cada produto na receita total
Classifique cada produto em A, B ou C
Mostre, por classe: quantidade de produtos, receita total e percentual da receita
Num comentário: o que o resultado revela sobre a concentração das vendas?



WITH receita_por_produto AS (
SELECT
	p.product_id ,
	p.product_name ,
	SUM(od.quantity * od.unit_price *(1-od.discount )) AS Receita
FROM order_details od 
INNER JOIN products p 
	ON p.product_id = od.product_id
GROUP BY p.product_id 
),
percentual_participacao_produto AS (
SELECT
	rc.product_id ,
	rc.product_name ,
	rc.receita ,
	(rc.receita / SUM(rc.receita ) OVER()*100) AS percentual_participacao
FROM receita_por_produto rc
),
percentual_acumulado AS (
    SELECT
        pd.*,
        SUM(pd.percentual_participacao) OVER (
            ORDER BY pd.receita DESC, pd.product_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS percentual_acumulado
    FROM percentual_participacao_produto pd
),
classificacao AS (
    SELECT
        pa.*,
        CASE
            WHEN pa.percentual_acumulado <= 80 THEN 'A'
            WHEN pa.percentual_acumulado <= 95 THEN 'B'
            ELSE 'C'
        END AS classe
    FROM percentual_acumulado pa
)
SELECT
	cs.classe ,
	count(*) AS qtd_produtos,
	ROUND(SUM(cs.receita )::numeric,2)AS receita,
	ROUND(SUM(cs.percentual_participacao )::numeric,2)AS percentual
FROM classificacao cs
GROUP BY cs.classe 
ORDER BY percentual DESC;


-- A curta A tem 35 dos 77 produtos ,  menor de 50% dos produtos geram 80% do faturamento


--Sanity checks
-- Soma de produtos da consulta 77
-- Soma da receita 1265793.04
-- Percentual do ultimo 100 (chocolate)