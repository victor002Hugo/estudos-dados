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
		WHEN pd.shipped_date IS NULL THEN 'Não Enviado'
		WHEN pd.dias_adiantado >=0 THEN 'No Prazo'
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


4. Gerar e-mails. Para cada cliente, gere um e-mail fictício para o contato (contact_name) no formato primeironome.ultimonome@nomedaempresa.com, tudo em minúsculas, sem espaços e sem pontuação no nome da empresa.


WITH nomes_tratados AS (
SELECT
	c.customer_id ,
	c.contact_name ,
	UNACCENT(SPLIT_PART(c.contact_name ,' ',1)) AS Primeiro_nome,
	UNACCENT(SPLIT_PART(c.contact_name ,' ',-1)) AS Ultimo_nome,
	UNACCENT((c.company_name))AS Nome_empresa
	FROM customers c 
),sem_caracteres_especiais AS(
SELECT
	nm.customer_id ,
	nm.contact_name ,
	(REGEXP_REPLACE(nm.primeiro_nome,'[^a-zA-Z0-9]', '', 'g')) AS Primeiro_nome,
	(REGEXP_REPLACE(nm.ultimo_nome ,'[^a-zA-Z0-9]', '', 'g')) AS Ultimo_nome,
	(REGEXP_REPLACE(nm.nome_empresa,'[^a-zA-Z0-9]', '', 'g')) AS Nome_empresa
FROM nomes_tratados  nm
)
SELECT
	sp.customer_id ,
	sp.contact_name ,
	LOWER(sp.primeiro_nome ||'.'||sp.ultimo_nome ||'@'||sp.nome_empresa ||'.com')AS email
FROM sem_caracteres_especiais sp;

--Na verdade todos ficaram no padrão, a unica coisa estranha é que alguns nomes de empresas são muito grandes

5. Limpeza de telefones.

Parte A: para cada cliente, mostre o país, o telefone original, o telefone só com dígitos e a quantidade de dígitos.
Parte B: mostre quantos clientes há para cada quantidade de dígitos.

Num comentário: o que isso revela sobre a padronização dos dados? Pense no que seria necessário para usar esses telefones numa integração, por exemplo, para enviar mensagens por WhatsApp.



Parte A: para cada cliente, mostre o país, o telefone original, o telefone só com dígitos e a quantidade de dígitos.


WITH telefones_tratados_por_pais AS (
SELECT
	c.customer_id ,
	c.country ,
	c.phone ,
	REGEXP_REPLACE(c.phone ,'[^0-9]', '', 'g') AS Numero_tratado,
	LENGTH(REGEXP_REPLACE(c.phone ,'[^0-9]', '', 'g'))AS Qtd_numeros
FROM customers c 
)
SELECT
	tl.customer_id ,
	tl.country ,
	tl.phone ,
	tl.numero_tratado ,
	tl.qtd_numeros 
FROM telefones_tratados_por_pais tl;






Parte B: mostre quantos clientes há para cada quantidade de dígitos.


WITH telefones_tratados_por_pais AS (
SELECT
	c.country ,
	c.phone ,
	REGEXP_REPLACE(c.phone ,'[^0-9]', '', 'g') AS Numero_tratado,
	LENGTH(REGEXP_REPLACE(c.phone ,'[^0-9]', '', 'g'))AS Qtd_numeros
FROM customers c 
)
SELECT
	tl.qtd_numeros ,
	COUNT(*)AS Qtd_clientes
FROM telefones_tratados_por_pais tl
GROUP BY tl.qtd_numeros 
ORDER BY tl.qtd_numeros  DESC;

--Revela o grau de importancia para a padronização dos dados, a base "crua" tem dados totalmente despadronizados, tornando praticamente impossivel sua utilização em uma integração que precisa de dados formatados em um formato adequado.
--Isso revela como a camada bronze pode não estar preparada para consumo interno ou até mesmo em uma IA.
