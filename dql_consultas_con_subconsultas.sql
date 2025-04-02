-- Consultas con Subconsultas y Cálculos Avanzados

-- 1. Obtener los campers con la nota más alta en cada módulo
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

-- 2. Mostrar el promedio general de notas por ruta y comparar con el promedio global
SELECT 
    r.nombre AS ruta,
    AVG(sn.nota) AS promedio_ruta,
    (SELECT AVG(nota) FROM skillsNotas) AS promedio_global
FROM skillsNotas sn
JOIN inscripciones i ON sn.doc_camper = i.doc_camper
JOIN rutaAprendizaje r ON i.id_ruta = r.id
GROUP BY r.id
ORDER BY promedio_ruta DESC;

-- 3. Listar las áreas con más del 80% de ocupación
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

-- 4. Mostrar los trainers con menos del 70% de rendimiento promedio
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

-- 5. Consultar los campers cuyo promedio está por debajo del promedio general
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

-- 6. Obtener los módulos con la menor tasa de aprobación
SELECT 
    m.nombre AS modulo,
    COUNT(CASE WHEN nf.aprobado = TRUE THEN 1 END) AS campers_aprobados,
    COUNT(nf.id) AS total_campers,
    (COUNT(CASE WHEN nf.aprobado = TRUE THEN 1 END) / COUNT(nf.id)) * 100 AS tasa_aprobacion
FROM moduloAprendizaje m
JOIN rutaModulo rm ON m.id = rm.id_modulo
JOIN inscripciones i ON rm.id_ruta = i.id_ruta
JOIN notaFinal nf ON i.doc_camper = nf.doc_camper AND nf.id_modulo = m.id
GROUP BY m.id
ORDER BY tasa_aprobacion ASC;

-- 7. Listar los campers que han aprobado todos los módulos de su ruta
SELECT 
    c.nombres,
    c.apellidos,
    r.nombre AS ruta,
    COUNT(rm.id_modulo) AS total_modulos_ruta,
    COUNT(CASE WHEN nf.aprobado = TRUE THEN 1 END) AS modulos_aprobados
FROM camper c
JOIN inscripciones i ON c.documento = i.doc_camper
JOIN rutaAprendizaje r ON i.id_ruta = r.id
JOIN rutaModulo rm ON r.id = rm.id_ruta
JOIN notaFinal nf ON nf.doc_camper = c.documento AND nf.id_modulo = rm.id_modulo
GROUP BY c.documento, r.id
HAVING total_modulos_ruta = modulos_aprobados
ORDER BY c.apellidos, c.nombres;

-- 8. Mostrar rutas con más de 10 campers en bajo rendimiento
SELECT 
    r.nombre AS ruta,
    COUNT(c.documento) AS campers_bajo_rendimiento
FROM rutaAprendizaje r
JOIN inscripciones i ON r.id = i.id_ruta
JOIN camper c ON i.doc_camper = c.documento
JOIN notaFinal nf ON nf.doc_camper = c.documento
WHERE nf.nota_final < 6.00
GROUP BY r.id
HAVING campers_bajo_rendimiento > 10
ORDER BY campers_bajo_rendimiento DESC;

-- 9. Calcular el promedio de rendimiento por SGDB principal
SELECT 
    s.nombre AS sgbd_principal,
    AVG(nf.nota_final) AS promedio_rendimiento
FROM bdAsociados ba
JOIN sgbd s ON ba.id_sgbd = s.id
JOIN rutaAprendizaje r ON ba.id_ruta = r.id
JOIN inscripciones i ON r.id = i.id_ruta
JOIN camper c ON i.doc_camper = c.documento
JOIN notaFinal nf ON nf.doc_camper = c.documento
WHERE ba.es_principal = TRUE
GROUP BY s.id
ORDER BY promedio_rendimiento DESC;

-- 10. Listar los módulos con al menos un 30% de campers reprobados
SELECT 
    m.nombre AS modulo,
    COUNT(CASE WHEN nf.nota_final < 6.00 THEN 1 END) * 100 / COUNT(*) AS porcentaje_reprobados
FROM moduloAprendizaje m
JOIN rutaModulo rm ON m.id = rm.id_modulo
JOIN inscripciones i ON rm.id_ruta = i.id_ruta
JOIN camper c ON i.doc_camper = c.documento
JOIN notaFinal nf ON nf.doc_camper = c.documento AND nf.id_modulo = m.id
GROUP BY m.id
HAVING porcentaje_reprobados >= 30;

-- 11. Mostrar el módulo más cursado por campers con riesgo alto
SELECT 
    m.nombre AS modulo,
    COUNT(*) AS cantidad_cursados
FROM moduloAprendizaje m
JOIN rutaModulo rm ON m.id = rm.id_modulo
JOIN inscripciones i ON rm.id_ruta = i.id_ruta
JOIN camper c ON i.doc_camper = c.documento
WHERE c.id_nivel_riesgo = (SELECT id FROM nivelRiesgo WHERE nivel = 'Alto')
GROUP BY m.id
ORDER BY cantidad_cursados DESC
LIMIT 1;

-- 12. Consultar los trainers con más de 3 rutas asignadas
SELECT 
    t.id AS trainer_id,
    t.nombres AS trainer_nombre,
    t.apellidos AS trainer_apellidos,
    COUNT(rt.id_ruta) AS rutas_asignadas
FROM trainer t
JOIN rutaTrainer rt ON t.id = rt.id_trainer
GROUP BY t.id
HAVING COUNT(rt.id_ruta) > 3
ORDER BY rutas_asignadas DESC;

-- 13. Listar los horarios más ocupados por áreas
SELECT 
    h.hora_inicio,
    h.hora_fin,
    a.nombre AS area_nombre,
    COUNT(sa.id) AS ocupaciones
FROM horarios h
JOIN asignacionArea sa ON h.id = sa.id_horario
JOIN areaSalon a ON sa.id_area = a.id
GROUP BY h.id, a.id
ORDER BY ocupaciones DESC;

-- 14. Consultar las rutas con el mayor número de módulos
SELECT 
    r.id AS ruta_id,
    r.nombre AS ruta_nombre,
    COUNT(rm.id_modulo) AS numero_modulos
FROM rutaAprendizaje r
JOIN rutaModulo rm ON r.id = rm.id_ruta
GROUP BY r.id
ORDER BY numero_modulos DESC;

-- 15. Obtener los campers que han cambiado de estado más de una vez
SELECT 
    hc.doc_camper,
    c.nombres,
    c.apellidos,
    COUNT(hc.id) AS cambios_estado
FROM historicoEstadoCamper hc
JOIN camper c ON hc.doc_camper = c.documento
GROUP BY hc.doc_camper
HAVING cambios_estado > 1;

-- 16. Mostrar las evaluaciones donde la nota teórica sea mayor a la práctica
SELECT 
    nf.id AS evaluacion_id,
    nf.doc_camper,
    c.nombres,
    c.apellidos,
    nf.nota_teorica,
    nf.nota_practica
FROM notaFinal nf
JOIN camper c ON nf.doc_camper = c.documento
WHERE nf.nota_teorica > nf.nota_practica;

-- 17. Listar los módulos donde la media de quizzes supera el 9
SELECT 
    sn.id_modulo,
    m.nombre AS modulo_nombre,
    AVG(sn.nota) AS promedio_quizzes
FROM skillsNotas sn
JOIN moduloAprendizaje m ON sn.id_modulo = m.id
JOIN tipoEvaluacion te ON sn.id_tipo_evaluacion = te.id
WHERE te.nombre = 'Quiz'
GROUP BY sn.id_modulo
HAVING AVG(sn.nota) > 9;

-- 18. Consultar la ruta con mayor tasa de graduación
SELECT 
    ra.nombre AS ruta_nombre,
    COUNT(DISTINCT eg.documento) AS num_egresados,
    COUNT(DISTINCT i.doc_camper) AS num_inscritos,
    (COUNT(DISTINCT eg.documento) / COUNT(DISTINCT i.doc_camper)) * 100 AS tasa_graduacion
FROM rutaAprendizaje ra
JOIN inscripciones i ON ra.id = i.id_ruta
LEFT JOIN egresados eg ON i.doc_camper = eg.documento
GROUP BY ra.id
ORDER BY tasa_graduacion DESC
LIMIT 1;

-- 19. Mostrar los módulos cursados por campers de nivel de riesgo medio o alto
SELECT 
    ma.nombre AS modulo_nombre,
    COUNT(DISTINCT cam.documento) AS num_camper
FROM moduloAprendizaje ma
JOIN skillModulo sm ON ma.id = sm.id_modulo
JOIN skills s ON sm.id_skill = s.id
JOIN campersModulosAsignados cma ON ma.id = cma.id_modulo
JOIN camper cam ON cma.doc_camper = cam.documento
JOIN nivelRiesgo nr ON cam.id_nivel_riesgo = nr.id
WHERE nr.nivel IN ('Medio', 'Alto')
GROUP BY ma.id
ORDER BY num_camper DESC;

-- 20. Obtener la diferencia entre capacidad y ocupación en cada área
SELECT 
    a.nombre AS area_nombre,
    a.capacidad AS capacidad_maxima,
    COUNT(DISTINCT ac.doc_camper) AS ocupacion_actual,
    (a.capacidad - COUNT(DISTINCT ac.doc_camper)) AS diferencia
FROM areaSalon a
LEFT JOIN asignacionCamper ac ON a.id = ac.id_area
GROUP BY a.id;