CREATE DATABASE IF NOT EXISTS CTA;
USE CTA;

CREATE TABLE Aluno (
    id_aluno INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    data_nascimento DATE NOT NULL
) ENGINE=InnoDB;

CREATE TABLE Professor (
    id_professor INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    data_nascimento DATE NOT NULL,
    mini_curriculo TEXT,
    percentual_comissao DECIMAL(5,2) NOT NULL 
) ENGINE=InnoDB;

CREATE TABLE Categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
) ENGINE=InnoDB;


CREATE TABLE Curso (
    id_curso INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    descricao TEXT,
    carga_horaria INT NOT NULL,
    preco_base DECIMAL(10,2) NOT NULL,
    data_publicacao DATE NOT NULL,
    id_categoria INT NOT NULL,
    id_professor INT NOT NULL,
    total_alunos INT DEFAULT 0,
    CONSTRAINT fk_curso_categoria FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria),
    CONSTRAINT fk_curso_professor FOREIGN KEY (id_professor) REFERENCES Professor(id_professor)
) ENGINE=InnoDB;


CREATE TABLE Matricula (
    id_matricula INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT NOT NULL,
    id_curso INT NOT NULL,
    data_matricula DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Ativa', 'Concluida', 'Cancelada') DEFAULT 'Ativa',
    progresso DECIMAL(5,2) DEFAULT 0.00,
    valor_comissao DECIMAL(10,2),
    valor_plataforma DECIMAL(10,2),
    CONSTRAINT fk_matricula_aluno FOREIGN KEY (id_aluno) REFERENCES Aluno(id_aluno),
    CONSTRAINT fk_matricula_curso FOREIGN KEY (id_curso) REFERENCES Curso(id_curso),
    CONSTRAINT uk_aluno_curso UNIQUE (id_aluno, id_curso)
) ENGINE=InnoDB;


CREATE TABLE Log_Preco_Curso (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_curso INT NOT NULL,
    preco_antigo DECIMAL(10,2) NOT NULL,
    preco_novo DECIMAL(10,2) NOT NULL,
    data_alteracao DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_curso FOREIGN KEY (id_curso) REFERENCES Curso(id_curso) ON DELETE CASCADE
) ENGINE=InnoDB;


CREATE TABLE Pagamento (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_matricula INT NOT NULL,
    valor_final DECIMAL(10,2) NOT NULL,
    metodo ENUM('Cartao', 'Pix', 'Boleto') NOT NULL,
    data_vencimento DATE NOT NULL,
    status ENUM('Pendente', 'Pago', 'Atrasado') DEFAULT 'Pendente',
    CONSTRAINT fk_pagamento_matricula FOREIGN KEY (id_matricula) REFERENCES Matricula(id_matricula) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Avaliacao (
    id_avaliacao INT AUTO_INCREMENT PRIMARY KEY,
    id_matricula INT NOT NULL,
    nota INT NOT NULL,
    comentario TEXT,
    data_avaliacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_nota CHECK (nota >= 1 AND nota <= 5),
    CONSTRAINT fk_avaliacao_matricula FOREIGN KEY (id_matricula) REFERENCES Matricula(id_matricula) ON DELETE CASCADE
) ENGINE=InnoDB;


CREATE TABLE Log_Acesso (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT NOT NULL,
    id_curso INT NOT NULL,
    data_inicio DATETIME NOT NULL,
    data_fim DATETIME,
    CONSTRAINT fk_log_acesso_aluno FOREIGN KEY (id_aluno) REFERENCES Aluno(id_aluno),
    CONSTRAINT fk_log_acesso_curso FOREIGN KEY (id_curso) REFERENCES Curso(id_curso)
) ENGINE=InnoDB;
