SELECT * FROM clientes_crm cc ;



1. Perfil da tabela. Monte uma consulta (no estilo do pandas) mostrando, para as colunas email, telefone, status e data_cadastro: a quantidade de NULLs reais, a quantidade de nulos disfarçados (vazios, só espaços ou N/A) e a quantidade de valores distintos. Pode ser uma linha por coluna (com UNION ALL) ou uma linha só com várias colunas.


SELECT
	COUNT(*) FILTER(WHERE cc.email IS NULL) AS email_null,
	COUNT(*) FILTER(WHERE TRIM(cc.email) = '') AS email_disfarcado,
	COUNT(DISTINCT cc.email) AS email_unicos,
	COUNT(*) FILTER(WHERE cc.telefone IS NULL) AS telefone_null,
	COUNT(*) FILTER(WHERE TRIM(cc.telefone) IN('','N/A','0000000000')) AS telefone_disfarcado,
	COUNT(DISTINCT cc.telefone) AS telefones_unicos,
	COUNT(*) FILTER(WHERE cc.status IS NULL) AS status_null,
	COUNT(*) FILTER(WHERE TRIM(LOWER(cc.status)) IN ('')) AS status_disfarcado,
	COUNT(DISTINCT cc.status) AS status_unicos,
	COUNT(*) FILTER(WHERE cc.data_cadastro IS NULL) AS data_cadastro_null,
	COUNT(*) FILTER(WHERE TRIM(cc.data_cadastro) IN ('')) AS data_cadastro_disfarcado,
	COUNT(DISTINCT cc.data_cadastro) AS data_cadastros_unicos
FROM clientes_crm cc ;


2. Padronização. Numa consulta, mostre cada registro com as colunas padronizadas:

nome: sem espaços nas pontas e com iniciais maiúsculas
email: minúsculas, sem espaços, vazio vira NULL
telefone: só dígitos, e N/A, vazios e 0000000000 viram NULL
cidade: sem espaços nas pontas, sem acento e com iniciais maiúsculas
status: minúsculas, sem espaços, vazio vira NULL


SELECT
	INITCAP(TRIM(cc.nome )) AS NOME,
	NULLIF(TRIM(LOWER(cc.email )),'') AS EMAIL,
	CASE
    WHEN REGEXP_REPLACE(cc.telefone, '[^0-9]', '', 'g') IN ('', '0000000000') THEN NULL
    ELSE REGEXP_REPLACE(cc.telefone, '[^0-9]', '', 'g')
END AS TELEFONE,
	INITCAP(TRIM(UNACCENT(cc.cidade)))AS CIDADE,
	NULLIF(TRIM(LOWER(cc.status )),'')AS STATUS
FROM clientes_crm cc ;


3. Encontrar duplicados.

Parte A: encontre as duplicidades exatas
Parte B: encontre os e-mails duplicados depois de padronizados. Compare com o resultado de agrupar pelo e-mail original: quantos duplicados a mais você encontrou?

--PARTE A
SELECT
	cc.nome,
	cc.email ,
	cc.telefone ,
	cc.cidade ,
	cc.status ,
	cc.data_cadastro ,
	cc.atualizado_em ,
	COUNT(*) AS DUPLICADOS
FROM clientes_crm cc 
GROUP BY cc.nome,cc.email ,cc.telefone ,cc.cidade ,cc.status ,cc.data_cadastro ,cc.atualizado_em 
HAVING COUNT(*) >1;

--PARTE B 
--Consulta 1
SELECT
	TRIM(LOWER(cc.email )) AS Email_Padronizado,
	COUNT(*) AS DUPLICADOS
FROM clientes_crm cc 
GROUP BY TRIM(LOWER(cc.email ))
ORDER BY DUPLICADOS DESC;

--Consulta 2
SELECT
	cc.email,
	COUNT(*) AS DUPLICADOS
FROM clientes_crm cc 
GROUP BY cc.email
ORDER BY DUPLICADOS DESC;


--Apos padronização apareceram mais duplicadas, 2 casos a mais




4. Deduplicação. Mantenha só o registro mais recente de cada e-mail.
Atenção a uma armadilha: os registros sem e-mail (NULL) também formam um grupo no PARTITION BY. Pense no que aconteceria com eles e como resolver para não perder clientes que simplesmente não têm e-mail.


SELECT * FROM clientes_crm cc ;

WITH email_padronizado AS (
SELECT
	cc.id,
	NULLIF(TRIM(LOWER(cc.email )),'') AS email_padronizado,
	cc.atualizado_em 
FROM clientes_crm cc 
),ordenado AS (
SELECT
	em.email_padronizado,
	ROW_NUMBER() OVER (
    PARTITION BY COALESCE(em.email_padronizado, 'sem_email_' || em.id::text)
    ORDER BY em.atualizado_em DESC
) AS ordem
FROM email_padronizado em
)
SELECT
	ord.email_padronizado 
FROM ordenado ord
WHERE ord.ordem = 1;


5. Datas. Converta a data_cadastro para o tipo DATE, tratando os três formatos que aparecem na tabela. Vazios e NULLs devem virar NULL.
Antes de escrever, olhe os valores da coluna e identifique os formatos. Use o operador ~ com uma expressão regular para reconhecer cada um, como na seção 5 da aula.

SELECT
	cc.data_cadastro ,
	CASE
		WHEN cc.data_cadastro ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN TO_DATE(cc.data_cadastro, 'YYYY-MM-DD')
		WHEN cc.data_cadastro ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN TO_DATE(cc.data_cadastro, 'DD/MM/YYYY')
		WHEN cc.data_cadastro ~ '^[0-9]{4}/[0-9]{2}/[0-9]{2}$' THEN TO_DATE(cc.data_cadastro, 'YYYY/MM/DD')
		ELSE NULL
	END AS data_cadastro2
FROM clientes_crm cc ;



6. Desafio: a camada silver. Junte tudo numa única consulta com CTEs e grave como clientes_crm_silver com CREATE TABLE AS:

Colunas padronizadas (exercício 2)
Data convertida (exercício 5)
Sem duplicados (exercício 4)
Sem o registro de teste

Sanity checks, anotados num comentário:

Quantos registros a tabela final deve ter? Calcule antes de rodar e confira
Nenhum e-mail repetido na tabela final
Nenhum texto vazio nas colunas tratadas

WITH colunas_tratadas AS (
SELECT
	cc.id,
	INITCAP(TRIM(cc.nome )) AS NOME,
	NULLIF(TRIM(LOWER(cc.email )),'') AS EMAIL,
	CASE
    WHEN REGEXP_REPLACE(cc.telefone, '[^0-9]', '', 'g') IN ('', '0000000000') THEN NULL
    ELSE REGEXP_REPLACE(cc.telefone, '[^0-9]', '', 'g')
END AS TELEFONE,
	INITCAP(TRIM(UNACCENT(cc.cidade)))AS CIDADE,
	NULLIF(TRIM(LOWER(cc.status )),'')AS STATUS,
	cc.data_cadastro ,
	cc.atualizado_em 
FROM clientes_crm cc
),data_tratada AS(
SELECT
	cr.*,
	CASE
		WHEN cr.data_cadastro ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN TO_DATE(cr.data_cadastro, 'YYYY-MM-DD')
		WHEN cr.data_cadastro ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN TO_DATE(cr.data_cadastro, 'DD/MM/YYYY')
		WHEN cr.data_cadastro ~ '^[0-9]{4}/[0-9]{2}/[0-9]{2}$' THEN TO_DATE(cr.data_cadastro, 'YYYY/MM/DD')
		ELSE NULL
	END AS data_cadastro_dt
FROM colunas_tratadas cr
),sem_deduplicados AS(
SELECT
	dt.*,
	ROW_NUMBER() OVER (
    PARTITION BY COALESCE(dt.email , 'sem_email_' || dt.id::text)
    ORDER BY dt.atualizado_em  DESC
) AS ordem
FROM data_tratada dt
)
SELECT
	sc.id ,
	sc.nome ,
	sc.email ,
	sc.telefone ,
	sc.cidade ,
	sc.status ,
	sc.data_cadastro_dt 
FROM sem_deduplicados sc
WHERE sc.ordem =1 AND sc.status IS DISTINCT FROM 'teste'
ORDER BY sc.id ASC;

--A TABELA FINAL DEVE CONTER 10 REGISTROS
--PESSOAS SEM E-MAIL ESTÃO COM O CAMPO NULL
--NÃO EXISTE TEXTO VAZIO NAS COLUNAS TRATADAS

CREATE TABLE  clientes_crm_silver AS(
WITH colunas_tratadas AS (
SELECT
	cc.id,
	INITCAP(TRIM(cc.nome )) AS NOME,
	NULLIF(TRIM(LOWER(cc.email )),'') AS EMAIL,
	CASE
    WHEN REGEXP_REPLACE(cc.telefone, '[^0-9]', '', 'g') IN ('', '0000000000') THEN NULL
    ELSE REGEXP_REPLACE(cc.telefone, '[^0-9]', '', 'g')
END AS TELEFONE,
	INITCAP(TRIM(UNACCENT(cc.cidade)))AS CIDADE,
	NULLIF(TRIM(LOWER(cc.status )),'')AS STATUS,
	cc.data_cadastro ,
	cc.atualizado_em 
FROM clientes_crm cc
),data_tratada AS(
SELECT
	cr.*,
	CASE
		WHEN cr.data_cadastro ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN TO_DATE(cr.data_cadastro, 'YYYY-MM-DD')
		WHEN cr.data_cadastro ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN TO_DATE(cr.data_cadastro, 'DD/MM/YYYY')
		WHEN cr.data_cadastro ~ '^[0-9]{4}/[0-9]{2}/[0-9]{2}$' THEN TO_DATE(cr.data_cadastro, 'YYYY/MM/DD')
		ELSE NULL
	END AS data_cadastro_dt
FROM colunas_tratadas cr
),sem_deduplicados AS(
SELECT
	dt.*,
	ROW_NUMBER() OVER (
    PARTITION BY COALESCE(dt.email , 'sem_email_' || dt.id::text)
    ORDER BY dt.atualizado_em  DESC
) AS ordem
FROM data_tratada dt
)
SELECT
	sc.id ,
	sc.nome ,
	sc.email ,
	sc.telefone ,
	sc.cidade ,
	sc.status ,
	sc.data_cadastro_dt 
FROM sem_deduplicados sc
WHERE sc.ordem =1 AND sc.status IS DISTINCT FROM 'teste'
ORDER BY sc.id ASC
);



SELECT * FROM clientes_crm_silver;
