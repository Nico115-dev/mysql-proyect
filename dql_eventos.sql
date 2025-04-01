-- Consultas con Subconsultas y Cálculos Avanzados

-- 1. Obtener los campers con la nota más alta en cada módulo
SELECT e.id_modulo, c.doc, c.nombres, c.apellidos, e.nota_final
FROM evaluacion e
JOIN camper c ON e.doc_camper = c.doc
WHERE e.nota_final = (SELECT MAX(nota_final) FROM evaluacion WHERE id_modulo = e.id_modulo);

-- 2. Mostrar el promedio general de notas por ruta y comparar con el promedio global
SELECT r.nombre AS ruta, AVG(e.nota_final) AS promedio_ruta, 
       (SELECT AVG(nota_final) FROM evaluacion) AS promedio_global
FROM evaluacion e
JOIN moduloAprendizaje m ON e.id_modulo = m.id
JOIN rutaAprendizaje r ON m.id_ruta = r.id
GROUP BY r.nombre;

-- 3. Listar las áreas con más del 80% de ocupación
SELECT ae.nombre, ae.capacidad, COUNT(cr.doc_camper) AS ocupacion_actual
FROM areaEntrenamiento ae
JOIN rutaAprendizaje r ON ae.id = r.id_area
JOIN camperRuta cr ON r.id = cr.id_ruta
GROUP BY ae.nombre, ae.capacidad
HAVING COUNT(cr.doc_camper) > (0.8 * ae.capacidad);

-- 4. Mostrar los trainers con menos del 70% de rendimiento promedio
SELECT t.id, t.nombres, t.apellidos, AVG(e.nota_final) AS rendimiento_promedio
FROM trainer t
JOIN rutaTrainer rt ON t.id = rt.id_trainer
JOIN camperRuta cr ON rt.id_ruta = cr.id_ruta
JOIN evaluacion e ON cr.doc_camper = e.doc_camper
GROUP BY t.id, t.nombres, t.apellidos
HAVING AVG(e.nota_final) < 70;

-- 5. Consultar los campers cuyo promedio está por debajo del promedio general
SELECT c.doc, c.nombres, c.apellidos, AVG(e.nota_final) AS promedio_camper
FROM camper c
JOIN evaluacion e ON c.doc = e.doc_camper
GROUP BY c.doc, c.nombres, c.apellidos
HAVING AVG(e.nota_final) < (SELECT AVG(nota_final) FROM evaluacion);

-- 6. Obtener los módulos con la menor tasa de aprobación
SELECT m.id, m.nombre, 
       COUNT(CASE WHEN e.nota_final >= 60 THEN 1 END) * 100.0 / COUNT(*) AS tasa_aprobacion
FROM moduloAprendizaje m
JOIN evaluacion e ON m.id = e.id_modulo
GROUP BY m.id, m.nombre
ORDER BY tasa_aprobacion ASC;

-- 7. Listar los campers que han aprobado todos los módulos de su ruta
SELECT c.doc, c.nombres, c.apellidos
FROM camper c
WHERE NOT EXISTS (
    SELECT 1 FROM evaluacion e
    JOIN moduloAprendizaje m ON e.id_modulo = m.id
    WHERE e.doc_camper = c.doc AND e.nota_final < 60
);

-- 8. Mostrar rutas con más de 10 campers en bajo rendimiento
SELECT r.nombre, COUNT(cr.doc_camper) AS campers_bajo_rendimiento
FROM rutaAprendizaje r
JOIN camperRuta cr ON r.id = cr.id_ruta
JOIN evaluacion e ON cr.doc_camper = e.doc_camper
WHERE e.nota_final < 60
GROUP BY r.nombre
HAVING COUNT(cr.doc_camper) > 10;

-- 9. Calcular el promedio de rendimiento por SGDB principal
SELECT r.sgdb_principal, AVG(e.nota_final) AS promedio_rendimiento
FROM rutaAprendizaje r
JOIN moduloAprendizaje m ON r.id = m.id_ruta
JOIN evaluacion e ON m.id = e.id_modulo
GROUP BY r.sgdb_principal;

-- 10. Listar los módulos con al menos un 30% de campers reprobados
SELECT m.id, m.nombre, 
       COUNT(CASE WHEN e.nota_final < 60 THEN 1 END) * 100.0 / COUNT(*) AS tasa_reprobacion
FROM moduloAprendizaje m
JOIN evaluacion e ON m.id = e.id_modulo
GROUP BY m.id, m.nombre
HAVING tasa_reprobacion >= 30;

-- 11. Mostrar el módulo más cursado por campers con riesgo alto
SELECT e.id_modulo, m.nombre, COUNT(e.doc_camper) AS total_inscritos
FROM evaluacion e
JOIN camper c ON e.doc_camper = c.doc
JOIN moduloAprendizaje m ON e.id_modulo = m.id
WHERE c.nivel_riesgo = 'Alto'
GROUP BY e.id_modulo, m.nombre
ORDER BY total_inscritos DESC
LIMIT 1;

-- 12. Consultar los trainers con más de 3 rutas asignadas
SELECT t.id, t.nombres, t.apellidos, COUNT(rt.id_ruta) AS total_rutas
FROM trainer t
JOIN rutaTrainer rt ON t.id = rt.id_trainer
GROUP BY t.id, t.nombres, t.apellidos
HAVING COUNT(rt.id_ruta) > 3;

-- 13. Listar los horarios más ocupados por áreas
SELECT ht.id_area, ae.nombre, COUNT(ht.id_trainer) AS total_ocupacion
FROM horarioTrainer ht
JOIN areaEntrenamiento ae ON ht.id_area = ae.id
GROUP BY ht.id_area, ae.nombre
ORDER BY total_ocupacion DESC;

-- 14. Consultar las rutas con el mayor número de módulos
SELECT r.id, r.nombre, COUNT(m.id) AS total_modulos
FROM rutaAprendizaje r
JOIN moduloAprendizaje m ON r.id = m.id_ruta
GROUP BY r.id, r.nombre
ORDER BY total_modulos DESC;

-- 15. Obtener los campers que han cambiado de estado más de una vez
SELECT he.doc_camper, c.nombres, c.apellidos, COUNT(he.id) AS total_cambios
FROM historialEstado he
JOIN camper c ON he.doc_camper = c.doc
GROUP BY he.doc_camper, c.nombres, c.apellidos
HAVING COUNT(he.id) > 1;

-- 16. Mostrar las evaluaciones donde la nota teórica sea mayor a la práctica
SELECT * FROM evaluacion
WHERE nota_teorica > nota_practica;

-- 17. Listar los módulos donde la media de quizzes supera el 9
SELECT e.id_modulo, m.nombre, AVG(e.nota_quiz) AS promedio_quiz
FROM evaluacion e
JOIN moduloAprendizaje m ON e.id_modulo = m.id
GROUP BY e.id_modulo, m.nombre
HAVING AVG(e.nota_quiz) > 9;

-- 18. Consultar la ruta con mayor tasa de graduación
SELECT r.nombre, 
       COUNT(CASE WHEN c.estado = 'Graduado' THEN 1 END) * 100.0 / COUNT(*) AS tasa_graduacion
FROM rutaAprendizaje r
JOIN camperRuta cr ON r.id = cr.id_ruta
JOIN camper c ON cr.doc_camper = c.doc
GROUP BY r.nombre
ORDER BY tasa_graduacion DESC
LIMIT 1;

-- 19. Mostrar los módulos cursados por campers de nivel de riesgo medio o alto
SELECT DISTINCT m.id, m.nombre
FROM moduloAprendizaje m
JOIN evaluacion e ON m.id = e.id_modulo
JOIN camper c ON e.doc_camper = c.doc
WHERE c.nivel_riesgo IN ('Medio', 'Alto');

-- 20. Obtener la diferencia entre capacidad y ocupación en cada área
SELECT ae.nombre, ae.capacidad, 
       ae.capacidad - COUNT(cr.doc_camper) AS espacios_disponibles
FROM areaEntrenamiento ae
LEFT JOIN rutaAprendizaje r ON ae.id = r.id_area
LEFT JOIN camperRuta cr ON r.id = cr.id_ruta
GROUP BY ae.nombre, ae.capacidad;