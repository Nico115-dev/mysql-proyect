-- 1. Registrar un nuevo camper con toda su información personal y estado inicial.
DELIMITER $$

CREATE PROCEDURE registrarNuevoCamper(
    IN p_documento VARCHAR(11),
    IN p_nombres VARCHAR(45),
    IN p_apellidos VARCHAR(45),
    IN p_fecha_nacimiento DATE,
    IN p_email VARCHAR(100),
    IN p_id_estado INT,
    IN p_id_nivel_riesgo INT,
    IN p_fecha_registro DATE,
    IN p_id_sede INT
)
BEGIN
    -- Insertar los datos del nuevo camper
    INSERT INTO camper (documento, nombres, apellidos, fecha_nacimiento, email, id_estado, id_nivel_riesgo, fecha_registro, id_sede)
    VALUES (p_documento, p_nombres, p_apellidos, p_fecha_nacimiento, p_email, p_id_estado, p_id_nivel_riesgo, p_fecha_registro, p_id_sede);
END$$

DELIMITER ;

-- 2. Actualizar el estado de un camper luego de completar el proceso de ingreso.
DELIMITER $$

CREATE PROCEDURE actualizarEstadoCamper(
    IN p_documento VARCHAR(11),
    IN p_id_estado_nuevo INT,
    IN p_motivo TEXT
)
BEGIN
    DECLARE v_id_estado_actual INT;

    -- Obtener el estado actual del camper
    SELECT id_estado INTO v_id_estado_actual
    FROM camper
    WHERE documento = p_documento;

    -- Actualizar el estado del camper
    UPDATE camper
    SET id_estado = p_id_estado_nuevo
    WHERE documento = p_documento;

    -- Registrar el cambio en la tabla historicoEstadoCamper
    INSERT INTO historicoEstadoCamper (doc_camper, id_estado_anterior, id_estado_nuevo, motivo)
    VALUES (p_documento, v_id_estado_actual, p_id_estado_nuevo, p_motivo);
END$$

DELIMITER ;

-- 3. Procesar la inscripción de un camper a una ruta específica.
DELIMITER $$

CREATE PROCEDURE procesarInscripcionCamper(
    IN p_documento VARCHAR(11),
    IN p_id_ruta INT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin_estimada DATE
)
BEGIN
    DECLARE v_estado_actual VARCHAR(20);

    -- Verificar si el camper ya está inscrito en la ruta
    SELECT estado INTO v_estado_actual
    FROM inscripciones
    WHERE doc_camper = p_documento
    AND id_ruta = p_id_ruta
    AND estado IN ('Pendiente', 'Aprobada', 'Completada');

    IF v_estado_actual IS NULL THEN
        -- Si no está inscrito, realizar la inscripción
        INSERT INTO inscripciones (doc_camper, id_ruta, fecha_inscripcion, fecha_inicio, fecha_fin_estimada, estado)
        VALUES (p_documento, p_id_ruta, CURRENT_DATE, p_fecha_inicio, p_fecha_fin_estimada, 'Pendiente');
    ELSE
        -- Si ya está inscrito, actualizar la fecha de inscripción y el estado si es necesario
        UPDATE inscripciones
        SET fecha_inicio = p_fecha_inicio,
            fecha_fin_estimada = p_fecha_fin_estimada,
            estado = 'Pendiente'
        WHERE doc_camper = p_documento
        AND id_ruta = p_id_ruta;
    END IF;
END$$

DELIMITER ;

-- 4. Registrar una evaluación completa (teórica, práctica y quizzes) para un camper.
DELIMITER $$

CREATE PROCEDURE registrarEvaluacionCamper(
    IN p_doc_camper VARCHAR(11),
    IN p_id_modulo INT,
    IN p_id_tipo_evaluacion_teorica INT,
    IN p_nota_teorica DECIMAL(5,2),
    IN p_id_tipo_evaluacion_practica INT,
    IN p_nota_practica DECIMAL(5,2),
    IN p_id_tipo_evaluacion_quizzes INT,
    IN p_nota_quizzes DECIMAL(5,2)
)
BEGIN
    DECLARE v_nota_final DECIMAL(5,2);
    DECLARE v_aprobado BOOLEAN;

    -- Calcular la nota final como un promedio ponderado (ajustar los porcentajes según lo que desees)
    SET v_nota_final = (p_nota_teorica * 0.40) + (p_nota_practica * 0.40) + (p_nota_quizzes * 0.20);

    -- Determinar si el camper aprueba o no (nota final >= 60)
    SET v_aprobado = IF(v_nota_final >= 60, TRUE, FALSE);

    -- Insertar la evaluación en la tabla skillsNotas
    INSERT INTO skillsNotas (doc_camper, id_modulo, id_tipo_evaluacion, nota, fecha_evaluacion)
    VALUES (p_doc_camper, p_id_modulo, p_id_tipo_evaluacion_teorica, p_nota_teorica, CURRENT_DATE);

    INSERT INTO skillsNotas (doc_camper, id_modulo, id_tipo_evaluacion, nota, fecha_evaluacion)
    VALUES (p_doc_camper, p_id_modulo, p_id_tipo_evaluacion_practica, p_nota_practica, CURRENT_DATE);

    INSERT INTO skillsNotas (doc_camper, id_modulo, id_tipo_evaluacion, nota, fecha_evaluacion)
    VALUES (p_doc_camper, p_id_modulo, p_id_tipo_evaluacion_quizzes, p_nota_quizzes, CURRENT_DATE);

    -- Registrar la nota final en la tabla notaFinal
    INSERT INTO notaFinal (doc_camper, id_modulo, nota_teorica, nota_practica, nota_quizzes, nota_final, aprobado)
    VALUES (p_doc_camper, p_id_modulo, p_nota_teorica, p_nota_practica, p_nota_quizzes, v_nota_final, v_aprobado);

END$$

DELIMITER ;

-- 5. Calcular y registrar automáticamente la nota final de un módulo.
DELIMITER $$

CREATE PROCEDURE calcularRegistrarNotaFinal(
    IN p_doc_camper VARCHAR(11),
    IN p_id_modulo INT
)
BEGIN
    DECLARE v_nota_teorica DECIMAL(5,2);
    DECLARE v_nota_practica DECIMAL(5,2);
    DECLARE v_nota_quizzes DECIMAL(5,2);
    DECLARE v_nota_final DECIMAL(5,2);
    DECLARE v_aprobado BOOLEAN;

    -- Obtener las notas teórica, práctica y quizzes para el camper y el módulo especificado
    SELECT nota 
    INTO v_nota_teorica
    FROM skillsNotas
    WHERE doc_camper = p_doc_camper AND id_modulo = p_id_modulo AND id_tipo_evaluacion = 1
    LIMIT 1;

    SELECT nota 
    INTO v_nota_practica
    FROM skillsNotas
    WHERE doc_camper = p_doc_camper AND id_modulo = p_id_modulo AND id_tipo_evaluacion = 2
    LIMIT 1;

    SELECT nota 
    INTO v_nota_quizzes
    FROM skillsNotas
    WHERE doc_camper = p_doc_camper AND id_modulo = p_id_modulo AND id_tipo_evaluacion = 3
    LIMIT 1;

    -- Calcular la nota final como un promedio ponderado (ajustar los porcentajes según lo que desees)
    SET v_nota_final = (v_nota_teorica * 0.40) + (v_nota_practica * 0.40) + (v_nota_quizzes * 0.20);

    -- Determinar si el camper aprueba o no (nota final >= 60)
    SET v_aprobado = IF(v_nota_final >= 60, TRUE, FALSE);

    -- Registrar la nota final en la tabla notaFinal (si no existe ya una entrada para el camper y el módulo)
    INSERT INTO notaFinal (doc_camper, id_modulo, nota_teorica, nota_practica, nota_quizzes, nota_final, aprobado)
    SELECT p_doc_camper, p_id_modulo, v_nota_teorica, v_nota_practica, v_nota_quizzes, v_nota_final, v_aprobado
    WHERE NOT EXISTS (
        SELECT 1
        FROM notaFinal
        WHERE doc_camper = p_doc_camper AND id_modulo = p_id_modulo
    );
    
END$$

DELIMITER ;

-- 6. Asignar campers aprobados a una ruta de acuerdo con la disponibilidad del área.
DELIMITER $$

CREATE PROCEDURE asignarCampersAprobadosRuta(
    IN p_id_ruta INT
)
BEGIN
    DECLARE v_doc_camper VARCHAR(11);
    DECLARE v_id_area INT;
    DECLARE v_capacidad_actual INT;
    DECLARE v_capacidad_total INT;
    DECLARE v_estado_camper ENUM('Pendiente', 'Aprobada', 'Rechazada', 'Cancelada', 'Completada');
    
    -- Cursor para obtener todos los campers aprobados para la ruta específica
    DECLARE camper_cursor CURSOR FOR
        SELECT c.documento
        FROM camper c
        JOIN inscripciones i ON c.documento = i.doc_camper
        JOIN notaFinal nf ON c.documento = nf.doc_camper
        WHERE i.id_ruta = p_id_ruta
        AND nf.nota_final >= 60
        AND i.estado = 'Aprobada';
    
    -- Abrir el cursor
    OPEN camper_cursor;

    -- Loop para asignar a cada camper aprobado
    read_loop: LOOP
        FETCH camper_cursor INTO v_doc_camper;
        
        -- Si no hay más campers, salir del loop
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Obtener el área disponible en la ruta
        SELECT a.id, a.capacidad, COUNT(ac.id) AS capacidad_actual
        INTO v_id_area, v_capacidad_total, v_capacidad_actual
        FROM areaSalon a
        JOIN asignacionArea ac ON a.id = ac.id_area
        WHERE ac.fecha_fin IS NULL -- Área disponible
        GROUP BY a.id
        HAVING v_capacidad_actual < v_capacidad_total
        LIMIT 1; -- Seleccionamos solo una área disponible

        -- Si se encontró un área disponible
        IF v_id_area IS NOT NULL THEN
            -- Asignar al camper a la ruta y área
            INSERT INTO asignacionCamper (doc_camper, id_area, id_horario, fecha_inicio)
            VALUES (v_doc_camper, v_id_area, (SELECT id_horario FROM asignacionArea WHERE id_area = v_id_area LIMIT 1), NOW());
        END IF;

    END LOOP;

    -- Cerrar el cursor
    CLOSE camper_cursor;
    
END$$

DELIMITER ;

-- 7. Asignar un trainer a una ruta y área específica, validando el horario.
DELIMITER $$

CREATE PROCEDURE asignarTrainerRutaArea(
    IN p_id_trainer INT,
    IN p_id_ruta INT,
    IN p_id_area INT,
    IN p_id_horario INT
)
BEGIN
    DECLARE v_conflicto_horario INT;

    -- Verificar si el trainer ya está asignado en el mismo horario
    SELECT COUNT(*)
    INTO v_conflicto_horario
    FROM horarioTrainer ht
    WHERE ht.id_trainer = p_id_trainer
    AND ht.id_horario = p_id_horario
    AND ht.id_area = p_id_area
    AND ht.dia_semana = (SELECT dia_semana FROM horarios WHERE id = p_id_horario LIMIT 1);
    
    -- Si hay conflicto de horario, no permitir la asignación
    IF v_conflicto_horario > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El trainer ya está asignado a otro horario en esta área.';
    ELSE
        -- Si no hay conflicto, proceder con la asignación
        INSERT INTO horarioTrainer (id_trainer, id_ruta, id_area, id_horario, dia_semana)
        VALUES (p_id_trainer, p_id_ruta, p_id_area, p_id_horario, (SELECT dia_semana FROM horarios WHERE id = p_id_horario LIMIT 1));
    END IF;

END$$

DELIMITER ;

-- 8. Registrar una nueva ruta con sus módulos y SGDB asociados.
DELIMITER $$

CREATE PROCEDURE registrarRutaConModulosSGDB(
    IN p_nombre_ruta VARCHAR(100),
    IN p_descripcion_ruta TEXT,
    IN p_duracion_meses INT,
    IN p_fecha_creacion DATE,
    IN p_modulos_ids TEXT,  -- Lista de IDs de módulos separados por coma
    IN p_sgbd_ids TEXT      -- Lista de IDs de SGBD separados por coma
)
BEGIN
    DECLARE v_id_ruta INT;
    DECLARE v_id_modulo INT;
    DECLARE v_id_sgbd INT;
    DECLARE v_idx INT DEFAULT 1;
    DECLARE v_total_modulos INT;
    DECLARE v_total_sgbd INT;

    -- Iniciar la transacción
    START TRANSACTION;

    -- Insertar la nueva ruta
    INSERT INTO rutaAprendizaje (nombre, descripcion, duracion_meses, fecha_creacion)
    VALUES (p_nombre_ruta, p_descripcion_ruta, p_duracion_meses, p_fecha_creacion);
    
    -- Obtener el ID de la ruta recién insertada
    SET v_id_ruta = LAST_INSERT_ID();

    -- Insertar los módulos asociados a la ruta
    SET v_total_modulos = LENGTH(p_modulos_ids) - LENGTH(REPLACE(p_modulos_ids, ',', '')) + 1;
    
    WHILE v_idx <= v_total_modulos DO
        SET v_id_modulo = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(p_modulos_ids, ',', v_idx), ',', -1) AS UNSIGNED);

        -- Insertar el módulo en la relación de ruta-modulo
        INSERT INTO rutaModulo (id_ruta, id_modulo, orden)
        VALUES (v_id_ruta, v_id_modulo, v_idx);

        SET v_idx = v_idx + 1;
    END WHILE;

    -- Insertar los SGBD asociados a la ruta
    SET v_idx = 1;
    SET v_total_sgbd = LENGTH(p_sgbd_ids) - LENGTH(REPLACE(p_sgbd_ids, ',', '')) + 1;
    
    WHILE v_idx <= v_total_sgbd DO
        SET v_id_sgbd = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(p_sgbd_ids, ',', v_idx), ',', -1) AS UNSIGNED);

        -- Insertar el SGBD en la relación de ruta-SGBD
        INSERT INTO bdAsociados (id_ruta, id_sgbd)
        VALUES (v_id_ruta, v_id_sgbd);

        SET v_idx = v_idx + 1;
    END WHILE;

    -- Si todo se ha ejecutado correctamente, confirmar la transacción
    COMMIT;

END$$

DELIMITER ;

-- 9. Registrar una nueva área de entrenamiento con su capacidad y horarios.
DELIMITER $$

CREATE PROCEDURE registrarAreaEntrenamiento(
    IN p_nombre_area VARCHAR(50),
    IN p_capacidad INT,
    IN p_descripcion TEXT,
    IN p_id_sede INT,
    IN p_estado ENUM('Activa', 'Inactiva', 'En mantenimiento'),
    IN p_horarios_ids TEXT -- Lista de IDs de horarios asociados a la nueva área, separados por coma
)
BEGIN
    DECLARE v_id_area INT;
    DECLARE v_id_horario INT;
    DECLARE v_idx INT DEFAULT 1;
    DECLARE v_total_horarios INT;

    -- Iniciar la transacción
    START TRANSACTION;

    -- Insertar la nueva área de entrenamiento
    INSERT INTO areaSalon (nombre, capacidad, descripcion, id_sede, estado)
    VALUES (p_nombre_area, p_capacidad, p_descripcion, p_id_sede, p_estado);
    
    -- Obtener el ID de la nueva área insertada
    SET v_id_area = LAST_INSERT_ID();

    -- Insertar los horarios asociados a la nueva área
    SET v_total_horarios = LENGTH(p_horarios_ids) - LENGTH(REPLACE(p_horarios_ids, ',', '')) + 1;

    WHILE v_idx <= v_total_horarios DO
        SET v_id_horario = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(p_horarios_ids, ',', v_idx), ',', -1) AS UNSIGNED);

        -- Insertar la asignación del horario al área
        INSERT INTO asignacionArea (id_area, id_horario, fecha_inicio)
        VALUES (v_id_area, v_id_horario, CURDATE());

        SET v_idx = v_idx + 1;
    END WHILE;

    -- Si todo se ha ejecutado correctamente, confirmar la transacción
    COMMIT;

END$$

DELIMITER ;

-- 11. Reasignar a un camper a otra ruta en caso de bajo rendimiento.
DELIMITER $$

CREATE PROCEDURE reasignarCamperRuta(
    IN p_doc_camper VARCHAR(11),
    IN p_nueva_ruta INT
)
BEGIN
    DECLARE v_nota_final DECIMAL(5,2);
    DECLARE v_estado_ruta ENUM('Pendiente', 'Aprobada', 'Rechazada', 'Cancelada', 'Completada');
    DECLARE v_id_ruta_actual INT;
    
    -- Obtener la nota final del camper en su ruta actual
    SELECT nota_final INTO v_nota_final
    FROM notaFinal
    WHERE doc_camper = p_doc_camper
    AND aprobado = TRUE;
    
    -- Si la nota final es baja (menos del 60%), reasignar
    IF v_nota_final < 60 THEN
        
        -- Obtener la ruta actual del camper
        SELECT id_ruta INTO v_id_ruta_actual
        FROM inscripciones
        WHERE doc_camper = p_doc_camper
        AND estado IN ('Pendiente', 'Aprobada') -- Considerar rutas activas
        
        -- Actualizar la inscripción del camper para la nueva ruta
        UPDATE inscripciones
        SET id_ruta = p_nueva_ruta, fecha_inscripcion = CURDATE(), estado = 'Pendiente'
        WHERE doc_camper = p_doc_camper
        AND id_ruta = v_id_ruta_actual;

        -- Registrar el cambio de ruta en un historial o log de cambios
        INSERT INTO cambiosRuta (id_ruta, descripcion)
        VALUES (v_id_ruta_actual, CONCAT('Reasignado a la ruta ', p_nueva_ruta, ' por bajo rendimiento'));
        
    ELSE
        -- Si la nota es suficiente, mostrar mensaje (opcional)
        SELECT 'El rendimiento es suficiente, no es necesario reasignar.' AS mensaje;
    END IF;

END$$

DELIMITER ;

-- 12. Cambiar el estado de un camper a “Graduado” al finalizar todos los módulos.
DELIMITER $$

CREATE PROCEDURE graduarCamper(
    IN p_doc_camper VARCHAR(11)
)
BEGIN
    DECLARE v_ruta INT;
    DECLARE v_estado_actual INT;
    DECLARE v_estado_graduado INT;
    DECLARE v_modulos_completados INT;
    DECLARE v_total_modulos INT;

    -- Obtener la ruta en la que está inscrito el camper
    SELECT id_ruta INTO v_ruta
    FROM inscripciones
    WHERE doc_camper = p_doc_camper
    AND estado = 'Completada';  -- Asegurarse de que el camper haya finalizado una ruta

    -- Verificar si se encontró la ruta
    IF v_ruta IS NOT NULL THEN
        -- Obtener el estado "Graduado"
        SELECT id INTO v_estado_graduado
        FROM estadoActual
        WHERE nombre = 'Graduado';

        -- Contar la cantidad de módulos completados por el camper (estado 'Aprobado' en cada módulo)
        SELECT COUNT(*) INTO v_modulos_completados
        FROM campersModulosAsignados
        WHERE doc_camper = p_doc_camper
        AND estado = 'Aprobado';

        -- Contar el total de módulos asignados a la ruta
        SELECT COUNT(*) INTO v_total_modulos
        FROM rutaModulo
        WHERE id_ruta = v_ruta;

        -- Si el número de módulos completados es igual al total de módulos, se puede graduar al camper
        IF v_modulos_completados = v_total_modulos THEN
            -- Actualizar el estado del camper a "Graduado"
            UPDATE camper
            SET id_estado = v_estado_graduado
            WHERE documento = p_doc_camper;

            -- Registrar en el historial de cambios de estado del camper
            INSERT INTO historicoEstadoCamper (doc_camper, id_estado_anterior, id_estado_nuevo, motivo)
            VALUES (p_doc_camper, (SELECT id_estado FROM camper WHERE documento = p_doc_camper), v_estado_graduado, 'Graduado por completar todos los módulos');

            -- Mostrar mensaje de éxito
            SELECT 'Camper graduado exitosamente' AS mensaje;
        ELSE
            -- Si no ha completado todos los módulos, mostrar mensaje
            SELECT 'El camper no ha completado todos los módulos. No se puede graduar.' AS mensaje;
        END IF;
    ELSE
        -- Si no se encuentra la ruta o el estado de inscripción no es "Completada", mostrar mensaje
        SELECT 'No se encontró la ruta completada para el camper.' AS mensaje;
    END IF;
END$$

DELIMITER ;

-- 13. Consultar y exportar todos los datos de rendimiento de un camper.
DELIMITER $$

CREATE PROCEDURE consultarRendimientoCamper(
    IN p_doc_camper VARCHAR(11)
)
BEGIN
    -- Consultar información general del camper
    SELECT c.documento, c.nombres, c.apellidos, c.fecha_nacimiento, e.nombre AS estado,
           r.nombre AS ruta, r.descripcion AS ruta_descripcion
    FROM camper c
    JOIN estadoActual e ON c.id_estado = e.id
    JOIN inscripciones i ON c.documento = i.doc_camper
    JOIN rutaAprendizaje r ON i.id_ruta = r.id
    WHERE c.documento = p_doc_camper;

    -- Consultar los módulos asignados al camper
    SELECT m.nombre AS modulo, m.tipo, cm.estado AS modulo_estado,
           sn.nota_teorica, sn.nota_practica, sn.nota_quizzes, sn.nota_final
    FROM campersModulosAsignados cm
    JOIN moduloAprendizaje m ON cm.id_modulo = m.id
    LEFT JOIN notaFinal sn ON cm.id_modulo = sn.id_modulo AND cm.doc_camper = sn.doc_camper
    WHERE cm.doc_camper = p_doc_camper;

    -- Consultar las evaluaciones realizadas por el camper
    SELECT te.nombre AS tipo_evaluacion, sn.nota, sn.fecha_evaluacion, sn.observaciones
    FROM skillsNotas sn
    JOIN tipoEvaluacion te ON sn.id_tipo_evaluacion = te.id
    WHERE sn.doc_camper = p_doc_camper;
    
END$$

DELIMITER ;

-- 14. Registrar la asistencia a clases por área y horario.
DELIMITER $$

CREATE PROCEDURE registrarAsistencia(
    IN p_doc_camper VARCHAR(11),
    IN p_id_area INT,
    IN p_id_horario INT,
    IN p_fecha DATE,
    IN p_asistio BOOLEAN
)
BEGIN
    -- Verificar si el camper está asignado a la combinación de área y horario especificados
    DECLARE v_existente INT;
    
    SELECT COUNT(*) INTO v_existente
    FROM asignacionCamper
    WHERE doc_camper = p_doc_camper AND id_area = p_id_area AND id_horario = p_id_horario;
    
    -- Si la asignación existe, registrar la asistencia
    IF v_existente > 0 THEN
        INSERT INTO asistencia (
            doc_camper, id_area, id_horario, fecha_asistencia, asistio
        )
        VALUES (p_doc_camper, p_id_area, p_id_horario, p_fecha, p_asistio);
    ELSE
        -- Si no está asignado a la clase, generar un error
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El camper no está asignado a este área y horario.';
    END IF;
END$$

DELIMITER ;

-- 15. Generar reporte mensual de notas por ruta.
DELIMITER $$

CREATE PROCEDURE generarReporteNotasPorRuta(
    IN p_mes INT,               -- Mes en formato numérico (1-12)
    IN p_anio INT               -- Año en formato numérico (por ejemplo, 2025)
)
BEGIN
    -- Generar el reporte de notas por ruta y módulo, agrupado por ruta, módulo y camper
    SELECT 
        ra.nombre AS ruta,
        ma.nombre AS modulo,
        CONCAT(c.nombres, ' ', c.apellidos) AS camper,
        nf.nota_teorica,
        nf.nota_practica,
        nf.nota_quizzes,
        nf.nota_final,
        -- Calcular el promedio de las notas finales de todos los campers en el módulo
        (SELECT AVG(nf2.nota_final)
         FROM notaFinal nf2
         WHERE nf2.id_modulo = ma.id AND MONTH(nf2.fecha_calculo) = p_mes AND YEAR(nf2.fecha_calculo) = p_anio) AS promedio_modulo
    FROM 
        rutaAprendizaje ra
    JOIN 
        rutaModulo rm ON ra.id = rm.id_ruta
    JOIN 
        moduloAprendizaje ma ON rm.id_modulo = ma.id
    JOIN 
        notaFinal nf ON ma.id = nf.id_modulo
    JOIN 
        camper c ON nf.doc_camper = c.documento
    WHERE 
        MONTH(nf.fecha_calculo) = p_mes AND YEAR(nf.fecha_calculo) = p_anio
    ORDER BY 
        ra.nombre, ma.nombre, camper;
END$$

DELIMITER ;

-- 16. Validar y registrar la asignación de un salón a una ruta sin exceder la capacidad.
DELIMITER $$

CREATE PROCEDURE asignarSalonARuta(
    IN p_id_ruta INT,            -- ID de la ruta a asignar
    IN p_id_area INT,            -- ID del área de salón a asignar
    IN p_id_horario INT,         -- ID del horario para la asignación
    IN p_num_camper INT          -- Número de campers asignados a la ruta
)
BEGIN
    DECLARE capacidad_area INT;

    -- Obtener la capacidad del área de salón
    SELECT capacidad INTO capacidad_area
    FROM areaSalon
    WHERE id = p_id_area;

    -- Verificar si la capacidad del área es suficiente para el número de campers
    IF p_num_camper > capacidad_area THEN
        -- Si el número de campers excede la capacidad, generar un error
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay suficiente capacidad en el salón para los campers asignados.';
    ELSE
        -- Si la capacidad es suficiente, registrar la asignación
        INSERT INTO asignacionArea (id_area, id_horario, fecha_inicio)
        VALUES (p_id_area, p_id_horario, CURRENT_DATE);
        
        -- Notificar éxito en la asignación
        SELECT 'Asignación de salón realizada exitosamente.' AS mensaje;
    END IF;
END$$

DELIMITER ;

-- 17. Registrar cambio de horario de un trainer.
DELIMITER $$

CREATE PROCEDURE cambiarHorarioTrainer(
    IN p_id_trainer INT,        -- ID del trainer cuyo horario se va a cambiar
    IN p_id_area INT,           -- ID del área de trabajo donde se va a cambiar el horario
    IN p_id_nuevo_horario INT,  -- ID del nuevo horario a asignar
    IN p_dia_semana ENUM('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado')  -- Día de la semana
)
BEGIN
    DECLARE horario_conflicto INT;

    -- Verificar si el nuevo horario ya está ocupado por otro trainer en el mismo área y día
    SELECT COUNT(*) INTO horario_conflicto
    FROM horarioTrainer
    WHERE id_area = p_id_area
    AND id_horario = p_id_nuevo_horario
    AND dia_semana = p_dia_semana
    AND id_trainer != p_id_trainer; -- Excluir al trainer actual

    -- Si hay conflicto de horario, generar error
    IF horario_conflicto > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nuevo horario está ocupado por otro trainer en el área seleccionada.';
    ELSE
        -- Si no hay conflicto, actualizar el horario del trainer
        UPDATE horarioTrainer
        SET id_horario = p_id_nuevo_horario
        WHERE id_trainer = p_id_trainer
        AND id_area = p_id_area
        AND dia_semana = p_dia_semana;

        -- Notificar éxito en el cambio de horario
        SELECT 'Horario de trainer actualizado exitosamente.' AS mensaje;
    END IF;
END$$

DELIMITER ;

-- 18. Eliminar la inscripción de un camper a una ruta (en caso de retiro).
DELIMITER $$

CREATE PROCEDURE eliminarInscripcionCamper(
    IN p_doc_camper VARCHAR(11),  -- Documento del camper a eliminar la inscripción
    IN p_id_ruta INT              -- ID de la ruta a la que el camper está inscrito
)
BEGIN
    DECLARE inscripcion_existente INT;

    -- Verificar si la inscripción existe para el camper en la ruta indicada
    SELECT COUNT(*) INTO inscripcion_existente
    FROM inscripciones
    WHERE doc_camper = p_doc_camper
    AND id_ruta = p_id_ruta;

    -- Si no existe la inscripción, generar un error
    IF inscripcion_existente = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El camper no está inscrito en la ruta seleccionada.';
    ELSE
        -- Si la inscripción existe, eliminarla
        DELETE FROM inscripciones
        WHERE doc_camper = p_doc_camper
        AND id_ruta = p_id_ruta;

        -- Notificar éxito en la eliminación
        SELECT 'Inscripción eliminada exitosamente.' AS mensaje;
    END IF;
END$$

DELIMITER ;

-- 19. Recalcular el estado de todos los campers según su rendimiento acumulado.
DELIMITER $$

CREATE PROCEDURE recalcularEstadoCamper()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE camper_doc VARCHAR(11);
    DECLARE promedio_notas DECIMAL(5,2);
    DECLARE id_estado INT;

    -- Cursor para recorrer todos los campers
    DECLARE camper_cursor CURSOR FOR 
        SELECT DISTINCT doc_camper 
        FROM notaFinal
        WHERE nota_final IS NOT NULL;

    -- Handlers para el cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Abrir el cursor
    OPEN camper_cursor;

    -- Recorrer todos los campers
    read_loop: LOOP
        FETCH camper_cursor INTO camper_doc;
        
        -- Si ya no hay más campers, salir del loop
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Calcular el promedio de las notas finales de los módulos del camper
        SELECT AVG(nota_final) INTO promedio_notas
        FROM notaFinal
        WHERE doc_camper = camper_doc;

        -- Determinar el estado del camper según el promedio
        IF promedio_notas >= 60 THEN
            SET id_estado = (SELECT id FROM estadoActual WHERE nombre = 'Aprobado');
        ELSE
            SET id_estado = (SELECT id FROM estadoActual WHERE nombre = 'Reprobado');
        END IF;

        -- Actualizar el estado del camper
        UPDATE camper 
        SET id_estado = id_estado 
        WHERE documento = camper_doc;
    END LOOP;

    -- Cerrar el cursor
    CLOSE camper_cursor;
    
    -- Mensaje de éxito
    SELECT 'Recalculo de estado de todos los campers completado.' AS mensaje;
END$$

DELIMITER ;

-- 20. Asignar horarios automáticamente a trainers disponibles según sus áreas.
DELIMITER $$

CREATE PROCEDURE asignarHorariosATrainers()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE trainer_id INT;
    DECLARE area_id INT;
    DECLARE horario_id INT;
    DECLARE dia_semana ENUM('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado');

    -- Cursor para recorrer todos los trainers disponibles
    DECLARE trainer_cursor CURSOR FOR 
        SELECT id, id_sede 
        FROM trainer 
        WHERE id_sede IS NOT NULL;

    -- Handler para el cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Abrir el cursor
    OPEN trainer_cursor;

    -- Recorrer todos los trainers disponibles
    read_loop: LOOP
        FETCH trainer_cursor INTO trainer_id, area_id;

        -- Si no hay más trainers disponibles, salir del loop
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Buscar un horario disponible para este trainer basado en las áreas asignadas
        SELECT id 
        INTO horario_id
        FROM horarios
        WHERE id NOT IN (SELECT id_horario FROM horarioTrainer WHERE id_trainer = trainer_id)
        LIMIT 1;

        -- Si se encuentra un horario disponible, asignar el horario
        IF horario_id IS NOT NULL THEN
            -- Suponiendo que la asignación se realiza en base a un día de la semana (en este caso, 'Lunes')
            SET dia_semana = 'Lunes';

            -- Insertar la asignación del horario al trainer en el área correspondiente
            INSERT INTO horarioTrainer (id_trainer, id_horario, id_area, dia_semana)
            VALUES (trainer_id, horario_id, area_id, dia_semana);
        END IF;

    END LOOP;

    -- Cerrar el cursor
    CLOSE trainer_cursor;

    -- Mensaje de éxito
    SELECT 'Horarios asignados automáticamente a los trainers disponibles.' AS mensaje;
END$$

DELIMITER ;