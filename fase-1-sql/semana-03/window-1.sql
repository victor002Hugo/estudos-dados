1. Para cada produto, mostre nome, categoria (o nome), preço, o preço médio da categoria e a diferença entre os dois. Use window function.





WITH media_categoria AS(
SELECT
	p.product_name ,
	p.category_id ,
	p.unit_price ,
	AVG(p.unit_price) OVER(PARTITION BY p.category_id )AS Media_categoria
FROM products p 
)
SELECT
	md.product_name ,
	c.category_name ,
	ROUND((md.unit_price)::numeric,2)AS Preco_produto ,
	ROUND((md.media_categoria)::numeric,2) AS Media_categoria,
	ROUND((md.unit_price - md.media_categoria)::numeric,2) AS Diferenca
FROM media_categoria md
INNER JOIN categories c 
	ON c.category_id = md.category_id 
ORDER BY diferenca DESC;