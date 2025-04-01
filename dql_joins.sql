-- JOINS BASICOS 

-- 1. Obtener los nombres completos de los campers junto con el nombre de la ruta a la que están inscritos.
SELECT c.nombres, c.apellidos, r.nombre AS ruta
FROM camper c
JOIN camperRuta cr ON c.doc = cr.doc_camper
JOIN rutaAprendizaje r ON cr.id_ruta = r.id;

-- 2. Mostrar los campers con sus evaluaciones (nota teórica, práctica, quizzes y nota final) por cada módulo.
SELECT c.nombres, c.apellidos, m.nombre AS modulo, 
       e.nota_teorica, e.nota_practica, e.nota_quiz, e.nota_final
FROM camper c
JOIN evaluacion e ON c.doc = e.doc_camper
JOIN moduloAprendizaje m ON e.id_modulo = m.id;

-- 3. Listar todos los módulos que componen cada ruta de entrenamiento.
SELECT r.nombre AS ruta, m.nombre AS modulo
FROM rutaAprendizaje r
JOIN moduloAprendizaje m ON r.id = m.id_ruta;

-- 4. Consultar las rutas con sus trainers asignados y las áreas en las que imparten clases.
SELECT r.nombre AS ruta, t.nombres AS trainer, t.apellidos, a.nombre AS area
FROM rutaAprendizaje r
JOIN rutaTrainer rt ON r.id = rt.id_ruta
JOIN trainer t ON rt.id_trainer = t.id
JOIN areaEntrenamiento a ON r.id_area = a.id;

-- 5. Mostrar los campers junto con el trainer responsable de su ruta actual.
SELECT c.nombres AS camper, c.apellidos, t.nombres AS trainer, t.apellidos AS trainer_apellidos
FROM camper c
JOIN camperRuta cr ON c.doc = cr.doc_camper
JOIN rutaTrainer rt ON cr.id_ruta = rt.id_ruta
JOIN trainer t ON rt.id_trainer = t.id;

-- 6. Obtener el listado de evaluaciones realizadas con nombre de camper, módulo y ruta.
SELECT c.nombres, c.apellidos, m.nombre AS modulo, r.nombre AS ruta, 
       e.nota_teorica, e.nota_practica, e.nota_quiz, e.nota_final
FROM evaluacion e
JOIN camper c ON e.doc_camper = c.doc
JOIN moduloAprendizaje m ON e.id_modulo = m.id
JOIN rutaAprendizaje r ON m.id_ruta = r.id;

-- 7. Listar los trainers y los horarios en que están asignados a las áreas de entrenamiento.
SELECT t.nombres, t.apellidos, a.nombre AS area, h.dia, h.hora_inicio, h.hora_fin
FROM trainer t
JOIN horarioTrainer h ON t.id = h.id_trainer
JOIN areaEntrenamiento a ON h.id_area = a.id;

-- 8. Consultar todos los campers junto con su estado actual y el nivel de riesgo.
SELECT c.nombres, c.apellidos, c.estado, c.nivel_riesgo
FROM camper c;

-- 9. Obtener todos los módulos de cada ruta junto con su porcentaje teórico, práctico y de quizzes.
SELECT r.nombre AS ruta, m.nombre AS modulo, 
       m.porcentaje_teorico, m.porcentaje_practico, m.porcentaje_quiz
FROM moduloAprendizaje m
JOIN rutaAprendizaje r ON m.id_ruta = r.id;

-- 10. Mostrar los nombres de las áreas junto con los nombres de los campers que están asistiendo en esos espacios.
SELECT a.nombre AS area, c.nombres AS camper, c.apellidos
FROM areaEntrenamiento a
JOIN rutaAprendizaje r ON a.id = r.id_area
JOIN camperRuta cr ON r.id = cr.id_ruta
JOIN camper c ON cr.doc_camper = c.doc;

-- JOINS CON CONDICIONES ESPECIFICAS

-- 1. Listar los campers que han aprobado todos los módulos de su ruta (nota_final >= 60).
SELECT c.nombres, c.apellidos, r.nombre AS ruta
FROM camper c
JOIN camperRuta cr ON c.doc = cr.doc_camper
JOIN rutaAprendizaje r ON cr.id_ruta = r.id
WHERE NOT EXISTS (
    SELECT 1
    FROM evaluacion e
    JOIN moduloAprendizaje m ON e.id_modulo = m.id
    WHERE e.doc_camper = c.doc AND e.nota_final < 60
);

-- 2. Mostrar las rutas que tienen más de 10 campers inscritos actualmente.
SELECT r.nombre, COUNT(cr.doc_camper) AS total_campers
FROM rutaAprendizaje r
JOIN camperRuta cr ON r.id = cr.id_ruta
GROUP BY r.id
HAVING COUNT(cr.doc_camper) > 10;

-- 3. Consultar las áreas que superan el 80% de su capacidad con el número actual de campers asignados.
SELECT a.nombre AS area, COUNT(cr.doc_camper) AS ocupacion_actual, a.capacidad_maxima
FROM areaEntrenamiento a
JOIN rutaAprendizaje r ON a.id = r.id_area
JOIN camperRuta cr ON r.id = cr.id_ruta
GROUP BY a.id
HAVING COUNT(cr.doc_camper) > (a.capacidad_maxima * 0.8);

-- 4. Obtener los trainers que imparten más de una ruta diferente.
SELECT t.nombres, t.apellidos, COUNT(DISTINCT rt.id_ruta) AS total_rutas
FROM trainer t
JOIN rutaTrainer rt ON t.id = rt.id_trainer
GROUP BY t.id
HAVING COUNT(DISTINCT rt.id_ruta) > 1;

-- 5. Listar las evaluaciones donde la nota práctica es mayor que la nota teórica.
SELECT c.nombres, c.apellidos, m.nombre AS modulo, e.nota_teorica, e.nota_practica
FROM evaluacion e
JOIN camper c ON e.doc_camper = c.doc
JOIN moduloAprendizaje m ON e.id_modulo = m.id
WHERE e.nota_practica > e.nota_teorica;

-- 6. Mostrar campers que están en rutas cuyo SGDB principal es MySQL.
SELECT c.nombres, c.apellidos, r.nombre AS ruta
FROM camper c
JOIN camperRuta cr ON c.doc = cr.doc_camper
JOIN rutaAprendizaje r ON cr.id_ruta = r.id
WHERE r.sgdb_principal = 'MySQL';

-- 7. Obtener los nombres de los módulos donde los campers han tenido bajo rendimiento.
SELECT DISTINCT m.nombre AS modulo
FROM evaluacion e
JOIN moduloAprendizaje m ON e.id_modulo = m.id
WHERE e.nota_final < 60;

-- 8. Consultar las rutas con más de 3 módulos asociados.
SELECT r.nombre AS ruta, COUNT(m.id) AS total_modulos
FROM rutaAprendizaje r
JOIN moduloAprendizaje m ON r.id = m.id_ruta
GROUP BY r.id
HAVING COUNT(m.id) > 3;

-- 9. Listar las inscripciones realizadas en los últimos 30 días con sus respectivos campers y rutas.
SELECT c.nombres, c.apellidos, r.nombre AS ruta, cr.fecha_inscripcion
FROM camperRuta cr
JOIN camper c ON cr.doc_camper = c.doc
JOIN rutaAprendizaje r ON cr.id_ruta = r.id
WHERE cr.fecha_inscripcion >= CURDATE() - INTERVAL 30 DAY;

-- 10. Obtener los trainers que están asignados a rutas con campers en estado de “Alto Riesgo”.
SELECT DISTINCT t.nombres, t.apellidos
FROM trainer t
JOIN rutaTrainer rt ON t.id = rt.id_trainer
JOIN camperRuta cr ON rt.id_ruta = cr.id_ruta
JOIN camper c ON cr.doc_camper = c.doc
WHERE c.nivel_riesgo = 'Alto';

-- JOINS CON FUNCIONES DE AGREGACION

-- 1. Obtener el promedio de nota final por módulo.
SELECT m.nombre AS modulo, AVG(e.nota_final) AS promedio_nota_final
FROM evaluacion e
JOIN moduloAprendizaje m ON e.id_modulo = m.id
GROUP BY m.id;

-- 2. Calcular la cantidad total de campers por ruta.
SELECT r.nombre AS ruta, COUNT(cr.doc_camper) AS total_campers
FROM rutaAprendizaje r
JOIN camperRuta cr ON r.id = cr.id_ruta
GROUP BY r.id;

-- 3. Mostrar la cantidad de evaluaciones realizadas por cada trainer (según las rutas que imparte).
SELECT t.nombres, t.apellidos, COUNT(e.id) AS total_evaluaciones
FROM trainer t
JOIN rutaTrainer rt ON t.id = rt.id_trainer
JOIN rutaAprendizaje r ON rt.id_ruta = r.id
JOIN moduloAprendizaje m ON r.id = m.id_ruta
JOIN evaluacion e ON m.id = e.id_modulo
GROUP BY t.id;

-- 4. Consultar el promedio general de rendimiento por cada área de entrenamiento.
SELECT a.nombre AS area, AVG(e.nota_final) AS promedio_rendimiento
FROM areaEntrenamiento a
JOIN rutaAprendizaje r ON a.id = r.id_area
JOIN moduloAprendizaje m ON r.id = m.id_ruta
JOIN evaluacion e ON m.id = e.id_modulo
GROUP BY a.id;

-- 5. Obtener la cantidad de módulos asociados a cada ruta de entrenamiento.
SELECT r.nombre AS ruta, COUNT(m.id) AS total_modulos
FROM rutaAprendizaje r
JOIN moduloAprendizaje m ON r.id = m.id_ruta
GROUP BY r.id;

-- 6. Mostrar el promedio de nota final de los campers en estado “Cursando”.
SELECT AVG(e.nota_final) AS promedio_nota_final
FROM evaluacion e
JOIN camper c ON e.doc_camper = c.doc
WHERE c.estado = 'Cursando';

-- 7. Listar el número de campers evaluados en cada módulo.
SELECT m.nombre AS modulo, COUNT(e.id) AS total_evaluados
FROM moduloAprendizaje m
JOIN evaluacion e ON m.id = e.id_modulo
GROUP BY m.id;

-- 8. Consultar el porcentaje de ocupación actual por cada área de entrenamiento.
SELECT a.nombre AS area, 
       (COUNT(cr.doc_camper) / a.capacidad_maxima) * 100 AS porcentaje_ocupacion
FROM areaEntrenamiento a
JOIN rutaAprendizaje r ON a.id = r.id_area
JOIN camperRuta cr ON r.id = cr.id_ruta
GROUP BY a.id;

-- 9. Mostrar cuántos trainers tiene asignados cada área.
SELECT a.nombre AS area, COUNT(DISTINCT rt.id_trainer) AS total_trainers
FROM areaEntrenamiento a
JOIN rutaAprendizaje r ON a.id = r.id_area
JOIN rutaTrainer rt ON r.id = rt.id_ruta
GROUP BY a.id;

-- 10. Listar las rutas que tienen más campers en riesgo alto.
SELECT r.nombre AS ruta, COUNT(c.doc) AS total_campers_riesgo_alto
FROM rutaAprendizaje r
JOIN camperRuta cr ON r.id = cr.id_ruta
JOIN camper c ON cr.doc_camper = c.doc
WHERE c.nivel_riesgo = 'Alto'
GROUP BY r.id
ORDER BY total_campers_riesgo_alto DESC;
