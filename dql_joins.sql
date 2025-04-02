-- JOINS BASICOS 

-- 1. Obtener los nombres completos de los campers junto con el nombre de la ruta a la que están inscritos.
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
    r.nombre AS ruta_nombre
FROM camper c
JOIN inscripciones i ON c.documento = i.doc_camper
JOIN rutaAprendizaje r ON i.id_ruta = r.id;

-- 2. Mostrar los campers con sus evaluaciones (nota teórica, práctica, quizzes y nota final) por cada módulo.
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

-- 3. Listar todos los módulos que componen cada ruta de entrenamiento.
SELECT 
    r.nombre AS ruta_nombre,
    m.nombre AS modulo_nombre
FROM rutaAprendizaje r
JOIN rutaModulo rm ON r.id = rm.id_ruta
JOIN moduloAprendizaje m ON rm.id_modulo = m.id
ORDER BY r.nombre, m.nombre;

-- 4. Consultar las rutas con sus trainers asignados y las áreas en las que imparten clases.
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

-- 5. Mostrar los campers junto con el trainer responsable de su ruta actual.
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

-- 6. Obtener el listado de evaluaciones realizadas con nombre de camper, módulo y ruta.
SELECT 
    c.nombres AS camper_nombre,
    c.apellidos AS camper_apellido,
    r.nombre AS ruta_nombre,
    m.nombre AS modulo_nombre,
    sn.nota AS nota
FROM 
    skillsNotas sn
JOIN 
    camper c ON sn.doc_camper = c.documento
JOIN 
    moduloAprendizaje m ON sn.id_modulo = m.id
JOIN 
    rutaAprendizaje r ON r.id = (SELECT id_ruta FROM inscripciones i WHERE i.doc_camper = c.documento AND i.estado = 'Completada' LIMIT 1)
ORDER BY 
    c.nombres, r.nombre, m.nombre;

-- 7. Listar los trainers y los horarios en que están asignados a las áreas de entrenamiento.
SELECT 
    t.nombres AS trainer_nombre,
    t.apellidos AS trainer_apellidos,
    a.nombre AS area_nombre,
    h.hora_inicio,
    h.hora_fin,
    ht.dia_semana
FROM 
    horarioTrainer ht
JOIN 
    trainer t ON ht.id_trainer = t.id
JOIN 
    areaSalon a ON ht.id_area = a.id
JOIN 
    horarios h ON ht.id_horario = h.id
ORDER BY 
    t.nombres, t.apellidos, ht.dia_semana;

-- 8. Consultar todos los campers junto con su estado actual y el nivel de riesgo.
SELECT 
    c.nombres AS camper_nombre,
    c.apellidos AS camper_apellidos,
    e.nombre AS estado_actual,
    nr.nivel AS nivel_riesgo
FROM 
    camper c
JOIN 
    estadoActual e ON c.id_estado = e.id
JOIN 
    nivelRiesgo nr ON c.id_nivel_riesgo = nr.id
ORDER BY 
    c.nombres, c.apellidos;

-- 9. Obtener todos los módulos de cada ruta junto con su porcentaje teórico, práctico y de quizzes.
SELECT 
    ra.nombre AS ruta_nombre,
    ma.nombre AS modulo_nombre,
    te.nombre AS tipo_evaluacion,
    te.porcentaje
FROM 
    rutaAprendizaje ra
JOIN 
    rutaModulo rm ON ra.id = rm.id_ruta
JOIN 
    moduloAprendizaje ma ON rm.id_modulo = ma.id
JOIN 
    skillsNotas sn ON sn.id_modulo = ma.id
JOIN 
    tipoEvaluacion te ON sn.id_tipo_evaluacion = te.id
ORDER BY 
    ra.nombre, ma.nombre, te.nombre;

-- 10. Mostrar los nombres de las áreas junto con los nombres de los campers que están asistiendo en esos espacios.
SELECT 
    asn.id_area, 
    asn.fecha_inicio,
    asn.fecha_fin,
    a.nombre AS area_nombre,
    c.nombres AS camper_nombres,
    c.apellidos AS camper_apellidos
FROM 
    asignacionCamper asn
JOIN 
    areaSalon a ON asn.id_area = a.id
JOIN 
    camper c ON asn.doc_camper = c.documento
ORDER BY 
    asn.id_area, c.nombres, c.apellidos;

-- JOINS CON CONDICIONES ESPECIFICAS

-- 1. Listar los campers que han aprobado todos los módulos de su ruta (nota_final >= 60).
SELECT 
    c.nombres,
    c.apellidos,
    r.nombre AS ruta_nombre
FROM 
    camper c
JOIN 
    inscripciones i ON c.documento = i.doc_camper
JOIN 
    rutaAprendizaje r ON i.id_ruta = r.id
JOIN 
    campersModulosAsignados cma ON c.documento = cma.doc_camper
JOIN 
    notaFinal nf ON cma.id_modulo = nf.id_modulo AND c.documento = nf.doc_camper
WHERE 
    nf.nota_final >= 60  -- Aprobó el módulo
GROUP BY 
    c.documento, r.id
HAVING 
    COUNT(cma.id_modulo) = COUNT(CASE WHEN nf.nota_final >= 60 THEN 1 END);  -- Verifica que todos los módulos estén aprobados

-- 2. Mostrar las rutas que tienen más de 10 campers inscritos actualmente.
SELECT 
    r.nombre AS ruta_nombre,
    COUNT(i.doc_camper) AS total_camper_inscritos
FROM 
    rutaAprendizaje r
JOIN 
    inscripciones i ON r.id = i.id_ruta
WHERE 
    i.estado = 'Pendiente' OR i.estado = 'Aprobada' -- Solo contar los campers activos
GROUP BY 
    r.id
HAVING 
    COUNT(i.doc_camper) > 10;

-- 3. Consultar las áreas que superan el 80% de su capacidad con el número actual de campers asignados.
SELECT 
    a.nombre AS area_nombre,
    a.capacidad AS capacidad_total,
    COUNT(ac.doc_camper) AS campers_asignados,
    (COUNT(ac.doc_camper) / a.capacidad) * 100 AS porcentaje_ocupacion
FROM 
    areaSalon a
JOIN 
    asignacionCamper ac ON a.id = ac.id_area
GROUP BY 
    a.id
HAVING 
    (COUNT(ac.doc_camper) / a.capacidad) > 0.8;

-- 4. Obtener los trainers que imparten más de una ruta diferente.
SELECT 
    t.nombres AS trainer_nombre,
    t.apellidos AS trainer_apellidos,
    COUNT(rt.id_ruta) AS cantidad_rutas
FROM 
    trainer t
JOIN 
    rutaTrainer rt ON t.id = rt.id_trainer
GROUP BY 
    t.id
HAVING 
    COUNT(rt.id_ruta) > 1;

-- 5. Listar las evaluaciones donde la nota práctica es mayor que la nota teórica.
SELECT 
    nf.doc_camper,
    nf.id_modulo,
    nf.nota_teorica,
    nf.nota_practica,
    nf.nota_quizzes,
    nf.nota_final
FROM 
    notaFinal nf
WHERE 
    nf.nota_practica > nf.nota_teorica;

-- 6. Mostrar campers que están en rutas cuyo SGDB principal es MySQL.
SELECT 
    c.documento,
    c.nombres,
    c.apellidos,
    r.nombre AS ruta
FROM 
    camper c
JOIN 
    inscripciones i ON c.documento = i.doc_camper
JOIN 
    rutaAprendizaje r ON i.id_ruta = r.id
JOIN 
    bdAsociados ba ON r.id = ba.id_ruta
JOIN 
    sgbd s ON ba.id_sgbd = s.id
WHERE 
    s.nombre = 'MySQL' AND ba.es_principal = TRUE;

-- 7. Obtener los nombres de los módulos donde los campers han tenido bajo rendimiento.
SELECT 
    m.nombre AS modulo
FROM 
    notaFinal nf
JOIN 
    moduloAprendizaje m ON nf.id_modulo = m.id
WHERE 
    nf.nota_final < 60;

-- 8. Consultar las rutas con más de 3 módulos asociados.
SELECT 
    r.nombre AS ruta,
    COUNT(rm.id_modulo) AS cantidad_modulos
FROM 
    rutaModulo rm
JOIN 
    rutaAprendizaje r ON rm.id_ruta = r.id
GROUP BY 
    rm.id_ruta
HAVING 
    COUNT(rm.id_modulo) > 3;

-- 9. Listar las inscripciones realizadas en los últimos 30 días con sus respectivos campers y rutas.
SELECT 
    i.id AS id_inscripcion,
    c.nombres AS nombre_camper,
    c.apellidos AS apellido_camper,
    r.nombre AS ruta,
    i.fecha_inscripcion
FROM 
    inscripciones i
JOIN 
    camper c ON i.doc_camper = c.documento
JOIN 
    rutaAprendizaje r ON i.id_ruta = r.id
WHERE 
    i.fecha_inscripcion >= CURDATE() - INTERVAL 30 DAY;

-- 10. Obtener los trainers que están asignados a rutas con campers en estado de “Alto Riesgo”.
SELECT 
    t.nombres AS nombre_trainer,
    t.apellidos AS apellido_trainer,
    r.nombre AS ruta,
    c.nombres AS nombre_camper,
    c.apellidos AS apellido_camper,
    nr.nivel AS nivel_riesgo
FROM 
    trainer t
JOIN 
    rutaTrainer rt ON t.id = rt.id_trainer
JOIN 
    rutaAprendizaje r ON rt.id_ruta = r.id
JOIN 
    inscripciones i ON r.id = i.id_ruta
JOIN 
    camper c ON i.doc_camper = c.documento
JOIN 
    nivelRiesgo nr ON c.id_nivel_riesgo = nr.id
WHERE 
    nr.nivel = 'Alto'
GROUP BY 
    t.id, r.id, c.documento;

-- JOINS CON FUNCIONES DE AGREGACION

-- 1. Obtener el promedio de nota final por módulo.
SELECT 
    m.nombre AS modulo,
    AVG(nf.nota_final) AS promedio_nota_final
FROM 
    moduloAprendizaje m
JOIN 
    notaFinal nf ON m.id = nf.id_modulo
GROUP BY 
    m.id;

-- 2. Calcular la cantidad total de campers por ruta.
SELECT 
    r.nombre AS ruta,
    COUNT(i.id) AS total_camper
FROM 
    rutaAprendizaje r
JOIN 
    inscripciones i ON r.id = i.id_ruta
WHERE 
    i.estado = 'Aprobada' 
GROUP BY 
    r.id;

-- 3. Mostrar la cantidad de evaluaciones realizadas por cada trainer (según las rutas que imparte).
SELECT 
    t.nombres AS trainer,
    t.apellidos AS apellidos,
    COUNT(se.id) AS total_evaluaciones
FROM 
    trainer t
JOIN 
    rutaTrainer rt ON t.id = rt.id_trainer
JOIN 
    rutaAprendizaje r ON rt.id_ruta = r.id
JOIN 
    inscripciones i ON r.id = i.id_ruta
JOIN 
    skillsNotas se ON i.doc_camper = se.doc_camper
WHERE 
    se.id_modulo = r.id  -- Asumiendo que el módulo se asocia a la ruta, ajusta si es necesario
GROUP BY 
    t.id;

-- 4. Consultar el promedio general de rendimiento por cada área de entrenamiento.
SELECT 
    a.nombre AS area,
    AVG(nf.nota_final) AS promedio_rendimiento
FROM 
    areaSalon a
JOIN 
    asignacionCamper ac ON a.id = ac.id_area
JOIN 
    notaFinal nf ON ac.doc_camper = nf.doc_camper
WHERE 
    nf.nota_final IS NOT NULL  -- Asegura que solo se incluyan las notas finales existentes
GROUP BY 
    a.id;

-- 5. Obtener la cantidad de módulos asociados a cada ruta de entrenamiento.
SELECT 
    ra.nombre AS ruta,
    COUNT(rm.id_modulo) AS cantidad_modulos
FROM 
    rutaAprendizaje ra
JOIN 
    rutaModulo rm ON ra.id = rm.id_ruta
GROUP BY 
    ra.id;

-- 6. Mostrar el promedio de nota final de los campers en estado “Cursando”.
SELECT 
    AVG(nf.nota_final) AS promedio_nota_final
FROM 
    notaFinal nf
JOIN 
    camper c ON nf.doc_camper = c.documento
JOIN 
    estadoActual e ON c.id_estado = e.id
WHERE 
    e.nombre = 'Cursando';

-- 7. Listar el número de campers evaluados en cada módulo.
SELECT 
    ma.nombre AS modulo_nombre,
    COUNT(sn.doc_camper) AS campers_evaluados
FROM 
    skillsNotas sn
JOIN 
    moduloAprendizaje ma ON sn.id_modulo = ma.id
GROUP BY 
    ma.id;

-- 8. Consultar el porcentaje de ocupación actual por cada área de entrenamiento.
SELECT 
    aa.id_area,
    asn.nombre AS area_nombre,
    asn.capacidad,
    COUNT(sa.id) AS campers_asignados,
    (COUNT(sa.id) / asn.capacidad) * 100 AS porcentaje_ocupacion
FROM 
    asignacionArea aa
JOIN 
    areaSalon asn ON aa.id_area = asn.id
LEFT JOIN 
    asignacionCamper sa ON sa.id_area = aa.id_area
GROUP BY 
    aa.id_area;

-- 9. Mostrar cuántos trainers tiene asignados cada área.
SELECT 
    asn.id AS area_id,
    asn.nombre AS area_nombre,
    COUNT(ht.id_trainer) AS numero_trainers_asignados
FROM 
    areaSalon asn
LEFT JOIN 
    horarioTrainer ht ON ht.id_area = asn.id
GROUP BY 
    asn.id;

-- 10. Listar las rutas que tienen más campers en riesgo alto.
SELECT 
    r.nombre AS ruta_nombre,
    COUNT(i.id) AS cantidad_camper_riesgo_alto
FROM 
    inscripciones i
JOIN 
    camper c ON i.doc_camper = c.documento
JOIN 
    nivelRiesgo nr ON c.id_nivel_riesgo = nr.id
JOIN 
    rutaAprendizaje r ON i.id_ruta = r.id
WHERE 
    nr.nivel = 'AL'  -- Considerando 'AL' como el nivel de riesgo alto
GROUP BY 
    i.id_ruta
ORDER BY 
    cantidad_camper_riesgo_alto DESC;

