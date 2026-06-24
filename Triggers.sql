USE CTA;

DELIMITER //

-- 1 Auditoria: Grava histórico de alterações nos preços
CREATE TRIGGER tg_AuditoriaPrecoCurso
AFTER UPDATE ON Curso
FOR EACH ROW
BEGIN
    IF OLD.preco_base <> NEW.preco_base THEN
        INSERT INTO Log_Preco_Curso (id_curso, preco_antigo, preco_novo)
        VALUES (OLD.id_curso, OLD.preco_base, NEW.preco_base);
    END IF;
END //

-- 2 Agregação: Atualiza o contador de alunos matriculados
CREATE TRIGGER tg_AtualizarContadorAlunos
AFTER INSERT ON Matricula
FOR EACH ROW
BEGIN
    IF NEW.status = 'Ativa' THEN
        UPDATE Curso 
        SET total_alunos = total_alunos + 1
        WHERE id_curso = NEW.id_curso;
    END IF;
END //

-- 3 Restrição: Impede novas matrículas se o aluno estiver inadimplente
CREATE TRIGGER tg_BloquearMatriculaInadimplente
BEFORE INSERT ON Matricula
FOR EACH ROW
BEGIN
    DECLARE v_atrasos INT;
    
    SELECT COUNT(*) INTO v_atrasos
    FROM Pagamento p
    JOIN Matricula m ON p.id_matricula = m.id_matricula
    WHERE m.id_aluno = NEW.id_aluno AND p.status = 'Atrasado';
    
    IF v_atrasos > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Matrícula Negada: Aluno possui pendências financeiras em aberto.';
    END IF;
END //

-- 4 Cálculo Prévio: Preenche a divisão financeira com base nas regras do professor
CREATE TRIGGER tg_CalcularFinanceiroMatricula
BEFORE INSERT ON Matricula
FOR EACH ROW
BEGIN
    DECLARE v_preco DECIMAL(10,2);
    DECLARE v_comissao_pct DECIMAL(5,2);
    DECLARE v_prof_id INT;
    
    SELECT preco_base, id_professor INTO v_preco, v_prof_id FROM Curso WHERE id_curso = NEW.id_curso;
    SELECT percentual_comissao INTO v_comissao_pct FROM Professor WHERE id_professor = v_prof_id;
    
    SET NEW.valor_comissao = (v_preco * v_comissao_pct) / 100;
    SET NEW.valor_plataforma = v_preco - NEW.valor_comissao;
END //

-- 5 Automação de Fluxo: Gera faturamento inicial pendente
CREATE TRIGGER tg_GerarFaturamentoMatricula
AFTER INSERT ON Matricula
FOR EACH ROW
BEGIN
    DECLARE v_preco DECIMAL(10,2);
    SELECT preco_base INTO v_preco FROM Curso WHERE id_curso = NEW.id_curso;
    
    INSERT INTO Pagamento (id_matricula, valor_final, metodo, data_vencimento, status)
    VALUES (NEW.id_matricula, v_preco, 'Pix', DATE_ADD(CURDATE(), INTERVAL 5 DAY), 'Pendente');
END //

DELIMITER ;
