-- 1. Tabela Aluno (OK)
CREATE TABLE Aluno (
    Id_aluno INT PRIMARY KEY,
    Nome VARCHAR(100),
    Data_nasc DATE,
    E_mail VARCHAR(100),
    CPF VARCHAR(14)
);

-- 2. Tabela Professor (OK)
CREATE TABLE Professor (
    Id_professor INT PRIMARY KEY,
    Nome VARCHAR(100),
    E_Mail VARCHAR(100),
    Telefone VARCHAR(20)
);

-- 3. Tabela Curso (Ajustada: removido Id_turma)
CREATE TABLE Curso (
    Id_curso INT PRIMARY KEY,
    Nome_Curso VARCHAR(50), -- Ex: Inglês, Espanhol
    Nivel VARCHAR(50),      -- Ex: Iniciante, Avançado
    Carga_Horaria INT
);

-- 4. Tabela Turma (Ajustada: recebe Id_curso e Id_professor)
CREATE TABLE Turma (
    Id_turma INT PRIMARY KEY,
    Periodo VARCHAR(50),
    Turno VARCHAR(20),
    Id_professor INT,
    Id_curso INT,
    FOREIGN KEY (Id_professor) REFERENCES Professor(Id_professor),
    FOREIGN KEY (Id_curso) REFERENCES Curso(Id_curso)
);

-- 5. Tabela Matricula (Ajustada: agora vincula Aluno à Turma)
CREATE TABLE Matricula (
    Id_matricula INT PRIMARY KEY,
    Data_mat DATE,
    Status VARCHAR(20),
    Id_aluno INT,
    Id_turma INT,
    FOREIGN KEY (Id_aluno) REFERENCES Aluno(Id_aluno),
    FOREIGN KEY (Id_turma) REFERENCES Turma(Id_turma)
);

-- 6. Tabela Pagamento (OK)
CREATE TABLE Pagamento (
    Id_pagamento INT PRIMARY KEY,
    Id_matricula INT,
    Data_pgto DATE,
    Valor DECIMAL(10,2),
    Status VARCHAR(20),
    FOREIGN KEY (Id_matricula) REFERENCES Matricula(Id_matricula)
);
