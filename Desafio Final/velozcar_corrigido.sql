-- ============================================================
--  VELOZCAR — Sistema de Aluguel de Veículos
--  Script SQL Completo: DDL + DML + DQL
--  Autor: Equipe Técnica VelozCar
--  Data: 2026-03-20
-- ============================================================

-- ============================================================
-- SEÇÃO 1 — DDL: CRIAÇÃO DO BANCO E TABELAS
-- ============================================================

DROP DATABASE IF EXISTS velozcar;
CREATE DATABASE velozcar
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE velozcar;

-- ------------------------------------------------------------
-- Tabela: ENDERECOS (compartilhada por Cliente e Funcionário)
-- ------------------------------------------------------------
CREATE TABLE enderecos (
    id_endereco     INT             NOT NULL AUTO_INCREMENT,
    logradouro      VARCHAR(150)    NOT NULL,
    numero          VARCHAR(10)     NOT NULL,
    complemento     VARCHAR(60)     NULL,
    bairro          VARCHAR(80)     NOT NULL,
    cidade          VARCHAR(80)     NOT NULL,
    estado          CHAR(2)         NOT NULL,
    cep             CHAR(9)         NOT NULL,
    pais            VARCHAR(50)     NOT NULL DEFAULT 'Brasil',
    CONSTRAINT pk_enderecos PRIMARY KEY (id_endereco),
    CONSTRAINT chk_estado   CHECK (estado REGEXP '^[A-Z]{2}$'),
    CONSTRAINT chk_cep      CHECK (cep REGEXP '^[0-9]{5}-[0-9]{3}$')
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Tabela: CLIENTES
-- ------------------------------------------------------------
CREATE TABLE clientes (
    id_cliente      INT             NOT NULL AUTO_INCREMENT,
    nome_completo   VARCHAR(120)    NOT NULL,
    cpf             CHAR(14)        NOT NULL,
    data_nascimento DATE            NOT NULL,
    email           VARCHAR(100)    NOT NULL,
    telefone        VARCHAR(20)     NOT NULL,
    cnh             VARCHAR(20)     NOT NULL,
    categoria_cnh   VARCHAR(5)      NOT NULL DEFAULT 'B',
    data_cadastro   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ativo           TINYINT(1)      NOT NULL DEFAULT 1,
    id_endereco     INT             NOT NULL,
    CONSTRAINT pk_clientes      PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cpf_cliente   UNIQUE (cpf),
    CONSTRAINT uq_email_cliente UNIQUE (email),
    CONSTRAINT uq_cnh_cliente   UNIQUE (cnh),
    CONSTRAINT fk_cli_end       FOREIGN KEY (id_endereco)
                                REFERENCES enderecos(id_endereco)
                                ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Tabela: CARGOS
-- ------------------------------------------------------------
CREATE TABLE cargos (
    id_cargo        INT             NOT NULL AUTO_INCREMENT,
    nome_cargo      VARCHAR(80)     NOT NULL,
    descricao       VARCHAR(200)    NULL,
    salario_base    DECIMAL(10,2)   NOT NULL,
    nivel           VARCHAR(20)     NOT NULL DEFAULT 'Operacional',
    CONSTRAINT pk_cargos PRIMARY KEY (id_cargo),
    CONSTRAINT uq_nome_cargo UNIQUE (nome_cargo),
    CONSTRAINT chk_salario   CHECK (salario_base > 0)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Tabela: FUNCIONARIOS
-- ------------------------------------------------------------
CREATE TABLE funcionarios (
    id_funcionario  INT             NOT NULL AUTO_INCREMENT,
    nome_completo   VARCHAR(120)    NOT NULL,
    cpf             CHAR(14)        NOT NULL,
    email           VARCHAR(100)    NOT NULL,
    telefone        VARCHAR(20)     NOT NULL,
    data_admissao   DATE            NOT NULL,
    data_demissao   DATE            NULL,
    matricula       VARCHAR(20)     NOT NULL,
    status_func     ENUM('ativo','inativo','férias','licença') NOT NULL DEFAULT 'ativo',
    salario         DECIMAL(10,2)   NOT NULL,
    id_cargo        INT             NOT NULL,
    id_endereco     INT             NOT NULL,
    CONSTRAINT pk_funcionarios      PRIMARY KEY (id_funcionario),
    CONSTRAINT uq_cpf_func          UNIQUE (cpf),
    CONSTRAINT uq_email_func        UNIQUE (email),
    CONSTRAINT uq_matricula         UNIQUE (matricula),
    CONSTRAINT fk_func_cargo        FOREIGN KEY (id_cargo)
                                    REFERENCES cargos(id_cargo)
                                    ON UPDATE CASCADE,
    CONSTRAINT fk_func_end          FOREIGN KEY (id_endereco)
                                    REFERENCES enderecos(id_endereco)
                                    ON UPDATE CASCADE,
    CONSTRAINT chk_salario_func     CHECK (salario > 0)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Tabela: CATEGORIAS_VEICULO
-- ------------------------------------------------------------
CREATE TABLE categorias_veiculo (
    id_categoria    INT             NOT NULL AUTO_INCREMENT,
    nome_categoria  VARCHAR(50)     NOT NULL,
    descricao       VARCHAR(200)    NULL,
    diaria_minima   DECIMAL(10,2)   NOT NULL,
    diaria_maxima   DECIMAL(10,2)   NOT NULL,
    CONSTRAINT pk_categorias PRIMARY KEY (id_categoria),
    CONSTRAINT uq_nome_cat   UNIQUE (nome_categoria),
    CONSTRAINT chk_diarias   CHECK (diaria_maxima >= diaria_minima)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Tabela: VEICULOS
-- ------------------------------------------------------------
CREATE TABLE veiculos (
    id_veiculo          INT             NOT NULL AUTO_INCREMENT,
    placa               VARCHAR(8)      NOT NULL,
    marca               VARCHAR(50)     NOT NULL,
    modelo              VARCHAR(80)     NOT NULL,
    ano_fabricacao      YEAR            NOT NULL,
    ano_modelo          YEAR            NOT NULL,
    cor                 VARCHAR(30)     NOT NULL,
    numero_chassis      VARCHAR(17)     NOT NULL,
    quilometragem       DECIMAL(10,2)   NOT NULL DEFAULT 0,
    valor_diaria        DECIMAL(10,2)   NOT NULL,
    status_veiculo      ENUM('disponível','alugado','manutenção','inativo') NOT NULL DEFAULT 'disponível',
    data_cadastro       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_categoria        INT             NOT NULL,
    CONSTRAINT pk_veiculos      PRIMARY KEY (id_veiculo),
    CONSTRAINT uq_placa         UNIQUE (placa),
    CONSTRAINT uq_chassis       UNIQUE (numero_chassis),
    CONSTRAINT fk_vei_cat       FOREIGN KEY (id_categoria)
                                REFERENCES categorias_veiculo(id_categoria)
                                ON UPDATE CASCADE,
    CONSTRAINT chk_valor_diaria CHECK (valor_diaria > 0),
    CONSTRAINT chk_km           CHECK (quilometragem >= 0)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Tabela: ALUGUEIS
-- ------------------------------------------------------------
CREATE TABLE alugueis (
    id_aluguel          INT             NOT NULL AUTO_INCREMENT,
    data_inicio         DATE            NOT NULL,
    data_fim_prevista   DATE            NOT NULL,
    data_fim_real       DATE            NULL,
    valor_total         DECIMAL(10,2)   NOT NULL,
    valor_multa         DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    quilometragem_saida DECIMAL(10,2)   NOT NULL,
    quilometragem_retorno DECIMAL(10,2) NULL,
    status_aluguel      ENUM('ativo','finalizado','atrasado','cancelado') NOT NULL DEFAULT 'ativo',
    observacoes         TEXT            NULL,
    data_registro       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_cliente          INT             NOT NULL,
    id_funcionario      INT             NOT NULL,
    id_veiculo          INT             NOT NULL,
    CONSTRAINT pk_alugueis      PRIMARY KEY (id_aluguel),
    CONSTRAINT fk_alg_cli       FOREIGN KEY (id_cliente)
                                REFERENCES clientes(id_cliente)
                                ON UPDATE CASCADE,
    CONSTRAINT fk_alg_func      FOREIGN KEY (id_funcionario)
                                REFERENCES funcionarios(id_funcionario)
                                ON UPDATE CASCADE,
    CONSTRAINT fk_alg_vei       FOREIGN KEY (id_veiculo)
                                REFERENCES veiculos(id_veiculo)
                                ON UPDATE CASCADE,
    CONSTRAINT chk_datas        CHECK (data_fim_prevista > data_inicio),
    CONSTRAINT chk_valor_total  CHECK (valor_total > 0)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Tabela: PAGAMENTOS
-- ------------------------------------------------------------
CREATE TABLE pagamentos (
    id_pagamento    INT             NOT NULL AUTO_INCREMENT,
    valor_pago      DECIMAL(10,2)   NOT NULL,
    data_pagamento  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metodo          ENUM('cartão_crédito','cartão_débito','pix','boleto','dinheiro') NOT NULL,
    status_pag      ENUM('pendente','concluído','cancelado','estornado') NOT NULL DEFAULT 'pendente',
    codigo_transacao VARCHAR(60)    NULL,
    parcelas        TINYINT         NOT NULL DEFAULT 1,
    observacoes     VARCHAR(200)    NULL,
    id_aluguel      INT             NOT NULL,
    CONSTRAINT pk_pagamentos    PRIMARY KEY (id_pagamento),
    CONSTRAINT fk_pag_alg       FOREIGN KEY (id_aluguel)
                                REFERENCES alugueis(id_aluguel)
                                ON UPDATE CASCADE,
    CONSTRAINT chk_valor_pago   CHECK (valor_pago > 0),
    CONSTRAINT chk_parcelas     CHECK (parcelas BETWEEN 1 AND 12)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Tabela: MANUTENCOES
-- ------------------------------------------------------------
CREATE TABLE manutencoes (
    id_manutencao       INT             NOT NULL AUTO_INCREMENT,
    tipo_manutencao     ENUM('preventiva','corretiva','recall','lavagem','revisão') NOT NULL,
    descricao           TEXT            NOT NULL,
    data_entrada        DATE            NOT NULL,
    data_saida          DATE            NULL,
    custo               DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    fornecedor          VARCHAR(100)    NOT NULL,
    numero_ordem        VARCHAR(30)     NULL,
    status_manut        ENUM('agendada','em andamento','concluída','cancelada') NOT NULL DEFAULT 'agendada',
    quilometragem_atual DECIMAL(10,2)   NOT NULL,
    proxima_revisao_km  DECIMAL(10,2)   NULL,
    id_veiculo          INT             NOT NULL,
    id_funcionario_resp INT             NOT NULL,
    CONSTRAINT pk_manutencoes   PRIMARY KEY (id_manutencao),
    CONSTRAINT fk_man_vei       FOREIGN KEY (id_veiculo)
                                REFERENCES veiculos(id_veiculo)
                                ON UPDATE CASCADE,
    CONSTRAINT fk_man_func      FOREIGN KEY (id_funcionario_resp)
                                REFERENCES funcionarios(id_funcionario)
                                ON UPDATE CASCADE,
    CONSTRAINT chk_custo        CHECK (custo >= 0),
    CONSTRAINT chk_datas_manu   CHECK (data_saida IS NULL OR data_saida >= data_entrada)
) ENGINE=InnoDB;


-- ============================================================
-- SEÇÃO 2 — DML: INSERÇÃO DE DADOS
-- ============================================================

-- ------------------------------------------------------------
-- Endereços
-- ------------------------------------------------------------
INSERT INTO enderecos (logradouro, numero, complemento, bairro, cidade, estado, cep) VALUES
('Av. Epitácio Pessoa',       '1200', 'Apto 301',  'Bessa',           'João Pessoa',    'PB', '58036-001'),
('Rua das Trincheiras',       '455',  NULL,        'Centro',          'João Pessoa',    'PB', '58013-420'),
('Av. Beira Mar',             '890',  'Casa 2',    'Tambaú',          'João Pessoa',    'PB', '58039-000'),
('Rua Maestro Villa-Lobos',   '33',   'Bl B Ap 12','Bairro Nobre',    'Campina Grande', 'PB', '58400-105'),
('Av. Agamenon Magalhães',    '3000', NULL,        'Espinheiro',      'Recife',         'PE', '52021-170'),
('Rua da Aurora',             '120',  'Sala 5',    'Santo Antônio',   'Recife',         'PE', '50050-000'),
('Av. Paulista',              '2300', 'Cj 74',     'Bela Vista',      'São Paulo',      'SP', '01310-100'),
('Rua das Flores',            '78',   NULL,        'Ponta Negra',     'Natal',          'RN', '59090-000'),
('Travessa do Carmo',         '15',   'Casa',      'Boa Viagem',      'Recife',         'PE', '51020-310'),
('Av. Dom Helder Câmara',     '500',  NULL,        'Engenho Velho',   'Salvador',       'BA', '41940-455'),
('Rua Coronel Estácio',       '210',  NULL,        'Centro',          'Campina Grande', 'PB', '58400-000'),
('Av. João Medeiros Filho',   '1010', 'Loja 3',    'Lagoa Nova',      'Natal',          'RN', '59056-000'),
('Rua Barão de Itapetininga', '50',   NULL,        'Centro',          'São Paulo',      'SP', '01042-000'),
('Av. Rio Branco',            '156',  NULL,        'Centro',          'Rio de Janeiro', 'RJ', '20040-006'),
('Rua 24 de Outubro',         '1020', 'Ap 801',    'Moinhos de Vento','Porto Alegre',   'RS', '90510-003');

-- ------------------------------------------------------------
-- Cargos
-- ------------------------------------------------------------
INSERT INTO cargos (nome_cargo, descricao, salario_base, nivel) VALUES
('Gerente Geral',         'Gestão geral da concessionária',               8500.00, 'Estratégico'),
('Gerente de Operações',  'Supervisão de aluguéis e frota',               6800.00, 'Tático'),
('Atendente de Locação',  'Atendimento ao cliente e registro de aluguéis', 2800.00, 'Operacional'),
('Analista de TI',        'Suporte e manutenção dos sistemas',             5200.00, 'Tático'),
('Mecânico',              'Manutenção e revisão dos veículos',             3500.00, 'Operacional'),
('Auxiliar Administrativo','Apoio às rotinas administrativas',             2200.00, 'Operacional'),
('Analista Financeiro',   'Controle de pagamentos e relatórios',           5000.00, 'Tático'),
('Lavador/Preparador',    'Higienização e preparação dos veículos',        1800.00, 'Operacional'),
('Consultor de Vendas',   'Prospecção e negociação de contratos de locação', 3200.00, 'Operacional'),
('Coordenador de Frota',  'Gestão e controle do inventário de veículos',     4500.00, 'Tático');

-- ------------------------------------------------------------
-- Funcionários
-- ------------------------------------------------------------
INSERT INTO funcionarios (nome_completo, cpf, email, telefone, data_admissao, matricula, status_func, salario, id_cargo, id_endereco) VALUES
('Carlos Eduardo Lima',      '111.222.333-44', 'carlos.lima@velozcar.com.br',     '(83) 99911-0001', '2020-03-01', 'VC-0001', 'ativo',   8500.00, 1, 1),
('Fernanda Oliveira Souza',  '222.333.444-55', 'fernanda.souza@velozcar.com.br',  '(83) 99911-0002', '2021-06-15', 'VC-0002', 'ativo',   6800.00, 2, 2),
('Lucas Henrique Martins',   '333.444.555-66', 'lucas.martins@velozcar.com.br',   '(83) 99911-0003', '2022-01-10', 'VC-0003', 'ativo',   2800.00, 3, 3),
('Amanda Costa Rodrigues',   '444.555.666-77', 'amanda.rodrigues@velozcar.com.br','(83) 99911-0004', '2022-04-20', 'VC-0004', 'ativo',   2800.00, 3, 4),
('Rafael Torres Neto',       '555.666.777-88', 'rafael.torres@velozcar.com.br',   '(81) 99911-0005', '2021-11-05', 'VC-0005', 'ativo',   3500.00, 5, 5),
('Juliana Pereira Alves',    '666.777.888-99', 'juliana.alves@velozcar.com.br',   '(81) 99911-0006', '2023-02-01', 'VC-0006', 'férias',  2200.00, 6, 6),
('Marcos Vinícius Santos',   '777.888.999-00', 'marcos.santos@velozcar.com.br',   '(11) 99911-0007', '2020-08-12', 'VC-0007', 'ativo',   5000.00, 7, 7),
('Patrícia Barbosa Campos',  '888.999.000-11', 'patricia.campos@velozcar.com.br', '(84) 99911-0008', '2023-07-19', 'VC-0008', 'ativo',   1800.00, 8, 8),
('Thiago Ferreira Cruz',     '999.000.111-22', 'thiago.cruz@velozcar.com.br',     '(81) 99911-0009', '2022-09-03', 'VC-0009', 'ativo',   3500.00, 5, 9),
('Bianca Mendes Figueiredo', '000.111.222-33', 'bianca.figueiredo@velozcar.com.br','(71) 99911-0010','2024-01-15', 'VC-0010', 'ativo',   2800.00, 3,10);

-- ------------------------------------------------------------
-- Clientes
-- ------------------------------------------------------------
INSERT INTO clientes (nome_completo, cpf, data_nascimento, email, telefone, cnh, categoria_cnh, id_endereco) VALUES
('Ana Paula Ferreira',      '123.456.789-01', '1990-05-14', 'anapaula@gmail.com',      '(83) 98800-1001', 'PB-001234567', 'B',  1),
('Bruno Gomes Carvalho',    '234.567.890-12', '1985-11-22', 'brunogomes@gmail.com',    '(83) 98800-2002', 'PB-002345678', 'B',  2),
('Camila Dias Rocha',       '345.678.901-23', '1995-07-08', 'camiladias@outlook.com',  '(11) 98800-3003', 'SP-003456789', 'AB', 3),
('Daniel Nascimento Silva',  '456.789.012-34', '1988-03-30', 'danieln@gmail.com',       '(81) 98800-4004', 'PE-004567890', 'B',  4),
('Eduarda Pinto Lima',      '567.890.123-45', '1993-09-17', 'eduardap@yahoo.com',      '(84) 98800-5005', 'RN-005678901', 'B',  5),
('Felipe Araújo Mendes',    '678.901.234-56', '1980-01-25', 'felipearaujo@gmail.com',  '(83) 98800-6006', 'PB-006789012', 'E',  6),
('Gabriela Nunes Costa',    '789.012.345-67', '1997-12-03', 'gabrielanunes@gmail.com', '(71) 98800-7007', 'BA-007890123', 'B',  7),
('Henrique Teixeira Viana', '890.123.456-78', '1975-06-19', 'hteixeira@empresa.com',   '(11) 98800-8008', 'SP-008901234', 'D',  8),
('Isabela Cardoso Ramos',   '901.234.567-89', '1991-08-11', 'isabelac@gmail.com',      '(81) 98800-9009', 'PE-009012345', 'B',  9),
('João Victor Melo',        '012.345.678-90', '1999-04-27', 'joaomelo@gmail.com',      '(83) 98800-0010', 'PB-010123456', 'B', 10),
('Karen Lopes Freitas',     '102.938.475-61', '1987-10-05', 'karenlopes@hotmail.com',  '(83) 98800-1011', 'PB-011234567', 'B', 11),
('Leonardo Fonseca Batista','203.847.561-72', '1983-02-14', 'leonardob@gmail.com',     '(84) 98800-2012', 'RN-012345678', 'AB',12),
('Marina Correia Abreu',    '304.756.182-83', '1994-07-22', 'marinac@gmail.com',       '(11) 98800-3013', 'SP-013456789', 'B', 13);

-- ------------------------------------------------------------
-- Categorias de veículo
-- ------------------------------------------------------------
INSERT INTO categorias_veiculo (nome_categoria, descricao, diaria_minima, diaria_maxima) VALUES
('Econômico',     'Veículos compactos de baixo consumo',          80.00,  150.00),
('Intermediário', 'Sedans e hatches médios',                     150.00,  250.00),
('SUV Compacto',  'SUVs de porte compacto',                      250.00,  400.00),
('SUV Premium',   'SUVs de luxo e grande porte',                 400.00,  700.00),
('Executivo',     'Sedans de alto padrão',                       350.00,  600.00),
('Utilitário',    'Pickups e veículos para carga leve',          200.00,  380.00),
('Minivan',       'Vans para grupos e famílias',                 280.00,  450.00),
('Elétrico',      'Veículos 100% elétricos',                     200.00,  500.00),
('Esportivo',     'Cupês e esportivos de alto desempenho',        500.00,  900.00),
('Conversível',   'Cabrios e decapotáveis',                       450.00,  850.00);

-- ------------------------------------------------------------
-- Veículos
-- ------------------------------------------------------------
INSERT INTO veiculos (placa, marca, modelo, ano_fabricacao, ano_modelo, cor, numero_chassis, quilometragem, valor_diaria, status_veiculo, id_categoria) VALUES
('PBG-2A01', 'Volkswagen', 'Gol',        2021, 2022, 'Prata',    'VWG0000000000001', 32500.00,  95.00, 'disponível',  1),
('PBH-3B02', 'Chevrolet',  'Onix',       2022, 2022, 'Branco',   'GMA0000000000002', 21000.00,  98.00, 'alugado',     1),
('PBJ-4C03', 'Hyundai',    'HB20',       2021, 2021, 'Vermelho', 'HYU0000000000003', 45000.00,  92.00, 'disponível',  1),
('PBK-5D04', 'Toyota',     'Corolla',    2022, 2023, 'Cinza',    'TOY0000000000004', 18000.00, 185.00, 'disponível',  2),
('PBL-6E05', 'Honda',      'Civic',      2021, 2022, 'Preto',    'HON0000000000005', 28000.00, 195.00, 'alugado',     2),
('PBM-7F06', 'Jeep',       'Compass',    2022, 2023, 'Azul',     'JEP0000000000006', 15000.00, 280.00, 'disponível',  3),
('PBN-8G07', 'Renault',    'Duster',     2021, 2022, 'Prata',    'REN0000000000007', 38000.00, 260.00, 'manutenção',  3),
('PBO-9H08', 'Toyota',     'SW4',        2021, 2022, 'Branco',   'TOY0000000000008', 42000.00, 490.00, 'disponível',  4),
('PBP-0I09', 'BMW',        '320i',       2022, 2023, 'Preto',    'BMW0000000000009',  9500.00, 520.00, 'disponível',  5),
('PBQ-1J10', 'Mercedes',   'C200',       2021, 2022, 'Prata',    'MBZ0000000000010', 22000.00, 580.00, 'alugado',     5),
('PBR-2K11', 'Ford',       'Ranger',     2022, 2023, 'Branco',   'FOR0000000000011', 31000.00, 320.00, 'disponível',  6),
('PBS-3L12', 'Volkswagen', 'Amarok',     2021, 2022, 'Cinza',    'VWA0000000000012', 55000.00, 350.00, 'disponível',  6),
('PBT-4M13', 'Kia',        'Carnival',   2022, 2023, 'Preto',    'KIA0000000000013', 12000.00, 380.00, 'disponível',  7),
('PBU-5N14', 'Chevrolet',  'Tracker',    2023, 2023, 'Branco',   'GMA0000000000014',  5000.00, 265.00, 'disponível',  3),
('PBV-6O15', 'Honda',      'HR-V',       2022, 2023, 'Vermelho', 'HON0000000000015', 19000.00, 270.00, 'disponível',  3);

-- ------------------------------------------------------------
-- Aluguéis
-- ------------------------------------------------------------
INSERT INTO alugueis (data_inicio, data_fim_prevista, data_fim_real, valor_total, valor_multa, quilometragem_saida, quilometragem_retorno, status_aluguel, observacoes, id_cliente, id_funcionario, id_veiculo) VALUES
('2025-10-01','2025-10-05','2025-10-05',  380.00,  0.00, 32500.00, 32850.00, 'finalizado', 'Devolução no prazo',              1, 3,  1),
('2025-10-10','2025-10-14','2025-10-16',  784.00, 98.00, 21000.00, 21420.00, 'finalizado', 'Atraso de 2 dias',                2, 4,  2),
('2025-10-20','2025-10-25','2025-10-25',  975.00,  0.00, 28000.00, 28380.00, 'finalizado', NULL,                              3, 3,  5),
('2025-11-01','2025-11-07','2025-11-07', 1680.00,  0.00, 15000.00, 15620.00, 'finalizado', 'Cliente corporativo',             4, 4,  6),
('2025-11-12','2025-11-17','2025-11-17', 2450.00,  0.00,  9500.00,  9850.00, 'finalizado', NULL,                              5, 3,  9),
('2025-11-20','2025-11-25','2025-11-27', 2900.00,290.00, 22000.00, 22480.00, 'finalizado', 'Retorno com arranhão lateral',    6, 10, 10),
('2025-12-01','2025-12-04','2025-12-04', 285.00,  0.00, 45000.00, 45200.00, 'finalizado', NULL,                              7, 3,  3),
('2025-12-10','2025-12-16','2025-12-16', 1920.00,  0.00, 42000.00, 42500.00, 'finalizado', NULL,                              8, 4,  8),
('2025-12-20','2025-12-26',NULL,         1600.00,  0.00, 31000.00,      NULL, 'atrasado',  'Sem contato com cliente',         9, 10, 11),
('2026-01-05','2026-01-09','2026-01-09',  380.00,  0.00, 32850.00, 33100.00, 'finalizado', NULL,                              10, 3,  1),
('2026-01-15','2026-01-20','2026-01-20',  975.00,  0.00, 18000.00, 18310.00, 'finalizado', NULL,                              11, 4,  4),
('2026-02-01','2026-02-05',NULL,         1050.00,  0.00,  5000.00,       NULL,'ativo',     'Em andamento',                    12, 3, 14),
('2026-02-10','2026-02-13',NULL,          810.00,  0.00, 19000.00,       NULL,'ativo',     NULL,                              13, 10, 15),
('2026-03-01','2026-03-05','2026-03-05', 1040.00,  0.00, 55000.00, 55380.00, 'finalizado', NULL,                              1, 4,  12),
('2026-03-10','2026-03-14',NULL,         1520.00,  0.00, 12000.00,       NULL,'ativo',     'Contrato vigente',                6, 3,  13);

-- ------------------------------------------------------------
-- Pagamentos
-- ------------------------------------------------------------
INSERT INTO pagamentos (valor_pago, data_pagamento, metodo, status_pag, codigo_transacao, parcelas, id_aluguel) VALUES
( 380.00, '2025-10-01 09:30:00', 'pix',            'concluído',  'PIX202510010001', 1,  1),
( 784.00, '2025-10-10 14:15:00', 'cartão_crédito', 'concluído',  'CC20251010K0002', 3,  2),
(  98.00, '2025-10-17 10:00:00', 'pix',            'concluído',  'PIX202510170003', 1,  2),  -- multa
( 975.00, '2025-10-20 11:00:00', 'boleto',         'concluído',  'BOL20251020B004', 1,  3),
(1680.00, '2025-11-01 08:45:00', 'cartão_débito',  'concluído',  'DB20251101D0005', 1,  4),
(2450.00, '2025-11-12 16:20:00', 'cartão_crédito', 'concluído',  'CC20251112K0006', 6,  5),
(2900.00, '2025-11-20 09:00:00', 'pix',            'concluído',  'PIX202511200007', 1,  6),
( 290.00, '2025-11-28 09:00:00', 'pix',            'concluído',  'PIX202511280008', 1,  6),  -- multa
( 285.00, '2025-12-01 10:30:00', 'dinheiro',       'concluído',  NULL,              1,  7),
(1920.00, '2025-12-10 13:00:00', 'cartão_crédito', 'concluído',  'CC20251210K0010', 2,  8),
(1600.00, '2025-12-20 09:00:00', 'pix',            'pendente',   'PIX202512200011', 1,  9),  -- atrasado
( 380.00, '2026-01-05 10:00:00', 'pix',            'concluído',  'PIX202601050012', 1, 10),
( 975.00, '2026-01-15 11:30:00', 'boleto',         'concluído',  'BOL20260115B013', 1, 11),
(1050.00, '2026-02-01 09:00:00', 'cartão_crédito', 'pendente',   'CC20260201K0014', 3, 12),
( 810.00, '2026-02-10 14:00:00', 'pix',            'pendente',   'PIX202602100015', 1, 13);

-- ------------------------------------------------------------
-- Manutenções
-- ------------------------------------------------------------
INSERT INTO manutencoes (tipo_manutencao, descricao, data_entrada, data_saida, custo, fornecedor, numero_ordem, status_manut, quilometragem_atual, proxima_revisao_km, id_veiculo, id_funcionario_resp) VALUES
('preventiva',  'Troca de óleo e filtros — revisão 30.000 km',      '2025-10-05','2025-10-06',  350.00, 'Auto Center JP',     'OS-001', 'concluída',   32850.00, 42850.00,  1, 5),
('corretiva',   'Reparo no sistema de freios dianteiros',            '2025-10-16','2025-10-18',  980.00, 'Freios & Cia',       'OS-002', 'concluída',   21420.00, 31420.00,  2, 9),
('preventiva',  'Revisão completa 40.000 km — troca de correias',   '2025-11-01','2025-11-03', 1200.00, 'AutoCar Service',    'OS-003', 'concluída',   38000.00, 48000.00,  7, 5),
('lavagem',     'Higienização completa pós-locação',                 '2025-11-08','2025-11-08',   80.00, 'LavaRápido Tambaú', 'OS-004', 'concluída',   38380.00,       NULL,  7, 8),
('corretiva',   'Substituição do alternador',                        '2025-12-02','2025-12-05', 1500.00, 'Elétrica Mota',     'OS-005', 'concluída',   45200.00, 55200.00,  3, 9),
('preventiva',  'Troca de pneus — 4 unidades',                      '2025-12-10','2025-12-11',  2400.00,'PneuCenter',        'OS-006', 'concluída',   42500.00, 52500.00,  8, 5),
('recall',      'Recall fabricante — sensor de airbag',             '2026-01-05','2026-01-07',    0.00, 'BMW Concessionária', 'OS-007', 'concluída',    9850.00, 19850.00,  9, 5),
('revisão',     'Revisão semestral 50.000 km',                      '2026-01-20','2026-01-22', 1800.00, 'Auto Center JP',    'OS-008', 'concluída',   55000.00, 65000.00, 12, 9),
('corretiva',   'Reparo na lataria — arranhão lateral',             '2026-01-28','2026-02-03', 1100.00, 'Funilaria Central', 'OS-009', 'concluída',   22480.00, 32480.00, 10, 5),
('preventiva',  'Troca de óleo sintético e filtro de ar',           '2026-02-10','2026-02-10',  420.00, 'Auto Center JP',    'OS-010', 'concluída',   28000.00, 38000.00,  5, 9),
('corretiva'  , 'Verificação do sistema de injeção eletrônica',     '2026-02-20',NULL,          600.00, 'AutoCar Service',   'OS-011', 'em andamento', 38000.00, NULL,       7, 5),
('lavagem',     'Preparação para nova locação',                     '2026-03-05','2026-03-05',   80.00, 'LavaRápido Tambaú', 'OS-012', 'concluída',   33100.00, NULL,      12, 8),
('preventiva',  'Revisão 20.000 km — troca de velas e filtros',    '2026-03-08','2026-03-09',  550.00, 'Auto Center JP',    'OS-013', 'concluída',   19000.00, 29000.00, 15, 9);


-- ============================================================
-- SEÇÃO 3 — DML: ATUALIZAÇÕES (UPDATE)
-- ============================================================

-- UPDATE 1: Marcar veículo como disponível após devolução atrasada do aluguel #9
-- Motivo: aluguel 9 está com status 'atrasado' — após acordo extrajudicial,
-- o veículo foi devolvido e o contrato encerrado.
UPDATE alugueis
SET
    data_fim_real      = '2026-01-10',
    status_aluguel     = 'finalizado',
    valor_multa        = 640.00,     -- 16 dias de atraso × R$40/dia
    observacoes        = 'Devolvido em 10/01/2026 após contato jurídico. Multa aplicada.'
WHERE id_aluguel = 9;

UPDATE veiculos
SET status_veiculo = 'disponível'
WHERE id_veiculo = 11;

-- UPDATE 2: Aplicar reajuste salarial de 8% para todos os atendentes de locação
-- Motivo: reajuste anual da categoria conforme convenção coletiva 2026.
UPDATE funcionarios f
INNER JOIN cargos c ON f.id_cargo = c.id_cargo
SET f.salario = ROUND(f.salario * 1.08, 2)
WHERE c.nome_cargo = 'Atendente de Locação';

-- UPDATE 3 (extra): Atualizar quilometragem dos veículos com aluguel finalizado
UPDATE veiculos v
INNER JOIN alugueis a ON a.id_veiculo = v.id_veiculo
SET v.quilometragem = a.quilometragem_retorno
WHERE a.status_aluguel = 'finalizado'
  AND a.quilometragem_retorno IS NOT NULL
  AND a.data_fim_real = (
      SELECT MAX(a2.data_fim_real)
      FROM alugueis a2
      WHERE a2.id_veiculo = v.id_veiculo
        AND a2.status_aluguel = 'finalizado'
  );


-- ============================================================
-- SEÇÃO 4 — DQL: CONSULTAS ANALÍTICAS
-- ============================================================

-- ─────────────────────────────────────
-- CLIENTES
-- ─────────────────────────────────────

-- DQL-01: Total de aluguéis por cliente e valor gasto (ordenado por maior gasto)
-- Insight: identificar clientes de maior valor para programas de fidelidade
SELECT
    c.nome_completo,
    COUNT(a.id_aluguel)          AS total_alugueis,
    SUM(a.valor_total)           AS total_gasto,
    AVG(a.valor_total)           AS ticket_medio,
    MAX(a.data_inicio)           AS ultimo_aluguel
FROM clientes c
LEFT JOIN alugueis a ON a.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nome_completo
ORDER BY total_gasto DESC;

-- DQL-02: Clientes que realizaram mais de 1 aluguel (potencial de retenção)
-- Insight: base de clientes recorrentes — alvo para campanhas de retenção
SELECT
    c.nome_completo,
    c.email,
    COUNT(a.id_aluguel) AS qtd_alugueis,
    SUM(a.valor_total)  AS receita_gerada
FROM clientes c
INNER JOIN alugueis a ON a.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nome_completo, c.email
HAVING COUNT(a.id_aluguel) > 1
ORDER BY qtd_alugueis DESC;

-- ─────────────────────────────────────
-- VEÍCULOS
-- ─────────────────────────────────────

-- DQL-03: Receita gerada por veículo e taxa de ocupação
-- Insight: detectar veículos mais rentáveis e os ociosos
SELECT
    v.placa,
    v.marca,
    v.modelo,
    cat.nome_categoria,
    COUNT(a.id_aluguel)                    AS total_locacoes,
    COALESCE(SUM(a.valor_total), 0)        AS receita_total,
    COALESCE(AVG(a.valor_total), 0)        AS receita_media,
    v.status_veiculo
FROM veiculos v
LEFT JOIN alugueis a      ON a.id_veiculo   = v.id_veiculo
LEFT JOIN categorias_veiculo cat ON cat.id_categoria = v.id_categoria
GROUP BY v.id_veiculo, v.placa, v.marca, v.modelo, cat.nome_categoria, v.status_veiculo
ORDER BY receita_total DESC;

-- DQL-04: Custo total de manutenção por veículo
-- Insight: identificar veículos com alto custo de manutenção (candidatos à renovação de frota)
SELECT
    v.placa,
    v.marca,
    v.modelo,
    v.ano_fabricacao,
    COUNT(m.id_manutencao)        AS total_manutencoes,
    SUM(m.custo)                  AS custo_total_manutencao,
    AVG(m.custo)                  AS custo_medio_manutencao,
    MAX(m.data_entrada)           AS ultima_manutencao
FROM veiculos v
LEFT JOIN manutencoes m ON m.id_veiculo = v.id_veiculo
GROUP BY v.id_veiculo, v.placa, v.marca, v.modelo, v.ano_fabricacao
ORDER BY custo_total_manutencao DESC;

-- ─────────────────────────────────────
-- ALUGUÉIS
-- ─────────────────────────────────────

-- DQL-05: Receita mensal de aluguéis (últimos 6 meses)
-- Insight: sazonalidade — quais meses geram mais receita
SELECT
    DATE_FORMAT(data_inicio, '%Y-%m') AS mes,
    COUNT(*)                           AS total_contratos,
    SUM(valor_total)                   AS receita_bruta,
    SUM(valor_multa)                   AS total_multas,
    AVG(DATEDIFF(COALESCE(data_fim_real, data_fim_prevista), data_inicio)) AS duracao_media_dias
FROM alugueis
WHERE data_inicio >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY DATE_FORMAT(data_inicio, '%Y-%m')
ORDER BY mes;

-- DQL-06: Distribuição de aluguéis por status
-- Insight: monitoramento operacional — quantos contratos estão em aberto/atrasados
SELECT
    status_aluguel,
    COUNT(*)           AS quantidade,
    SUM(valor_total)   AS valor_envolvido,
    AVG(valor_total)   AS valor_medio
FROM alugueis
GROUP BY status_aluguel
ORDER BY quantidade DESC;

-- ─────────────────────────────────────
-- PAGAMENTOS
-- ─────────────────────────────────────

-- DQL-07: Receita por método de pagamento
-- Insight: entender preferências e custos de cada canal de pagamento
SELECT
    metodo,
    COUNT(*)            AS total_transacoes,
    SUM(valor_pago)     AS valor_total,
    AVG(valor_pago)     AS ticket_medio,
    SUM(CASE WHEN status_pag = 'concluído' THEN valor_pago ELSE 0 END) AS total_confirmado
FROM pagamentos
GROUP BY metodo
ORDER BY valor_total DESC;

-- DQL-08: Pagamentos pendentes — exposição ao risco de inadimplência
-- Insight: acompanhamento financeiro urgente
SELECT
    p.id_pagamento,
    c.nome_completo    AS cliente,
    p.valor_pago       AS valor_pendente,
    p.metodo,
    p.data_pagamento   AS data_registro,
    a.status_aluguel
FROM pagamentos p
INNER JOIN alugueis a   ON a.id_aluguel = p.id_aluguel
INNER JOIN clientes c   ON c.id_cliente = a.id_cliente
WHERE p.status_pag = 'pendente'
ORDER BY p.data_pagamento;

-- ─────────────────────────────────────
-- FUNCIONÁRIOS
-- ─────────────────────────────────────

-- DQL-09: Desempenho dos atendentes — quantidade e receita gerada por contratos
-- Insight: avaliar produtividade individual da equipe
SELECT
    f.nome_completo,
    cg.nome_cargo,
    COUNT(a.id_aluguel)      AS contratos_realizados,
    SUM(a.valor_total)       AS receita_gerada,
    AVG(a.valor_total)       AS ticket_medio_contrato
FROM funcionarios f
INNER JOIN cargos cg  ON cg.id_cargo = f.id_cargo
LEFT JOIN  alugueis a ON a.id_funcionario = f.id_funcionario
GROUP BY f.id_funcionario, f.nome_completo, cg.nome_cargo
ORDER BY receita_gerada DESC;

-- DQL-10: Custo da folha salarial por cargo
-- Insight: peso de cada nível hierárquico no custo operacional
SELECT
    cg.nome_cargo,
    cg.nivel,
    COUNT(f.id_funcionario)          AS total_funcionarios,
    AVG(f.salario)                   AS salario_medio,
    SUM(f.salario)                   AS custo_mensal_total
FROM cargos cg
LEFT JOIN funcionarios f ON f.id_cargo = cg.id_cargo AND f.status_func != 'inativo'
GROUP BY cg.id_cargo, cg.nome_cargo, cg.nivel
ORDER BY custo_mensal_total DESC;

-- ─────────────────────────────────────
-- MANUTENÇÕES
-- ─────────────────────────────────────

-- DQL-11: Custo total de manutenção por tipo e fornecedor
-- Insight: avaliar se algum fornecedor é mais caro e se os tipos de manutenção estão equilibrados
SELECT
    tipo_manutencao,
    fornecedor,
    COUNT(*)     AS ocorrencias,
    SUM(custo)   AS custo_total,
    AVG(custo)   AS custo_medio,
    MIN(custo)   AS menor_custo,
    MAX(custo)   AS maior_custo
FROM manutencoes
GROUP BY tipo_manutencao, fornecedor
ORDER BY custo_total DESC;

-- DQL-12: Tempo médio de imobilização por tipo de manutenção (dias)
-- Insight: quanto tempo cada tipo de manutenção tira o veículo de circulação
SELECT
    tipo_manutencao,
    COUNT(*) AS total,
    ROUND(AVG(DATEDIFF(COALESCE(data_saida, CURDATE()), data_entrada)), 1) AS media_dias_imobilizado,
    MAX(DATEDIFF(COALESCE(data_saida, CURDATE()), data_entrada))           AS max_dias,
    SUM(custo) AS custo_acumulado
FROM manutencoes
GROUP BY tipo_manutencao
ORDER BY media_dias_imobilizado DESC;

-- ─────────────────────────────────────
-- CATEGORIAS
-- ─────────────────────────────────────

-- DQL-13: Receita e frequência de aluguel por categoria de veículo
-- Insight: quais categorias são mais demandadas e lucrativas
SELECT
    cat.nome_categoria,
    COUNT(DISTINCT v.id_veiculo)   AS veiculos_na_frota,
    COUNT(a.id_aluguel)            AS total_alugueis,
    SUM(a.valor_total)             AS receita_total,
    AVG(v.valor_diaria)            AS diaria_media_cobrada
FROM categorias_veiculo cat
LEFT JOIN veiculos v ON v.id_categoria = cat.id_categoria
LEFT JOIN alugueis a ON a.id_veiculo   = v.id_veiculo
GROUP BY cat.id_categoria, cat.nome_categoria
ORDER BY receita_total DESC;

-- DQL-14: Ticket médio e ocupação por categoria
SELECT
    cat.nome_categoria,
    COUNT(a.id_aluguel) AS locacoes,
    ROUND(AVG(a.valor_total), 2) AS ticket_medio,
    ROUND(AVG(DATEDIFF(COALESCE(a.data_fim_real, a.data_fim_prevista), a.data_inicio)), 1) AS duracao_media_dias
FROM categorias_veiculo cat
LEFT JOIN veiculos v ON v.id_categoria = cat.id_categoria
LEFT JOIN alugueis a ON a.id_veiculo   = v.id_veiculo
GROUP BY cat.id_categoria, cat.nome_categoria
ORDER BY locacoes DESC;


-- ─────────────────────────────────────
-- JOINs
-- ─────────────────────────────────────

-- JOIN-01 (INNER JOIN): Contratos ativos com dados completos do cliente, veículo e funcionário
-- Insight: visão operacional do dia a dia — o que está em campo agora
SELECT
    a.id_aluguel,
    c.nome_completo                                    AS cliente,
    c.telefone                                         AS telefone_cliente,
    v.placa,
    CONCAT(v.marca,' ',v.modelo,' (',v.ano_modelo,')') AS veiculo,
    f.nome_completo                                    AS atendente,
    a.data_inicio,
    a.data_fim_prevista,
    DATEDIFF(a.data_fim_prevista, CURDATE())           AS dias_restantes,
    a.valor_total,
    a.status_aluguel
FROM alugueis a
INNER JOIN clientes     c ON c.id_cliente    = a.id_cliente
INNER JOIN veiculos     v ON v.id_veiculo    = a.id_veiculo
INNER JOIN funcionarios f ON f.id_funcionario = a.id_funcionario
WHERE a.status_aluguel IN ('ativo','atrasado')
ORDER BY a.data_fim_prevista;

-- JOIN-02 (LEFT JOIN): Todos os veículos e seus aluguéis (incluindo os nunca alugados)
-- Insight: detectar veículos ociosos que nunca foram locados — custo sem retorno
SELECT
    v.placa,
    v.marca,
    v.modelo,
    cat.nome_categoria,
    v.status_veiculo,
    COUNT(a.id_aluguel)              AS total_locacoes,
    COALESCE(SUM(a.valor_total), 0)  AS receita_gerada,
    MAX(a.data_inicio)               AS ultima_locacao
FROM veiculos v
LEFT JOIN categorias_veiculo cat ON cat.id_categoria = v.id_categoria
LEFT JOIN alugueis a             ON a.id_veiculo     = v.id_veiculo
GROUP BY v.id_veiculo, v.placa, v.marca, v.modelo, cat.nome_categoria, v.status_veiculo
ORDER BY total_locacoes ASC, receita_gerada ASC;

-- JOIN-03 (RIGHT JOIN): Todos os pagamentos e seus respectivos aluguéis
-- Insight: rastrear pagamentos e identificar quais aluguéis têm pagamentos em aberto
SELECT
    p.id_pagamento,
    p.metodo,
    p.valor_pago,
    p.status_pag,
    p.data_pagamento,
    a.id_aluguel,
    a.status_aluguel,
    c.nome_completo AS cliente
FROM alugueis a
RIGHT JOIN pagamentos p ON p.id_aluguel = a.id_aluguel
LEFT  JOIN clientes   c ON c.id_cliente = a.id_cliente
ORDER BY p.data_pagamento DESC;

-- JOIN-04 (INNER JOIN triplo + agregação — BÔNUS):
-- Ranking de funcionários: receita gerada × custo salarial (ROI do atendente)
SELECT
    f.nome_completo,
    cg.nome_cargo,
    f.salario                              AS salario_atual,
    COUNT(a.id_aluguel)                    AS contratos,
    COALESCE(SUM(a.valor_total), 0)        AS receita_gerada,
    ROUND(COALESCE(SUM(a.valor_total), 0)
          / f.salario, 2)                  AS ratio_receita_salario
FROM funcionarios f
INNER JOIN cargos   cg ON cg.id_cargo       = f.id_cargo
LEFT  JOIN alugueis a  ON a.id_funcionario  = f.id_funcionario
GROUP BY f.id_funcionario, f.nome_completo, cg.nome_cargo, f.salario
ORDER BY ratio_receita_salario DESC;

-- ============================================================
-- FIM DO SCRIPT — VelozCar v1.0
-- ============================================================
