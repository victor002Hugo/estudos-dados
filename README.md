# estudos-dados
## 15/10/2026 — Semana 0
- **Estudei:** instalação do PostgreSQL, DBeaver, Git e carga do Northwind
- **Travou:** Não consegui colocar o dbeaver para manter palavras reservadas em maiusculo
- **Amanhã:** terminar o que faltou da Semana 0

## 16/10/2026 — Semana 0
- **Estudei:** grão das tabelas -> 
customers: Representa os clientes do banco de dados, empresas no caso
orders: Representa os pedidos ou compras
order_details: Representa os detalhes de cada item de cada pedido
products: Representa os produtos
categories: Categorias de produtos
employees: Informações relacionadas aos funcionarios

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