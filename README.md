# Tarea-1-BBD

:p

version postgresql = 18

schema.sql = esquema de la base de datos

data.sql = datos de la base de datos (hechos por IA)

chat ia esquema = para que vean como funciona el esquema por si lo necesitan para la parte A



cambio al esquema:  se hace limpieza inicial al iniciar el esquema (Para permitir reinicializar sin errores)



comandos para inicializar:

&#x20;  1. python -m venv venv

&#x20;  2. venv\\Scripts\\activate (en linux, usar

source venv/bin/activate)

&#x20;  3. pip install -r app/requirements.txt

&#x20;  4. python setup\_db.py
py
&#x20;  5. python app/main.py



luego, ir a localhost:5000 en el navegador web.
Para conectar a psql:
psql -h localhost -p 5432 -U postgres -d tarea1



