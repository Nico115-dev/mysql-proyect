-- 1. Calcular el promedio ponderado de evaluaciones de un camper.
DELIMITER //
CREATE FUNCTION calcular_promedio_ponderado(
    p_doc_camper INT, 
    p_id_modulo INT
) RETURNS DECIMAL(5,2)
BEGIN
    DECLARE v_nota_teorica DECIMAL(5,2);
    DECLARE v_nota_practica DECIMAL(5,2);
    DECLARE v_nota_quiz DECIMAL(5,2);
    DECLARE v_promedio DECIMAL(5,2);

    -- Obtener las notas de la evaluación
    SELECT nota_teorica, nota_practica, nota_quiz
    INTO v_nota_teorica, v_nota_practica, v_nota_quiz
    FROM evaluacion
    WHERE doc_camper = p_doc_camper AND id_modulo = p_id_modulo;

    -- Calcular el promedio ponderado
    SET v_promedio = (v_nota_teorica * 0.4) + (v_nota_practica * 0.4) + (v_nota_quiz * 0.2);

    RETURN v_promedio;
END //
DELIMITER ;

-- 2. Determinar si un camper aprueba o no un módulo específico.
DELIMITER //
CREATE FUNCTION aprobar_modulo(
    p_doc_camper INT, 
    p_id_modulo INT
) RETURNS BOOLEAN
BEGIN
    DECLARE v_nota_final DECIMAL(5,2);

    -- Obtener la nota final del camper
    SELECT nota_final INTO v_nota_final
    FROM evaluacion
    WHERE doc_camper = p_doc_camper AND id_modulo = p_id_modulo;

    -- Verificar si la nota final es aprobatoria
    IF v_nota_final >= 60 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END //
DELIMITER ;

-- 3. Evaluar el nivel de riesgo de un camper según su rendimiento promedio.
DELIMITER //
CREATE FUNCTION evaluar_riesgo_camper(
    p_doc_camper INT
) RETURNS VARCHAR(50)
BEGIN
    DECLARE v_promedio DECIMAL(5,2);

    -- Calcular el promedio de notas del camper
    SELECT AVG(nota_final) INTO v_promedio
    FROM evaluacion
    WHERE doc_camper = p_doc_camper;

    -- Evaluar el nivel de riesgo según el promedio
    IF v_promedio >= 80 THEN
        RETURN 'Bajo';
    ELSEIF v_promedio >= 60 THEN
        RETURN 'Medio';
    ELSE
        RETURN 'Alto';
    END IF;
END //
DELIMITER ;

-- 4. Obtener el total de campers asignados a una ruta específica.
DELIMITER //
CREATE FUNCTION total_camper_ruta(
    p_id_ruta INT
) RETURNS INT
BEGIN
    DECLARE v_total INT;

    -- Contar los campers asignados a la ruta
    SELECT COUNT(*) INTO v_total
    FROM camperRuta
    WHERE id_ruta = p_id_ruta;

    RETURN v_total;
END //
DELIMITER ;

-- 5. Consultar la cantidad de módulos que ha aprobado un camper.
DELIMITER //
CREATE FUNCTION cantidad_modulos_aprobados(
    p_doc_camper INT
) RETURNS INT
BEGIN
    DECLARE v_aprobados INT;

    -- Contar los módulos aprobados
    SELECT COUNT(*) INTO v_aprobados
    FROM evaluacion
    WHERE doc_camper = p_doc_camper AND nota_final >= 60;

    RETURN v_aprobados;
END //
DELIMITER ;

-- 6. Validar si hay cupos disponibles en una determinada área.
DELIMITER //
CREATE FUNCTION validar_cupos_area(
    p_id_area INT
) RETURNS BOOLEAN
BEGIN
    DECLARE v_capacidad_max INT;
    DECLARE v_num_camper INT;

    -- Obtener la capacidad máxima del área
    SELECT capacidad_maxima INTO v_capacidad_max
    FROM areaEntrenamiento
    WHERE id = p_id_area;

    -- Contar el número de campers asignados al área
    SELECT COUNT(*) INTO v_num_camper
    FROM camperRuta
    WHERE id_area = p_id_area;

    -- Verificar si hay cupos disponibles
    IF v_num_camper < v_capacidad_max THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END //
DELIMITER ;

-- 7. Calcular el porcentaje de ocupación de un área de entrenamiento.
DELIMITER //
CREATE FUNCTION porcentaje_ocupacion_area(
    p_id_area INT
) RETURNS DECIMAL(5,2)
BEGIN
    DECLARE v_capacidad_max INT;
    DECLARE v_num_camper INT;
    DECLARE v_porcentaje DECIMAL(5,2);

    -- Obtener la capacidad máxima del área
    SELECT capacidad_maxima INTO v_capacidad_max
    FROM areaEntrenamiento
    WHERE id = p_id_area;

    -- Contar el número de campers asignados al área
    SELECT COUNT(*) INTO v_num_camper
    FROM camperRuta
    WHERE id_area = p_id_area;

    -- Calcular el porcentaje de ocupación
    SET v_porcentaje = (v_num_camper / v_capacidad_max) * 100;

    RETURN v_porcentaje;
END //
DELIMITER ;

-- 8. Determinar la nota más alta obtenida en un módulo.
DELIMITER //
CREATE FUNCTION nota_mas_alta_modulo(
    p_id_modulo INT
) RETURNS DECIMAL(5,2)
BEGIN
    DECLARE v_nota_max DECIMAL(5,2);

    -- Obtener la nota máxima del módulo
    SELECT MAX(nota_final) INTO v_nota_max
    FROM evaluacion
    WHERE id_modulo = p_id_modulo;

    RETURN v_nota_max;
END //
DELIMITER ;

-- 9. Calcular la tasa de aprobación de una ruta.
DELIMITER //
CREATE FUNCTION tasa_aprobacion_ruta(
    p_id_ruta INT
) RETURNS DECIMAL(5,2)
BEGIN
    DECLARE v_total INT;
    DECLARE v_aprobados INT;
    DECLARE v_tasa DECIMAL(5,2);

    -- Contar los total de campers asignados a la ruta
    SELECT COUNT(*) INTO v_total
    FROM camperRuta
    WHERE id_ruta = p_id_ruta;

    -- Contar los campers aprobados en esa ruta
    SELECT COUNT(*) INTO v_aprobados
    FROM camperRuta cr
    JOIN evaluacion e ON cr.doc_camper = e.doc_camper
    WHERE cr.id_ruta = p_id_ruta AND e.nota_final >= 60;

    -- Calcular la tasa de aprobación
    SET v_tasa = (v_aprobados / v_total) * 100;

    RETURN v_tasa;
END //
DELIMITER ;

-- 10. Verificar si un trainer tiene horario disponible.
DELIMITER //
CREATE FUNCTION horario_disponible_trainer(
    p_id_trainer INT, 
    p_horario TIME
) RETURNS BOOLEAN
BEGIN
    DECLARE v_disponibilidad INT;

    -- Verificar si el trainer tiene el horario disponible
    SELECT COUNT(*) INTO v_disponibilidad
    FROM rutaTrainer
    WHERE id_trainer = p_id_trainer AND horario = p_horario;

    IF v_disponibilidad = 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END //
DELIMITER ;

-- 11. Obtener el promedio de notas por ruta.
DELIMITER //
CREATE FUNCTION promedio_notas_ruta(
    p_id_ruta INT
) RETURNS DECIMAL(5,2)
BEGIN
    DECLARE v_promedio DECIMAL(5,2);

    -- Calcular el promedio de notas en la ruta
    SELECT AVG(nota_final) INTO v_promedio
    FROM evaluacion e
    JOIN camperRuta cr ON e.doc_camper = cr.doc_camper
    WHERE cr.id_ruta = p_id_ruta;

    RETURN v_promedio;
END //
DELIMITER ;

-- 12. Calcular cuántas rutas tiene asignadas un trainer.
DELIMITER //
CREATE FUNCTION cantidad_rutas_trainer(
    p_id_trainer INT
) RETURNS INT
BEGIN
    DECLARE v_total INT;

    -- Contar las rutas asignadas al trainer
    SELECT COUNT(*) INTO v_total
    FROM rutaTrainer
    WHERE id_trainer = p_id_trainer;

    RETURN v_total;
END //
DELIMITER ;

-- 13. Verificar si un camper puede ser graduado.
DELIMITER //
CREATE FUNCTION puede_ser_graduado(
    p_doc_camper INT
) RETURNS BOOLEAN
BEGIN
    DECLARE v_total_modulos INT;
    DECLARE v_modulos_aprobados INT;

    -- Contar los módulos aprobados y el total de módulos
    SELECT COUNT(*), SUM(CASE WHEN nota_final >= 60 THEN 1 ELSE 0 END)
    INTO v_total_modulos, v_modulos_aprobados
    FROM evaluacion
    WHERE doc_camper = p_doc_camper;

    -- Verificar si aprobó todos los módulos
    IF v_modulos_aprobados = v_total_modulos THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END //
DELIMITER ;

-- 14. Obtener el estado actual de un camper en función de sus evaluaciones.
DELIMITER //
CREATE FUNCTION estado_camper(
    p_doc_camper INT
) RETURNS VARCHAR(50)
BEGIN
    DECLARE v_promedio DECIMAL(5,2);

    -- Obtener el promedio de notas
    SELECT AVG(nota_final) INTO v_promedio
    FROM evaluacion
    WHERE doc_camper = p_doc_camper;

    -- Determinar el estado del camper
    IF v_promedio >= 60 THEN
        RETURN 'Aprobado';
    ELSE
        RETURN 'Reprobado';
    END IF;
END //
DELIMITER ;

-- 15. Calcular la carga horaria semanal de un trainer.
DELIMITER //
CREATE FUNCTION carga_horaria_trainer(
    p_id_trainer INT
) RETURNS INT
BEGIN
    DECLARE v_total_horas INT;

    -- Calcular el total de horas asignadas al trainer
    SELECT SUM(duracion) INTO v_total_horas
    FROM rutaTrainer
    WHERE id_trainer = p_id_trainer;

    RETURN v_total_horas;
END //
DELIMITER ;

-- 16. Determinar si una ruta tiene módulos pendientes por evaluación.
DELIMITER //
CREATE FUNCTION tiene_modulos_pendientes(
    p_id_ruta INT
) RETURNS BOOLEAN
BEGIN
    DECLARE v_pendientes INT;

    -- Verificar si hay módulos pendientes por evaluación
    SELECT COUNT(*) INTO v_pendientes
    FROM modulo
    WHERE id_ruta = p_id_ruta AND id_modulo NOT IN (
        SELECT id_modulo FROM evaluacion
        WHERE nota_final IS NOT NULL
    );

    IF v_pendientes > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END //
DELIMITER ;

-- 17. Calcular el promedio general del programa.
DELIMITER //
CREATE FUNCTION promedio_general_programa() RETURNS DECIMAL(5,2)
BEGIN
    DECLARE v_promedio DECIMAL(5,2);

    -- Calcular el promedio de todos los campers en todas las rutas
    SELECT AVG(nota_final) INTO v_promedio
    FROM evaluacion;

    RETURN v_promedio;
END //
DELIMITER ;

-- 18. Verificar si un horario choca con otros entrenadores en el área.
DELIMITER //
CREATE FUNCTION horario_choca(
    p_id_area INT, 
    p_horario TIME
) RETURNS BOOLEAN
BEGIN
    DECLARE v_choca INT;

    -- Verificar si el horario ya está ocupado
    SELECT COUNT(*) INTO v_choca
    FROM rutaTrainer
    WHERE id_area = p_id_area AND horario = p_horario;

    IF v_choca > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END //
DELIMITER ;

-- 19. Calcular cuántos campers están en riesgo en una ruta específica.
DELIMITER //
CREATE FUNCTION campers_en_riesgo(
    p_id_ruta INT
) RETURNS INT
BEGIN
    DECLARE v_riesgo INT;

    -- Contar los campers en riesgo
    SELECT COUNT(*) INTO v_riesgo
    FROM camperRuta cr
    JOIN evaluacion e ON cr.doc_camper = e.doc_camper
    WHERE cr.id_ruta = p_id_ruta AND e.nota_final < 60;

    RETURN v_riesgo;
END //
DELIMITER ;

-- 20. Consultar el número de módulos evaluados por un camper.
DELIMITER //
CREATE FUNCTION modulos_evaluados_camper(
    p_doc_camper INT
) RETURNS INT
BEGIN
    DECLARE v_modulos_evaluados INT;

    -- Contar los módulos evaluados por el camper
    SELECT COUNT(*) INTO v_modulos_evaluados
    FROM evaluacion
    WHERE doc_camper = p_doc_camper;

    RETURN v_modulos_evaluados;
END //
DELIMITER ;
