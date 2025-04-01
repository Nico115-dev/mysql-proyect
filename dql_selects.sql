-- CAMPERS 
-- 1. Obtener todos los campers inscritos actualmente
SELECT c.*
FROM camper c
JOIN inscripciones i ON c.documento = i.doc_camper
WHERE i.estado = 'Aprobada';

-- 2. Listar los campers con estado "Aprobado"
SELECT c.*
FROM camper c
JOIN estadoActual e ON c.id_estado = e.id
WHERE e.nombre = 'Aprobado';

-- 3. Mostrar los campers que ya están cursando alguna ruta
SELECT DISTINCT c.*
FROM camper c
JOIN inscripciones i ON c.documento = i.doc_camper
WHERE i.estado = 'Aprobada' AND i.fecha_inicio IS NOT NULL;

-- 4. Consultar los campers graduados por cada ruta
SELECT r.nombre AS ruta, COUNT(e.documento) AS total_graduados
FROM egresados e
JOIN rutaAprendizaje r ON e.id_ruta = r.id
GROUP BY r.nombre;

-- 5. Obtener los campers que se encuentran en estado "Expulsado" o "Retirado"
SELECT c.*
FROM camper c
JOIN estadoActual e ON c.id_estado = e.id
WHERE e.nombre IN ('Expulsado', 'Retirado');

-- 6. Listar campers con nivel de riesgo “Alto”
SELECT c.*
FROM camper c
JOIN nivelRiesgo nr ON c.id_nivel_riesgo = nr.id
WHERE nr.nivel = 'Alto';

-- 7. Mostrar el total de campers por cada nivel de riesgo
SELECT nr.nivel, COUNT(c.documento) AS total_campers
FROM camper c
JOIN nivelRiesgo nr ON c.id_nivel_riesgo = nr.id
GROUP BY nr.nivel;

-- 8. Obtener campers con más de un número telefónico registrado
SELECT c.*, COUNT(t.telefono) AS cantidad_telefonos
FROM camper c
JOIN telefonos t ON c.documento = t.doc_camper
GROUP BY c.documento
HAVING COUNT(t.telefono) > 1;

-- 9. Listar los campers y sus respectivos acudientes y teléfonos
SELECT c.documento, c.nombres, c.apellidos, 
       a.nombres AS acudiente_nombre, a.apellidos AS acudiente_apellido, a.telefono AS acudiente_telefono,
       t.telefono AS telefono_campers
FROM camper c
LEFT JOIN acudiente a ON c.documento = a.doc_camper
LEFT JOIN telefonos t ON c.documento = t.doc_camper;

-- 10. Mostrar campers que aún no han sido asignados a una ruta
SELECT c.*
FROM camper c
LEFT JOIN inscripciones i ON c.documento = i.doc_camper
WHERE i.id IS NULL;

-- EVALUACIONES 

-- 1. Obtener las notas teóricas, prácticas y quizzes de cada camper por módulo
SELECT nf.doc_camper, nf.id_modulo, nf.nota_teorica, nf.nota_practica, nf.nota_quizzes
FROM notaFinal nf;

-- 2. Calcular la nota final de cada camper por módulo
SELECT nf.doc_camper, nf.id_modulo, 
       (nf.nota_teorica * 0.4 + nf.nota_practica * 0.4 + nf.nota_quizzes * 0.2) AS nota_final_calculada
FROM notaFinal nf;

-- 3. Mostrar los campers que reprobaron algún módulo (nota < 60)
SELECT nf.doc_camper, nf.id_modulo, nf.nota_final
FROM notaFinal nf
WHERE nf.nota_final < 60;

-- 4. Listar los módulos con más campers en bajo rendimiento
SELECT m.nombre AS modulo, COUNT(nf.doc_camper) AS campers_en_bajo_rendimiento
FROM notaFinal nf
JOIN moduloAprendizaje m ON nf.id_modulo = m.id
WHERE nf.nota_final < 60
GROUP BY m.nombre
ORDER BY campers_en_bajo_rendimiento DESC;

-- 5. Obtener el promedio de notas finales por cada módulo
SELECT m.nombre AS modulo, AVG(nf.nota_final) AS promedio_nota_final
FROM notaFinal nf
JOIN moduloAprendizaje m ON nf.id_modulo = m.id
GROUP BY m.nombre;

-- 6. Consultar el rendimiento general por ruta de entrenamiento
SELECT r.nombre AS ruta, AVG(nf.nota_final) AS promedio_rendimiento
FROM notaFinal nf
JOIN campersModulosAsignados cma ON nf.doc_camper = cma.doc_camper AND nf.id_modulo = cma.id_modulo
JOIN rutaModulo rm ON cma.id_modulo = rm.id_modulo
JOIN rutaAprendizaje r ON rm.id_ruta = r.id
GROUP BY r.nombre;

-- 7. Mostrar los trainers responsables de campers con bajo rendimiento
SELECT DISTINCT t.nombres, t.apellidos, t.email
FROM notaFinal nf
JOIN campersModulosAsignados cma ON nf.doc_camper = cma.doc_camper AND nf.id_modulo = cma.id_modulo
JOIN rutaModulo rm ON cma.id_modulo = rm.id_modulo
JOIN rutaTrainer rt ON rm.id_ruta = rt.id_ruta
JOIN trainer t ON rt.id_trainer = t.id
WHERE nf.nota_final < 60;

-- 8. Comparar el promedio de rendimiento por trainer
SELECT t.nombres, t.apellidos, AVG(nf.nota_final) AS promedio_rendimiento
FROM notaFinal nf
JOIN campersModulosAsignados cma ON nf.doc_camper = cma.doc_camper AND nf.id_modulo = cma.id_modulo
JOIN rutaModulo rm ON cma.id_modulo = rm.id_modulo
JOIN rutaTrainer rt ON rm.id_ruta = rt.id_ruta
JOIN trainer t ON rt.id_trainer = t.id
GROUP BY t.nombres, t.apellidos
ORDER BY promedio_rendimiento DESC;

-- 9. Listar los mejores 5 campers por nota final en cada ruta
SELECT r.nombre AS ruta, c.documento, c.nombres, c.apellidos, nf.nota_final
FROM notaFinal nf
JOIN camper c ON nf.doc_camper = c.documento
JOIN campersModulosAsignados cma ON nf.doc_camper = cma.doc_camper AND nf.id_modulo = cma.id_modulo
JOIN rutaModulo rm ON cma.id_modulo = rm.id_modulo
JOIN rutaAprendizaje r ON rm.id_ruta = r.id
ORDER BY r.nombre, nf.nota_final DESC
LIMIT 5;

-- 10. Mostrar cuántos campers pasaron cada módulo por ruta
SELECT r.nombre AS ruta, m.nombre AS modulo, COUNT(nf.doc_camper) AS campers_aprobados
FROM notaFinal nf
JOIN moduloAprendizaje m ON nf.id_modulo = m.id
JOIN campersModulosAsignados cma ON nf.doc_camper = cma.doc_camper AND nf.id_modulo = cma.id_modulo
JOIN rutaModulo rm ON cma.id_modulo = rm.id_modulo
JOIN rutaAprendizaje r ON rm.id_ruta = r.id
WHERE nf.aprobado = TRUE
GROUP BY r.nombre, m.nombre;

-- RUTAS Y AREAS DE ENTRENAMIENTO

-- 1. Mostrar todas las rutas de entrenamiento disponibles
SELECT * FROM rutaAprendizaje;

-- 2. Obtener las rutas con su SGDB principal y alternativo
SELECT nombre, sgdb_principal, sgdb_alternativo
FROM rutaAprendizaje;

-- 3. Listar los módulos asociados a cada ruta
SELECT r.nombre AS ruta, m.nombre AS modulo
FROM rutaModulo rm
JOIN rutaAprendizaje r ON rm.id_ruta = r.id
JOIN moduloAprendizaje m ON rm.id_modulo = m.id
ORDER BY r.nombre, m.nombre;

-- 4. Consultar cuántos campers hay en cada ruta
SELECT r.nombre AS ruta, COUNT(cr.doc_camper) AS total_campers
FROM camperRuta cr
JOIN rutaAprendizaje r ON cr.id_ruta = r.id
GROUP BY r.nombre
ORDER BY total_campers DESC;

-- 5. Mostrar las áreas de entrenamiento y su capacidad máxima
SELECT id, nombre, capacidad_maxima
FROM areaEntrenamiento;

-- 6. Obtener las áreas que están ocupadas al 100%
SELECT a.id, a.nombre, COUNT(ca.doc_camper) AS campers_asignados, a.capacidad_maxima
FROM areaEntrenamiento a
JOIN camperAsignacionArea ca ON a.id = ca.id_area
GROUP BY a.id, a.nombre, a.capacidad_maxima
HAVING COUNT(ca.doc_camper) >= a.capacidad_maxima;

-- 7. Verificar la ocupación actual de cada área
SELECT a.id, a.nombre, COUNT(ca.doc_camper) AS campers_asignados, a.capacidad_maxima, 
       (COUNT(ca.doc_camper) * 100.0 / a.capacidad_maxima) AS porcentaje_ocupacion
FROM areaEntrenamiento a
LEFT JOIN camperAsignacionArea ca ON a.id = ca.id_area
GROUP BY a.id, a.nombre, a.capacidad_maxima
ORDER BY porcentaje_ocupacion DESC;

-- 8. Consultar los horarios disponibles por cada área
SELECT ha.id_area, ae.nombre AS area, ha.dia_semana, ha.hora_inicio, ha.hora_fin
FROM horarioArea ha
JOIN areaEntrenamiento ae ON ha.id_area = ae.id
WHERE ha.disponible = TRUE
ORDER BY ae.nombre, ha.dia_semana, ha.hora_inicio;

-- 9. Mostrar las áreas con más campers asignados
SELECT a.nombre AS area, COUNT(ca.doc_camper) AS total_campers
FROM areaEntrenamiento a
JOIN camperAsignacionArea ca ON a.id = ca.id_area
GROUP BY a.nombre
ORDER BY total_campers DESC;

-- 10. Listar las rutas con sus respectivos trainers y áreas asignadas
SELECT r.nombre AS ruta, t.nombres AS trainer, t.apellidos AS trainer_apellido, ae.nombre AS area
FROM rutaTrainer rt
JOIN trainer t ON rt.id_trainer = t.id
JOIN rutaAprendizaje r ON rt.id_ruta = r.id
LEFT JOIN areaEntrenamiento ae ON r.id_area = ae.id
ORDER BY r.nombre, t.nombres;

-- TRAINERS

-- 1. Listar todos los entrenadores registrados
SELECT * FROM trainer;

-- 2. Mostrar los trainers con sus horarios asignados
SELECT t.id, t.nombres, t.apellidos, ht.dia_semana, ht.hora_inicio, ht.hora_fin
FROM trainer t
JOIN horarioTrainer ht ON t.id = ht.id_trainer
ORDER BY t.nombres, ht.dia_semana, ht.hora_inicio;

-- 3. Consultar los trainers asignados a más de una ruta
SELECT t.id, t.nombres, t.apellidos, COUNT(rt.id_ruta) AS total_rutas
FROM trainer t
JOIN rutaTrainer rt ON t.id = rt.id_trainer
GROUP BY t.id, t.nombres, t.apellidos
HAVING COUNT(rt.id_ruta) > 1
ORDER BY total_rutas DESC;

-- 4. Obtener el número de campers por trainer
SELECT t.id, t.nombres, t.apellidos, COUNT(cr.doc_camper) AS total_campers
FROM trainer t
JOIN rutaTrainer rt ON t.id = rt.id_trainer
JOIN camperRuta cr ON rt.id_ruta = cr.id_ruta
GROUP BY t.id, t.nombres, t.apellidos
ORDER BY total_campers DESC;

-- 5. Mostrar las áreas en las que trabaja cada trainer
SELECT t.id, t.nombres, t.apellidos, ae.nombre AS area
FROM trainer t
JOIN rutaTrainer rt ON t.id = rt.id_trainer
JOIN rutaAprendizaje r ON rt.id_ruta = r.id
JOIN areaEntrenamiento ae ON r.id_area = ae.id
ORDER BY t.nombres, ae.nombre;

-- 6. Listar los trainers sin asignación de área o ruta
SELECT t.id, t.nombres, t.apellidos
FROM trainer t
LEFT JOIN rutaTrainer rt ON t.id = rt.id_trainer
WHERE rt.id_trainer IS NULL;

-- 7. Mostrar cuántos módulos están a cargo de cada trainer
SELECT t.id, t.nombres, t.apellidos, COUNT(m.id) AS total_modulos
FROM trainer t
JOIN moduloTrainer mt ON t.id = mt.id_trainer
JOIN moduloAprendizaje m ON mt.id_modulo = m.id
GROUP BY t.id, t.nombres, t.apellidos
ORDER BY total_modulos DESC;

-- 8. Obtener el trainer con mejor rendimiento promedio de campers
SELECT t.id, t.nombres, t.apellidos, AVG(cr.nota_final) AS promedio_rendimiento
FROM trainer t
JOIN rutaTrainer rt ON t.id = rt.id_trainer
JOIN camperRuta cr ON rt.id_ruta = cr.id_ruta
GROUP BY t.id, t.nombres, t.apellidos
ORDER BY promedio_rendimiento DESC
LIMIT 1;

-- 9. Consultar los horarios ocupados por cada trainer
SELECT t.id, t.nombres, t.apellidos, ht.dia_semana, ht.hora_inicio, ht.hora_fin
FROM trainer t
JOIN horarioTrainer ht ON t.id = ht.id_trainer
ORDER BY t.nombres, ht.dia_semana, ht.hora_inicio;

-- 10. Mostrar la disponibilidad semanal de cada trainer
SELECT t.id, t.nombres, t.apellidos, ht.dia_semana,
       CASE 
           WHEN ht.id_trainer IS NULL THEN 'Disponible'
           ELSE 'Ocupado'
       END AS disponibilidad
FROM trainer t
LEFT JOIN horarioTrainer ht ON t.id = ht.id_trainer
ORDER BY t.nombres, ht.dia_semana;

