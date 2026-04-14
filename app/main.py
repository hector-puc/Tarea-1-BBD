from flask import Flask, render_template, request, redirect, url_for
import psycopg2
from database import get_db_connection

app = Flask(__name__)

# ==========================================
# FUNCIONALIDAD 1: PÁGINA DE TORNEOS
# ==========================================
@app.route('/')
def index():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT nombre, videojuego, prize_pool_usd FROM Torneo ORDER BY fecha_inicio DESC;')
    torneos = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('index.html', torneos=torneos)

@app.route('/torneo/<string:nombre>')
def detalle_torneo(nombre):
    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute('SELECT nombre, videojuego, prize_pool_usd FROM Torneo WHERE nombre = %s', (nombre,))
    torneo = cur.fetchone()
    
    if not torneo:
        return "Torneo no encontrado", 404

    cur.execute("""
        WITH resultados AS (
            SELECT 
                i.nombre_equipo, i.grupo, p.id_partida,
                CASE 
                    WHEN (p.equipo_a = i.nombre_equipo AND p.puntaje_a > p.puntaje_b) OR
                         (p.equipo_b = i.nombre_equipo AND p.puntaje_b > p.puntaje_a) THEN 'W'
                    WHEN p.puntaje_a = p.puntaje_b THEN 'D'
                    ELSE 'L'
                END as resultado
            FROM Inscripcion i
            LEFT JOIN Partida p ON p.nombre_torneo = i.nombre_torneo 
                AND (p.equipo_a = i.nombre_equipo OR p.equipo_b = i.nombre_equipo)
                AND p.fase = 'fase de grupos'
                AND p.puntaje_a IS NOT NULL
            WHERE i.nombre_torneo = %s
        )
        SELECT 
            grupo, nombre_equipo, COUNT(id_partida) as pj,
            SUM(CASE WHEN resultado = 'W' THEN 1 ELSE 0 END) as pg,
            SUM(CASE WHEN resultado = 'D' THEN 1 ELSE 0 END) as pe,
            SUM(CASE WHEN resultado = 'L' THEN 1 ELSE 0 END) as pp,
            (SUM(CASE WHEN resultado = 'W' THEN 1 ELSE 0 END) * 3 + SUM(CASE WHEN resultado = 'D' THEN 1 ELSE 0 END) * 1) as pts
        FROM resultados
        GROUP BY grupo, nombre_equipo
        ORDER BY grupo, pts DESC, pg DESC
    """, (nombre,))
    posiciones = cur.fetchall()

    cur.execute("""
        SELECT fase, equipo_a, equipo_b, puntaje_a, puntaje_b, fecha_hora
        FROM Partida WHERE nombre_torneo = %s ORDER BY fecha_hora DESC
    """, (nombre,))
    partidas = cur.fetchall()

    cur.execute("""
        SELECT s.nombre_sponsor, s.industria, a.monto_usd
        FROM Sponsor s JOIN Auspicio a ON s.nombre_sponsor = a.nombre_sponsor
        WHERE a.nombre_torneo = %s
    """, (nombre,))
    sponsors = cur.fetchall()

    cur.close()
    conn.close()
    return render_template('detalle_torneo.html', torneoid=nombre, torneo=torneo, posiciones=posiciones, partidas=partidas, sponsors=sponsors)

# ==========================================
# FUNCIONALIDAD 2: ESTADÍSTICAS
# ==========================================
@app.route('/estadisticas')
def estadisticas():
    torneo_nom = request.args.get('torneo_nom', type=str)
    equipo_nom = request.args.get('equipo_nom', type=str)
    
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT nombre FROM Torneo ORDER BY fecha_inicio DESC')
    torneos = cur.fetchall()
    
    ranking = []
    evolucion = []
    equipos_torneo = []

    if torneo_nom:
        # Ranking de jugadores (General del Torneo)
        query_ranking = """
            SELECT j.gamertag, j.nombre_equipo, SUM(ei.kos), SUM(ei.restarts), SUM(ei.assists),
                   CAST(SUM(ei.kos) AS FLOAT) / NULLIF(SUM(ei.restarts), 0) as ratio
            FROM EstadisticaIndividual ei
            JOIN Jugador j ON ei.gamertag = j.gamertag
            JOIN Partida p ON ei.id_partida = p.id_partida
            WHERE p.nombre_torneo = %s
        """
        params = [torneo_nom]
        if equipo_nom:
            query_ranking += " AND j.nombre_equipo = %s"
            params.append(equipo_nom)
        
        query_ranking += """
            GROUP BY j.gamertag, j.nombre_equipo
            HAVING COUNT(DISTINCT p.id_partida) >= 2
            ORDER BY ratio DESC
        """
        cur.execute(query_ranking, tuple(params))
        ranking = cur.fetchall()
        
        cur.execute("SELECT nombre_equipo FROM Inscripcion WHERE nombre_torneo = %s", (torneo_nom,))
        equipos_torneo = cur.fetchall()

        if equipo_nom:
            # Evolución: Grupos vs Eliminatorias (comparación de promedios por jugador)
            cur.execute("""
                SELECT 
                    CASE WHEN fase = 'fase de grupos' THEN 'Fase de Grupos' 
                         ELSE 'Fases Eliminatorias (Semi/Final)' END as fase_tipo,
                    ROUND(AVG(kos), 2), ROUND(AVG(restarts), 2), ROUND(AVG(assists), 2)
                FROM EstadisticaIndividual ei
                JOIN Partida p ON ei.id_partida = p.id_partida
                JOIN Jugador j ON ei.gamertag = j.gamertag
                WHERE p.nombre_torneo = %s AND j.nombre_equipo = %s
                GROUP BY fase_tipo
                ORDER BY fase_tipo DESC
            """, (torneo_nom, equipo_nom))
            evolucion = cur.fetchall()

    cur.close()
    conn.close()
    return render_template('estadisticas.html', torneos=torneos, ranking=ranking, evolucion=evolucion, sel_torneo=torneo_nom, sel_equipo=equipo_nom, equipos=equipos_torneo)

# ==========================================
# FUNCIONALIDAD 3: BÚSQUEDA
# ==========================================
@app.route('/buscar')
def buscar():
    query = request.args.get('q', '')
    jugadores = []
    equipos = []
    if query:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT gamertag, nombre_real, pais_origen, nombre_equipo FROM Jugador WHERE gamertag ILIKE %s OR pais_origen ILIKE %s", (f'%{query}%', f'%{query}%'))
        jugadores = cur.fetchall()
        cur.execute("SELECT nombre_equipo, fecha_creacion FROM Equipo WHERE nombre_equipo ILIKE %s", (f'%{query}%',))
        equipos = cur.fetchall()
        cur.close()
        conn.close()
    return render_template('buscar.html', jugadores=jugadores, equipos=equipos, busqueda=query)

# ==========================================
# FUNCIONALIDAD 4: SPONSORS
# ==========================================
@app.route('/sponsors')
def sponsors():
    videojuego = request.args.get('videojuego', '')
    sponsors_top = []
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT DISTINCT videojuego FROM Torneo")
    videojuegos = [v[0] for v in cur.fetchall()]
    if videojuego:
        cur.execute("""
            SELECT s.nombre_sponsor, s.industria, SUM(a.monto_usd)
            FROM Sponsor s JOIN Auspicio a ON s.nombre_sponsor = a.nombre_sponsor JOIN Torneo t ON a.nombre_torneo = t.nombre
            WHERE t.videojuego = %s
            GROUP BY s.nombre_sponsor, s.industria
            HAVING COUNT(DISTINCT t.nombre) = (SELECT COUNT(*) FROM Torneo WHERE videojuego = %s)
        """, (videojuego, videojuego))
        sponsors_top = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('sponsors.html', videojuegos=videojuegos, sponsors=sponsors_top, sel_videojuego=videojuego)

# ==========================================
# FUNCIONALIDAD 5: INSCRIPCIÓN
# ==========================================
@app.route('/inscribir/<string:nombre>', methods=['GET', 'POST'])
def inscribir(nombre):
    conn = get_db_connection()
    cur = conn.cursor()
    error = None
    success = None

    if request.method == 'POST':
        equipo_nom = request.form.get('equipo_nom')
        try:
            cur.execute('INSERT INTO Inscripcion (nombre_torneo, nombre_equipo) VALUES (%s, %s)', (nombre, equipo_nom))
            conn.commit()
            success = "¡Equipo inscrito exitosamente!"
        except Exception as e:
            conn.rollback()
            error = str(e).split('\n')[0]

    cur.execute("SELECT nombre_equipo FROM Equipo WHERE nombre_equipo NOT IN (SELECT nombre_equipo FROM Inscripcion WHERE nombre_torneo = %s)", (nombre,))
    equipos_disponibles = cur.fetchall()
    
    cur.close()
    conn.close()
    return render_template('inscribir.html', torneo=[nombre], torneoid=nombre, equipos=equipos_disponibles, error=error, success=success)

if __name__ == '__main__':
    app.run(host='localhost', port=5000, debug=True)
