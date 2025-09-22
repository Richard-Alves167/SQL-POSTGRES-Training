create database revisao;
\c revisao;
create table produtos (id int primary key generated always as identity, nome text, preco float check (preco > 0), categoria text, estoque int check(estoque > 0) default 0);

alter table produtos alter column estoque set default 0;

alter table produtos add constraint categoria check(categoria in('Eletronicos','Livros','Alimentos'));

INSERT INTO produtos (nome, preco, categoria, estoque) VALUES
('Fone Bluetooth', 199.90, 'Eletronicos', 5),
('Notebook Slim 14"', 3499.00, 'Eletronicos', 2),
('Livro: SQL do Zero', 89.90, 'Livros', 10),
('Café Especial 500g', 34.50, 'Alimentos', 20),
('Chocolate Amargo 70%', 12.90, 'Alimentos', 50),
('Cadeira Gamer', 999.00, 'Eletronicos', 3),
('Livro: Estruturas de Dados', 120.00, 'Livros', 8),
('Azeite Extra Virgem 500ml', 39.90, 'Alimentos', 15);

insert into produtos (nome, preco, categoria, estoque) values ('Televisao', 1299.99, 'Eletronicos', 25);
insert into produtos (nome, preco, categoria, estoque) values ('Mouse', 199.99, 'Eletronicos', 56);
insert into produtos (nome, preco, categoria, estoque) values ('Harry Potter', 59.99,'Livros',23);
insert into produtos (nome, preco, categoria) values ('Pitaya', 19.99,'Alimentos');
insert into produtos (nome, preco, categoria) values ('Uva', 19.99,'Alimentos');

delete from produtos where id = 11;

select * from produtos where preco > 50 and preco < 200;

select * from produtos where categoria in ('Eletronicos','Livros');

select * from produtos where not estoque = 0;

select * from produtos where not nome ilike '%a%';

create table pedidos (id int primary key generated always as identity, cliente text, valor float check(valor >= 0), criado_em date);

INSERT INTO pedidos (cliente, valor, criado_em) VALUES ('Alice', 250.00, '2025-01-05'), ('Bruno', 120.00, '2025-01-12'), ('Carla', 800.00, '2025-02-03'), ('Alice', 150.00, '2025-02-15'), ('Daniel', 75.00, '2025-03-01'), ('Carla', 600.00, '2025-03-10'), ('Bruno', 90.00, '2025-03-22'), ('Eduarda', 1350.00, '2025-04-05'), ('Alice', 300.00, '2025-04-18'), ('Daniel', 220.00, '2025-05-01');

insert into pedidos (cliente, valor, criado_em) values ('Richard',199.99,'2024-07-12');
insert into pedidos (cliente, valor, criado_em) values ('Juan',109.99,'2022-12-28');
insert into pedidos (cliente, valor, criado_em) values ('Taylan',489.99,'2023-02-20');
insert into pedidos (cliente, valor, criado_em) values ('Sofia',489.99,'2024-06-10');
insert into pedidos (cliente, valor, criado_em) values ('Juliana',489.99,'2025-03-07');

select * from pedidos where criado_em > '2025-01-01';

select * from pedidos where extract(month from criado_em) = 2;

-- # questao 15
select cliente, sum(valor) as valor_total_gasto from pedidos group by cliente;

select extract(month from criado_em) as mes, round(avg(valor)) from pedidos group by mes order by mes;

select cliente, sum(valor) as total_gasto from pedidos group by cliente having sum(valor) > 500;

select extract(month from criado_em) as mes, count(*) as quantidade_de_pedidos from pedidos group by mes order by mes;

select cliente, max(valor) as maior_pedido, min(valor) as menor_pedido from pedidos group by cliente order by cliente;

with cliente_e_valor_total as (select cliente, sum(valor) as valor_total from pedidos group by cliente) select * from cliente_e_valor_total where valor_total > 1000;

with classificacao_pedidos as (select cliente, valor, criado_em, case when valor>=100 then 'caro' when valor<100 then 'barato' end as classificacao from pedidos) select classificacao, count(*) as quantidade from classificacao_pedidos group by classificacao;

with ranking_pedidos as (select row_number() over (order by criado_em) as ranking, cliente, valor, criado_em from pedidos) select * from ranking_pedidos;

-- questões 6 UNION (a terminar)

create view resumo_clientes as select cliente, sum(valor) as valor_total, count(*) as quantidade_pedidos from pedidos group by cliente;

create materialized view resumo_mensal as select extract(month from criado_em) as mes, count(*) as quantidade_pedidos from pedidos group by mes order by mes;

insert into pedidos (cliente, valor, criado_em) values ('Kaio', 299.99,'2025-03-18');
select * from resumo_mensal;
refresh materialized view resumo_mensal;
select * from resumo_mensal;

select * from resumo_clientes where valor_total > 1000;