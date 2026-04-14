# Tarea 1 - IIC 2413 - Sistema de Gestion de Torneos de Gaming

## Integrantes

* Integrante 1: Benjamin Alvarez - 25663283
* Integrante 2: Hector Muñoz - 25663925
* Integrante 3: Mateus Maia - 25201972

## Instrucciones de Despliegue

Para levantar la aplicación en un entorno local (Windows), se deben ejecutar estos 5 comandos en la raiz del proyecto:

1. Crear el entorno virtual:
`python -m venv venv`
2. Activar el entorno virtual:
`.\\\\venv\\\\Scripts\\\\activate` (en Linux/Mac; `source /venv/bin/activate`)
3. Instalar dependencias:
`pip install -r app/requirements.txt`
4. Inicializar base de datos (Carga schema.sql y data.sql):
`python setup\\\_db.py`
5. Ejecutar aplicación:
`python app/main.py`

Nota: Una vez ejecutados los comandos, se puede acceder a la pagina en http://localhost:5000.

Nota 2: Para hacer cambios desde la consola, ejecutar: "psql -h <db\_host> -p <db\_port> -U <db\_user> -d <db\_name>", después, ingresar la contraseña <db\_password>.



psql -h localhost -p 5432 -U postgres -d tarea1



## Variables de Entorno

La aplicación utiliza las siguientes variables de entorno para la conexión a la base de datos. Si no se especifican, se utilizaran los valores por defecto:

|Variable|Descripcion|Valor por Defecto|
|-|-|-|
|DB\_HOST|Host del servidor PostgreSQL|localhost|
|DB\_PORT|Puerto del servidor PostgreSQL|5432|
|DB\_USER|Usuario de la base de datos|postgres|
|DB\_PASSWORD|Contraseña del usuario|postgres|
|DB\_NAME|Nombre de la base de datos|tarea1|

Para personalizar estos valores sin modificar el código, se puede crear un archivo .env en la raíz del proyecto con el formato: VARIABLE=valor.

## Requisitos de Software

* Python 3.9 o superior.
* PostgreSQL 14 o superior.

