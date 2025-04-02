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
WHERE nr.nivel = 'Riesgo alto';

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
SELECT 
    r.id AS id_ruta,
    r.nombre AS nombre_ruta,
    sgbd_principal.nombre AS sgbd_principal,
    sgbd_alternativo.nombre AS sgbd_alternativo
FROM rutaAprendizaje r
LEFT JOIN bdAsociados ba_principal 
    ON r.id = ba_principal.id_ruta AND ba_principal.es_principal = TRUE
LEFT JOIN sgbd sgbd_principal 
    ON ba_principal.id_sgbd = sgbd_principal.id
LEFT JOIN bdAsociados ba_alternativo 
    ON r.id = ba_alternativo.id_ruta AND ba_alternativo.es_principal = FALSE
LEFT JOIN sgbd sgbd_alternativo 
    ON ba_alternativo.id_sgbd = sgbd_alternativo.id;

-- 3. Listar los módulos asociados a cada ruta
SELECT r.nombre AS ruta, m.nombre AS modulo
FROM rutaModulo rm
JOIN rutaAprendizaje r ON rm.id_ruta = r.id
JOIN moduloAprendizaje m ON rm.id_modulo = m.id
ORDER BY r.nombre, m.nombre;

-- 4. Consultar cuántos campers hay en cada ruta
SELECT 
    r.id AS id_ruta,
    r.nombre AS nombre_ruta,
    COUNT(i.doc_camper) AS cantidad_campers
FROM rutaAprendizaje r
LEFT JOIN inscripciones i 
    ON r.id = i.id_ruta
GROUP BY r.id, r.nombre
ORDER BY cantidad_campers DESC;

-- 5. Mostrar las áreas de entrenamiento y su capacidad máxima
SELECT 
    id AS id_area,
    nombre AS nombre_area,
    capacidad AS capacidad_maxima
FROM areaSalon
ORDER BY capacidad DESC;

-- 6. Obtener las áreas que están ocupadas al 100%
SELECT 
    a.id AS id_area,
    a.nombre AS nombre_area,
    a.capacidad AS capacidad_maxima,
    COUNT(ac.doc_camper) AS campers_asignados
FROM areaSalon a
JOIN asignacionCamper ac 
    ON a.id = ac.id_area
GROUP BY a.id, a.nombre, a.capacidad
HAVING COUNT(ac.doc_camper) >= a.capacidad
ORDER BY a.nombre;

-- 7. Verificar la ocupación actual de cada área
SELECT 
    a.id AS id_area,
    a.nombre AS nombre_area,
    a.capacidad AS capacidad_maxima,
    COUNT(ac.doc_camper) AS campers_asignados,
    ROUND((COUNT(ac.doc_camper) / a.capacidad) * 100, 2) AS porcentaje_ocupacion
FROM areaSalon a
LEFT JOIN asignacionCamper ac 
    ON a.id = ac.id_area
GROUP BY a.id, a.nombre, a.capacidad
ORDER BY porcentaje_ocupacion DESC;

-- 8. Consultar los horarios disponibles por cada área
SELECT 
    a.id AS id_area,
    a.nombre AS nombre_area,
    h.id AS id_horario,
    h.hora_inicio,
    h.hora_fin
FROM areaSalon a
JOIN horarios h 
    ON NOT EXISTS (
        SELECT 1 
        FROM asignacionArea aa
        WHERE aa.id_area = a.id 
        AND aa.id_horario = h.id
    )
ORDER BY a.nombre, h.hora_inicio;

-- 9. Mostrar las áreas con más campers asignados
SELECT 
    a.id AS id_area,
    a.nombre AS nombre_area,
    a.capacidad AS capacidad_maxima,
    COUNT(ac.doc_camper) AS campers_asignados
FROM areaSalon a
JOIN asignacionCamper ac 
    ON a.id = ac.id_area
GROUP BY a.id, a.nombre, a.capacidad
ORDER BY campers_asignados DESC;

-- 10. Listar las rutas con sus respectivos trainers y áreas asignadas
SELECT 
    r.id AS id_ruta,
    r.nombre AS nombre_ruta,
    t.id AS id_trainer,
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    a.id AS id_area,
    a.nombre AS nombre_area
FROM rutaAprendizaje r
LEFT JOIN rutaTrainer rt 
    ON r.id = rt.id_ruta
LEFT JOIN trainer t 
    ON rt.id_trainer = t.id
LEFT JOIN horarioTrainer ht 
    ON t.id = ht.id_trainer
LEFT JOIN areaSalon a 
    ON ht.id_area = a.id
ORDER BY r.nombre, t.nombres, a.nombre;

-- TRAINERS

-- 1. Listar todos los entrenadores registrados
SELECT * FROM trainer;

-- 2. Mostrar los trainers con sus horarios asignados
SELECT 
    t.nombres AS Nombre_Trainer,
    t.apellidos AS Apellido_Trainer,
    h.hora_inicio AS Inicio_Horario,
    h.hora_fin AS Fin_Horario,
    ht.dia_semana AS Día_Asignado,
    a.nombre AS Nombre_Area
FROM horarioTrainer ht
JOIN trainer t ON ht.id_trainer = t.id
JOIN horarios h ON ht.id_horario = h.id
JOIN areaSalon a ON ht.id_area = a.id
ORDER BY t.nombres, ht.dia_semana;

-- 3. Consultar los trainers asignados a más de una ruta
SELECT 
    t.id AS id_trainer,
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    COUNT(DISTINCT rt.id_ruta) AS numero_de_rutas
FROM trainer t
JOIN rutaTrainer rt ON t.id = rt.id_trainer
GROUP BY t.id, nombre_trainer
HAVING COUNT(DISTINCT rt.id_ruta) > 1
ORDER BY numero_de_rutas DESC;


-- 4. Obtener el número de campers por trainer
SELECT 
    t.id AS id_trainer,
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    COUNT(DISTINCT c.documento) AS numero_de_campers
FROM trainer t
LEFT JOIN rutaTrainer rt ON t.id = rt.id_trainer
LEFT JOIN inscripciones i ON rt.id_ruta = i.id_ruta
LEFT JOIN camper c ON i.doc_camper = c.documento
GROUP BY t.id, nombre_trainer
ORDER BY numero_de_campers DESC;

-- 5. Mostrar las áreas en las que trabaja cada trainer
SELECT 
    t.id AS id_trainer,
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    GROUP_CONCAT(a.nombre ORDER BY a.nombre SEPARATOR ', ') AS areas_trabajo
FROM trainer t
JOIN horarioTrainer ht ON t.id = ht.id_trainer
JOIN areaSalon a ON ht.id_area = a.id
GROUP BY t.id
ORDER BY nombre_trainer;

-- 6. Listar los trainers sin asignación de área o ruta
SELECT 
    t.id AS id_trainer,
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer
FROM trainer t
LEFT JOIN horarioTrainer ht ON t.id = ht.id_trainer
LEFT JOIN rutaTrainer rt ON t.id = rt.id_trainer
WHERE ht.id IS NULL AND rt.id IS NULL
ORDER BY nombre_trainer;

-- 7. Mostrar cuántos módulos están a cargo de cada trainer
SELECT 
    t.id AS id_trainer,
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    COUNT(DISTINCT sm.id_modulo) AS numero_de_modulos
FROM trainer t
JOIN trainerSkills ts ON t.id = ts.id_trainer
JOIN skillModulo sm ON ts.id_skill = sm.id_skill
GROUP BY t.id
ORDER BY numero_de_modulos DESC;

-- 8. Obtener el trainer con mejor rendimiento promedio de campers
SELECT 
    t.id AS id_trainer,
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    AVG(nf.nota_final) AS rendimiento_promedio
FROM trainer t
JOIN rutaTrainer rt ON t.id = rt.id_trainer
JOIN inscripciones i ON rt.id_ruta = i.id_ruta
JOIN notaFinal nf ON i.doc_camper = nf.doc_camper AND nf.id_modulo = i.id_ruta
GROUP BY t.id
ORDER BY rendimiento_promedio DESC
LIMIT 1;

-- 9. Consultar los horarios ocupados por cada trainer
SELECT 
    t.id AS id_trainer,
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    GROUP_CONCAT(DISTINCT CONCAT(h.hora_inicio, ' - ', h.hora_fin) ORDER BY h.hora_inicio SEPARATOR ', ') AS horarios_ocupados
FROM trainer t
JOIN horarioTrainer ht ON t.id = ht.id_trainer
JOIN horarios h ON ht.id_horario = h.id
GROUP BY t.id
ORDER BY nombre_trainer;

-- 10. Mostrar la disponibilidad semanal de cada trainer
SELECT 
    t.id AS id_trainer,
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    GROUP_CONCAT(DISTINCT CONCAT(ht.dia_semana, ': ', h.hora_inicio, ' - ', h.hora_fin) ORDER BY FIELD(ht.dia_semana, 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado') SEPARATOR '; ') AS horarios_ocupados,
    GROUP_CONCAT(DISTINCT CASE 
            WHEN ht.dia_semana = 'Lunes' THEN 'Lunes: Disponible'
            WHEN ht.dia_semana = 'Martes' THEN 'Martes: Disponible'
            WHEN ht.dia_semana = 'Miércoles' THEN 'Miércoles: Disponible'
            WHEN ht.dia_semana = 'Jueves' THEN 'Jueves: Disponible'
            WHEN ht.dia_semana = 'Viernes' THEN 'Viernes: Disponible'
            WHEN ht.dia_semana = 'Sábado' THEN 'Sábado: Disponible'
            ELSE NULL END SEPARATOR '; ') AS disponibilidad
FROM trainer t
LEFT JOIN horarioTrainer ht ON t.id = ht.id_trainer
LEFT JOIN horarios h ON ht.id_horario = h.id
GROUP BY t.id
ORDER BY nombre_trainer;

