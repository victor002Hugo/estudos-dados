# Diario de Estudos
## 15/10/2026 — Semana 0
- **Estudei:** instalação do PostgreSQL, DBeaver, Git e carga do Northwind
- **Travou:** Não consegui colocar o dbeaver para manter palavras reservadas em maiusculo
- **Amanhã:** terminar o que faltou da Semana 0

## 16/10/2026 — Semana 0
- **Estudei:** grão das tabelas -> 
customers: Uma linha por cliente, sua chave é o customer_id
orders: Uma linha por compra, sua chave é o order_id
order_details: Uma linha para cada produto de cada pedido, sua chave é order_id + product_id
products: Uma linha por produto, sua chave é product_id
categories: Uma linha por categoria que se relaciona com produto, sua chave é category_id
employees: Uma linha por funcionario, sua chave é employee_id

Aprendi sobre ligações, um pouco sobre subquery
Descobri que posso e devo utilizar filtros no ON das ligações, para não perder os dados no where, e que para cada relatorio e pergunta existe uma forma para resolução

- **Travou:** Travei nas subquery, travei no filtro no ON, no exists tambem pois esqueci de colocar no where a comparação para a filtragem da tabela externa
- **Amanhã:** Revisão da semana com aprendizado e alguns exercicios, visando que comecei no final da semana

## 17/10/2026 — Semana 0
- **Perguntas:** a-> O grão de uma tabela é o que cada linha dela representa no mundo real, falando especificamente da tabela order_details , cada linha desta tabela tende a representar detalhes de itens de orders, ou seja cada linha deve representar um produto de uma ordem, mostrando detalhes sobre o mesmo.
                b-> O count(*) conta linhas que estão como null tambem, sendo assim a depender do objetivo da consulta, ele pode trazer informações inexistentes.
                c-> Em um left join, se o filtro for para o where ele se torna um inner join, se o intuito é filtrar o produto final pós inclusão da tabela do left, o filtro deve estar no where, mas... se o intuito é levar uma base ja filtrada para depois efetuar o relacionamento no left, o filtro deverá ser feito no ON. Exemplo.. Quero saber todas as vendas do ano de 1998, todas as empresas inclusive as que não venderam. Para isso você precisa levar o filtro de data para pegar o ano de 1998 no ON, pois se incluir no where ele vai remover as empresas que tiveram 0;
                d-> Fan-out geralmente acontece quando se faz uma relação de 1 para muitos, para evitar é necessario entender o dado da tabela e da consulta e ja levar o mesmo agregado, com uma coluna calculada, por exemplo.. antes da ligação com outras tabelas.
                e-> O resultado será verdadeiro e não irá filtrar nada, pois o where serve como criteiro para dizer se o primeiro registro existe ou não na consulta do exists. 
                 - **Correção:** sem a ligação, o EXISTS dá o mesmo resultado para todas as linhas: traz todos os registros se a subquery encontrar algo no banco, ou nenhum se não encontrar. A ligação faz a subquery ser avaliada para cada linha da consulta de fora.
- **Travou:** Apenas alguns ajustes referentes as aulas da semana, mas sem travas
- **Amanhã:** Iniciar com subquery nos 3 lugares, from , where e exists 

## 18/10/2026 — Semana 1
- **Estudei:** Subqueries em join, where, from e etc
- **Travou:** Em um distinct que deveria ter colocado dentro do COUNT ao inves de colocar fora

## 20/10/2026 — Semana 2
- **Estudei:** Cte's
- **Travou:** Em entendimento de herança de informações em Cte's encadeadas

## 21/10/2026 — Semana 2
- **Estudei:** Reforço de CTE's
- **Travou:** Esqueci de levar parametros de algumas CTE's em diante

## 22/10/2026 — Semana 3
- **Estudei:** Aprendendo Window functions
- **Travou:** 

## 23/10/2026 — Semana 3
- **Estudei:** Aprendendo Window functions, usando RANK, ROW_NUMBER e aprendendo a utilizar SUM() OVER() para somar tudo.
- **Travou:**  Fiz um join errado inflanto um resultado, multiplicando ele algumas centenas de vezes.

## 24/10/2026 — Semana 3
- **Estudei:** Aprendendo a utilizar o DATE_TRUNC e o LAG
- **Travou:**  Filtrei na CTE ao inves de filtrar na coluna final

## 27/10/2026 — Semana 3
- **Estudei:** Refiz alguns exercicios de window function
- **Travou:**  Na media movel, no que passar no lag e no order by do mês