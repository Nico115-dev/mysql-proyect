-- 1. Registrar un nuevo camper con toda su información personal y estado inicial.
DELIMITER //
CREATE PROCEDURE registrar_camper(
    IN p_doc_camper INT, 
    IN p_nombres VARCHAR(255), 
    IN p_apellidos VARCHAR(255), 
    IN p_fecha_nacimiento DATE, 
    IN p_email VARCHAR(255), 
    IN p_telefono VARCHAR(20), 
    IN p_estado VARCHAR(50), 
    IN p_nivel_riesgo VARCHAR(20)
)
BEGIN
    INSERT INTO camper (doc, nombres, apellidos, fecha_nacimiento, email, telefono, estado, nivel_riesgo)
    VALUES (p_doc_camper, p_nombres, p_apellidos, p_fecha_nacimiento, p_email, p_telefono, p_estado, p_nivel_riesgo);
END //
DELIMITER ;

-- 2. Actualizar el estado de un camper luego de completar el proceso de ingreso.
DELIMITER //
CREATE PROCEDURE actualizar_estado_camper(
    IN p_doc_camper INT, 
    IN p_nuevo_estado VARCHAR(50)
)
BEGIN
    UPDATE camper 
    SET estado = p_nuevo_estado 
    WHERE doc = p_doc_camper;
END //
DELIMITER ;

-- 3. Procesar la inscripción de un camper a una ruta específica.
DELIMITER //
CREATE PROCEDURE inscribir_camper_a_ruta(
    IN p_doc_camper INT, 
    IN p_id_ruta INT
)
BEGIN
    INSERT INTO camperRuta (doc_camper, id_ruta) 
    VALUES (p_doc_camper, p_id_ruta);
END //
DELIMITER ;

-- 4. Registrar una evaluación completa (teórica, práctica y quizzes) para un camper.
DELIMITER //
CREATE PROCEDURE registrar_evaluacion(
    IN p_doc_camper INT, 
    IN p_id_modulo INT, 
    IN p_nota_teorica DECIMAL(5,2), 
    IN p_nota_practica DECIMAL(5,2), 
    IN p_nota_quiz DECIMAL(5,2)
)
BEGIN
    INSERT INTO evaluacion (doc_camper, id_modulo, nota_teorica, nota_practica, nota_quiz)
    VALUES (p_doc_camper, p_id_modulo, p_nota_teorica, p_nota_practica, p_nota_quiz);
END //
DELIMITER ;

-- 5. Calcular y registrar automáticamente la nota final de un módulo.
DELIMITER //
CREATE PROCEDURE calcular_nota_final(
    IN p_doc_camper INT, 
    IN p_id_modulo INT
)
BEGIN
    DECLARE v_nota_teorica DECIMAL(5,2);
    DECLARE v_nota_practica DECIMAL(5,2);
    DECLARE v_nota_quiz DECIMAL(5,2);
    DECLARE v_nota_final DECIMAL(5,2);

    -- Obtener las notas de la evaluación
    SELECT nota_teorica, nota_practica, nota_quiz
    INTO v_nota_teorica, v_nota_practica, v_nota_quiz
    FROM evaluacion 
    WHERE doc_camper = p_doc_camper AND id_modulo = p_id_modulo;

    -- Calcular la nota final
    SET v_nota_final = (v_nota_teorica * 0.4) + (v_nota_practica * 0.4) + (v_nota_quiz * 0.2);

    -- Actualizar la nota final
    UPDATE evaluacion 
    SET nota_final = v_nota_final 
    WHERE doc_camper = p_doc_camper AND id_modulo = p_id_modulo;
END //
DELIMITER ;

-- 6. Asignar campers aprobados a una ruta de acuerdo con la disponibilidad del área.
DELIMITER //
CREATE PROCEDURE asignar_camper_a_ruta_aprobado(
    IN p_doc_camper INT, 
    IN p_id_ruta INT
)
BEGIN
    DECLARE v_nota_final DECIMAL(5,2);
    
    -- Obtener la nota final del camper
    SELECT nota_final INTO v_nota_final
    FROM evaluacion 
    WHERE doc_camper = p_doc_camper;

    -- Verificar si la nota final es aprobatoria
    IF v_nota_final >= 60 THEN
        -- Inscribir al camper en la ruta
        INSERT INTO camperRuta (doc_camper, id_ruta) 
        VALUES (p_doc_camper, p_id_ruta);
    END IF;
END //
DELIMITER ;

-- 7. Asignar un trainer a una ruta y área específica, validando el horario.
DELIMITER //
CREATE PROCEDURE asignar_trainer_a_ruta_y_area(
    IN p_id_trainer INT, 
    IN p_id_ruta INT, 
    IN p_id_area INT, 
    IN p_horario TIME
)
BEGIN
    DECLARE v_horario_ocupado INT;

    -- Verificar si el trainer ya tiene asignado un horario en el área
    SELECT COUNT(*) INTO v_horario_ocupado
    FROM rutaTrainer 
    WHERE id_trainer = p_id_trainer AND id_area = p_id_area AND horario = p_horario;

    IF v_horario_ocupado = 0 THEN
        -- Asignar al trainer a la ruta y área
        INSERT INTO rutaTrainer (id_trainer, id_ruta, id_area, horario) 
        VALUES (p_id_trainer, p_id_ruta, p_id_area, p_horario);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Horario ya ocupado para este trainer.';
    END IF;
END //
DELIMITER ;

-- 8. Registrar una nueva ruta con sus módulos y SGDB asociados.
DELIMITER //
CREATE PROCEDURE registrar_ruta(
    IN p_nombre_ruta VARCHAR(255), 
    IN p_sgdb_principal VARCHAR(255), 
    IN p_sgdb_alternativo VARCHAR(255)
)
BEGIN
    DECLARE v_id_ruta INT;

    -- Insertar la nueva ruta
    INSERT INTO rutaAprendizaje (nombre, sgdb_principal, sgdb_alternativo)
    VALUES (p_nombre_ruta, p_sgdb_principal, p_sgdb_alternativo);

    -- Obtener el ID de la nueva ruta
    SET v_id_ruta = LAST_INSERT_ID();

    -- Insertar módulos asociados a la ruta
    INSERT INTO moduloAprendizaje (id_ruta, nombre) 
    VALUES (v_id_ruta, 'Módulo 1'), (v_id_ruta, 'Módulo 2');
END //
DELIMITER ;

-- 9. Registrar una nueva área de entrenamiento con su capacidad y horarios.
DELIMITER //
CREATE PROCEDURE registrar_area_entrenamiento(
    IN p_nombre_area VARCHAR(255), 
    IN p_capacidad_maxima INT, 
    IN p_horarios VARCHAR(255)
)
BEGIN
    -- Insertar la nueva área de entrenamiento
    INSERT INTO areaEntrenamiento (nombre, capacidad_maxima, horarios)
    VALUES (p_nombre_area, p_capacidad_maxima, p_horarios);
END //
DELIMITER ;

-- 10. Consultar disponibilidad de horario en un área determinada.
DELIMITER //
CREATE PROCEDURE consultar_disponibilidad_area(
    IN p_id_area INT, 
    IN p_horario TIME
)
BEGIN
    DECLARE v_disponibilidad INT;

    -- Verificar disponibilidad del horario
    SELECT COUNT(*) INTO v_disponibilidad 
    FROM rutaTrainer 
    WHERE id_area = p_id_area AND horario = p_horario;

    IF v_disponibilidad = 0 THEN
        SELECT 'Disponible' AS disponibilidad;
    ELSE
        SELECT 'No disponible' AS disponibilidad;
    END IF;
END //
DELIMITER ;

-- 11. Reasignar a un camper a otra ruta en caso de bajo rendimiento.
DELIMITER //
CREATE PROCEDURE reasignar_camper_a_nueva_ruta(
    IN p_doc_camper INT, 
    IN p_nueva_ruta INT
)
BEGIN
    DECLARE v_nota_final DECIMAL(5,2);

    -- Obtener la nota final
    SELECT nota_final INTO v_nota_final
    FROM evaluacion 
    WHERE doc_camper = p_doc_camper;

    -- Si el rendimiento es bajo, reasignar
    IF v_nota_final < 60 THEN
        -- Eliminar la inscripción de la ruta actual
        DELETE FROM camperRuta 
        WHERE doc_camper = p_doc_camper;

        -- Inscribir en la nueva ruta
        INSERT INTO camperRuta (doc_camper, id_ruta) 
        VALUES (p_doc_camper, p_nueva_ruta);
    END IF;
END //
DELIMITER ;

-- 12. Cambiar el estado de un camper a “Graduado” al finalizar todos los módulos.
DELIMITER //
CREATE PROCEDURE cambiar_estado_a_graduado(
    IN p_doc_camper INT
)
BEGIN
    DECLARE v_total_modulos INT;
    DECLARE v_modulos_aprobados INT;

    -- Contar el total de módulos y los aprobados
    SELECT COUNT(*), SUM(CASE WHEN nota_final >= 60 THEN 1 ELSE 0 END)
    INTO v_total_modulos, v_modulos_aprobados
    FROM evaluacion
    WHERE doc_camper = p_doc_camper;

    -- Si todos los módulos están aprobados, cambiar el estado a "Graduado"
    IF v_total_modulos = v_modulos_aprobados THEN
        UPDATE camper 
        SET estado = 'Graduado' 
        WHERE doc = p_doc_camper;
    END IF;
END //
DELIMITER ;

-- 13. Consultar y exportar todos los datos de rendimiento de un camper.
DELIMITER //
CREATE PROCEDURE exportar_datos_rendimiento_camper(
    IN p_doc_camper INT
)
BEGIN
    SELECT c.nombres, c.apellidos, e.id_modulo, e.nota_teorica, e.nota_practica, e.nota_quiz, e.nota_final
    FROM camper c
    JOIN evaluacion e ON c.doc = e.doc_camper
    WHERE c.doc = p_doc_camper;
END //
DELIMITER ;

-- 14. Registrar la asistencia a clases por área y horario.
DELIMITER //
CREATE PROCEDURE registrar_asistencia(
    IN p_doc_camper INT, 
    IN p_id_area INT, 
    IN p_fecha DATE, 
    IN p_horario TIME
)
BEGIN
    INSERT INTO asistencia (doc_camper, id_area, fecha, horario)
    VALUES (p_doc_camper, p_id_area, p_fecha, p_horario);
END //
DELIMITER ;

-- 15. Generar reporte mensual de notas por ruta.
DELIMITER //
CREATE PROCEDURE reporte_mensual_notas_por_ruta(
    IN p_mes INT, 
    IN p_ano INT
)
BEGIN
    SELECT r.nombre AS ruta, m.nombre AS modulo, AVG(e.nota_final) AS promedio_notas
    FROM rutaAprendizaje r
    JOIN moduloAprendizaje m ON r.id = m.id_ruta
    JOIN evaluacion e ON m.id = e.id_modulo
    WHERE MONTH(e.fecha) = p_mes AND YEAR(e.fecha) = p_ano
    GROUP BY r.id, m.id;
END //
DELIMITER ;

-- 16. Validar y registrar la asignación de un salón a una ruta sin exceder la capacidad.
DELIMITER //
CREATE PROCEDURE asignar_salon_a_ruta(
    IN p_id_ruta INT, 
    IN p_id_area INT
)
BEGIN
    DECLARE v_capacidad_max INT;
    DECLARE v_num_camper INT;

    -- Obtener la capacidad máxima del área
    SELECT capacidad_maxima INTO v_capacidad_max
    FROM areaEntrenamiento
    WHERE id = p_id_area;

    -- Contar el número de campers asignados
    SELECT COUNT(*) INTO v_num_camper
    FROM camperRuta
    WHERE id_ruta = p_id_ruta AND id_area = p_id_area;

    -- Verificar si no se excede la capacidad
    IF v_num_camper < v_capacidad_max THEN
        -- Asignar el salón a la ruta
        UPDATE rutaAprendizaje 
        SET id_area = p_id_area
        WHERE id = p_id_ruta;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Capacidad del salón excedida.';
    END IF;
END //
DELIMITER ;

-- 17. Registrar cambio de horario de un trainer.
DELIMITER //
CREATE PROCEDURE cambiar_horario_trainer(
    IN p_id_trainer INT, 
    IN p_nuevo_horario TIME
)
BEGIN
    UPDATE rutaTrainer 
    SET horario = p_nuevo_horario 
    WHERE id_trainer = p_id_trainer;
END //
DELIMITER ;

-- 18. Eliminar la inscripción de un camper a una ruta (en caso de retiro).
DELIMITER //
CREATE PROCEDURE eliminar_inscripcion_camper(
    IN p_doc_camper INT, 
    IN p_id_ruta INT
)
BEGIN
    DELETE FROM camperRuta 
    WHERE doc_camper = p_doc_camper AND id_ruta = p_id_ruta;
END //
DELIMITER ;

-- 19. Recalcular el estado de todos los campers según su rendimiento acumulado.
DELIMITER //
CREATE PROCEDURE recalcular_estado_camper()
BEGIN
    DECLARE v_doc_camper INT;
    DECLARE v_nota_final DECIMAL(5,2);
    DECLARE v_estado VARCHAR(50);

    DECLARE camper_cursor CURSOR FOR 
    SELECT doc FROM camper;

    OPEN camper_cursor;

    read_loop: LOOP
        FETCH camper_cursor INTO v_doc_camper;

        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Obtener la nota final promedio
        SELECT AVG(nota_final) INTO v_nota_final
        FROM evaluacion 
        WHERE doc_camper = v_doc_camper;

        -- Determinar estado basado en la nota
        IF v_nota_final >= 60 THEN
            SET v_estado = 'Aprobado';
        ELSE
            SET v_estado = 'Reprobado';
        END IF;

        -- Actualizar el estado del camper
        UPDATE camper
        SET estado = v_estado
        WHERE doc = v_doc_camper;

    END LOOP;

    CLOSE camper_cursor;
END //
DELIMITER ;

-- 20. Asignar horarios automáticamente a trainers disponibles según sus áreas.
DELIMITER //
CREATE PROCEDURE asignar_horarios_trainer()
BEGIN
    DECLARE v_id_trainer INT;
    DECLARE v_id_area INT;
    DECLARE v_horario TIME;

    -- Buscar trainers disponibles
    DECLARE trainer_cursor CURSOR FOR 
    SELECT id_trainer, id_area FROM rutaTrainer WHERE horario IS NULL;

    OPEN trainer_cursor;

    read_loop: LOOP
        FETCH trainer_cursor INTO v_id_trainer, v_id_area;

        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Asignar horario automáticamente
        SET v_horario = '09:00:00';  -- Ejemplo de asignación automática

        UPDATE rutaTrainer
        SET horario = v_horario
        WHERE id_trainer = v_id_trainer AND id_area = v_id_area;
    END LOOP;

    CLOSE trainer_cursor;
END //
DELIMITER ;
