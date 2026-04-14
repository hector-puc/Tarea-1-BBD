-- ============================================================
-- LIMPIEZA INICIAL
-- ============================================================
DROP VIEW IF EXISTS v_resumen_financiero_torneo CASCADE;
DROP VIEW IF EXISTS v_stats_jugador_torneo CASCADE;
DROP VIEW IF EXISTS v_clasificacion_grupos CASCADE;
DROP TABLE IF EXISTS Auspicio CASCADE;
DROP TABLE IF EXISTS Sponsor CASCADE;
DROP TABLE IF EXISTS EstadisticaIndividual CASCADE;
DROP TABLE IF EXISTS Partida CASCADE;
DROP TABLE IF EXISTS Inscripcion CASCADE;
DROP TABLE IF EXISTS Torneo CASCADE;
DROP TABLE IF EXISTS Jugador CASCADE;
DROP TABLE IF EXISTS Equipo CASCADE;

-- ============================================================
-- TABLA: Equipo
-- ============================================================
CREATE TABLE Equipo (
    nombre_equipo    VARCHAR(100)    PRIMARY KEY,
    fecha_creacion   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    capitan_gamertag VARCHAR(50)     -- FK añadida después por dependencia circular
);

-- ============================================================
-- TABLA: Jugador
-- ============================================================
CREATE TABLE Jugador (
    gamertag         VARCHAR(50)     PRIMARY KEY,
    nombre_real      VARCHAR(100)    NOT NULL,
    email            VARCHAR(150)    NOT NULL UNIQUE,
    fecha_nacimiento DATE            NOT NULL,
    pais_origen      VARCHAR(50)     NOT NULL,
    nombre_equipo    VARCHAR(100)    NOT NULL,

    CONSTRAINT fk_jugador_equipo 
        FOREIGN KEY (nombre_equipo) REFERENCES Equipo(nombre_equipo)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
-- FK DIFERIDA: Equipo -> Jugador (Capitán)
-- ============================================================
ALTER TABLE Equipo 
    ADD CONSTRAINT fk_equipo_capitan 
    FOREIGN KEY (capitan_gamertag) REFERENCES Jugador(gamertag)
    ON DELETE RESTRICT ON UPDATE CASCADE
    DEFERRABLE INITIALLY DEFERRED;

-- TRIGGER: Validar que el capitán pertenezca al equipo
CREATE OR REPLACE FUNCTION fn_validar_capitan() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.capitan_gamertag IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM Jugador WHERE gamertag = NEW.capitan_gamertag AND nombre_equipo = NEW.nombre_equipo
        ) THEN
            RAISE EXCEPTION 'EL CAPITÁN % NO PERTENECE AL EQUIPO %', NEW.capitan_gamertag, NEW.nombre_equipo;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_capitan BEFORE INSERT OR UPDATE ON Equipo
FOR EACH ROW EXECUTE FUNCTION fn_validar_capitan();

-- ============================================================
-- TABLA: Torneo
-- ============================================================
CREATE TABLE Torneo (
    nombre           VARCHAR(150)    PRIMARY KEY,
    videojuego       VARCHAR(100)    NOT NULL,
    fecha_inicio     DATE            NOT NULL,
    fecha_fin        DATE            NOT NULL,
    prize_pool_usd   DECIMAL(14,2)   NOT NULL CHECK (prize_pool_usd >= 0),
    max_equipos      INT             NOT NULL CHECK (max_equipos > 0),
    CONSTRAINT chk_fechas CHECK (fecha_fin >= fecha_inicio)
);

-- ============================================================
-- TABLA: Inscripcion
-- ============================================================
CREATE TABLE Inscripcion (
    nombre_torneo     VARCHAR(150)    NOT NULL,
    nombre_equipo     VARCHAR(100)    NOT NULL,
    grupo             CHAR(1)         CHECK (grupo IN ('A', 'B')),
    fecha_inscripcion TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (nombre_torneo, nombre_equipo),
    FOREIGN KEY (nombre_torneo) REFERENCES Torneo(nombre) ON DELETE CASCADE,
    FOREIGN KEY (nombre_equipo) REFERENCES Equipo(nombre_equipo) ON DELETE RESTRICT
);

-- TRIGGER: Validar cupo máximo
CREATE OR REPLACE FUNCTION fn_validar_cupo() RETURNS TRIGGER AS $$
DECLARE
    v_max INT; v_actual INT;
BEGIN
    SELECT max_equipos INTO v_max FROM Torneo WHERE nombre = NEW.nombre_torneo;
    SELECT COUNT(*) INTO v_actual FROM Inscripcion WHERE nombre_torneo = NEW.nombre_torneo;
    IF v_actual >= v_max THEN
        RAISE EXCEPTION 'CUPO EXCEDIDO EN EL TORNEO %', NEW.nombre_torneo;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_cupo BEFORE INSERT ON Inscripcion
FOR EACH ROW EXECUTE FUNCTION fn_validar_cupo();

-- ============================================================
-- TABLA: Partida
-- ============================================================
CREATE TABLE Partida (
    id_partida       BIGSERIAL       PRIMARY KEY,
    nombre_torneo    VARCHAR(150)    NOT NULL,
    equipo_a         VARCHAR(100)    NOT NULL,
    equipo_b         VARCHAR(100)    NOT NULL,
    fecha_hora       TIMESTAMP       NOT NULL,
    fase             VARCHAR(20)     NOT NULL CHECK (fase IN ('fase de grupos', 'cuartos de final', 'semifinal', 'final')),
    puntaje_a        INT             CHECK (puntaje_a >= 0),
    puntaje_b        INT             CHECK (puntaje_b >= 0),

    FOREIGN KEY (nombre_torneo) REFERENCES Torneo(nombre),
    FOREIGN KEY (equipo_a) REFERENCES Equipo(nombre_equipo),
    FOREIGN KEY (equipo_b) REFERENCES Equipo(nombre_equipo),
    CONSTRAINT chk_equipos_distintos CHECK (equipo_a <> equipo_b),
    CONSTRAINT chk_puntajes_completos CHECK (
        (puntaje_a IS NULL AND puntaje_b IS NULL) OR (puntaje_a IS NOT NULL AND puntaje_b IS NOT NULL)
    )
);

-- ============================================================
-- TABLA: EstadisticaIndividual
-- ============================================================
CREATE TABLE EstadisticaIndividual (
    id_partida       BIGINT          NOT NULL,
    gamertag         VARCHAR(50)     NOT NULL,
    kos              INT             NOT NULL DEFAULT 0 CHECK (kos >= 0),
    restarts         INT             NOT NULL DEFAULT 0 CHECK (restarts >= 0),
    assists          INT             NOT NULL DEFAULT 0 CHECK (assists >= 0),

    PRIMARY KEY (id_partida, gamertag),
    FOREIGN KEY (id_partida) REFERENCES Partida(id_partida),
    FOREIGN KEY (gamertag) REFERENCES Jugador(gamertag)
);

-- ============================================================
-- TABLA: Sponsor
-- ============================================================
CREATE TABLE Sponsor (
    nombre_sponsor   VARCHAR(100)    PRIMARY KEY,
    industria        VARCHAR(50)     NOT NULL
);

-- ============================================================
-- TABLA: Auspicio
-- ============================================================
CREATE TABLE Auspicio (
    nombre_sponsor   VARCHAR(100)    NOT NULL,
    nombre_torneo    VARCHAR(150)    NOT NULL,
    monto_usd        DECIMAL(14,2)   NOT NULL CHECK (monto_usd > 0),

    PRIMARY KEY (nombre_sponsor, nombre_torneo),
    FOREIGN KEY (nombre_sponsor) REFERENCES Sponsor(nombre_sponsor),
    FOREIGN KEY (nombre_torneo) REFERENCES Torneo(nombre)
);
