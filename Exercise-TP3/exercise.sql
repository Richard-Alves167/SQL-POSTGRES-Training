select * from usuario_antigo;

-- Ato 0 – Banco herdado (Ajustes Iniciais)

ALTER TABLE usuario_antigo DROP CONSTRAINT email;
ALTER TABLE usuario_antigo  RENAME nome_completo TO nome;
ALTER TABLE usuario_antigo ALTER COLUMN criado_em TYPE TIMESTAMPTZ;

-- Ato 1 – O Alicerce (Modelagem e DDL)

CREATE TABLE usuario (id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY, nome TEXT NOT NULL, email TEXT NOT NULL UNIQUE, tipo TEXT CHECK(tipo IN ('ALUNO','INSTRUTOR')) ,criado_em TIMESTAMPTZ DEFAULT now());
CREATE TABLE curso (id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY, titulo TEXT NOT NULL, categoria TEXT NOT NULL, nivel TEXT NOT NULL CHECK(nivel IN('inic','inter','avanc')), preco NUMERIC CHECK(preco >= 0), publicado_em DATE,  instrutor_id BIGINT);
CREATE TABLE pagamento (id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY, matricula_id BIGINT, valor_pago NUMERIC CHECK(valor_pago >= 0), realizado_em TIMESTAMPTZ, meio TEXT CHECK(meio IN('PIX','CARTAO','BOLETO')), status TEXT CHECK(status IN('OK','FALHA')));
CREATE INDEX idx_usuario_nome ON usuario (nome);
CREATE INDEX idx_curso_titulo ON curso (titulo);
CREATE INDEX idx_pagamento_matricula_id ON pagamento (matricula_id);

-- Ato 2 – Inserts manuais

insert into usuario (nome,email,tipo,criado_em) values ('Richard Alves','richard.alves@al.infnet.edu.br','ALUNO','2024-08-29');
insert into usuario (nome,email,tipo,criado_em) values ('Mell Alves','mell.alves@al.infnet.edu.br','ALUNO','2024-08-29');
insert into usuario (nome,email,tipo,criado_em) values ('Taylan Gonzaga','taylan.gonzaga@al.infnet.edu.br','ALUNO','2024-08-29');
insert into usuario (nome,email,tipo,criado_em) values ('Lucas Cabral','lucas.cabral@al.infnet.edu.br','ALUNO','2023-08-25');
insert into usuario (nome,email,tipo,criado_em) values  ('Alicia Silva','alicia.silva@prof.infnet.edu.br','INSTRUTOR','2021-08-25');
insert into curso (titulo, categoria, nivel, preco, publicado_em, instrutor_id)  values ('Engenharia de Software','Tecnologia da Informacao','inter',1200,'2019-01-30',5);
insert into curso (titulo, categoria, nivel, preco, publicado_em, instrutor_id)  values ('Engenharia da Computacao','Tecnologia da Informacao','avanc',1800,'2017-06-30',5);
insert into curso  (titulo, categoria, nivel, preco, publicado_em, instrutor_id)  values ('Analise e Desenvolvimento de Sistemas','Tecnologia da Informacao','inic',1000,'2019-03-30',5);
insert into curso (titulo, categoria, nivel, preco, publicado_em, instrutor_id) values ('Analise de Dados','Tecnologia da Informacao','inic',800,'2012-08-30',5);
insert into curso (titulo, categoria, nivel, preco, publicado_em, instrutor_id)  values ('Curso de GitHub','DevOps','inic',600,'2012-08-30',5)
insert into pagamento (matricula_id, valor_pago, realizado_em, meio, status)  values (1,1250,'2020-01-02','CARTAO','OK');
insert into pagamento (matricula_id, valor_pago, realizado_em, meio, status) values (2,875,'2024-05-30','PIX','OK');
insert into pagamento (matricula_id, valor_pago, realizado_em, meio, status) values (3,5500,'2025-04-21','PIX','FALHA');
insert into pagamento (matricula_id, valor_pago, realizado_em, meio, status) values (4,6250,'2021-07-20','BOLETO','FALHA');
insert into pagamento (matricula_id, valor_pago, realizado_em, meio, status) values (5,6250,'2019-09-10','BOLETO','OK');
insert into pagamento (matricula_id, valor_pago, realizado_em, meio, status) values (6,1000,'2024-12-10','PIX','OK');
insert into pagamento (matricula_id, valor_pago, realizado_em, meio, status) values (7,1000,'2023-11-07','CARTAO','OK');
insert into pagamento (matricula_id, valor_pago, realizado_em, meio, status) values (8,2700,'2018-10-28','BOLETO','OK');

-- Ato 3 – A Enxurrada de Dados (Bulk Load)

-- Nesse exercício de popular o banco, estava com problemas de duplicidade de dados de Primary Key, sendo assim, minha resolução foi pegar uma nova tabela usuario_importado, pegar esses dados com todas as colunas, incluindo os ids do csv, e depois pegar os dados da tabela usuario_importado e transferi-los para a tabela primaria que é o usuario.
-- A mesma coisa será feita com as tabelas curso e pagamento, e depois de todas as tabelas primarias com os bancos populados do csv, serão feitos drop tables para as tabelas suportes, para evitar de deixar o banco de dados com tabelas ‘inúteis’.

CREATE TABLE usuario_importado (id INT PRIMARY KEY, nome TEXT NOT NULL, email TEXT NOT NULL UNIQUE, tipo TEXT CHECK(tipo IN ('ALUNO','INSTRUTOR')) ,criado_em TIMESTAMPTZ DEFAULT now());
copy usuario_importado from '/import/usuarios.csv' with(format csv, header)
insert into usuario (nome, email, tipo, criado_em) select nome, email, tipo, criado_em from usuario_importado;
select count(*) from usuario;
drop table usuario_importado;
CREATE TABLE curso_importado (id INT PRIMARY KEY, titulo TEXT NOT NULL, categoria TEXT NOT NULL, nivel TEXT NOT NULL CHECK(nivel IN('inic','inter','avanc')), preco NUMERIC CHECK(preco >= 0), publicado_em DATE,  instrutor_id BIGINT);
copy curso_importado from '/import/cursos.csv' with(format csv, header);
insert into curso (titulo, categoria, nivel, preco, publicado_em, instrutor_id) select (titulo, categoria, nivel, preco, publicado_em, instrutor_id) from curso_importado;
select count(*) from curso;
drop table curso_importado;
CREATE TABLE pagamento_importado (id INT PRIMARY KEY, matricula_id BIGINT, valor_pago NUMERIC CHECK(valor_pago >= 0), realizado_em TIMESTAMPTZ, meio TEXT CHECK(meio IN('PIX','CARTAO','BOLETO')), status TEXT CHECK(status IN('OK','FALHA')));
copy pagamento_importado from '/import/pagamentos.csv' with(format csv, header);
insert into pagamento(matricula_id, valor_pago, realizado_em, meio, status) select matricula_id, valor_pago, realizado_em, meio, status from pagamento_importado;
select count(*) from pagamento;
drop table pagamento_importado;

-- Diferença entre GENERATED ALWAYS AS IDENTITY e GENERATED BY DEFAULT AS IDENTITY:
-- GENERATED ALWAYS AS IDENTITY
-- Quando se utiliza o ALWAYS AS IDENTITY, o banco popula o id automaticamente, mas impedindo que o usuário coloque o id. Tornando seguro a criação dos IDs
-- GENERATED BY DEFAULT AS IDENTITY:
-- Quando se utiliza o DEFAULT AS IDENTITY, o banco popula o id automaticamente, mas ele não impede que o usuário coloque o id manualmente. Entretanto, ainda tem as chances de ocorrer erro se colocar um id já populado.

-- Ato 4 – Consultas (SQL)

-- Bloco A

select * from curso where nivel='inter' and categoria in ('Data','DBA','DevOps') and titulo ilike '%sql%' order by publicado_em desc offset 20;
select id, nome, email from usuario where email like '%.edu.br%';
select id, nome, email from usuario where right(email,7) = '.edu.br';
select id, titulo, REPLACE(titulo,'SQL','SQL (2025)') AS titulo_formatado from curso;
select * from pagamento where realizado_em between '2025-02-01' and '2025-03-15';
select * from curso where nivel='avanc' and preco between 300 and 800 and categoria <> 'ML';

-- Bloco B

select categoria, count(*) ,avg(preco) from curso where extract(year from publicado_em) = 2025 group by categoria;
select TO_CHAR(realizado_em, 'Month') as mes, sum(valor_pago) as total_pagamentos_ok from pagamento where extract(year from realizado_em)=2025 and status = 'OK' group by mes order by mes;
select to_char(realizado_em, 'Month') as mes, sum(valor_pago) as receita_total from pagamento where status = 'OK' group by mes having sum(valor_pago) >= 10000;
select count(*) from pagamento;
select count(meio) from pagamento;

-- Diferença entre COUNT(*) e COUNT(meio):
-- COUNT(*)
-- Conta por uma linha inteira.
-- COUNT(meio):
-- Conta somente se na coluna ‘meio’ estiver com valor.

select nivel, count(*) as qtd_cursos, min(preco) as preco_min, max(preco) as preco_max, avg(preco) as preco_avg from curso group by nivel order by preco_avg desc;

-- Bloco C

select * from curso where preco > (select avg(preco) from curso);
 select * from usuario where tipo ilike '%ALUNO%' and id not in(select instrutor_id from curso);

-- Bloco E

select instrutor_id, string_agg(titulo,',' order by publicado_em) as cursos from curso group by instrutor_id having count(*) > 3;
select substring(email, position('@' in email)) as dominio_email, count(*) from usuario group by dominio_email order by dominio_email desc;

-- Bloco F

select * from pagamento where status='OK' and valor_pago <=0;
select * from pagamento where status='OK' and valor_pago >=0;
select email, count(*) from usuario group by email having count(*) > 1
