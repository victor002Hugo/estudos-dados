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














