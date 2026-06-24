USE CTA;

DELIMITER //

-- 1. Calcular a idade exata do aluno
CREATE FUNCTION fn_CalcularIdade(data_nasc DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, data_nasc, CURDATE());
END //

-- 2. Calcular valor com desconto
CREATE FUNCTION fn_CalcularDesconto(preco DECIMAL(10,2), percentual_desconto DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN preco - (preco * (percentual_desconto / 100));
END //

-- 3. Somar total de horas assistidas por um aluno
CREATE FUNCTION fn_TotalHorasAluno(p_id_aluno INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE total_horas INT;
    SELECT COALESCE(SUM(TIMESTAMPDIFF(HOUR, data_inicio, data_fim)), 0)
    INTO total_horas
    FROM Log_Acesso
    WHERE id_aluno = p_id_aluno;
    RETURN total_horas;
END //

-- 4. Verificar status de aprovação com base no progresso
CREATE FUNCTION fn_VerificarAprovacao(p_progresso DECIMAL(5,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    IF p_progresso >= 100.00 THEN
        RETURN 'Aprovado';
    ELSE
        RETURN 'Em Andamento';
    END IF;
END //

-- 5. Calcular a comissão líquida acumulada de um professor
CREATE FUNCTION fn_ComissaoAcumuladaProfessor(p_id_professor INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE total_comissao DECIMAL(10,2);
    SELECT COALESCE(SUM(m.valor_comissao), 0)
    INTO total_comissao
    FROM Matricula m
    JOIN Curso c ON m.id_curso = c.id_curso
    WHERE c.id_professor = p_id_professor AND m.status != 'Cancelada';
    RETURN total_comissao;
END //

DELIMITER ;
