### CampusLands Database Management System

## Descripción del Proyecto

El proyecto "CampusLands Database Management System" es una solución integral para la gestión de una institución educativa especializada en programación y tecnología. Esta base de datos permite administrar todos los aspectos operativos de CampusLands, incluyendo el seguimiento de campers (estudiantes), trainers (instructores), rutas de aprendizaje, módulos, evaluaciones, asistencia, y rendimiento académico.

El sistema está diseñado para facilitar:

- Gestión completa del ciclo de vida académico de los campers
- Administración de rutas de aprendizaje y módulos educativos
- Seguimiento detallado del rendimiento y asistencia
- Asignación de recursos (áreas, horarios, trainers)
- Comunicación mediante notificaciones
- Análisis de datos educativos para la toma de decisiones


## Requisitos del Sistema

Para implementar y ejecutar correctamente este sistema de base de datos, se requiere:

- MySQL Server 8.0 o superior
- MySQL Workbench 8.0 o superior (recomendado para la administración visual)
- Mínimo 4GB de RAM para un rendimiento óptimo
- Al menos 500MB de espacio en disco para la base de datos inicial


## Instalación y Configuración

### 1. Configuración Inicial

1. Instale MySQL Server y MySQL Workbench siguiendo las instrucciones oficiales para su sistema operativo.
2. Inicie sesión en MySQL Workbench con credenciales de administrador.
3. Cree un nuevo esquema (base de datos) llamado `campuslands`:


```sql
CREATE DATABASE campuslands;
USE campuslands;
```

### 2. Creación de la Estructura de la Base de Datos

1. Abra el archivo `ddl.sql` en MySQL Workbench.
2. Ejecute el script completo para crear todas las tablas, índices, restricciones y relaciones.
3. Verifique que todas las tablas se hayan creado correctamente mediante:


```sql
SHOW TABLES;
```

### 3. Carga de Datos Iniciales

1. Abra el archivo `dml.sql` que contiene todos los INSERT statements.
2. Para evitar problemas de ejecución, ejecute el script por secciones siguiendo el orden de las tablas (respetando las dependencias de claves foráneas).
3. Alternativamente, puede ejecutar el script completo si su versión de MySQL lo permite.
4. Verifique la carga de datos con consultas básicas:


```sql
SELECT COUNT(*) FROM camper;
SELECT COUNT(*) FROM trainer;
SELECT COUNT(*) FROM rutaAprendizaje;
```

### 4. Ejecución de Consultas y Procedimientos

1. Los procedimientos almacenados, funciones, triggers y eventos se encuentran en el archivo `procedures.sql`.
2. Ejecute este script para crear todos los objetos programables de la base de datos.
3. Para ejecutar un procedimiento almacenado específico, utilice:


```sql
CALL nombre_procedimiento(parametro1, parametro2, ...);
```

## Estructura de la Base de Datos

La base de datos está compuesta por 28 tablas interrelacionadas que modelan todos los aspectos del sistema educativo:

### Tablas Principales

1. **sede**: Almacena información sobre las sedes físicas de CampusLands.
2. **camper**: Contiene los datos básicos de los estudiantes.
3. **trainer**: Almacena información sobre los instructores.
4. **rutaAprendizaje**: Define las diferentes rutas formativas disponibles.
5. **moduloAprendizaje**: Contiene los módulos que componen cada ruta.
6. **estadoActual**: Define los posibles estados de un camper en el sistema.
7. **nivelRiesgo**: Clasifica el nivel de riesgo académico de los campers.


### Tablas de Relación

1. **rutaModulo**: Relaciona rutas con sus módulos correspondientes.
2. **inscripciones**: Registra las inscripciones de campers a rutas.
3. **rutaTrainer**: Asigna trainers a rutas específicas.
4. **asignacionCamper**: Asigna campers a áreas y horarios.
5. **bdAsociados**: Relaciona rutas con sistemas de gestión de bases de datos.


### Tablas de Seguimiento

1. **seguimientoRendimiento**: Registra observaciones sobre el rendimiento de los campers.
2. **moduloNotas**: Almacena las calificaciones de los campers en cada módulo.
3. **asistencia**: Registra la asistencia diaria de los campers.


### Tablas de Recursos

1. **areaSalon**: Define las áreas físicas disponibles para formación.
2. **horarios**: Establece los diferentes horarios de formación.
3. **asignacionArea**: Asigna áreas a horarios específicos.
4. **horarioTrainer**: Define el horario de cada trainer.


### Tablas Complementarias

1. **skills**: Habilidades técnicas que pueden tener los trainers.
2. **trainerSkills**: Relaciona trainers con sus habilidades.
3. **notificacion**: Sistema de notificaciones internas.
4. **notificacionDestinatario**: Destinatarios de las notificaciones.
5. **datosCamper**: Información complementaria de los campers.
6. **telefonos**: Números telefónicos de contacto de los campers.
7. **acudiente**: Información de contacto de acudientes de los campers.
8. **sgbd**: Sistemas de gestión de bases de datos utilizados.
9. **tipoEvaluacion**: Tipos de evaluaciones aplicadas en los módulos.