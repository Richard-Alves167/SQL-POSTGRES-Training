create table missoes (nome text primary key, tags text[], dias int[]);

INSERT INTO missoes (nome, tags, dias) VALUES
('Operação Nocturna',    ARRAY['nocturno','rural'], ARRAY[1,3,5]),
('Varredura Urbana',     ARRAY['urbano','leste'],   ARRAY[2,4]),
('Monitoramento Litoral',ARRAY['litoral'],          ARRAY[6,7]),
('Pico MG',              ARRAY['montanha','nocturno'], ARRAY[5]),
('Rota Sul',             ARRAY['rodovia','rural'],  ARRAY[1,2,3,4,5]);

create table relatorios (dados jsonb);

INSERT INTO relatorios (dados) VALUES
('{"sku":"R-42","tags":["laser","orb"],"confirmado":true,"pontos":7}'),
('{"sku":"R-77","tags":["triangular"],"confirmado":false,"pontos":3,"notas":{"origem":"CE"}}'),
('{"sku":"R-15","tags":["pulsante","orb"],"confirmado":true,"pontos":9}'),
('{"sku":"R-88","tags":["rastro"],"confirmado":false,"pontos":2}'),
('{"sku":"R-19","tags":["orb"],"confirmado":true,"pontos":5,"extra":{"angulo":45}}');

select * from missoes where tags @> array['nocturno'];

select * from missoes where dias @> array[5];

update missoes set tags = array_append(tags,'urgente') where nome = 'Operação Nocturna';

update missoes set tags = array_remove(tags, 'leste') where nome = 'Varredura Urbana';

select nome, array_length(dias,1) as quantidade_dias_missoes from missoes;

select nome, array_length(dias,1) as quantidade_dias_missoes from missoes where array_length(dias,1) > 3;

update missoes set dias = array_append(dias, 6) where nome = 'Rota Sul';

select nome, tags[1] from missoes;

select * from relatorios where dados->'tags' @> '["orb"]'::jsonb;

select dados->'sku' as sku from relatorios;

select * from relatorios where dados->>'confirmado' = 'true';

update relatorios set dados = jsonb_set(dados,'{pontos}', '10'::jsonb) where dados->>'sku' = 'R-42';

update relatorios set dados = jsonb_set(dados,'{tags}',(dados->'tags') - 'rastro');

select * from relatorios where dados ? 'extra';

select dados->>'pontos' from relatorios order by (dados->>'pontos')::int;