import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import os
from dotenv import load_dotenv

load_dotenv()

# Configuración desde variables de entorno (mismos defaults que enunciado)
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_USER = os.getenv('DB_USER', 'postgres')
DB_PASS = os.getenv('DB_PASSWORD', 'postgres')
DB_NAME = os.getenv('DB_NAME', 'tarea1')

def setup():
    print("--- Iniciando configuración de la base de datos ---")
    
    # 1. Conectar a 'postgres' para crear la base de datos si no existe
    try:
        conn = psycopg2.connect(
            host=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASS, database='postgres'
        )
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cur = conn.cursor()
        
        # Intentar crear la base de datos
        cur.execute(f"SELECT 1 FROM pg_database WHERE datname = '{DB_NAME}'")
        exists = cur.fetchone()
        if not exists:
            print(f"Creando base de datos '{DB_NAME}'...")
            cur.execute(f"CREATE DATABASE {DB_NAME}")
        else:
            print(f"La base de datos '{DB_NAME}' ya existe.")
            
        cur.close()
        conn.close()
    except Exception as e:
        print(f"Error al conectar con PostgreSQL/crear DB: {e}")
        return

    # 2. Cargar schema.sql y data.sql en la base de datos objetivo
    try:
        print(f"Conectando a '{DB_NAME}' para cargar scripts...")
        conn = psycopg2.connect(
            host=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASS, database=DB_NAME
        )
        cur = conn.cursor()

        # Ejecutar schema.sql
        print("Ejecutando schema.sql...")
        with open('schema.sql', 'r', encoding='utf-8') as f:
            cur.execute(f.read())

        # Ejecutar data.sql
        print("Ejecutando data.sql...")
        with open('data.sql', 'r', encoding='utf-8') as f:
            cur.execute(f.read())

        conn.commit()
        cur.close()
        conn.close()
        print("¡Base de datos configurada exitosamente!")
    except Exception as e:
        print(f"Error al ejecutar los scripts SQL: {e}")

if __name__ == "__main__":
    setup()
