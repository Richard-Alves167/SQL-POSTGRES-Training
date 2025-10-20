create table cupons (codigo text primary key, percentual numeric(5,2) check (percentual between 0 and 100), comercio(# expira_em date);

insert into cupons (codigo, percentual, expira_em) values ('1', 55, '2025-10-10');
insert into cupons (codigo, percentual, expira_em) values ('2', 75, '2025-11-04');
insert into cupons (codigo, percentual, expira_em) values ('3', 75, '2025-09-21');

-- Utilizar o tipo NUMERIC ao invés do REAL, acaba sendo melhor pois para dados mais precisos, o tipo NUMERIC é melhor do que o REAL que pode haver algumas variações em cálculos.

create table produtos (id int primary key generated always as identity, nome text, preco float check (preco > 0), categoria text, estoque int check(estoque > 0) default 0);

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

create table pedidos (id int primary key generated always as identity, cliente text, valor float check(valor >= 0), criado_em date);

INSERT INTO pedidos (cliente, valor, criado_em) VALUES ('Alice', 250.00, '2025-01-05'), ('Bruno', 120.00, '2025-01-12'), ('Carla', 800.00, '2025-02-03'), ('Alice', 150.00, '2025-02-15'), ('Daniel', 75.00, '2025-03-01'), ('Carla', 600.00, '2025-03-10'), ('Bruno', 90.00, '2025-03-22'), ('Eduarda', 1350.00, '2025-04-05'), ('Alice', 300.00, '2025-04-18'), ('Daniel', 220.00, '2025-05-01');

insert into pedidos (cliente, valor, criado_em) values ('Richard',199.99,'2024-07-12');
insert into pedidos (cliente, valor, criado_em) values ('Juan',109.99,'2022-12-28');
insert into pedidos (cliente, valor, criado_em) values ('Taylan',489.99,'2023-02-20');
insert into pedidos (cliente, valor, criado_em) values ('Sofia',489.99,'2024-06-10');
insert into pedidos (cliente, valor, criado_em) values ('Juliana',489.99,'2025-03-07');

alter table pedidos add column cupom_pedido text;

