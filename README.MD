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

1. Los procedimientos almacenados, funciones, triggers y eventos se encuentran en sus respectivos archivos.
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


## Descripción
Este repositorio contiene consultas SQL optimizadas para la gestión de la base de datos de **Campuslands**, una empresa dedicada a la formación de programadores junior.

## Consultas SQL

### 1. Obtener los nombres completos de los campers junto con el nombre de la ruta a la que están inscritos
```sql
SELECT
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
    r.nombre AS ruta_nombre
FROM camper c
JOIN inscripciones i ON c.documento = i.doc_camper
JOIN rutaAprendizaje r ON i.id_ruta = r.id;
```

### 2. Mostrar los campers con sus evaluaciones (nota teórica, práctica, quizzes y nota final) por cada módulo
```sql
SELECT
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
    m.nombre AS modulo_nombre,
    te.nombre AS tipo_evaluacion,
    sn.nota
FROM camper c
JOIN skillsNotas sn ON c.documento = sn.doc_camper
JOIN moduloAprendizaje m ON sn.id_modulo = m.id
JOIN tipoEvaluacion te ON sn.id_tipo_evaluacion = te.id
ORDER BY c.nombres, m.nombre, te.nombre;
```

### 3. Listar todos los módulos que componen cada ruta de entrenamiento
```sql
SELECT
    r.nombre AS ruta_nombre,
    m.nombre AS modulo_nombre
FROM rutaAprendizaje r
JOIN rutaModulo rm ON r.id = rm.id_ruta
JOIN moduloAprendizaje m ON rm.id_modulo = m.id
ORDER BY r.nombre, m.nombre;
```

### 4. Consultar las rutas con sus trainers asignados y las áreas en las que imparten clases
```sql
SELECT
    r.nombre AS ruta_nombre,
    t.nombres AS trainer_nombre,
    t.apellidos AS trainer_apellidos,
    a.nombre AS area_nombre
FROM rutaAprendizaje r
LEFT JOIN rutaTrainer rt ON r.id = rt.id_ruta
LEFT JOIN trainer t ON rt.id_trainer = t.id
LEFT JOIN horarioTrainer ht ON t.id = ht.id_trainer
LEFT JOIN areaSalon a ON ht.id_area = a.id
ORDER BY r.nombre, t.nombres, a.nombre;
```

### 5. Mostrar los campers junto con el trainer responsable de su ruta actual
```sql
SELECT
    c.nombres AS camper_nombre,
    c.apellidos AS camper_apellidos,
    r.nombre AS ruta_nombre,
    t.nombres AS trainer_nombre,
    t.apellidos AS trainer_apellidos
FROM inscripciones i
JOIN camper c ON i.doc_camper = c.documento
JOIN rutaAprendizaje r ON i.id_ruta = r.id
JOIN rutaTrainer rt ON r.id = rt.id_ruta
JOIN trainer t ON rt.id_trainer = t.id
WHERE i.estado = 'Aprobada'  -- Solo considerar las rutas aprobadas
ORDER BY r.nombre, t.nombres, c.nombres;
```

---

## Consultas avanzadas

### 1. Obtener los campers con la nota más alta en cada módulo
```sql
SELECT
    ca.documento AS doc_camper,
    CONCAT(ca.nombres, ' ', ca.apellidos) AS nombre_camper,
    m.nombre AS modulo,
    sn.nota AS nota_alta
FROM skillsNotas sn
JOIN camper ca ON sn.doc_camper = ca.documento
JOIN moduloAprendizaje m ON sn.id_modulo = m.id
WHERE sn.nota = (
    SELECT MAX(snota.nota)
    FROM skillsNotas snota
    WHERE snota.id_modulo = sn.id_modulo
)
ORDER BY m.nombre, sn.nota DESC;
```

### 2. Mostrar el promedio general de notas por ruta y comparar con el promedio global
```sql
SELECT
    r.nombre AS ruta,
    AVG(sn.nota) AS promedio_ruta,
    (SELECT AVG(nota) FROM skillsNotas) AS promedio_global
FROM skillsNotas sn
JOIN inscripciones i ON sn.doc_camper = i.doc_camper
JOIN rutaAprendizaje r ON i.id_ruta = r.id
GROUP BY r.id
ORDER BY promedio_ruta DESC;
```

### 3. Listar las áreas con más del 80% de ocupación
```sql
SELECT
    a.nombre AS area,
    a.capacidad AS capacidad_total,
    COUNT(sa.id) AS campers_asignados,
    (COUNT(sa.id) / a.capacidad) * 100 AS porcentaje_ocupacion
FROM areaSalon a
JOIN asignacionCamper sa ON a.id = sa.id_area
GROUP BY a.id
HAVING porcentaje_ocupacion > 80
ORDER BY porcentaje_ocupacion DESC;
```

### 4. Mostrar los trainers con menos del 70% de rendimiento promedio
```sql
SELECT
    t.nombres AS trainer,
    t.apellidos,
    AVG(nf.nota_final) AS rendimiento_promedio
FROM trainer t
JOIN rutaTrainer rt ON t.id = rt.id_trainer
JOIN inscripciones i ON rt.id_ruta = i.id_ruta
JOIN notaFinal nf ON i.doc_camper = nf.doc_camper
GROUP BY t.id
HAVING rendimiento_promedio < 70
ORDER BY rendimiento_promedio ASC;
```

### 5. Consultar los campers cuyo promedio está por debajo del promedio general
```sql
SELECT
    c.nombres,
    c.apellidos,
    AVG(nf.nota_final) AS promedio_camper
FROM camper c
JOIN notaFinal nf ON c.documento = nf.doc_camper
GROUP BY c.documento
HAVING promedio_camper < (
    SELECT AVG(nf2.nota_final)
    FROM notaFinal nf2
)
ORDER BY promedio_camper ASC;
```

## Uso
Para ejecutar estas consultas, asegúrese de estar conectado a la base de datos de **Campuslands** y contar con las tablas correspondientes creadas y pobladas con datos válidos.

## Contacto
Si tienes dudas o sugerencias sobre las consultas, no dudes en contribuir o ponerte en contacto.

# 📌 Base de Datos - Campuslands

Este documento describe los **triggers**, **procedimientos almacenados** y **funciones** implementados en la base de datos **Campuslands**. Estos elementos aseguran la integridad de los datos y automatizan procesos dentro del sistema.

---

## 📌 Triggers (Disparadores)

Los **triggers** son procedimientos que se ejecutan automáticamente antes o después de una operación `INSERT`, `UPDATE` o `DELETE`. Estos ayudan a mantener la coherencia de los datos.

### 🔹 Ejemplo de Trigger: Marcar Camper como "Retirado" al eliminar una inscripción

```sql
DELIMITER $$
CREATE TRIGGER after_delete_inscripcion
AFTER DELETE ON inscripciones
FOR EACH ROW
BEGIN
    UPDATE camper
    SET estado = 'Retirado'
    WHERE documento = OLD.doc_camper;
END$$
DELIMITER ;
```
**Explicación:** Cuando se elimina una inscripción, el estado del camper asociado se actualiza automáticamente a "Retirado".

---

## 📌 Procedimientos Almacenados (Stored Procedures)

Los **procedimientos almacenados** son conjuntos de instrucciones SQL que se pueden ejecutar con un solo comando. Se usan para encapsular lógica de negocio compleja y reutilizable.

### 🔹 Ejemplo de Procedimiento: Recalcular el promedio de una evaluación

```sql
DELIMITER $$
CREATE PROCEDURE RecalcularPromedio(IN p_id_evaluacion INT)
BEGIN
    DECLARE v_promedio DECIMAL(10,2);
    
    SELECT AVG(nota) INTO v_promedio
    FROM skillsNotas
    WHERE id_evaluacion = p_id_evaluacion;
    
    UPDATE evaluaciones
    SET promedio = v_promedio
    WHERE id = p_id_evaluacion;
END$$
DELIMITER ;
```

**Explicación:** Este procedimiento recalcula el promedio de una evaluación basándose en todas las notas registradas para esa evaluación.

---

## 📌 Funciones (Functions)

Las **funciones** devuelven un valor único y se pueden usar dentro de consultas SQL. Son útiles para cálculos y validaciones específicas.

### 🔹 Ejemplo de Función: Obtener el estado de un módulo según la nota final

```sql
DELIMITER $$
CREATE FUNCTION ObtenerEstadoModulo(nota_final DECIMAL(10,2))
RETURNS VARCHAR(20) DETERMINISTIC
BEGIN
    DECLARE estado VARCHAR(20);
    
    IF nota_final >= 80 THEN
        SET estado = 'Aprobado';
    ELSEIF nota_final >= 60 THEN
        SET estado = 'En revisión';
    ELSE
        SET estado = 'Reprobado';
    END IF;
    
    RETURN estado;
END$$
DELIMITER ;
