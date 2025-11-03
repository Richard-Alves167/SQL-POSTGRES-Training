create schema ComercialNovaEra;

CREATE TABLE ComercialNovaEra.lojas (
                       id SERIAL PRIMARY KEY,
                       nome TEXT NOT NULL,
                       cidade TEXT NOT NULL,
                       estado TEXT NOT NULL
);

CREATE TABLE ComercialNovaEra.vendedores (
                            id SERIAL PRIMARY KEY,
                            nome TEXT NOT NULL,
                            loja_id INT NOT NULL REFERENCES ComercialNovaEra.lojas(id)
);

CREATE TABLE ComercialNovaEra.produtos (
                          id SERIAL PRIMARY KEY,
                          nome TEXT NOT NULL,
                          categoria TEXT NOT NULL,
                          preco NUMERIC(10,2) NOT NULL
);

CREATE TABLE ComercialNovaEra.vendas (
                        id SERIAL PRIMARY KEY,
                        vendedor_id INT NOT NULL REFERENCES ComercialNovaEra.vendedores(id),
                        produto_id INT NOT NULL REFERENCES ComercialNovaEra.produtos(id),
                        data_venda DATE NOT NULL,
                        quantidade INT NOT NULL CHECK (quantidade > 0)
);

INSERT INTO ComercialNovaEra.lojas (nome, cidade, estado) VALUES
                                             ('Nova Era Centro', 'Rio de Janeiro', 'RJ'),
                                             ('Nova Era Norte', 'Niterói', 'RJ'),
                                             ('Nova Era Paulista', 'São Paulo', 'SP'),
                                             ('Nova Era Pampulha', 'Belo Horizonte', 'MG');

INSERT INTO ComercialNovaEra.vendedores (nome, loja_id) VALUES
                                           ('Ana Souza', 1),
                                           ('Bruno Martins', 1),
                                           ('Carlos Lima', 2),
                                           ('Daniela Rocha', 3),
                                           ('Eduardo Farias', 3),
                                           ('Fernanda Alves', 4);

INSERT INTO ComercialNovaEra.produtos (nome, categoria, preco) VALUES
                                                  ('Notebook Atlas 14"', 'Informática', 4500.00),
                                                  ('Mouse Óptico Pro', 'Informática', 80.00),
                                                  ('Cadeira Gamer Storm', 'Móveis', 1299.90),
                                                  ('Smartphone Zeta X', 'Telefonia', 2999.99),
                                                  ('Fone Bluetooth Wave', 'Telefonia', 199.90),
                                                  ('Mesa Escritório Compact', 'Móveis', 650.00);

INSERT INTO ComercialNovaEra.vendas (vendedor_id, produto_id, data_venda, quantidade) VALUES
                                                                         (1, 1, '2025-01-05', 2),
                                                                         (1, 2, '2025-01-05', 5),
                                                                         (2, 4, '2025-01-06', 1),
                                                                         (2, 5, '2025-01-06', 3),
                                                                         (3, 2, '2025-01-07', 4),
                                                                         (3, 6, '2025-01-08', 1),
                                                                         (4, 1, '2025-01-09', 1),
                                                                         (4, 3, '2025-01-09', 2),
                                                                         (5, 4, '2025-01-10', 2),
                                                                         (5, 5, '2025-01-11', 4),
                                                                         (6, 3, '2025-01-12', 1),
                                                                         (6, 6, '2025-01-12', 2);

INSERT INTO ComercialNovaEra.produtos (nome, categoria, preco) VALUES
    ('Webcam Crystal HD', 'Informática', 320.00);

INSERT INTO ComercialNovaEra.vendedores (nome, loja_id) VALUES
    ('Gustavo Nogueira', 2);

select l.nome as loja, l.cidade as cidade, v.nome as vendedor from ComercialNovaEra.vendedores v
    inner join ComercialNovaEra.lojas l on v.loja_id = l.id;

select vd.id as venda_id, p.nome as produto, vddr.nome as vendedor, p.categoria as categoria, l.nome as loja, l.cidade as cidade from ComercialNovaEra.vendas vd
    inner join ComercialNovaEra.produtos p on vd.produto_id = p.id
    inner join ComercialNovaEra.vendedores vddr on vd.vendedor_id = vddr.id
    inner join ComercialNovaEra.lojas l on vddr.loja_id = l.id where p.categoria like('Telefonia');

select vd.id as venda_id, p.nome as produto, p.preco as preco_produto, vd.quantidade from ComercialNovaEra.vendas vd
    inner join ComercialNovaEra.produtos p on vd.produto_id = p.id;

select vddr.id as vendedor_id, vddr.nome as vendedor, count(vd.vendedor_id) as quantidade_vendas from ComercialNovaEra.vendedores vddr
    left join comercialnovaera.vendas vd on vddr.id = vd.vendedor_id group by vddr.id;

select l.nome as loja, string_agg(distinct p.nome, ',') as produtos_vendidos , string_agg(distinct p.categoria, ', ') as categorias_vendidas from ComercialNovaEra.lojas l
    inner join ComercialNovaEra.vendedores vddr on l.id = vddr.loja_id
    inner join ComercialNovaEra.vendas vd on vddr.id = vd.vendedor_id
    inner join ComercialNovaEra.produtos p on vd.produto_id = p.id group by l.id;

select p.id, p.nome as produto, coalesce(string_agg(l.cidade, ','),'Nenhuma cidade') as cidade
    from ComercialNovaEra.produtos p
    left join ComercialNovaEra.vendas vd on p.id = vd.produto_id
    left join ComercialNovaEra.vendedores vddr on vd.vendedor_id = vddr.id
    left join ComercialNovaEra.lojas l on vddr.loja_id = l.id where p.categoria like('Móveis') group by p.id;

select vddr.nome as vendedor, p.nome as produto, vd.data_venda as data_venda, l.estado as loja_estado from ComercialNovaEra.vendas vd
    inner join ComercialNovaEra.produtos p on vd.produto_id = p.id
    inner join ComercialNovaEra.vendedores vddr on vd.vendedor_id = vddr.id
    inner join ComercialNovaEra.lojas l on vddr.loja_id = l.id where p.categoria like('Móveis');

select vddr.nome as vendedor, p.nome as produto, p.preco as preco, l.nome as loja from ComercialNovaEra.vendas vd
    inner join ComercialNovaEra.vendedores vddr on vd.vendedor_id = vddr.id
    inner join ComercialNovaEra.lojas l on vddr.loja_id = l.id
    inner join ComercialNovaEra.produtos p on vd.produto_id = p.id where p.preco > 3000;

select l.nome as loja, string_agg(v.nome, ',') as vendedores from ComercialNovaEra.vendedores v
    inner join ComercialNovaEra.lojas l on v.loja_id = l.id group by l.id having count(*) = 2;

create view cidades_vendeu_telefonia as (select l.cidade as cidade, case when p.categoria like('Telefonia') then 1 when p.categoria not like('Telefonia') then 0 end as vendeu_telefonia from ComercialNovaEra.vendas vd
    left join ComercialNovaEra.vendedores vddr on vd.vendedor_id = vddr.id
    left join ComercialNovaEra.lojas l on vddr.loja_id = l.id
    left join ComercialNovaEra.produtos p on vd.produto_id = p.id);

select cidade, sum(vendeu_telefonia) quantidade_telefonia_vendida from cidades_vendeu_telefonia group by cidade;

create schema CinePlus;

CREATE TABLE CinePlus.planos (
                                 id SERIAL PRIMARY KEY,
                                 tipo TEXT NOT NULL,
                                 valor_mensal NUMERIC(10,2) NOT NULL
);

CREATE TABLE CinePlus.usuarios (
                                   id SERIAL PRIMARY KEY,
                                   nome TEXT NOT NULL,
                                   cidade TEXT NOT NULL,
                                   plano_id INT REFERENCES CinePlus.planos(id)
);

CREATE TABLE CinePlus.filmes (
                                 id SERIAL PRIMARY KEY,
                                 titulo TEXT NOT NULL,
                                 genero TEXT NOT NULL,
                                 ano INT NOT NULL
);

CREATE TABLE CinePlus.assistidos (
                                     usuario_id INT REFERENCES CinePlus.usuarios(id),
                                     filme_id INT REFERENCES CinePlus.filmes(id),
                                     data_assistido DATE NOT NULL,
                                     avaliacao INT CHECK (avaliacao BETWEEN 1 AND 5),
                                     PRIMARY KEY (usuario_id, filme_id, data_assistido)
);

CREATE TABLE CinePlus.pagamentos (
                                     id SERIAL PRIMARY KEY,
                                     usuario_id INT REFERENCES CinePlus.usuarios(id),
                                     plano_id INT REFERENCES CinePlus.planos(id),
                                     data_pagamento DATE NOT NULL
);

INSERT INTO CinePlus.planos (tipo, valor_mensal) VALUES
                                                     ('Básico',   24.90),
                                                     ('Padrão',   39.90),
                                                     ('Premium',  59.90);

INSERT INTO CinePlus.usuarios (nome, cidade, plano_id) VALUES
                                                           ('Alice Moraes', 'Rio de Janeiro', 3),
                                                           ('Bruno Castro', 'São Paulo', 2),
                                                           ('Carla Nunes', 'Niterói', 1),
                                                           ('Diego Freitas', 'São Paulo', 3),
                                                           ('Elisa Prado', 'Belo Horizonte', 2),
                                                           ('Fernando Alves', 'Curitiba', NULL);

INSERT INTO CinePlus.filmes (titulo, genero, ano) VALUES
                                                      ('Noite Sem Fim', 'Ação', 2023),
                                                      ('Corações de Ferro', 'Drama', 2022),
                                                      ('Rastros da Neblina', 'Suspense', 2024),
                                                      ('Amor em São Paulo', 'Romance', 2021),
                                                      ('Circuito Clandestino', 'Ação', 2024),
                                                      ('Histórias do Subsolo', 'Documentário', 2020);

INSERT INTO CinePlus.assistidos (usuario_id, filme_id, data_assistido, avaliacao) VALUES
                                                                                      (1, 1, '2025-01-03', 4),
                                                                                      (1, 2, '2025-01-05', 5),
                                                                                      (1, 3, '2025-01-07', 3),
                                                                                      (2, 1, '2025-01-04', 5),
                                                                                      (2, 4, '2025-01-06', 2),
                                                                                      (3, 6, '2025-01-07', 4),
                                                                                      (3, 2, '2025-01-10', 3),
                                                                                      (4, 5, '2025-01-03', 5),
                                                                                      (4, 1, '2025-01-08', 4),
                                                                                      (5, 2, '2025-01-02', 4),
                                                                                      (5, 4, '2025-01-09', 5);

INSERT INTO CinePlus.pagamentos (usuario_id, plano_id, data_pagamento) VALUES
                                                                           (1, 3, '2025-01-01'),
                                                                           (2, 2, '2025-01-01'),
                                                                           (3, 1, '2025-01-01'),
                                                                           (4, 3, '2025-01-01'),
                                                                           (5, 2, '2025-01-01');

select u.id as id_usuario, u.nome as usuario, p.tipo as plano, u.cidade as cidade_usuario from CinePlus.usuarios u
    inner join CinePlus.planos p on u.plano_id = p.id;

--pensar melhor nessa questão 2
select u.nome as usuario, p.data_pagamento, count(a.filme_id) as quantidade_filmes_assistidos from CinePlus.usuarios u
    inner join CinePlus.pagamentos p on u.plano_id = p.id
    left join CinePlus.assistidos a on u.id = a.usuario_id
    left join CinePlus.filmes f on a.filme_id = f.id group by u.id, p.id;

select f.titulo as filme, f.genero as genero, coalesce(string_agg(u.nome,','),'Ninguém assistiu') as usuarios_assistiram from CinePlus.filmes f
    left join CinePlus.assistidos a on f.id = a.filme_id
    inner join CinePlus.usuarios u on a.usuario_id = u.id group by f.id;

select u.nome as usuario, f.titulo as filme, a.avaliacao as avaliacao from CinePlus.usuarios u
    inner join CinePlus.assistidos a on u.id = a.usuario_id
    inner join CinePlus.filmes f on a.filme_id = f.id where u.cidade like('São Paulo');

select u.nome as usuario, p.tipo as plano, f.titulo as filme from CinePlus.usuarios u
    inner join CinePlus.planos p on u.plano_id = p.id
    inner join CinePlus.assistidos a on u.id = a.usuario_id
    inner join CinePlus.filmes f on a.filme_id = f.id;

select f.titulo as filme, case count(a.filme_id) when 0 then 'Nenhuma Visualização' else 'Filme Visualizado' end as filme_vizualizado from CinePlus.filmes f
    left join CinePlus.assistidos a on f.id = a.filme_id group by f.titulo order by count(a.filme_id);

select u.nome as usuario, p.tipo as plano, f.titulo as filme, a.avaliacao as avaliacao from CinePlus.usuarios u
    inner join CinePlus.planos p on u.plano_id = p.id
    inner join CinePlus.assistidos a on u.id = a.usuario_id
    inner join CinePlus.filmes f on a.filme_id = f.id where p.tipo like('Premium');

select u.cidade as cidade, count(a.filme_id) as quantidade_assistido from CinePlus.usuarios u
    left join CinePlus.planos p on u.plano_id = p.id
    left join CinePlus.assistidos a on u.id = a.usuario_id
    left join CinePlus.filmes f on a.filme_id = f.id where f.genero like('Documentário') group by cidade;

select u.nome as usuario, coalesce(u.plano_id, 0) as plano, u.cidade as cidade from CinePlus.usuarios u
    left join CinePlus.pagamentos p on u.id = p.usuario_id where u.plano_id is null or p.id is null;

with usuario_filme as (select f.titulo, u.nome as usuario, row_number() over (partition by f.titulo) ordenacao_filme from CinePlus.usuarios u
    inner join CinePlus.assistidos a on u.id = a.usuario_id
    inner join CinePlus.filmes f on a.filme_id = f.id)
    select u_f_1.titulo, u_f_1.usuario, u_f_2.usuario from usuario_filme u_f_1
    inner join usuario_filme u_f_2 on u_f_1.titulo = u_f_2.titulo and u_f_1.ordenacao_filme < u_f_2.ordenacao_filme;
