BEGIN;

-- ============================================================
-- 1. EQUIPOS (10 Equipos)
-- ============================================================
INSERT INTO Equipo (nombre_equipo, fecha_creacion) VALUES
    ('Alpha Wolves',   '2023-01-01 10:00:00'),
    ('Omega Force',    '2023-01-05 11:00:00'),
    ('Phoenix Rising', '2023-01-10 12:00:00'),
    ('Dragon Squad',   '2023-01-15 13:00:00'),
    ('Shadow Ninjas',  '2023-01-20 14:00:00'),
    ('Nova Stars',     '2023-01-25 15:00:00'),
    ('Titan Clash',    '2023-01-30 16:00:00'),
    ('Vortex Team',    '2023-02-01 17:00:00'),
    ('Blaze Gaming',   '2023-02-05 18:00:00'),
    ('Ghost Protocol', '2023-02-10 19:00:00');

-- ============================================================
-- 2. JUGADORES (50 Jugadores, 5 por equipo)
-- ============================================================
-- Alpha Wolves
INSERT INTO Jugador (gamertag, nombre_real, email, fecha_nacimiento, pais_origen, nombre_equipo) VALUES
    ('xAlphaLead', 'Carlos M.', 'carlos@alpha.gg', '2000-01-01', 'Chile', 'Alpha Wolves'),
    ('xAlphaFrag', 'Diego R.', 'diego@alpha.gg', '2001-02-02', 'Argentina', 'Alpha Wolves'),
    ('xAlphaAim', 'Felipe C.', 'felipe@alpha.gg', '1999-03-03', 'Chile', 'Alpha Wolves'),
    ('xAlphaTank', 'Martin L.', 'martin@alpha.gg', '2002-04-04', 'Colombia', 'Alpha Wolves'),
    ('xAlphaSnipe', 'Seba T.', 'seba@alpha.gg', '2000-05-05', 'Chile', 'Alpha Wolves');

-- Omega Force
INSERT INTO Jugador (gamertag, nombre_real, email, fecha_nacimiento, pais_origen, nombre_equipo) VALUES
    ('OmegaCap', 'Rodrigo S.', 'rodrigo@omega.gg', '1999-06-06', 'Brasil', 'Omega Force'),
    ('OmegaStrike', 'Lucas O.', 'lucas@omega.gg', '2001-07-07', 'Brasil', 'Omega Force'),
    ('OmegaFlash', 'Andres H.', 'andres@omega.gg', '2000-08-08', 'Mexico', 'Omega Force'),
    ('OmegaBlast', 'Pablo V.', 'pablo@omega.gg', '1998-09-09', 'Argentina', 'Omega Force'),
    ('OmegaGhost', 'Mateo G.', 'mateo@omega.gg', '2002-10-10', 'Uruguay', 'Omega Force');

-- Phoenix Rising
INSERT INTO Jugador (gamertag, nombre_real, email, fecha_nacimiento, pais_origen, nombre_equipo) VALUES
    ('PhoenixBoss', 'Ale Ruiz', 'ale@phoenix.gg', '2001-11-11', 'Mexico', 'Phoenix Rising'),
    ('PhoenixFire', 'Camilo M.', 'camilo@phoenix.gg', '2000-12-12', 'Colombia', 'Phoenix Rising'),
    ('PhoenixAsh', 'Rob Diaz', 'rob@phoenix.gg', '1999-01-13', 'Peru', 'Phoenix Rising'),
    ('PhoenixWing', 'Ignacio P.', 'ignacio@phoenix.gg', '2002-02-14', 'Chile', 'Phoenix Rising'),
    ('PhoenixRise', 'Gabi S.', 'gabi@phoenix.gg', '2001-03-15', 'Brasil', 'Phoenix Rising');

-- Dragon Squad
INSERT INTO Jugador (gamertag, nombre_real, email, fecha_nacimiento, pais_origen, nombre_equipo) VALUES
    ('DragonLord', 'Emilio F.', 'emilio@dragon.gg', '1998-04-16', 'Venezuela', 'Dragon Squad'),
    ('DragonFang', 'Cesar R.', 'cesar@dragon.gg', '2000-05-17', 'Ecuador', 'Dragon Squad'),
    ('DragonClaw', 'Omar C.', 'omar@dragon.gg', '2001-06-18', 'Bolivia', 'Dragon Squad'),
    ('DragonScale', 'Nico P.', 'nico@dragon.gg', '1999-07-19', 'Argentina', 'Dragon Squad'),
    ('DragonBreath', 'Tomas A.', 'tomas@dragon.gg', '2002-08-20', 'Chile', 'Dragon Squad');

-- Shadow Ninjas
INSERT INTO Jugador (gamertag, nombre_real, email, fecha_nacimiento, pais_origen, nombre_equipo) VALUES
    ('ShadowMaster', 'Javi M.', 'javi@shadow.gg', '2000-09-21', 'Chile', 'Shadow Ninjas'),
    ('ShadowBlade', 'Andres V.', 'andres@shadow.gg', '2001-10-22', 'Colombia', 'Shadow Ninjas'),
    ('ShadowStep', 'Miguel R.', 'miguel@shadow.gg', '1999-11-23', 'Mexico', 'Shadow Ninjas'),
    ('ShadowStrike', 'Fran J.', 'fran@shadow.gg', '2002-12-24', 'Peru', 'Shadow Ninjas'),
    ('ShadowFlip', 'Cris M.', 'cris@shadow.gg', '2000-01-25', 'Chile', 'Shadow Ninjas');

-- Nova Stars
INSERT INTO Jugador (gamertag, nombre_real, email, fecha_nacimiento, pais_origen, nombre_equipo) VALUES
    ('NovaPrime', 'Ricar L.', 'ricar@nova.gg', '2001-02-26', 'Brasil', 'Nova Stars'),
    ('NovaBright', 'Seba G.', 'seba@nova.gg', '1999-03-27', 'Argentina', 'Nova Stars'),
    ('NovaBlast', 'Jorge M.', 'jorge@nova.gg', '2000-04-28', 'Colombia', 'Nova Stars'),
    ('NovaFlash', 'Alvaro S.', 'alvaro@nova.gg', '2002-05-29', 'Venezuela', 'Nova Stars'),
    ('NovaCore', 'Dani O.', 'dani@nova.gg', '2001-06-30', 'Uruguay', 'Nova Stars');

-- Titan Clash
INSERT INTO Jugador (gamertag, nombre_real, email, fecha_nacimiento, pais_origen, nombre_equipo) VALUES
    ('TitanKing', 'Hernan E.', 'hernan@titan.gg', '1998-07-01', 'Chile', 'Titan Clash'),
    ('TitanCrush', 'Luis M.', 'luis@titan.gg', '2001-08-02', 'Mexico', 'Titan Clash'),
    ('TitanSmash', 'Edu R.', 'edu@titan.gg', '2000-09-03', 'Brasil', 'Titan Clash'),
    ('TitanBreak', 'Vicen C.', 'vicen@titan.gg', '2002-10-04', 'Argentina', 'Titan Clash'),
    ('TitanHold', 'Mauri P.', 'mauri@titan.gg', '1999-11-05', 'Ecuador', 'Titan Clash');

-- Vortex Team
INSERT INTO Jugador (gamertag, nombre_real, email, fecha_nacimiento, pais_origen, nombre_equipo) VALUES
    ('VortexSpin', 'Claudio N.', 'claudio@vortex.gg', '2001-12-06', 'Chile', 'Vortex Team'),
    ('VortexSwirl', 'Bryan F.', 'bryan@vortex.gg', '2000-01-07', 'Peru', 'Vortex Team'),
    ('VortexTwist', 'Axel R.', 'axel@vortex.gg', '1999-02-08', 'Bolivia', 'Vortex Team'),
    ('VortexSurge', 'Ian B.', 'ian@vortex.gg', '2002-03-09', 'Colombia', 'Vortex Team'),
    ('VortexGale', 'Kevin S.', 'kevin@vortex.gg', '2001-04-10', 'Chile', 'Vortex Team');

-- Blaze Gaming
INSERT INTO Jugador (gamertag, nombre_real, email, fecha_nacimiento, pais_origen, nombre_equipo) VALUES
    ('BlazeFire', 'Patri V.', 'patri@blaze.gg', '2000-05-11', 'Chile', 'Blaze Gaming'),
    ('BlazeHeat', 'Ronald C.', 'ronald@blaze.gg', '2001-06-12', 'Chile', 'Blaze Gaming'),
    ('BlazeFlame', 'Sam A.', 'sam@blaze.gg', '1999-07-13', 'Argentina', 'Blaze Gaming'),
    ('BlazeScorch', 'Bas V.', 'bas@blaze.gg', '2002-08-14', 'Chile', 'Blaze Gaming'),
    ('BlazeEmber', 'Gon P.', 'gon@blaze.gg', '2000-09-15', 'Colombia', 'Blaze Gaming');

-- Ghost Protocol
INSERT INTO Jugador (gamertag, nombre_real, email, fecha_nacimiento, pais_origen, nombre_equipo) VALUES
    ('GhostAgent', 'Nico S.', 'nico@ghost.gg', '2001-10-16', 'Chile', 'Ghost Protocol'),
    ('GhostSpec', 'Max C.', 'max@ghost.gg', '1999-11-17', 'Brasil', 'Ghost Protocol'),
    ('GhostPhase', 'Fer I.', 'fer@ghost.gg', '2000-12-18', 'Mexico', 'Ghost Protocol'),
    ('GhostHaunt', 'Rod A.', 'rod@ghost.gg', '2002-01-19', 'Argentina', 'Ghost Protocol'),
    ('GhostSilent', 'Jon C.', 'jon@ghost.gg', '2001-02-20', 'Uruguay', 'Ghost Protocol');

-- ============================================================
-- 3. CAPITANES
-- ============================================================
UPDATE Equipo SET capitan_gamertag = 'xAlphaLead' WHERE nombre_equipo = 'Alpha Wolves';
UPDATE Equipo SET capitan_gamertag = 'OmegaCap' WHERE nombre_equipo = 'Omega Force';
UPDATE Equipo SET capitan_gamertag = 'PhoenixBoss' WHERE nombre_equipo = 'Phoenix Rising';
UPDATE Equipo SET capitan_gamertag = 'DragonLord' WHERE nombre_equipo = 'Dragon Squad';
UPDATE Equipo SET capitan_gamertag = 'ShadowMaster' WHERE nombre_equipo = 'Shadow Ninjas';
UPDATE Equipo SET capitan_gamertag = 'NovaPrime' WHERE nombre_equipo = 'Nova Stars';
UPDATE Equipo SET capitan_gamertag = 'TitanKing' WHERE nombre_equipo = 'Titan Clash';
UPDATE Equipo SET capitan_gamertag = 'VortexSpin' WHERE nombre_equipo = 'Vortex Team';
UPDATE Equipo SET capitan_gamertag = 'BlazeFire' WHERE nombre_equipo = 'Blaze Gaming';
UPDATE Equipo SET capitan_gamertag = 'GhostAgent' WHERE nombre_equipo = 'Ghost Protocol';

-- ============================================================
-- 4. TORNEOS
-- ============================================================
INSERT INTO Torneo (nombre, videojuego, fecha_inicio, fecha_fin, prize_pool_usd, max_equipos) VALUES
    ('Liga Mundial de Valorant 2025', 'Valorant', '2025-03-01','2025-03-31', 50000.00, 8),
    ('Copa Latina de League of Legends', 'League of Legends', '2025-05-10','2025-05-30', 30000.00, 6),
    ('Gran Prix de CS2 Chile 2025', 'Counter-Strike 2', '2025-07-12','2025-07-25', 20000.00, 8);

-- ============================================================
-- 5. INSCRIPCIONES (T1 LLENO, T2 PARCIAL, T3 CASI LLENO)
-- ============================================================
-- Torneo 1 (8 equipos)
INSERT INTO Inscripcion (nombre_torneo, nombre_equipo, grupo) VALUES
    ('Liga Mundial de Valorant 2025', 'Alpha Wolves', 'A'),
    ('Liga Mundial de Valorant 2025', 'Omega Force', 'A'),
    ('Liga Mundial de Valorant 2025', 'Phoenix Rising', 'A'),
    ('Liga Mundial de Valorant 2025', 'Dragon Squad', 'A'),
    ('Liga Mundial de Valorant 2025', 'Shadow Ninjas', 'B'),
    ('Liga Mundial de Valorant 2025', 'Nova Stars', 'B'),
    ('Liga Mundial de Valorant 2025', 'Titan Clash', 'B'),
    ('Liga Mundial de Valorant 2025', 'Vortex Team', 'B');

-- Torneo 2 (4 equipos de 6)
INSERT INTO Inscripcion (nombre_torneo, nombre_equipo, grupo) VALUES
    ('Copa Latina de League of Legends', 'Alpha Wolves', 'A'),
    ('Copa Latina de League of Legends', 'Shadow Ninjas', 'A'),
    ('Copa Latina de League of Legends', 'Blaze Gaming', 'B'),
    ('Copa Latina de League of Legends', 'Ghost Protocol', 'B');

-- Torneo 3 (7 equipos de 8)
INSERT INTO Inscripcion (nombre_torneo, nombre_equipo) VALUES
    ('Gran Prix de CS2 Chile 2025', 'Phoenix Rising'),
    ('Gran Prix de CS2 Chile 2025', 'Dragon Squad'),
    ('Gran Prix de CS2 Chile 2025', 'Titan Clash'),
    ('Gran Prix de CS2 Chile 2025', 'Vortex Team'),
    ('Gran Prix de CS2 Chile 2025', 'Blaze Gaming'),
    ('Gran Prix de CS2 Chile 2025', 'Ghost Protocol'),
    ('Gran Prix de CS2 Chile 2025', 'Omega Force');

-- ============================================================
-- 6. PARTIDAS (Torneo 1 completo - 15 partidas)
-- ============================================================
-- GRUPO A
INSERT INTO Partida (nombre_torneo, equipo_a, equipo_b, fecha_hora, fase, puntaje_a, puntaje_b) VALUES
    ('Liga Mundial de Valorant 2025', 'Alpha Wolves', 'Omega Force', '2025-03-01 10:00:00', 'fase de grupos', 16, 9),
    ('Liga Mundial de Valorant 2025', 'Phoenix Rising', 'Dragon Squad', '2025-03-01 14:00:00', 'fase de grupos', 13, 11),
    ('Liga Mundial de Valorant 2025', 'Alpha Wolves', 'Phoenix Rising', '2025-03-02 10:00:00', 'fase de grupos', 14, 14),
    ('Liga Mundial de Valorant 2025', 'Omega Force', 'Dragon Squad', '2025-03-02 14:00:00', 'fase de grupos', 12, 16),
    ('Liga Mundial de Valorant 2025', 'Alpha Wolves', 'Dragon Squad', '2025-03-03 10:00:00', 'fase de grupos', 16, 5),
    ('Liga Mundial de Valorant 2025', 'Omega Force', 'Phoenix Rising', '2025-03-03 14:00:00', 'fase de grupos', 10, 16);

-- GRUPO B
INSERT INTO Partida (nombre_torneo, equipo_a, equipo_b, fecha_hora, fase, puntaje_a, puntaje_b) VALUES
    ('Liga Mundial de Valorant 2025', 'Shadow Ninjas', 'Nova Stars', '2025-03-01 17:00:00', 'fase de grupos', 15, 12),
    ('Liga Mundial de Valorant 2025', 'Titan Clash', 'Vortex Team', '2025-03-02 17:00:00', 'fase de grupos', 11, 16),
    ('Liga Mundial de Valorant 2025', 'Shadow Ninjas', 'Titan Clash', '2025-03-03 17:00:00', 'fase de grupos', 16, 8),
    ('Liga Mundial de Valorant 2025', 'Nova Stars', 'Vortex Team', '2025-03-04 17:00:00', 'fase de grupos', 12, 14),
    ('Liga Mundial de Valorant 2025', 'Shadow Ninjas', 'Vortex Team', '2025-03-05 17:00:00', 'fase de grupos', 16, 10),
    ('Liga Mundial de Valorant 2025', 'Nova Stars', 'Titan Clash', '2025-03-06 17:00:00', 'fase de grupos', 14, 11);

-- SEMIFINALES
INSERT INTO Partida (nombre_torneo, equipo_a, equipo_b, fecha_hora, fase, puntaje_a, puntaje_b) VALUES
    ('Liga Mundial de Valorant 2025', 'Alpha Wolves', 'Vortex Team', '2025-03-10 15:00:00', 'semifinal', 13, 10),
    ('Liga Mundial de Valorant 2025', 'Shadow Ninjas', 'Phoenix Rising', '2025-03-11 15:00:00', 'semifinal', 12, 16);

-- FINAL
INSERT INTO Partida (nombre_torneo, equipo_a, equipo_b, fecha_hora, fase, puntaje_a, puntaje_b) VALUES
    ('Liga Mundial de Valorant 2025', 'Alpha Wolves', 'Phoenix Rising', '2025-03-20 18:00:00', 'final', 16, 12);

-- ============================================================
-- 7. ESTADISTICAS INDIVIDUALES (Para todos los partidos de T1)
-- ============================================================
-- Ejemplos para Alpha Wolves en todas sus partidas (para el Ranking)
INSERT INTO EstadisticaIndividual (id_partida, gamertag, kos, restarts, assists) VALUES
    (1, 'xAlphaLead', 20, 5, 5), (1, 'xAlphaFrag', 15, 8, 10),
    (3, 'xAlphaLead', 25, 4, 8), (3, 'xAlphaFrag', 18, 6, 7),
    (5, 'xAlphaLead', 30, 3, 12), (5, 'xAlphaFrag', 22, 5, 9),
    (13, 'xAlphaLead', 18, 10, 4), (13, 'xAlphaFrag', 12, 12, 3),
    (15, 'xAlphaLead', 28, 6, 15), (15, 'xAlphaFrag', 20, 8, 11);

-- Ejemplos para Phoenix Rising (para el Ranking y Evolución)
INSERT INTO EstadisticaIndividual (id_partida, gamertag, kos, restarts, assists) VALUES
    (2, 'PhoenixBoss', 22, 5, 10), (2, 'PhoenixFire', 18, 6, 8),
    (3, 'PhoenixBoss', 15, 8, 5),  (3, 'PhoenixFire', 20, 5, 12),
    (6, 'PhoenixBoss', 28, 4, 15), (6, 'PhoenixFire', 22, 7, 11),
    (14, 'PhoenixBoss', 30, 2, 8), (14, 'PhoenixFire', 18, 10, 5),
    (15, 'PhoenixBoss', 20, 12, 6), (15, 'PhoenixFire', 15, 15, 4);

-- Otros jugadores para que no se vea vacio
INSERT INTO EstadisticaIndividual (id_partida, gamertag, kos, restarts, assists) VALUES
    (1, 'OmegaCap', 15, 10, 5), (7, 'ShadowMaster', 25, 4, 8), (7, 'NovaPrime', 18, 9, 3);

-- ============================================================
-- 8. SPONSORS Y AUSPICIOS
-- ============================================================
INSERT INTO Sponsor (nombre_sponsor, industria) VALUES 
    ('ASUS ROG', 'tecnologia'), ('Red Bull', 'bebidas'), ('Intel', 'tecnologia'), 
    ('Logitech', 'perifericos'), ('Monster Energy', 'bebidas');

INSERT INTO Auspicio (nombre_sponsor, nombre_torneo, monto_usd) VALUES
    ('ASUS ROG', 'Liga Mundial de Valorant 2025', 50000.00),
    ('ASUS ROG', 'Copa Latina de League of Legends', 20000.00),
    ('ASUS ROG', 'Gran Prix de CS2 Chile 2025', 30000.00),
    ('Red Bull', 'Liga Mundial de Valorant 2025', 30000.00),
    ('Intel', 'Liga Mundial de Valorant 2025', 40000.00),
    ('Logitech', 'Copa Latina de League of Legends', 15000.00),
    ('Monster Energy', 'Gran Prix de CS2 Chile 2025', 25000.00);

COMMIT;

-- CASO DE PRUEBA: Torneo lleno (Para validación de la Parte C)
-- 'Liga Mundial de Valorant 2025' ya tiene 8 equipos.
-- El siguiente INSERT fallará por el trigger trg_validar_cupo.
-- INSERT INTO Inscripcion (nombre_torneo, nombre_equipo) VALUES ('Liga Mundial de Valorant 2025', 'Blaze Gaming');
