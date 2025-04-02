-- 1. Al insertar una evaluación, calcular automáticamente la nota final
DELIMITER $$
CREATE TRIGGER trig_calcular_nota_final_insert
AFTER INSERT ON skillsNotas
FOR EACH ROW
BEGIN
    DECLARE v_nota_teorica DECIMAL(5,2);
    DECLARE v_nota_practica DECIMAL(5,2);
    DECLARE v_nota_quizzes DECIMAL(5,2);
    DECLARE v_nota_final DECIMAL(5,2);
    DECLARE v_aprobado BOOLEAN;
    
    -- Obtener notas por tipo de evaluación
    SELECT 
        COALESCE(AVG(CASE WHEN te.nombre = 'Teórica' THEN sn.nota ELSE NULL END), 0) AS nota_teorica,
        COALESCE(AVG(CASE WHEN te.nombre = 'Práctica' THEN sn.nota ELSE NULL END), 0) AS nota_practica,
        COALESCE(AVG(CASE WHEN te.nombre = 'Quiz' THEN sn.nota ELSE NULL END), 0) AS nota_quizzes
    INTO v_nota_teorica, v_nota_practica, v_nota_quizzes
    FROM skillsNotas sn
    JOIN tipoEvaluacion te ON sn.id_tipo_evaluacion = te.id
    WHERE sn.doc_camper = NEW.doc_camper AND sn.id_modulo = NEW.id_modulo;
    
    -- Calcular nota final (asumiendo ponderaciones: teórica 40%, práctica 50%, quizzes 10%)
    SET v_nota_final = (v_nota_teorica * 0.4) + (v_nota_practica * 0.5) + (v_nota_quizzes * 0.1);
    SET v_aprobado = (v_nota_final >= 60);
    
    -- Actualizar o insertar en la tabla notaFinal
    INSERT INTO notaFinal 
        (doc_camper, id_modulo, nota_teorica, nota_practica, nota_quizzes, nota_final, aprobado)
    VALUES 
        (NEW.doc_camper, NEW.id_modulo, v_nota_teorica, v_nota_practica, v_nota_quizzes, v_nota_final, v_aprobado)
    ON DUPLICATE KEY UPDATE
        nota_teorica = v_nota_teorica,
        nota_practica = v_nota_practica,
        nota_quizzes = v_nota_quizzes,
        nota_final = v_nota_final,
        aprobado = v_aprobado;
END $$
DELIMITER ;

-- 2. Al actualizar la nota final de un módulo, verificar si el camper aprueba o reprueba

DELIMITER $$

CREATE TRIGGER trig_verificar_aprobacion
BEFORE UPDATE ON notaFinal
FOR EACH ROW
BEGIN
    -- Verificar si la nueva nota final es mayor o igual a 60
    IF NEW.nota_final >= 60 THEN
        SET NEW.aprobado = TRUE;
        
        -- Actualizar estado del módulo en la tabla campersModulosAsignados
        UPDATE campersModulosAsignados 
        SET estado = 'Aprobado'
        WHERE doc_camper = NEW.doc_camper 
        AND id_modulo = NEW.id_modulo;
        
    ELSE
        SET NEW.aprobado = FALSE;

        -- Actualizar estado del módulo en la tabla campersModulosAsignados
        UPDATE campersModulosAsignados 
        SET estado = 'Reprobado'
        WHERE doc_camper = NEW.doc_camper 
        AND id_modulo = NEW.id_modulo;
    END IF;
END $$

DELIMITER ;

-- 3. Al insertar una inscripción, cambiar el estado del camper a "Inscrito"
DELIMITER $$
CREATE TRIGGER trig_cambiar_estado_inscrito
AFTER INSERT ON inscripciones
FOR EACH ROW
BEGIN
    DECLARE id_estado_inscrito INT;
    DECLARE id_estado_actual INT;
    
    -- Obtener ID del estado "Inscrito"
    SELECT id INTO id_estado_inscrito FROM estadoActual WHERE nombre = 'Inscrito' LIMIT 1;
    
    -- Obtener estado actual del camper
    SELECT id_estado INTO id_estado_actual FROM camper WHERE documento = NEW.doc_camper;
    
    -- Actualizar el estado del camper
    UPDATE camper SET id_estado = id_estado_inscrito WHERE documento = NEW.doc_camper;
    
    -- Registrar el cambio en el historial
    INSERT INTO historicoEstadoCamper (doc_camper, id_estado_anterior, id_estado_nuevo, motivo)
    VALUES (NEW.doc_camper, id_estado_actual, id_estado_inscrito, 'Inscripción automática a ruta de aprendizaje');
END $$
DELIMITER ;

-- 4. Al actualizar una evaluación, recalcular su promedio inmediatamente

DELIMITER $$

CREATE TRIGGER recalcular_promedio_evaluacion
AFTER UPDATE ON skillsNotas
FOR EACH ROW
BEGIN
    DECLARE promedio DECIMAL(5,2);

    -- Calcular el promedio de todas las evaluaciones de ese camper para ese módulo
    SELECT AVG(nota) INTO promedio
    FROM skillsNotas
    WHERE doc_camper = NEW.doc_camper
    AND id_modulo = NEW.id_modulo;

    -- Actualizar el promedio de la nota final en la tabla notaFinal
    UPDATE notaFinal
    SET nota_final = promedio
    WHERE doc_camper = NEW.doc_camper
    AND id_modulo = NEW.id_modulo;
END$$

DELIMITER ;

-- 5. Al eliminar una inscripción, marcar al camper como "Retirado"
DELIMITER $$

CREATE TRIGGER marcar_camper_retirado
AFTER DELETE ON inscripciones
FOR EACH ROW
BEGIN
    -- Actualizar el estado del camper a "Retirado"
    UPDATE camper
    SET id_estado = (SELECT id FROM estadoActual WHERE nombre = 'Retirado')
    WHERE documento = OLD.doc_camper;
END$$

DELIMITER ;

-- 6. Al insertar un nuevo módulo, registrar automáticamente su SGDB asociado
DELIMITER $$

CREATE TRIGGER registrar_sgbd_asociado
AFTER INSERT ON moduloAprendizaje
FOR EACH ROW
BEGIN
    -- Insertar automáticamente el SGBD asociado para el nuevo módulo
    INSERT INTO moduloSGBD (id_modulo, id_sgbd)
    SELECT NEW.id, id_sgbd
    FROM bdAsociados
    WHERE id_ruta = (SELECT id_ruta FROM rutaModulo WHERE id_modulo = NEW.id LIMIT 1)
    AND es_principal = TRUE;
END$$

DELIMITER ;

-- 7. Al insertar un nuevo trainer, verificar duplicados por identificación
DELIMITER $$

CREATE TRIGGER verificar_duplicado_trainer
BEFORE INSERT ON trainer
FOR EACH ROW
BEGIN
    -- Comprobar si ya existe un trainer con el mismo documento
    IF EXISTS (SELECT 1 FROM trainer WHERE documento = NEW.documento) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un trainer con el mismo número de identificación.';
    END IF;
END$$

DELIMITER ;

-- 8. Al asignar un área, validar que no exceda su capacidad
DELIMITER $$

CREATE TRIGGER validar_capacidad_area
BEFORE INSERT ON asignacionCamper
FOR EACH ROW
BEGIN
    DECLARE cantidad_actual INT;

    -- Obtener la cantidad actual de campers asignados al área
    SELECT COUNT(*) INTO cantidad_actual
    FROM asignacionCamper
    WHERE id_area = NEW.id_area AND fecha_fin IS NULL;

    -- Comprobar si la cantidad actual supera la capacidad del área
    IF cantidad_actual >= (SELECT capacidad FROM areaSalon WHERE id = NEW.id_area) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No hay suficiente capacidad en el área para asignar este camper.';
    END IF;
END$$

DELIMITER ;

-- 9. Al insertar una evaluación con nota < 60, marcar al camper como "Bajo rendimiento"
DELIMITER $$

CREATE TRIGGER marcar_bajo_rendimiento
AFTER INSERT ON skillsNotas
FOR EACH ROW
BEGIN
    -- Verificar si la nota es menor a 60
    IF NEW.nota < 60 THEN
        -- Actualizar el nivel de riesgo del camper a "Bajo rendimiento"
        UPDATE camper
        SET id_nivel_riesgo = (SELECT id FROM nivelRiesgo WHERE nivel = 'BR' LIMIT 1)
        WHERE documento = NEW.doc_camper;
    END IF;
END$$

DELIMITER ;

-- 10. Al cambiar de estado a "Graduado", mover registro a la tabla de egresados
DELIMITER $$

CREATE TRIGGER mover_a_egresados
AFTER UPDATE ON camper
FOR EACH ROW
BEGIN
    -- Verificar si el estado del camper ha cambiado a "Graduado"
    IF NEW.id_estado = (SELECT id FROM estadoActual WHERE nombre = 'Graduado' LIMIT 1) THEN
        -- Insertar el camper en la tabla de egresados
        INSERT INTO egresados (documento, nombres, apellidos, email, fecha_graduacion, id_ruta)
        VALUES (NEW.documento, NEW.nombres, NEW.apellidos, NEW.email, CURDATE(), 
                (SELECT id_ruta FROM inscripciones WHERE doc_camper = NEW.documento AND estado = 'Completada' LIMIT 1));
    END IF;
END$$

DELIMITER ;

-- 11. Al modificar horarios de trainer, verificar solapamiento con otros
DELIMITER $$

CREATE TRIGGER verificar_solapamiento_horario
AFTER UPDATE ON horarioTrainer
FOR EACH ROW
BEGIN
    DECLARE solapamiento INT;

    -- Verificar si el nuevo horario del trainer se solapa con otro trainer en la misma área
    SELECT COUNT(*)
    INTO solapamiento
    FROM horarioTrainer
    WHERE id_area = NEW.id_area
    AND id_trainer != NEW.id_trainer  -- Excluimos el mismo trainer
    AND (
        (NEW.hora_inicio BETWEEN hora_inicio AND hora_fin) OR
        (NEW.hora_fin BETWEEN hora_inicio AND hora_fin) OR
        (hora_inicio BETWEEN NEW.hora_inicio AND NEW.hora_fin) OR
        (hora_fin BETWEEN NEW.hora_inicio AND NEW.hora_fin)
    );

    -- Si existe un solapamiento, cancelamos la actualización
    IF solapamiento > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El horario del trainer se solapa con otro trainer en la misma área';
    END IF;
END$$

DELIMITER ;

-- 12. Al eliminar un trainer, liberar sus horarios y rutas asignadas
DELIMITER $$

CREATE TRIGGER liberar_horarios_y_rutas
BEFORE DELETE ON trainer
FOR EACH ROW
BEGIN
    -- Eliminar horarios asignados al trainer
    DELETE FROM horarioTrainer
    WHERE id_trainer = OLD.id;

    -- Eliminar rutas asignadas al trainer
    DELETE FROM rutaTrainer
    WHERE id_trainer = OLD.id;
END$$

DELIMITER ;

-- 13. Al cambiar la ruta de un camper, actualizar automáticamente sus módulos
DELIMITER $$

CREATE TRIGGER actualizar_modulos_camper
AFTER UPDATE ON inscripciones
FOR EACH ROW
BEGIN
    -- Verificar si la ruta del camper ha cambiado
    IF OLD.id_ruta != NEW.id_ruta THEN
        -- Eliminar módulos asignados al camper para la ruta anterior
        DELETE FROM campersModulosAsignados
        WHERE doc_camper = NEW.doc_camper AND id_modulo IN (
            SELECT id_modulo
            FROM rutaModulo
            WHERE id_ruta = OLD.id_ruta
        );

        -- Asignar nuevos módulos del camper para la nueva ruta
        INSERT INTO campersModulosAsignados (doc_camper, id_modulo, estado)
        SELECT NEW.doc_camper, id_modulo, 'Pendiente'
        FROM rutaModulo
        WHERE id_ruta = NEW.id_ruta;
    END IF;
END$$

DELIMITER ;

-- 14. Al insertar un nuevo camper, verificar si ya existe por número de documento
DELIMITER $$

CREATE TRIGGER verificar_documento_camper
BEFORE INSERT ON camper
FOR EACH ROW
BEGIN
    -- Verificar si el documento ya existe en la tabla
    IF EXISTS (SELECT 1 FROM camper WHERE documento = NEW.documento) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El número de documento del camper ya está registrado.';
    END IF;
END$$

DELIMITER ;

-- 15. Al actualizar la nota final, recalcular el estado del módulo automáticamente
DELIMITER $$

CREATE TRIGGER actualizar_estado_modulo
AFTER UPDATE ON notaFinal
FOR EACH ROW
BEGIN
    -- Verificar si la nota final ha sido actualizada
    IF OLD.nota_final <> NEW.nota_final THEN
        -- Si la nota final es >= 60, se aprueba el módulo
        IF NEW.nota_final >= 60 THEN
            UPDATE campersModulosAsignados
            SET estado = 'Aprobado'
            WHERE doc_camper = NEW.doc_camper AND id_modulo = NEW.id_modulo;
        -- Si la nota final es < 60, se reprueba el módulo
        ELSE
            UPDATE campersModulosAsignados
            SET estado = 'Reprobado'
            WHERE doc_camper = NEW.doc_camper AND id_modulo = NEW.id_modulo;
        END IF;
    END IF;
END$$

DELIMITER ;

-- 16. Al asignar un módulo, verificar que el trainer tenga ese conocimiento
DELIMITER $$

CREATE TRIGGER verificar_skill_trainer
BEFORE INSERT ON rutaTrainer
FOR EACH ROW
BEGIN
    -- Verificar si el trainer tiene el skill necesario para el módulo de la ruta
    DECLARE skill_existente INT;

    -- Obtener el skill necesario para el módulo de la ruta
    SELECT id_skill
    INTO skill_existente
    FROM skillModulo
    WHERE id_modulo = (SELECT id_modulo FROM rutaModulo WHERE id_ruta = NEW.id_ruta LIMIT 1);

    -- Verificar si el trainer tiene ese skill
    IF NOT EXISTS (
        SELECT 1 
        FROM trainerSkills
        WHERE id_trainer = NEW.id_trainer 
        AND id_skill = skill_existente
    ) THEN
        -- Si el trainer no tiene el skill, lanzar un error
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El trainer no tiene el skill necesario para esta ruta.';
    END IF;
END$$

DELIMITER ;

-- 17. Al cambiar el estado de un área a inactiva, liberar campers asignados
DELIMITER $$

CREATE TRIGGER liberar_camper_area_inactiva
BEFORE UPDATE ON areaSalon
FOR EACH ROW
BEGIN
    -- Verificar si el estado del área cambia a 'Inactiva'
    IF NEW.estado = 'Inactiva' AND OLD.estado != 'Inactiva' THEN
        -- Eliminar las asignaciones de campers de esa área
        DELETE FROM asignacionCamper
        WHERE id_area = OLD.id;
    END IF;
END$$

DELIMITER ;

-- 18. Al crear una nueva ruta, clonar la plantilla base de módulos y SGDBs
DELIMITER $$

CREATE TRIGGER clonar_plantilla_modulos_sgbds
AFTER INSERT ON rutaAprendizaje
FOR EACH ROW
BEGIN
    -- Clonar los módulos desde la plantilla de módulos a la nueva ruta
    INSERT INTO rutaModulo (id_ruta, id_modulo, orden)
    SELECT NEW.id, id_modulo, orden
    FROM plantillaModulos
    WHERE id_ruta_base = NEW.id;
    
    -- Clonar los SGBDs asociados a los módulos desde la plantilla
    INSERT INTO moduloSGBD (id_modulo, id_sgbd)
    SELECT id_modulo, id_sgbd
    FROM plantillaModulos
    JOIN moduloSGBD ON plantillaModulos.id_modulo = moduloSGBD.id_modulo
    WHERE id_ruta_base = NEW.id;
END$$

DELIMITER ;

-- 19. Al registrar la nota práctica, verificar que no supere 60% del total
DELIMITER $$

CREATE TRIGGER verificar_nota_practica
BEFORE INSERT ON skillsNotas
FOR EACH ROW
BEGIN
    DECLARE total_nota DECIMAL(5,2);
    
    -- Calcular el total de la nota final permitida (considerando que la nota final no debe superar 100)
    SET total_nota = 100; -- Esto puede variar según el sistema de evaluación
    
    -- Verificar si la nota práctica no supera el 60% del total
    IF NEW.nota > (total_nota * 0.60) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La nota práctica no puede superar el 60% del total';
    END IF;
END$$

DELIMITER ;

-- 20. Al modificar una ruta, notificar cambios a los trainers asignados
DELIMITER $$

CREATE TRIGGER notificar_cambio_ruta
AFTER UPDATE ON rutaAprendizaje
FOR EACH ROW
BEGIN
    DECLARE trainer_id INT;
    DECLARE mensaje_notificacion TEXT;
    
    -- Verificar si hubo un cambio en la descripción o en la fecha de la ruta
    IF OLD.descripcion != NEW.descripcion OR OLD.fecha_creacion != NEW.fecha_creacion THEN
        SET mensaje_notificacion = CONCAT('La ruta "', NEW.nombre, '" ha sido modificada. Verifique los cambios.');
        
        -- Enviar notificación a todos los trainers asignados a esta ruta
        DECLARE trainer_cursor CURSOR FOR
            SELECT id_trainer
            FROM rutaTrainer
            WHERE id_ruta = OLD.id;
        
        OPEN trainer_cursor;
        read_loop: LOOP
            FETCH trainer_cursor INTO trainer_id;
            IF done THEN
                LEAVE read_loop;
            END IF;
            
            -- Insertar notificación automatizada para cada trainer
            INSERT INTO notificacionesAutomatizadas (id_ruta, id_trainer, mensaje)
            VALUES (OLD.id, trainer_id, mensaje_notificacion);
        END LOOP;
        
        CLOSE trainer_cursor;
    END IF;
END$$

DELIMITER ;