create schema if not exists clinica;

--pacientes(id, nome, cpf, data_nascimento, cidade, criado_em)
CREATE TABLE if not exists clinica.pacientes (
                           id SERIAL PRIMARY KEY,
                           nome VARCHAR(150) NOT NULL,
                           cpf CHAR(11) NOT NULL UNIQUE,
                           data_nascimento DATE NOT NULL
                               CHECK (data_nascimento <= CURRENT_DATE),
                           cidade VARCHAR(80) NOT NULL,
                           criado_em TIMESTAMP NOT NULL DEFAULT NOW()
);

--medicos(id, nome, crm, especialidade, ativo, criado_em) DDL:
CREATE TABLE if not exists clinica.medicos (
                         id SERIAL PRIMARY KEY,
                         nome VARCHAR(150) NOT NULL,
                         crm VARCHAR(20) NOT NULL UNIQUE,
                         especialidade VARCHAR(80) NOT NULL,
                         ativo BOOLEAN NOT NULL DEFAULT TRUE,
                         criado_em TIMESTAMP NOT NULL DEFAULT NOW()
);

--unidades(id, nome, cidade, bairro, criado_em) DDL:
CREATE TABLE if not exists clinica.unidades (
                          id SERIAL PRIMARY KEY,
                          nome VARCHAR(120) NOT NULL,
                          cidade VARCHAR(80) NOT NULL,
                          bairro VARCHAR(80) NOT NULL,
                          criado_em TIMESTAMP NOT NULL DEFAULT NOW()
);

-- exames(id, nome, exige_jejum, duracao_min, ativo) DDL:
CREATE TABLE if not exists clinica.exames (
                        id SERIAL PRIMARY KEY,
                        nome VARCHAR(150) NOT NULL UNIQUE,
                        exige_jejum BOOLEAN NOT NULL DEFAULT FALSE,
                        duracao_min INTEGER NOT NULL
                            CHECK (duracao_min BETWEEN 5 AND 240),
                        ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE if not exists clinica.combos (
                        id SERIAL PRIMARY KEY,
                        nome VARCHAR(100) NOT NULL UNIQUE,
                        preco numeric NOT NULL check (preco > 0),
                        ativo boolean NOT NULL default True
);

--RICHARD DE JESUS CABRAL ALVES
CREATE TABLE if not exists clinica.combo_itens (
                                combo_id VARCHAR(100) not null references clinica.combos(nome),
                                exame_id VARCHAR(100) not null references clinica.exames(nome),
                                obrigatorio boolean not null default True,
                                primary key (combo_id, exame_id)
);

CREATE TABLE if not exists clinica.agendamentos (
                                      id SERIAL PRIMARY KEY,
                                      paciente_id integer not null references clinica.pacientes(id),
                                      medico_id integer not null references clinica.medicos(id),
                                      unidade_id integer not null references clinica.unidades(id),
                                      data_hora timestamp NOT NULL check (data_hora > date_trunc('year', timestamp '2020-01-01')),
                                      tipo_atendimento char(15) NOT NULL check (tipo_atendimento in ('CONSULTA','EXAME','RETORNO')),
                                      status char(15) NOT NULL check (tipo_atendimento in ('AGENDADO','REALIZADO','CANCELADO', 'FALTOU'))
);

CREATE TABLE if not exists clinica.exames_realizados (
                                      id SERIAL PRIMARY KEY,
                                      agendamento_id integer not null unique references clinica.agendamentos(id),
                                      exame_id integer not null unique references clinica.exames(id),
                                      realizado_em date NOT NULL,
                                      resultado_status char(15) NOT NULL check (resultado_status in ('NORMAL','ALTERADO','INCONCLUSIVO'))
);

CREATE TABLE if not exists clinica.faturamentos (
                                        id SERIAL PRIMARY KEY,
                                        paciente_id integer not null references clinica.pacientes(id),
                                        combo_id integer references clinica.combos(id)
                                        check ((origem like 'COMBO' and combo_id is not null) or (origem like 'AVULSO' and combo_id is null)),
                                        total_pago numeric NOT NULL check (total_pago > 0),
                                        origem varchar(15) NOT NULL check (origem in ('COMBO','AVULSO')),
                                        data_pagamento date NOT NULL,
                                        CONSTRAINT unique_faturamento_paciente_combo_data
                                        UNIQUE (paciente_id, combo_id, data_pagamento)
);

CREATE SCHEMA if not exists tabela_suporte;

create table if not exists tabela_suporte.combos (
                                                     nome VARCHAR(100) NOT NULL UNIQUE,
                                                     preco text NOT NULL,
                                                     ativo text NOT NULL default 'True'
);
COPY tabela_suporte.combos (nome, preco) FROM '/tmp/clinica/combos.csv' DELIMITER ',';
insert into clinica.combos(nome, preco, ativo) select nome, preco::numeric, ativo::boolean from tabela_suporte.combos;
select count(*) from clinica.combos;

create table if not exists tabela_suporte.exames (
                                                     nome VARCHAR(150) NOT NULL UNIQUE,
                                                     exige_jejum text NOT NULL DEFAULT 'FALSE',
                                                     duracao_min text NOT NULL,
                                                     ativo text NOT NULL DEFAULT 'TRUE'
);
COPY tabela_suporte.exames (nome, exige_jejum, duracao_min) FROM '/tmp/clinica/exames.csv' DELIMITER ',';
insert into clinica.exames(nome, exige_jejum, duracao_min, ativo) select nome, exige_jejum::boolean, duracao_min::integer, ativo::boolean from tabela_suporte.exames;
select count(*) from clinica.exames;

create table if not exists tabela_suporte.combo_itens (
                                        combo_id text not null,
                                        exame_id text not null,
                                        obrigatorio text not null default 'True',
                                        primary key (combo_id, exame_id)
);
COPY tabela_suporte.combo_itens FROM '/tmp/clinica/combo_itens.csv' DELIMITER ',';
insert into clinica.combo_itens(combo_id, exame_id, obrigatorio) select combo_id, exame_id, obrigatorio::boolean from tabela_suporte.combo_itens;
select count(*) from clinica.combo_itens;

create table if not exists tabela_suporte.medicos (
                                        nome VARCHAR(150) NOT NULL,
                                        crm VARCHAR(20) NOT NULL UNIQUE,
                                        especialidade VARCHAR(80) NOT NULL,
                                        ativo text NOT NULL DEFAULT 'TRUE',
                                        criado_em text NOT NULL DEFAULT NOW()
);
COPY tabela_suporte.medicos (nome, crm, especialidade) FROM '/tmp/clinica/medicos.csv' DELIMITER ',';
insert into clinica.medicos(nome, crm, especialidade, ativo, criado_em) select nome, crm, especialidade, ativo::boolean, criado_em::timestamp from tabela_suporte.medicos;
select count(*) from clinica.medicos;

create table if not exists tabela_suporte.pacientes (
                                          nome VARCHAR(150) NOT NULL,
                                          cpf CHAR(11) NOT NULL UNIQUE,
                                          data_nascimento text NOT NULL,
                                          cidade VARCHAR(80) NOT NULL,
                                          criado_em text NOT NULL DEFAULT NOW()
);
COPY tabela_suporte.pacientes (nome, cpf, data_nascimento, cidade) FROM '/tmp/clinica/pacientes.csv' DELIMITER ',';
insert into clinica.pacientes(nome, cpf, data_nascimento, cidade, criado_em) select nome, cpf, data_nascimento::date, cidade, criado_em::timestamp from tabela_suporte.pacientes;
select count(*) from clinica.pacientes;

--RICHARD DE JESUS CABRAL ALVES
create table if not exists tabela_suporte.unidades (
                                         nome VARCHAR(120) NOT NULL,
                                         cidade VARCHAR(80) NOT NULL,
                                         bairro VARCHAR(80) NOT NULL,
                                         criado_em text NOT NULL DEFAULT NOW()
);
COPY tabela_suporte.unidades (nome, cidade, bairro) FROM '/tmp/clinica/unidades.csv' DELIMITER ',';
insert into clinica.unidades(nome, cidade, bairro, criado_em) select nome, cidade, bairro, criado_em::timestamp from tabela_suporte.unidades;
select count(*) from clinica.unidades;
--RICHARD DE JESUS CABRAL ALVES
create table if not exists tabela_suporte.faturamentos (
                                            paciente_id text,
                                            combo_id text check ((origem like 'COMBO' and combo_id is not null) or (origem like 'AVULSO' and combo_id is null)),
                                            total_pago text,
                                            origem varchar(15) NOT NULL check (origem in ('COMBO','AVULSO')),
                                            data_pagamento text NOT NULL,
                                            CONSTRAINT unique_faturamento_paciente_combo_data
                                            UNIQUE (paciente_id, combo_id, data_pagamento)
);
COPY tabela_suporte.faturamentos (paciente_id, combo_id, total_pago, origem, data_pagamento) FROM '/tmp/faturamento.csv' DELIMITER ',' NULL '';
insert into clinica.faturamentos(paciente_id, combo_id, total_pago, origem, data_pagamento) select paciente_id::integer, combo_id::integer, total_pago::numeric, trim(origem), data_pagamento::date from tabela_suporte.faturamentos;

select * from tabela_suporte.faturamentos where total_pago::numeric < 0;
delete from tabela_suporte.faturamentos where total_pago::numeric < 0;
select * from tabela_suporte.faturamentos where total_pago::numeric < 0;

insert into clinica.faturamentos(paciente_id, combo_id, total_pago, origem, data_pagamento) select paciente_id::integer, combo_id::integer, total_pago::numeric, trim(origem), data_pagamento::date from tabela_suporte.faturamentos;
select count(*) from clinica.faturamentos;


select p.id as paciente_id, p.nome from clinica.pacientes p
    inner join clinica.faturamentos f on p.id = f.paciente_id where f.origem like 'AVULSO' group by p.id;

select c.nome, count(distinct f.paciente_id) as qtd_combo_usado from clinica.pacientes p
    inner join clinica.faturamentos f on f.paciente_id = p.id
    right join clinica.combos c on f.combo_id = c.id group by c.id;

create view total_paciente_gasto as
    select p.id as paciente_id, p.nome, sum(f.total_pago) as total_gasto from clinica.pacientes p
    inner join clinica.faturamentos f on f.paciente_id = p.id group by p.id;

with rankeamento_total_gasto as (
select *, row_number() over (order by total_gasto desc) as rankeamento_gasto from total_paciente_gasto)
select * from rankeamento_total_gasto where rankeamento_gasto <= 5;

select p.id as paciente_id, p.nome, count(distinct date_trunc('year',f.data_pagamento)) as qtd_anos_distintos from clinica.pacientes p
    inner join clinica.faturamentos f on f.paciente_id = p.id group by p.id having count(distinct date_trunc('year',f.data_pagamento)) >= 2;


select c.id as combi_id, c.nome from clinica.combos c
    left join clinica.faturamentos f on c.id = f.combo_id where f.combo_id is null;

select p.id as paciente_id, p.nome, f.data_pagamento, f.total_pago,
       sum(f.total_pago) over (partition by p.id order by f.data_pagamento) as total_acumulado_paciente
from clinica.pacientes p
    inner join clinica.faturamentos f on f.paciente_id = p.id order by p.nome, total_acumulado_paciente;

--RICHARD DE JESUS CABRAL ALVES
select c.id as combo_id, c.nome,
       count(f.id) as qtd_combo_usado,
       (c.preco * count(f.id)) as valor_total_em_combo,
       sum(f.total_pago) as total_pago_em_combo,
       (c.preco * count(f.id)) - sum(f.total_pago) as lucro_combo from clinica.combos c
    inner join clinica.faturamentos f on c.id = f.combo_id group by c.id order by lucro_combo desc;

--PART 2
select l.id as linha_id, l.nome_linha, sum(v.passageiros_transportados) as qtd_passageiros_transportados from transporte.viagens v
    inner join transporte.linha_onibus l on v.linha_id = l.id group by l.id;

select m.nome, count(v.id) as qtd_viagens, sum(v.passageiros_transportados) as qtd_passageiros_transportados from transporte.motoristas m
    inner join transporte.viagens v on m.id = v.motorista_id group by m.id;

--RICHARD DE JESUS CABRAL ALVES
create view linha_receita_total as (select l.id as linha_id, l.nome_linha, sum(v.receita_total) as valor_total_arrecadado from transporte.linha_onibus l
    inner join transporte.viagens v on l.id = v.linha_id group by l.id);

create view linha_manutencao_total as (select l.id as linha_id, l.nome_linha, sum(m.custo) as valor_total_manutencao from transporte.linha_onibus l
    inner join transporte.manutencoes m on l.id = m.linha_id group by l.id);

select rt.linha_id, rt.nome_linha, rt.valor_total_arrecadado, mt.valor_total_manutencao,
       (rt.valor_total_arrecadado - mt.valor_total_manutencao) as lucro_total from linha_receita_total rt
    inner join linha_manutencao_total mt on rt.linha_id = mt.linha_id order by valor_total_manutencao desc;
-------

with motorista_quantidade_passageiros as (
    select m.id as motorista_id, m.nome, v.data_viagem, v.passageiros_transportados,
    sum(v.passageiros_transportados) over (partition by m.id order by v.data_viagem) as qtd_passageiros_transportados_acumulado,
    sum(v.passageiros_transportados) over (partition by m.id) as qtd_passageiros_transportados_total
    from transporte.motoristas m
    left join transporte.viagens v on m.id = v.motorista_id)
select *, dense_rank() over (order by qtd_passageiros_transportados_total desc) from motorista_quantidade_passageiros;

create view linhas_faturamento_media as (with faturamento_linhas as (
select distinct l.id, l.nome_linha, sum(v.receita_total) as faturamento_total from transporte.linha_onibus l
    inner join transporte.viagens v on l.id = v.linha_id group by l.id)
select *, avg(faturamento_total) over () as media_faturamento from faturamento_linhas);

select * from linhas_faturamento_media where faturamento_total < media_faturamento;

select l.id, l.nome_linha, count(v.id) as qtd_viagens, count(m.id) as qtd_manutencoes from transporte.linha_onibus l
    full join transporte.viagens v on l.id = v.linha_id
    full join transporte.manutencoes m on l.id = m.linha_id group by l.id;

create view motorista_dia_consecutivo as (
select distinct on (m.id) m.id as motorista_id,
    m.nome, v.data_viagem viagem_atual, v2.data_viagem viagem_seguinte from transporte.motoristas m
    inner join transporte.viagens v on m.id = v.motorista_id
    inner join transporte.viagens v2 on m.id = v2.motorista_id
where date_trunc('day',v.data_viagem::date) = date_trunc('day',v2.data_viagem - INTERVAL '1 day'));

select nome, viagem_atual, viagem_seguinte from motorista_dia_consecutivo;