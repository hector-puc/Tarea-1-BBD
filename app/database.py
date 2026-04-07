import os
import psycopg2
from dotenv import load_dotenv

# Carga variables desde un archivo .env si existe (opcional para desarrollo local)
load_dotenv()

def get_db_connection():
    """
    Obtiene una conexión a PostgreSQL usando las variables de entorno
    especificadas en el enunciado (pág. 4).
    """
    try:
        conn = psycopg2.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            port=os.getenv('DB_PORT', '5432'),
            user=os.getenv('DB_USER', 'postgres'),
            password=os.getenv('DB_PASSWORD', 'postgres'),
            database=os.getenv('DB_NAME', 'tarea1')
        )
        return conn
    except Exception as e:
        print(f"Error conectando a la base de datos: {e}")
        return None
