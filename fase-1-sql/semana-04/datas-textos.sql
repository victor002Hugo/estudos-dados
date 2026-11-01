--Extraindo partes de uma data

--Exemplo de extração, ano, mes, dia e dia da semana
SELECT
	o.order_date ,
	EXTRACT(YEAR FROM o.order_date) AS ANO,
	EXTRACT(MONTH FROM o.order_date) AS MES,
	EXTRACT(DAY FROM o.order_date) AS DIA,
	EXTRACT(ISODOW FROM o.order_date) AS DIA_SEMANA
FROM orders o ;

--Formatar uma data como texto no padrão pt-br por exemplo
SELECT
	o.order_date,
	TO_CHAR(o.order_date ,'DD/MM/YYYY') AS DATA_FORMATADA,
	TO_CHAR(o.order_date ,'YYYY-MM') AS PADRAO_AMERICANO,
	TO_CHAR(o.order_date ,'Day') AS DIA_SEMANA_PADRAO_BANCO
FROM orders o ;

--Exercicios

1. Pedidos por dia da semana. Mostre, para cada dia da semana, a quantidade de pedidos e a receita total. Ordene de segunda a domingo.
Dica: ordene pelo número do dia (EXTRACT(ISODOW ...)), não pelo nome. Num comentário, diga qual é o dia mais forte e se há algum dia sem pedidos.


WITH pedidos_por_data AS (
SELECT
	o.order_id ,
	o.order_date ,
	SUM(od.quantity * od.unit_price * (1-od.discount))AS Receita
FROM orders o 
INNER JOIN order_details od 
	ON od.order_id = o.order_id 
GROUP BY o.order_date ,o.order_id
),
receita_por_dia AS (
SELECT
	EXTRACT(ISODOW FROM pd.order_date)AS Dia_semana ,
	TO_CHAR(pd.order_date,'FMDay') AS Nome_dia,
	COUNT(pd.order_id)AS Qtd_pedidos,
	SUM(pd.receita ) AS Receita_do_dia
FROM pedidos_por_data pd
GROUP BY EXTRACT(ISODOW FROM pd.order_date),TO_CHAR(pd.order_date,'FMDay')
)
SELECT
	rd.nome_dia,
	rd.qtd_pedidos,
ROUND(rd.receita_do_dia::numeric,2)AS Receita
FROM receita_por_dia rd
ORDER BY rd.dia_semana ASC;

-- O dia mais forte em receita é a Sexta-feira, e em quantidade de pedidos temos a terça e a quinta empatadas.
-- Não há pedidos no final de semana, o que indica uma operação que funciona de Seg a Sex
-- Achei bem parecido a quantidade de pedidos dos dias da semana.. com uma variação de no max 2 pedidos, fiz um sanity check da CTE para conferir, são 830 pedidos transformei a ultima consulta em uma cte resultado e somei o qtd_pedidos
-- Na linha abaixo fiz uma consulta direto na orders, fazendo um count de order_date, obtive o mesmo resultado de 830




2. Prazo de entrega.
Parte A: para cada pedido, mostre os dias entre o pedido e o envio e uma classificação: “No prazo” (enviado até a required_date), “Atrasado” ou “Não enviado” (sem shipped_date).


WITH pedidos_datas AS (
SELECT
	o.order_id ,
	o.ship_via ,
	o.shipped_date ,
	o.shipped_date - o.order_date AS Dias_ate_entrega,
	o.required_date - o.shipped_date AS Dias_adiantado
FROM orders o 
), classificacao AS (
SELECT
	pd.*,
	CASE
		WHEN pd.shipped_date IS NULL THEN 'Não Enviado'
		WHEN pd.dias_adiantado >=0 THEN 'No Prazo'
	ELSE 'Atrasado'
	END AS Status_Pedido
FROM pedidos_datas pd
)
SELECT 
	cs.order_id ,
	cs.dias_ate_entrega ,
	cs.status_pedido 
FROM classificacao cs;



Parte B: mostre o percentual de pedidos atrasados por transportadora.


WITH pedidos_datas AS (
SELECT
	o.order_id ,
	o.ship_via ,
	o.shipped_date ,
	o.shipped_date - o.order_date AS Dias_ate_entrega,
	o.required_date - o.shipped_date AS Dias_adiantado
FROM orders o 
), classificacao AS (
SELECT
	pd.*,
	CASE
		WHEN pd.dias_adiantado >=0 THEN 'No Prazo'
		WHEN pd.shipped_date IS NULL THEN 'Não Enviado'
	ELSE 'Atrasado'
	END AS Status_Pedido
FROM pedidos_datas pd
),atrasados_por_transportadora AS (
SELECT
	s.company_name,
	COUNT(*) AS Qtd_pedidos,
	SUM(CASE WHEN cs.Status_Pedido = 'Atrasado' THEN 1 ELSE 0 END) AS qtd_atrasados
	FROM classificacao cs
INNER JOIN shippers s 
	ON s.shipper_id = cs.ship_via 
GROUP BY cs.ship_via,s.company_name
)
SELECT
	ats.*,
	ROUND((ats.qtd_atrasados::numeric /ats.qtd_pedidos ) *100::numeric,2) AS Percentual_atrasado
FROM atrasados_por_transportadora ats;

--Tambem estou contando pedidos não enviados

3. Funcionários. Para cada funcionário, mostre:
O nome completo em maiúsculas
A idade na data de contratação, em anos completos
O tempo de casa em anos e meses, usando como referência a data do último pedido do banco
Colunas: birth_date e hire_date, em employees.


SELECT
	UPPER(CONCAT(e.first_name , ' ' ,e.last_name ))AS NOME_COMPLETO,
	EXTRACT(YEAR FROM AGE(e.hire_date,e.birth_date))AS IDADE_NA_CONTRATACAO,
	TO_CHAR(AGE((SELECT MAX(o.order_date) FROM orders o),e.hire_date),'YY" anos e "MM" meses"') AS TEMPO_DE_CASA
FROM employees e ;


