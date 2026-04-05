<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# tienes que leer la información de la imagen y hacer un esquema para utilizar en una base de datos, indicando tablas, atributos, tipos de datos, llaves primarias, foraneas y restricciones que sean relevantes. Tienes que ser lo más explicito posible ya que es un proyecto a gran escala.

Adicionalmente te pasaré lo que se necesita aquí: La organizaci´on necesita gestionar la siguiente informaci´on:

1. Torneos. La organizaci´on realiza m´ultiples torneos. Cada torneo tiene un nombre, el t´ıtulo del video-
juego que se juega, fechas de inicio y fin, y un pozo de premios (prize pool) en USD. Adem´as tiene un
n´umero m´aximo de equipos por participar.
2. Jugadores. Los jugadores se registran en la plataforma con un gamertag (´unico), su nombre real,
email, fecha de nacimiento y pa´ıs de origen.
3. Equipos. Los jugadores forman equipos (de un numero no acotado de jugadores). Cada equipo tiene
un nombre ´unico, una fecha de creaci´on y un capit´an. El capit´an debe ser miembro del equipo. Un
jugador pertenece a exactamente un equipo (la membres´ıa es fija, no cambia entre torneos).
4. Inscripci´on a torneos. Los equipos se inscriben en torneos. Cada torneo tiene un n´umero m´aximo
de equipos que pueden participar. Un equipo puede inscribirse en m´ultiples torneos.
5. Partidas. Dentro de un torneo se juegan partidas (matches). Cada partida enfrenta a exactamente dos
equipos distintos, tiene una fecha y hora programada, un resultado (puntaje equipo A y puntaje equipo
B) y una fase del torneo. Las fases posibles son: fase de grupos, cuartos de final, semifinal,
final. El formato del torneo es: 8 equipos divididos en 2 grupos de 4, round-robin dentro de cada
grupo, los 2 mejores de cada grupo avanzan a semifinales, luego final.
6. Estad´ısticas individuales. Para cada partida se registran las estad´ısticas de cada jugador de los
equipos participantes: KOs, restarts y assists.
7. Sponsors. Empresas pueden auspiciar torneos. De cada sponsor se conoce su nombre, industria (tec-
nolog´ıa, bebidas, ropa, etc.) y el monto en USD que aporta a cada torneo que auspicia. Un sponsor
puede auspiciar m´ultiples torneos

Para diseñar una base de datos robusta y escalable basada en los requerimientos entregados, utilizaremos un enfoque relacional. Dado que es un proyecto a gran escala, es fundamental definir correctamente los tipos de datos, las llaves primarias (PK), llaves foráneas (FK) y las restricciones (constraints) para asegurar la integridad de los datos.[^1_1]

A continuación, presento el esquema detallado para la base de datos:

### 1. Tabla `Jugador`

Almacena la información de los usuarios registrados.


| Atributo | Tipo de Dato | Restricciones y Detalles |
| :-- | :-- | :-- |
| **id_jugador** | `BIGINT` | **PK**, Autoincremental. |
| **id_equipo** | `BIGINT` | **FK** hacia `Equipo(id_equipo)`. `NOT NULL` (todo jugador pertenece a exactamente un equipo). |
| **gamertag** | `VARCHAR(50)` | `UNIQUE`, `NOT NULL`. |
| **nombre_real** | `VARCHAR(100)` | `NOT NULL`. |
| **email** | `VARCHAR(150)` | `UNIQUE`, `NOT NULL`. |
| **fecha_nacimiento** | `DATE` | `NOT NULL`. |
| **pais_origen** | `VARCHAR(50)` | `NOT NULL`. |

### 2. Tabla `Equipo`

Almacena la información de los equipos formados por los jugadores. Existe una dependencia circular lógica con `Jugador` (por el capitán), por lo que a nivel de base de datos la llave foránea del capitán suele crearse después de insertar el equipo, o se maneja mediante transacciones.


| Atributo | Tipo de Dato | Restricciones y Detalles |
| :-- | :-- | :-- |
| **id_equipo** | `BIGINT` | **PK**, Autoincremental. |
| **nombre** | `VARCHAR(100)` | `UNIQUE`, `NOT NULL`. |
| **fecha_creacion** | `TIMESTAMP` | `NOT NULL`, Default: `CURRENT_TIMESTAMP`. |
| **id_capitan** | `BIGINT` | **FK** hacia `Jugador(id_jugador)`. `NOT NULL`. <br>*(Restricción de negocio: El capitán debe pertenecer al equipo. Se recomienda un `CHECK` function o un `TRIGGER` que valide que `Jugador.id_equipo = Equipo.id_equipo`)*. |

### 3. Tabla `Torneo`

Contiene la configuración general de cada competencia.


| Atributo | Tipo de Dato | Restricciones y Detalles |
| :-- | :-- | :-- |
| **id_torneo** | `BIGINT` | **PK**, Autoincremental. |
| **nombre** | `VARCHAR(150)` | `NOT NULL`. |
| **videojuego** | `VARCHAR(100)` | `NOT NULL`. |
| **fecha_inicio** | `DATE` | `NOT NULL`. |
| **fecha_fin** | `DATE` | `NOT NULL`. <br>*(Constraint: `fecha_fin >= fecha_inicio`)*. |
| **prize_pool_usd** | `DECIMAL(12,2)` | `NOT NULL`, Constraint: `>= 0`. |
| **max_equipos** | `INT` | `NOT NULL`, Constraint: `> 0`. (Típicamente 8, según la regla de negocio descrita). |

### 4. Tabla `Inscripcion_Torneo`

Tabla puente que relaciona a los Equipos con los Torneos (relación N:M).


| Atributo | Tipo de Dato | Restricciones y Detalles |
| :-- | :-- | :-- |
| **id_torneo** | `BIGINT` | **PK / FK** hacia `Torneo(id_torneo)`. |
| **id_equipo** | `BIGINT` | **PK / FK** hacia `Equipo(id_equipo)`. |
| **grupo** | `VARCHAR(1)` | `NULL`. Permite asignar al equipo a un grupo específico ('A', 'B') para la fase de grupos. |
| **fecha_inscripcion** | `TIMESTAMP` | `NOT NULL`, Default: `CURRENT_TIMESTAMP`. |

*(Restricción de negocio: Un `TRIGGER` debe validar antes de insertar que el recuento actual de equipos inscritos en `id_torneo` no supere el `max_equipos` del Torneo).*

### 5. Tabla `Partida`

Registra los encuentros entre dos equipos en un torneo específico.


| Atributo | Tipo de Dato | Restricciones y Detalles |
| :-- | :-- | :-- |
| **id_partida** | `BIGINT` | **PK**, Autoincremental. |
| **id_torneo** | `BIGINT` | **FK** hacia `Torneo(id_torneo)`. `NOT NULL`. |
| **id_equipo_A** | `BIGINT` | **FK** hacia `Equipo(id_equipo)`. `NOT NULL`. |
| **id_equipo_B** | `BIGINT` | **FK** hacia `Equipo(id_equipo)`. `NOT NULL`. |
| **fecha_hora** | `TIMESTAMP` | `NOT NULL`. |
| **fase** | `VARCHAR(20)` | `NOT NULL`. Restricción `CHECK` (`fase IN ('fase de grupos', 'cuartos de final', 'semifinal', 'final')`). |
| **puntaje_equipo_A** | `INT` | `NULL` (hasta que termine la partida). Restricción: `>= 0`. |
| **puntaje_equipo_B** | `INT` | `NULL` (hasta que termine la partida). Restricción: `>= 0`. |

*(Restricciones de negocio: `id_equipo_A != id_equipo_B`. Además, ambos equipos deben estar previamente inscritos en el `id_torneo` correspondiente).*

### 6. Tabla `Estadistica_Individual`

Registra el rendimiento específico de cada jugador dentro de una partida.


| Atributo | Tipo de Dato | Restricciones y Detalles |
| :-- | :-- | :-- |
| **id_partida** | `BIGINT` | **PK / FK** hacia `Partida(id_partida)`. |
| **id_jugador** | `BIGINT` | **PK / FK** hacia `Jugador(id_jugador)`. |
| **kos** | `INT` | `NOT NULL`, Default `0`, Constraint: `>= 0`. |
| **restarts** | `INT` | `NOT NULL`, Default `0`, Constraint: `>= 0`. |
| **assists** | `INT` | `NOT NULL`, Default `0`, Constraint: `>= 0`. |

*(Restricción de negocio: El `id_jugador` debe pertenecer al `id_equipo_A` o `id_equipo_B` de la partida. Esto se garantiza mediante un `TRIGGER` de validación al insertar el registro).*

### 7. Tabla `Sponsor`

Catálogo maestro de las empresas auspiciadoras.


| Atributo | Tipo de Dato | Restricciones y Detalles |
| :-- | :-- | :-- |
| **id_sponsor** | `BIGINT` | **PK**, Autoincremental. |
| **nombre** | `VARCHAR(100)` | `UNIQUE`, `NOT NULL`. |
| **industria** | `VARCHAR(50)` | `NOT NULL` (ej: 'tecnología', 'bebidas'). |

### 8. Tabla `Auspicio_Torneo`

Tabla puente que relaciona Sponsors con Torneos, detallando el monto aportado por competencia.


| Atributo | Tipo de Dato | Restricciones y Detalles |
| :-- | :-- | :-- |
| **id_sponsor** | `BIGINT` | **PK / FK** hacia `Sponsor(id_sponsor)`. |
| **id_torneo** | `BIGINT` | **PK / FK** hacia `Torneo(id_torneo)`. |
| **monto_usd** | `DECIMAL(12,2)` | `NOT NULL`, Constraint: `> 0`. |

<div align="center">⁂</div>

[^1_1]: image.jpg


---

# Ahora que tienes el esquema tienes que crear la base de datos con los mismos datos en postresql

Aquí tienes el archivo SQL completo listo para ejecutar en PostgreSQL. A continuación, el desglose de todas las decisiones técnicas tomadas:

## Estructura General

El schema incluye **8 tablas**, **4 triggers**, **3 vistas** e **índices de rendimiento**. El orden de creación es importante por las dependencias entre tablas.

## Manejo de la Dependencia Circular

El punto más delicado del diseño es que `Equipo.id_capitan → Jugador` y `Jugador.id_equipo → Equipo` se referencian mutuamente. La solución en PostgreSQL es:

1. Crear `Equipo` primero con `id_capitan` como `NULL` (sin FK aún)
2. Crear `Jugador` con FK normal hacia `Equipo`
3. Agregar la FK de `id_capitan` con `DEFERRABLE INITIALLY DEFERRED`, lo que permite insertar el equipo y sus jugadores **dentro de una misma transacción** antes de validar la referencia
```sql
-- Así se inserta correctamente un equipo con su capitán:
BEGIN;
    INSERT INTO Equipo(nombre) VALUES ('Team Alpha') RETURNING id_equipo; -- id=1
    INSERT INTO Jugador(id_equipo, gamertag, ...) VALUES (1, 'gamer01', ...); -- id=1
    UPDATE Equipo SET id_capitan = 1 WHERE id_equipo = 1;
COMMIT; -- Aquí PostgreSQL valida la FK diferida
```


## Triggers Implementados

| Trigger | Tabla | Valida |
| :-- | :-- | :-- |
| `trg_validar_capitan` | `Equipo` | El capitán debe ser miembro del equipo |
| `trg_validar_max_equipos` | `Inscripcion_Torneo` | No superar `Torneo.max_equipos` |
| `trg_validar_equipos_inscritos` | `Partida` | Ambos equipos deben estar inscritos en el torneo |
| `trg_validar_jugador_en_partida` | `Estadistica_Individual` | El jugador debe pertenecer a uno de los dos equipos de la partida |

## Vistas Incluidas

- **`v_clasificacion_grupos`** — Tabla de posiciones por grupo/torneo con victorias y diferencia de puntos
- **`v_stats_jugador_torneo`** — KOs, restarts y assists acumulados por jugador en cada torneo
- **`v_resumen_financiero_torneo`** — Prize pool + aportes de sponsors = presupuesto total por torneo


## Decisiones de Diseño Clave

- `DECIMAL(14,2)` para montos en USD en lugar de `FLOAT`, evitando errores de precisión flotante en valores financieros
- `puntaje_equipo_A` y `puntaje_equipo_B` son `NULL` hasta que la partida se dispute; un `CHECK` obliga a que ambos se registren juntos o queden ambos en `NULL`
- `ON DELETE CASCADE` solo en relaciones donde tiene sentido que los hijos desaparezcan con el padre (ej: estadísticas de una partida eliminada); en otros casos se usa `RESTRICT` para forzar integridad explícita
- `ON DELETE RESTRICT` en `Jugador → Equipo` para evitar eliminar un equipo que todavía tiene jugadores activos

