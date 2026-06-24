USE CTA;

-- 1 Faturamento mensal consolidado
CREATE OR REPLACE VIEW VW_Faturamento_Mensal AS
SELECT 
    DATE_FORMAT(data_vencimento, '%Y-%m') AS mes_referencia,
    COUNT(id_pagamento) AS qtd_vendas,
    SUM(valor_final) AS faturamento_total
FROM Pagamento
WHERE status = 'Pago'
GROUP BY DATE_FORMAT(data_vencimento, '%Y-%m')
ORDER BY mes_referencia DESC;

-- 2 Ranking de cursos (Melhores avaliados)
CREATE OR REPLACE VIEW VW_Ranking_Cursos AS
SELECT 
    c.id_curso,
    c.titulo AS nome_curso,
    p.nome AS professor_ministrante,
    ROUND(AVG(a.nota), 2) AS media_avaliacao,
    COUNT(a.id_avaliacao) AS total_avaliacoes
FROM Curso c
JOIN Professor p ON c.id_professor = p.id_professor
JOIN Matricula m ON c.id_curso = m.id_curso
JOIN Avaliacao a ON m.id_matricula = a.id_matricula
GROUP BY c.id_curso, c.titulo, p.nome
ORDER BY media_avaliacao DESC;

-- 3 Monitoramento de alunos inadimplentes (Cobrança)
CREATE OR REPLACE VIEW VW_Alunos_Inadimplentes AS
SELECT 
    a.id_aluno,
    a.nome AS nome_aluno,
    a.email,
    c.titulo AS curso_devedor,
    p.valor_final AS valor_pendente,
    p.data_vencimento
FROM Aluno a
JOIN Matricula m ON a.id_aluno = m.id_aluno
JOIN Curso c ON m.id_curso = c.id_curso
JOIN Pagamento p ON m.id_matricula = p.id_matricula
WHERE p.status = 'Atrasado';

-- 4 Relatório de repasse aos professores
CREATE OR REPLACE VIEW VW_Faturamento_Professor AS
SELECT 
    p.id_professor,
    p.nome AS nome_professor,
    p.percentual_comissao,
    COUNT(m.id_matricula) AS total_vendas_realizadas,
    SUM(m.valor_comissao) AS total_comissao_acumulada
FROM Professor p
JOIN Curso c ON p.id_professor = c.id_professor
JOIN Matricula m ON c.id_curso = m.id_curso
WHERE m.status != 'Cancelada'
GROUP BY p.id_professor, p.nome, p.percentual_comissao
ORDER BY total_comissao_acumulada DESC;

-- 5 Alunos ativos por curso e categoria
CREATE OR REPLACE VIEW VW_Alunos_Ativos AS
SELECT 
    m.id_matricula,
    a.nome AS nome_aluno,
    c.titulo AS nome_curso,
    cat.nome AS nome_categoria,
    m.data_matricula,
    m.progresso
FROM Matricula m
JOIN Aluno a ON m.id_aluno = a.id_aluno
JOIN Curso c ON m.id_curso = c.id_curso
JOIN Categoria cat ON c.id_categoria = cat.id_categoria
WHERE m.status = 'Ativa';
