-- ============================================================
--  BASE DE DATOS: SISTEMA DE GESTIÓN DE TORNEOS DE VIDEOJUEGOS
--  Motor: PostgreSQL 15+
--  Autor: Generado a partir de requerimientos del cliente
-- ============================================================
--
--  NOTA SOBRE DEPENDENCIA CIRCULAR (Equipo <-> Jugador):
--  Equipo.id_capitan → Jugador  y  Jugador.id_equipo → Equipo
--  Solución: Crear Equipo con id_capitan nullable primero,
--  luego Jugador, luego agregar FK DEFERRABLE INITIALLY DEFERRED.
--  Esto permite insertar Equipo + sus Jugadores en una sola
--  transacción antes de asignar el capitán.
-- ============================================================

-- ============================================================
-- LIMPIEZA INICIAL (Para permitir reinicializar sin errores)
-- ============================================================
DROP VIEW IF EXISTS v_resumen_financiero_torneo CASCADE;
DROP VIEW IF EXISTS v_stats_jugador_torneo CASCADE;
DROP VIEW IF EXISTS v_clasificacion_grupos CASCADE;
DROP TABLE IF EXISTS Auspicio_Torneo CASCADE;
DROP TABLE IF EXISTS Sponsor CASCADE;
DROP TABLE IF EXISTS Estadistica_Individual CASCADE;
DROP TABLE IF EXISTS Partida CASCADE;
DROP TABLE IF EXISTS Inscripcion_Torneo CASCADE;
DROP TABLE IF EXISTS Torneo CASCADE;
DROP TABLE IF EXISTS Jugador CASCADE;
DROP TABLE IF EXISTS Equipo CASCADE;
DROP TYPE IF EXISTS fase_torneo CASCADE;

-- ============================================================
-- TIPOS ENUMERADOS
-- ============================================================

CREATE TYPE fase_torneo AS ENUM (
    'fase de grupos',
    'cuartos de final',
    'semifinal',
    'final'
);

-- ============================================================
-- TABLA: Equipo
-- Se crea sin la FK de id_capitan (dependencia circular).
-- La FK se agrega después de crear la tabla Jugador.
-- ============================================================

CREATE TABLE Equipo (
    id_equipo       BIGSERIAL       NOT NULL,
    nombre          VARCHAR(100)    NOT NULL,
    fecha_creacion  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_capitan      BIGINT,         -- FK añadida más abajo con ALTER TABLE

    CONSTRAINT pk_equipo        PRIMARY KEY (id_equipo),
    CONSTRAINT uq_equipo_nombre UNIQUE      (nombre)
);

COMMENT ON TABLE  Equipo             IS 'Equipos formados por jugadores.';
COMMENT ON COLUMN Equipo.id_capitan  IS 'Debe ser un jugador miembro de este mismo equipo (validado por trigger).';

-- ============================================================
-- TABLA: Jugador
-- ============================================================

CREATE TABLE Jugador (
    id_jugador          BIGSERIAL       NOT NULL,
    id_equipo           BIGINT          NOT NULL,
    gamertag            VARCHAR(50)     NOT NULL,
    nombre_real         VARCHAR(100)    NOT NULL,
    email               VARCHAR(150)    NOT NULL,
    fecha_nacimiento    DATE            NOT NULL,
    pais_origen         VARCHAR(50)     NOT NULL,

    CONSTRAINT pk_jugador           PRIMARY KEY (id_jugador),
    CONSTRAINT uq_jugador_gamertag  UNIQUE      (gamertag),
    CONSTRAINT uq_jugador_email     UNIQUE      (email),

    CONSTRAINT fk_jugador_equipo
        FOREIGN KEY (id_equipo)
        REFERENCES  Equipo(id_equipo)
        ON DELETE   RESTRICT
        ON UPDATE   CASCADE
);

COMMENT ON TABLE  Jugador                IS 'Usuarios registrados en la plataforma. Cada jugador pertenece exactamente a un equipo (fijo).';
COMMENT ON COLUMN Jugador.gamertag       IS 'Identificador único público del jugador dentro de la plataforma.';
COMMENT ON COLUMN Jugador.id_equipo      IS 'Membresía fija: no cambia entre torneos.';

-- ============================================================
-- FK DIFERIDA: Equipo.id_capitan → Jugador
-- DEFERRABLE INITIALLY DEFERRED permite insertar Equipo y sus
-- Jugadores en la misma transacción antes de fijar el capitán.
-- ============================================================

ALTER TABLE Equipo
    ADD CONSTRAINT fk_equipo_capitan
        FOREIGN KEY (id_capitan)
        REFERENCES  Jugador(id_jugador)
        ON DELETE   RESTRICT
        ON UPDATE   CASCADE
        DEFERRABLE INITIALLY DEFERRED;

-- ============================================================
-- TRIGGER: Validar que el capitán pertenezca al equipo
-- ============================================================

CREATE OR REPLACE FUNCTION fn_validar_capitan()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
BEGIN
    -- Solo validar si id_capitan no es NULL
    IF NEW.id_capitan IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1
            FROM   Jugador
            WHERE  id_jugador = NEW.id_capitan
            AND    id_equipo  = NEW.id_equipo
        ) THEN
            RAISE EXCEPTION
                'VIOLACIÓN DE INTEGRIDAD: El capitán (id_jugador=%) '
                'no pertenece al equipo (id_equipo=%).',
                NEW.id_capitan, NEW.id_equipo;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_capitan
    BEFORE INSERT OR UPDATE ON Equipo
    FOR EACH ROW
    EXECUTE FUNCTION fn_validar_capitan();

-- ============================================================
-- TABLA: Torneo
-- ============================================================

CREATE TABLE Torneo (
    id_torneo       BIGSERIAL           NOT NULL,
    nombre          VARCHAR(150)        NOT NULL,
    videojuego      VARCHAR(100)        NOT NULL,
    fecha_inicio    DATE                NOT NULL,
    fecha_fin       DATE                NOT NULL,
    prize_pool_usd  DECIMAL(14, 2)      NOT NULL,
    max_equipos     INT                 NOT NULL DEFAULT 8,

    CONSTRAINT pk_torneo            PRIMARY KEY (id_torneo),
    CONSTRAINT chk_torneo_fechas    CHECK (fecha_fin >= fecha_inicio),
    CONSTRAINT chk_torneo_prize     CHECK (prize_pool_usd >= 0),
    CONSTRAINT chk_torneo_max_eq    CHECK (max_equipos > 0)
);

COMMENT ON TABLE  Torneo                IS 'Competencias organizadas por la plataforma.';
COMMENT ON COLUMN Torneo.prize_pool_usd IS 'Pozo de premios total en dólares estadounidenses.';
COMMENT ON COLUMN Torneo.max_equipos    IS 'Límite de equipos inscribibles. El formato estándar es 8.';

-- ============================================================
-- TABLA: Inscripcion_Torneo  (relación N:M Equipo ↔ Torneo)
-- ============================================================

CREATE TABLE Inscripcion_Torneo (
    id_torneo           BIGINT      NOT NULL,
    id_equipo           BIGINT      NOT NULL,
    grupo               CHAR(1),    -- 'A' o 'B' para fase de grupos
    fecha_inscripcion   TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_inscripcion
        PRIMARY KEY (id_torneo, id_equipo),

    CONSTRAINT fk_inscripcion_torneo
        FOREIGN KEY (id_torneo)
        REFERENCES  Torneo(id_torneo)
        ON DELETE   CASCADE
        ON UPDATE   CASCADE,

    CONSTRAINT fk_inscripcion_equipo
        FOREIGN KEY (id_equipo)
        REFERENCES  Equipo(id_equipo)
        ON DELETE   RESTRICT
        ON UPDATE   CASCADE,

    CONSTRAINT chk_inscripcion_grupo
        CHECK (grupo IN ('A', 'B') OR grupo IS NULL)
);

COMMENT ON TABLE  Inscripcion_Torneo        IS 'Registro de qué equipos participan en qué torneos.';
COMMENT ON COLUMN Inscripcion_Torneo.grupo  IS 'Grupo asignado en la fase de grupos (A o B). NULL si aún no se asignó.';

-- ============================================================
-- TRIGGER: Validar cupo máximo de equipos por torneo
-- ============================================================

CREATE OR REPLACE FUNCTION fn_validar_max_equipos()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
DECLARE
    v_max_equipos   INT;
    v_inscritos     INT;
BEGIN
    SELECT max_equipos
    INTO   v_max_equipos
    FROM   Torneo
    WHERE  id_torneo = NEW.id_torneo;

    SELECT COUNT(*)
    INTO   v_inscritos
    FROM   Inscripcion_Torneo
    WHERE  id_torneo = NEW.id_torneo;

    IF v_inscritos >= v_max_equipos THEN
        RAISE EXCEPTION
            'CUPO EXCEDIDO: El torneo (id=%) ya tiene % equipos inscritos '
            '(máximo permitido: %).',
            NEW.id_torneo, v_inscritos, v_max_equipos;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_max_equipos
    BEFORE INSERT ON Inscripcion_Torneo
    FOR EACH ROW
    EXECUTE FUNCTION fn_validar_max_equipos();

-- ============================================================
-- TABLA: Partida
-- ============================================================

CREATE TABLE Partida (
    id_partida          BIGSERIAL       NOT NULL,
    id_torneo           BIGINT          NOT NULL,
    id_equipo_A         BIGINT          NOT NULL,
    id_equipo_B         BIGINT          NOT NULL,
    fecha_hora          TIMESTAMP       NOT NULL,
    fase                fase_torneo     NOT NULL,
    puntaje_equipo_A    INT             DEFAULT NULL,   -- NULL hasta que se juegue
    puntaje_equipo_B    INT             DEFAULT NULL,

    CONSTRAINT pk_partida           PRIMARY KEY (id_partida),

    CONSTRAINT fk_partida_torneo
        FOREIGN KEY (id_torneo)
        REFERENCES  Torneo(id_torneo)
        ON DELETE   RESTRICT --Restringe la eliminacion de datos
        ON UPDATE   CASCADE, -- Hace que se actualicen losa datos en cascada

    CONSTRAINT fk_partida_equipo_A
        FOREIGN KEY (id_equipo_A)
        REFERENCES  Equipo(id_equipo)
        ON DELETE   RESTRICT
        ON UPDATE   CASCADE,

    CONSTRAINT fk_partida_equipo_B
        FOREIGN KEY (id_equipo_B)
        REFERENCES  Equipo(id_equipo)
        ON DELETE   RESTRICT
        ON UPDATE   CASCADE,

    -- Los dos equipos deben ser distintos
    CONSTRAINT chk_partida_equipos_distintos
        CHECK (id_equipo_A <> id_equipo_B),

    -- Puntajes no negativos si ya fueron registrados
    CONSTRAINT chk_partida_puntaje_A
        CHECK (puntaje_equipo_A IS NULL OR puntaje_equipo_A >= 0),
    CONSTRAINT chk_partida_puntaje_B
        CHECK (puntaje_equipo_B IS NULL OR puntaje_equipo_B >= 0),

    -- Ambos puntajes deben registrarse juntos (no parciales)
    CONSTRAINT chk_partida_puntajes_completos
        CHECK (
            (puntaje_equipo_A IS NULL AND puntaje_equipo_B IS NULL) OR
            (puntaje_equipo_A IS NOT NULL AND puntaje_equipo_B IS NOT NULL)
        )
);

COMMENT ON TABLE  Partida                   IS 'Encuentros disputados dentro de un torneo entre exactamente dos equipos.';
COMMENT ON COLUMN Partida.puntaje_equipo_A  IS 'NULL mientras la partida no se ha jugado. Se registra junto con puntaje_equipo_B.';
COMMENT ON COLUMN Partida.fase              IS 'Fase del torneo: fase de grupos, cuartos de final, semifinal o final.';

-- ============================================================
-- TRIGGER: Validar que ambos equipos estén inscritos en el torneo
-- ============================================================

CREATE OR REPLACE FUNCTION fn_validar_equipos_inscritos()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM   Inscripcion_Torneo
        WHERE  id_torneo = NEW.id_torneo
        AND    id_equipo = NEW.id_equipo_A
    ) THEN
        RAISE EXCEPTION
            'EQUIPO NO INSCRITO: El equipo A (id=%) no está inscrito '
            'en el torneo (id=%).',
            NEW.id_equipo_A, NEW.id_torneo;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM   Inscripcion_Torneo
        WHERE  id_torneo = NEW.id_torneo
        AND    id_equipo = NEW.id_equipo_B
    ) THEN
        RAISE EXCEPTION
            'EQUIPO NO INSCRITO: El equipo B (id=%) no está inscrito '
            'en el torneo (id=%).',
            NEW.id_equipo_B, NEW.id_torneo;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_equipos_inscritos
    BEFORE INSERT OR UPDATE ON Partida
    FOR EACH ROW
    EXECUTE FUNCTION fn_validar_equipos_inscritos();

-- ============================================================
-- TABLA: Estadistica_Individual
-- ============================================================

CREATE TABLE Estadistica_Individual (
    id_partida  BIGINT  NOT NULL,
    id_jugador  BIGINT  NOT NULL,
    kos         INT     NOT NULL DEFAULT 0,
    restarts    INT     NOT NULL DEFAULT 0,
    assists     INT     NOT NULL DEFAULT 0,

    CONSTRAINT pk_estadistica
        PRIMARY KEY (id_partida, id_jugador),

    CONSTRAINT fk_estadistica_partida
        FOREIGN KEY (id_partida)
        REFERENCES  Partida(id_partida)
        ON DELETE   CASCADE
        ON UPDATE   CASCADE,

    CONSTRAINT fk_estadistica_jugador
        FOREIGN KEY (id_jugador)
        REFERENCES  Jugador(id_jugador)
        ON DELETE   RESTRICT
        ON UPDATE   CASCADE,

    CONSTRAINT chk_estadistica_kos      CHECK (kos      >= 0),
    CONSTRAINT chk_estadistica_restarts CHECK (restarts >= 0),
    CONSTRAINT chk_estadistica_assists  CHECK (assists  >= 0)
);

COMMENT ON TABLE  Estadistica_Individual IS 'Estadísticas por jugador por partida: KOs, restarts y assists.';

-- ============================================================
-- TRIGGER: Validar que el jugador pertenece a uno de los equipos
--          de la partida al registrar estadística individual
-- ============================================================

CREATE OR REPLACE FUNCTION fn_validar_jugador_en_partida()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
DECLARE
    v_equipo_A  BIGINT;
    v_equipo_B  BIGINT;
    v_equipo_j  BIGINT;
BEGIN
    SELECT id_equipo_A, id_equipo_B
    INTO   v_equipo_A,  v_equipo_B
    FROM   Partida
    WHERE  id_partida = NEW.id_partida;

    SELECT id_equipo
    INTO   v_equipo_j
    FROM   Jugador
    WHERE  id_jugador = NEW.id_jugador;

    IF v_equipo_j <> v_equipo_A AND v_equipo_j <> v_equipo_B THEN
        RAISE EXCEPTION
            'JUGADOR INVÁLIDO: El jugador (id=%) pertenece al equipo (id=%) '
            'que no participa en la partida (id=%). '
            'Equipos válidos: A=% y B=%.',
            NEW.id_jugador, v_equipo_j, NEW.id_partida,
            v_equipo_A, v_equipo_B;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_jugador_en_partida
    BEFORE INSERT OR UPDATE ON Estadistica_Individual
    FOR EACH ROW
    EXECUTE FUNCTION fn_validar_jugador_en_partida();

-- ============================================================
-- TABLA: Sponsor
-- ============================================================

CREATE TABLE Sponsor (
    id_sponsor  BIGSERIAL       NOT NULL,
    nombre      VARCHAR(100)    NOT NULL,
    industria   VARCHAR(50)     NOT NULL,

    CONSTRAINT pk_sponsor       PRIMARY KEY (id_sponsor),
    CONSTRAINT uq_sponsor_nombre UNIQUE     (nombre)
);

COMMENT ON TABLE  Sponsor           IS 'Empresas que auspician torneos.';
COMMENT ON COLUMN Sponsor.industria IS 'Ej: tecnología, bebidas, ropa, alimentación, etc.';

-- ============================================================
-- TABLA: Auspicio_Torneo  (relación N:M Sponsor ↔ Torneo)
-- ============================================================

CREATE TABLE Auspicio_Torneo (
    id_sponsor  BIGINT          NOT NULL,
    id_torneo   BIGINT          NOT NULL,
    monto_usd   DECIMAL(14, 2)  NOT NULL,

    CONSTRAINT pk_auspicio PRIMARY KEY (id_sponsor, id_torneo),

    CONSTRAINT fk_auspicio_sponsor
        FOREIGN KEY (id_sponsor)
        REFERENCES  Sponsor(id_sponsor)
        ON DELETE   RESTRICT
        ON UPDATE   CASCADE,

    CONSTRAINT fk_auspicio_torneo
        FOREIGN KEY (id_torneo)
        REFERENCES  Torneo(id_torneo)
        ON DELETE   CASCADE
        ON UPDATE   CASCADE,

    CONSTRAINT chk_auspicio_monto
        CHECK (monto_usd > 0)
);

COMMENT ON TABLE  Auspicio_Torneo           IS 'Monto que aporta cada sponsor a cada torneo que auspicia.';
COMMENT ON COLUMN Auspicio_Torneo.monto_usd IS 'Monto en USD. Debe ser estrictamente positivo.';

-- ============================================================
-- ÍNDICES DE RENDIMIENTO
-- ============================================================

-- Jugador
CREATE INDEX idx_jugador_equipo   ON Jugador(id_equipo);
CREATE INDEX idx_jugador_pais     ON Jugador(pais_origen);

-- Inscripcion_Torneo
CREATE INDEX idx_inscripcion_torneo ON Inscripcion_Torneo(id_torneo);
CREATE INDEX idx_inscripcion_equipo ON Inscripcion_Torneo(id_equipo);
CREATE INDEX idx_inscripcion_grupo  ON Inscripcion_Torneo(grupo);

-- Partida
CREATE INDEX idx_partida_torneo   ON Partida(id_torneo);
CREATE INDEX idx_partida_equipo_A ON Partida(id_equipo_A);
CREATE INDEX idx_partida_equipo_B ON Partida(id_equipo_B);
CREATE INDEX idx_partida_fase     ON Partida(fase);
CREATE INDEX idx_partida_fecha    ON Partida(fecha_hora);

-- Estadistica_Individual
CREATE INDEX idx_estadistica_jugador ON Estadistica_Individual(id_jugador);

-- Auspicio_Torneo
CREATE INDEX idx_auspicio_torneo  ON Auspicio_Torneo(id_torneo);
CREATE INDEX idx_auspicio_sponsor ON Auspicio_Torneo(id_sponsor);

-- ============================================================
-- VISTAS ÚTILES
-- ============================================================

-- Vista: Clasificación de equipos por torneo en fase de grupos
CREATE VIEW v_clasificacion_grupos AS
SELECT
    it.id_torneo,
    t.nombre            AS torneo,
    it.grupo,
    e.id_equipo,
    e.nombre            AS equipo,
    COUNT(p.id_partida) AS partidas_jugadas,
    SUM(
        CASE
            WHEN p.id_equipo_A = e.id_equipo AND p.puntaje_equipo_A > p.puntaje_equipo_B THEN 1
            WHEN p.id_equipo_B = e.id_equipo AND p.puntaje_equipo_B > p.puntaje_equipo_A THEN 1
            ELSE 0
        END
    )                   AS victorias,
    SUM(
        CASE
            WHEN p.id_equipo_A = e.id_equipo THEN COALESCE(p.puntaje_equipo_A, 0)
            WHEN p.id_equipo_B = e.id_equipo THEN COALESCE(p.puntaje_equipo_B, 0)
            ELSE 0
        END
    )                   AS puntos_favor,
    SUM(
        CASE
            WHEN p.id_equipo_A = e.id_equipo THEN COALESCE(p.puntaje_equipo_B, 0)
            WHEN p.id_equipo_B = e.id_equipo THEN COALESCE(p.puntaje_equipo_A, 0)
            ELSE 0
        END
    )                   AS puntos_contra
FROM  Inscripcion_Torneo it
JOIN  Torneo   t ON t.id_torneo = it.id_torneo
JOIN  Equipo   e ON e.id_equipo = it.id_equipo
LEFT JOIN Partida p ON p.id_torneo = it.id_torneo
    AND p.fase = 'fase de grupos'
    AND (p.id_equipo_A = e.id_equipo OR p.id_equipo_B = e.id_equipo)
GROUP BY it.id_torneo, t.nombre, it.grupo, e.id_equipo, e.nombre;

-- Vista: Estadísticas acumuladas por jugador en un torneo
CREATE VIEW v_stats_jugador_torneo AS
SELECT
    j.id_jugador,
    j.gamertag,
    j.nombre_real,
    e.nombre            AS equipo,
    p.id_torneo,
    t.nombre            AS torneo,
    SUM(ei.kos)         AS total_kos,
    SUM(ei.restarts)    AS total_restarts,
    SUM(ei.assists)     AS total_assists,
    COUNT(p.id_partida) AS partidas_jugadas
FROM  Estadistica_Individual ei
JOIN  Jugador  j ON j.id_jugador  = ei.id_jugador
JOIN  Equipo   e ON e.id_equipo   = j.id_equipo
JOIN  Partida  p ON p.id_partida  = ei.id_partida
JOIN  Torneo   t ON t.id_torneo   = p.id_torneo
GROUP BY
    j.id_jugador, j.gamertag, j.nombre_real,
    e.nombre, p.id_torneo, t.nombre;

-- Vista: Resumen financiero de torneos (prize pool + sponsors)
CREATE VIEW v_resumen_financiero_torneo AS
SELECT
    t.id_torneo,
    t.nombre                        AS torneo,
    t.videojuego,
    t.prize_pool_usd,
    COALESCE(SUM(a.monto_usd), 0)   AS total_auspicio_usd,
    t.prize_pool_usd + COALESCE(SUM(a.monto_usd), 0) AS presupuesto_total_usd,
    COUNT(DISTINCT a.id_sponsor)    AS cantidad_sponsors
FROM  Torneo t
LEFT JOIN Auspicio_Torneo a ON a.id_torneo = t.id_torneo
GROUP BY t.id_torneo, t.nombre, t.videojuego, t.prize_pool_usd;

-- ============================================================
-- FIN DEL SCHEMA
-- ============================================================
