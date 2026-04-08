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
    cur.execute('SELECT id_torneo, nombre, videojuego, prize_pool_usd FROM Torneo ORDER BY fecha_inicio DESC;')
    torneos = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('index.html', torneos=torneos)

@app.route('/torneo/<int:id>')
def detalle_torneo(id):
    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute('SELECT nombre, videojuego, prize_pool_usd FROM Torneo WHERE id_torneo = %s', (id,))
    torneo = cur.fetchone()
    
    cur.execute("""
        WITH resultados AS (
            SELECT 
                it.id_equipo, e.nombre as equipo, it.grupo, p.id_partida,
                CASE 
                    WHEN (p.id_equipo_A = it.id_equipo AND p.puntaje_equipo_A > p.puntaje_equipo_B) OR
                         (p.id_equipo_B = it.id_equipo AND p.puntaje_equipo_B > p.puntaje_equipo_A) THEN 'W'
                    WHEN p.puntaje_equipo_A = p.puntaje_equipo_B THEN 'D'
                    ELSE 'L'
                END as resultado
            FROM Inscripcion_Torneo it
            JOIN Equipo e ON it.id_equipo = e.id_equipo
            LEFT JOIN Partida p ON p.id_torneo = it.id_torneo 
                AND (p.id_equipo_A = it.id_equipo OR p.id_equipo_B = it.id_equipo)
                AND p.fase = 'fase de grupos'
                AND p.puntaje_equipo_A IS NOT NULL
            WHERE it.id_torneo = %s
        )
        SELECT 
            grupo, equipo, COUNT(id_partida) as pj,
            SUM(CASE WHEN resultado = 'W' THEN 1 ELSE 0 END) as pg,
            SUM(CASE WHEN resultado = 'D' THEN 1 ELSE 0 END) as pe,
            SUM(CASE WHEN resultado = 'L' THEN 1 ELSE 0 END) as pp,
            (SUM(CASE WHEN resultado = 'W' THEN 1 ELSE 0 END) * 3 + SUM(CASE WHEN resultado = 'D' THEN 1 ELSE 0 END) * 1) as pts
        FROM resultados
        GROUP BY grupo, equipo, id_equipo
        ORDER BY grupo, pts DESC, pg DESC
    """, (id,))
    posiciones = cur.fetchall()

    cur.execute("""
        SELECT p.fase, eA.nombre, eB.nombre, p.puntaje_equipo_A, p.puntaje_equipo_B, p.fecha_hora
        FROM Partida p
        JOIN Equipo eA ON p.id_equipo_A = eA.id_equipo
        JOIN Equipo eB ON p.id_equipo_B = eB.id_equipo
        WHERE p.id_torneo = %s ORDER BY p.fecha_hora DESC
    """, (id,))
    partidas = cur.fetchall()

    cur.execute("""
        SELECT s.nombre, s.industria, at.monto_usd
        FROM Sponsor s
        JOIN Auspicio_Torneo at ON s.id_sponsor = at.id_sponsor
        WHERE at.id_torneo = %s
    """, (id,))
    sponsors = cur.fetchall()

    cur.close()
    conn.close()
    return render_template('detalle_torneo.html', torneoid=id, torneo=torneo, posiciones=posiciones, partidas=partidas, sponsors=sponsors)

# ==========================================
# FUNCIONALIDAD 2: ESTADÍSTICAS DE TORNEO
# ==========================================
@app.route('/estadisticas')
def estadisticas():
    torneo_id = request.args.get('torneo_id', type=int)
    equipo_id = request.args.get('equipo_id', type=int)
    
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT id_torneo, nombre FROM Torneo ORDER BY fecha_inicio DESC')
    torneos = cur.fetchall()
    
    ranking = []
    evolucion = []
    equipos_torneo = []

    if torneo_id:
        # Ranking filtrable por equipo
        query_ranking = """
            SELECT j.gamertag, e.nombre, SUM(ei.kos), SUM(ei.restarts), SUM(ei.assists),
                   CAST(SUM(ei.kos) AS FLOAT) / NULLIF(SUM(ei.restarts), 0) as ratio
            FROM Estadistica_Individual ei
            JOIN Jugador j ON ei.id_jugador = j.id_jugador
            JOIN Equipo e ON j.id_equipo = e.id_equipo
            JOIN Partida p ON ei.id_partida = p.id_partida
            WHERE p.id_torneo = %s
        """
        params = [torneo_id]
        if equipo_id:
            query_ranking += " AND e.id_equipo = %s"
            params.append(equipo_id)
        
        query_ranking += """
            GROUP BY j.id_jugador, j.gamertag, e.nombre
            HAVING COUNT(DISTINCT p.id_partida) >= 2
            ORDER BY ratio DESC
        """
        cur.execute(query_ranking, tuple(params))
        ranking = cur.fetchall()
        
        cur.execute("SELECT e.id_equipo, e.nombre FROM Equipo e JOIN Inscripcion_Torneo it ON e.id_equipo = it.id_equipo WHERE it.id_torneo = %s", (torneo_id,))
        equipos_torneo = cur.fetchall()

        if equipo_id:
            cur.execute("""
                SELECT CASE WHEN fase = 'fase de grupos' THEN 'Grupos' ELSE 'Eliminatorias' END as fase_tipo,
                       AVG(kos), AVG(restarts), AVG(assists)
                FROM Estadistica_Individual ei
                JOIN Partida p ON ei.id_partida = p.id_partida
                JOIN Jugador j ON ei.id_jugador = j.id_jugador
                WHERE p.id_torneo = %s AND j.id_equipo = %s
                GROUP BY fase_tipo
            """, (torneo_id, equipo_id))
            evolucion = cur.fetchall()

    cur.close()
    conn.close()
    return render_template('estadisticas.html', torneos=torneos, ranking=ranking, evolucion=evolucion, sel_torneo=torneo_id, sel_equipo=equipo_id, equipos=equipos_torneo)

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
        cur.execute("""
            SELECT j.gamertag, j.nombre_real, j.pais_origen, e.nombre 
            FROM Jugador j JOIN Equipo e ON j.id_equipo = e.id_equipo
            WHERE j.gamertag ILIKE %s OR j.pais_origen ILIKE %s
        """, (f'%{query}%', f'%{query}%'))
        jugadores = cur.fetchall()
        cur.execute("SELECT nombre, fecha_creacion FROM Equipo WHERE nombre ILIKE %s", (f'%{query}%',))
        equipos = cur.fetchall()
        cur.close()
        conn.close()
    return render_template('buscar.html', jugadores=jugadores, equipos=equipos, busqueda=query)

# ==========================================
# FUNCIONALIDAD 4: PÁGINA DE SPONSORS
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
            SELECT s.nombre, s.industria, SUM(at.monto_usd)
            FROM Sponsor s JOIN Auspicio_Torneo at ON s.id_sponsor = at.id_sponsor JOIN Torneo t ON at.id_torneo = t.id_torneo
            WHERE t.videojuego = %s
            GROUP BY s.id_sponsor, s.nombre, s.industria
            HAVING COUNT(DISTINCT t.id_torneo) = (SELECT COUNT(*) FROM Torneo WHERE videojuego = %s)
        """, (videojuego, videojuego))
        sponsors_top = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('sponsors.html', videojuegos=videojuegos, sponsors=sponsors_top, sel_videojuego=videojuego)

# ==========================================
# FUNCIONALIDAD 5: FORMULARIO DE INSCRIPCIÓN
# ==========================================
@app.route('/inscribir/<int:id>', methods=['GET', 'POST'])
def inscribir(id):
    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute('SELECT nombre FROM Torneo WHERE id_torneo = %s', (id,))
    torneo = cur.fetchone()
    
    error = None
    success = None

    if request.method == 'POST':
        equipo_id = request.form.get('equipo_id')
        try:
            cur.execute('INSERT INTO Inscripcion_Torneo (id_torneo, id_equipo) VALUES (%s, %s)', (id, equipo_id))
            conn.commit()
            success = "¡Equipo inscrito exitosamente!"
        except Exception as e:
            conn.rollback()
            # Capturamos el mensaje del RAISE EXCEPTION del trigger
            error = str(e).split('\n')[0]

    # Equipos no inscritos aún
    cur.execute("SELECT id_equipo, nombre FROM Equipo WHERE id_equipo NOT IN (SELECT id_equipo FROM Inscripcion_Torneo WHERE id_torneo = %s)", (id,))
    equipos_disponibles = cur.fetchall()
    
    cur.close()
    conn.close()
    return render_template('inscribir.html', torneo=torneo, torneoid=id, equipos=equipos_disponibles, error=error, success=success)

if __name__ == '__main__':
    app.run(host='localhost', port=5001, debug=True)
