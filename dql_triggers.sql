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

-- Para su uso:

SELECT * FROM notaFinal WHERE doc_camper = '1001234567' AND id_modulo = 1;

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

-- Para su uso:
 -- Actualizar la nota final de un módulo
UPDATE notaFinal 
SET nota_final = 75 
WHERE doc_camper = '1001234567' AND id_modulo = 1;

-- Verificar estado de campersModulosAsignados
SELECT * FROM campersModulosAsignados 
WHERE doc_camper = '1001234567' AND id_modulo = 1;

-- Repetir una nota reprobada
UPDATE notaFinal 
SET nota_final = 40 
WHERE doc_camper = '1001234567' AND id_modulo = 1;


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

-- Para su uso:

-- Verificar el estado actual del camper
SELECT 
    c.documento, 
    IF(e.nombre = 'Inscrito', 'Inscrito', 'No Inscrito') AS estado
FROM 
    camper c
JOIN 
    estadoActual e ON c.id_estado = e.id
WHERE 
    c.documento = '1001234567';

-- Verificar el historial del camper
SELECT * FROM historicoEstadoCamper WHERE doc_camper = '1001234567' ORDER BY fecha_cambio DESC LIMIT 1;


-- 4. Al actualizar una evaluación, recalcular su promedio inmediatamente

-- Corregirloooooooooooooooo


-- 5. Al eliminar una inscripción, marcar al camper como "Retirado"
DELIMITER $$

CREATE TRIGGER trig_marcar_retirado
AFTER DELETE ON inscripciones
FOR EACH ROW
BEGIN
    DECLARE id_estado_retirado INT;
    DECLARE id_estado_actual INT;
    
    -- Obtener el ID del estado "Retirado"
    SELECT id INTO id_estado_retirado FROM estadoActual WHERE nombre = 'Retirado' LIMIT 1;
    
    -- Obtener el estado actual del camper
    SELECT id_estado INTO id_estado_actual FROM camper WHERE documento = OLD.doc_camper;
    
    -- Actualizar el estado del camper a "Retirado"
    UPDATE camper 
    SET id_estado = id_estado_retirado 
    WHERE documento = OLD.doc_camper;
    
    -- Registrar el cambio en el historial
    INSERT INTO historicoEstadoCamper (doc_camper, id_estado_anterior, id_estado_nuevo, motivo, fecha_cambio)
    VALUES (OLD.doc_camper, id_estado_actual, id_estado_retirado, 'Se eliminó la inscripción', NOW());
END $$
DELIMITER ;

-- Para su uso:

-- 6. Al insertar un nuevo módulo, registrar automáticamente su SGDB asociado
DELIMITER $$
CREATE TRIGGER trig_registrar_sgbd_modulo
AFTER INSERT ON moduloAprendizaje
FOR EACH ROW
BEGIN
    DECLARE v_sgbd_id INT;
    
    -- Buscar un SGBD predeterminado según el tipo de módulo
    CASE NEW.tipo
        WHEN 'Bases de datos' THEN
            -- Obtener el ID de MySQL si es módulo de BD
            SELECT id INTO v_sgbd_id FROM sgbd WHERE nombre = 'MySQL' LIMIT 1;
        WHEN 'Backend' THEN
            -- Obtener el ID de PostgreSQL si es backend
            SELECT id INTO v_sgbd_id FROM sgbd WHERE nombre = 'PostgreSQL' LIMIT 1;
        ELSE
            -- Para otros tipos, usar un SGBD genérico
            SELECT id INTO v_sgbd_id FROM sgbd LIMIT 1;
    END CASE;
    
    -- Si encontramos un SGBD, lo asociamos al módulo
    IF v_sgbd_id IS NOT NULL THEN
        INSERT INTO moduloSGBD (id_modulo, id_sgbd)
        VALUES (NEW.id, v_sgbd_id);
    END IF;
END $$
DELIMITER ;

-- 7. Al insertar un nuevo trainer, verificar duplicados por identificación
DELIMITER $$
CREATE TRIGGER trig_verificar_duplicado_trainer
BEFORE INSERT ON trainer
FOR EACH ROW
BEGIN
    DECLARE count_trainers INT;
    
    -- Verificar si ya existe un trainer con el mismo documento
    SELECT COUNT(*) INTO count_trainers FROM trainer WHERE documento = NEW.documento;
    
    -- Si existe, lanzar un error
    IF count_trainers > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Ya existe un trainer con este número de documento';
    END IF;
END $$
DELIMITER ;

-- 8. Al asignar un área, validar que no exceda su capacidad
DELIMITER $$
CREATE TRIGGER trig_validar_capacidad_area
BEFORE INSERT ON asignacionCamper
FOR EACH ROW
BEGIN
    DECLARE capacidad_area INT;
    DECLARE ocupacion_actual INT;
    
    -- Obtener la capacidad del área
    SELECT capacidad INTO capacidad_area FROM areaSalon WHERE id = NEW.id_area;
    
    -- Contar campers asignados actualmente al área en ese horario
    SELECT COUNT(*) INTO ocupacion_actual 
    FROM asignacionCamper 
    WHERE id_area = NEW.id_area 
    AND id_horario = NEW.id_horario
    AND (fecha_fin IS NULL OR fecha_fin >= CURDATE());
    
    -- Verificar si hay espacio disponible
    IF (ocupacion_actual >= capacidad_area) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El área ha alcanzado su capacidad máxima';
    END IF;
END $$
DELIMITER ;

-- 9. Al insertar una evaluación con nota < 60, marcar al camper como "Bajo rendimiento"
DELIMITER $$
CREATE TRIGGER trig_marcar_bajo_rendimiento
AFTER INSERT ON skillsNotas
FOR EACH ROW
BEGIN
    DECLARE id_nivel_riesgo_bajo INT;
    
    -- Si la nota es menor a 60
    IF NEW.nota < 60 THEN
        -- Obtener ID del nivel de riesgo "Bajo" (asumiendo que existe con nivel "B")
        SELECT id INTO id_nivel_riesgo_bajo FROM nivelRiesgo WHERE nivel = 'B' LIMIT 1;
        
        -- Marcar al camper como "Bajo rendimiento"
        UPDATE camper SET id_nivel_riesgo = id_nivel_riesgo_bajo 
        WHERE documento = NEW.doc_camper;
        
        -- Crear notificación de alerta
        INSERT INTO notificacion (titulo, mensaje, tipo, estado)
        VALUES (
            CONCAT('Alerta: Camper con bajo rendimiento'),
            CONCAT('El camper con documento ', NEW.doc_camper, ' ha obtenido una nota de ', NEW.nota, ' en una evaluación.'),
            'Alerta',
            'Pendiente'
        );
    END IF;
END $$
DELIMITER ;

-- 10. Al cambiar de estado a "Graduado", mover registro a la tabla de egresados
DELIMITER $$
CREATE TRIGGER trig_mover_a_egresados
AFTER UPDATE ON camper
FOR EACH ROW
BEGIN
    DECLARE id_estado_graduado INT;
    DECLARE v_ruta_id INT;
    
    -- Obtener ID del estado "Graduado"
    SELECT id INTO id_estado_graduado FROM estadoActual WHERE nombre = 'Graduado' LIMIT 1;
    
    -- Si el estado nuevo es "Graduado"
    IF NEW.id_estado = id_estado_graduado AND OLD.id_estado != id_estado_graduado THEN
        -- Obtener la última ruta que el camper completó
        SELECT id_ruta INTO v_ruta_id
        FROM inscripciones
        WHERE doc_camper = NEW.documento AND estado = 'Completada'
        ORDER BY fecha_fin_real DESC
        LIMIT 1;
        
        -- Si encontramos una ruta, registrar en egresados
        IF v_ruta_id IS NOT NULL THEN
            INSERT INTO egresados (documento, nombres, apellidos, email, fecha_graduacion, id_ruta)
            VALUES (NEW.documento, NEW.nombres, NEW.apellidos, NEW.email, CURDATE(), v_ruta_id);
        END IF;
    END IF;
END $$
DELIMITER ;

-- 11. Al modificar horarios de trainer, verificar solapamiento con otros
DELIMITER $$
CREATE TRIGGER trig_verificar_solapamiento_horarios
BEFORE INSERT ON horarioTrainer
FOR EACH ROW
BEGIN
    DECLARE count_solapamientos INT;
    DECLARE hora_inicio TIME;
    DECLARE hora_fin TIME;
    
    -- Obtener horas de inicio y fin del horario a asignar
    SELECT hora_inicio, hora_fin INTO hora_inicio, hora_fin
    FROM horarios WHERE id = NEW.id_horario;
    
    -- Verificar si hay solapamientos con otros horarios del mismo trainer en el mismo día
    SELECT COUNT(*) INTO count_solapamientos
    FROM horarioTrainer ht
    JOIN horarios h ON ht.id_horario = h.id
    WHERE ht.id_trainer = NEW.id_trainer
    AND ht.dia_semana = NEW.dia_semana
    AND (
        (hora_inicio BETWEEN h.hora_inicio AND h.hora_fin) OR
        (hora_fin BETWEEN h.hora_inicio AND h.hora_fin) OR
        (h.hora_inicio BETWEEN hora_inicio AND hora_fin)
    );
    
    -- Si hay solapamientos, lanzar error
    IF count_solapamientos > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El horario se solapa con otro horario asignado al mismo trainer';
    END IF;
END $$
DELIMITER ;

-- 12. Al eliminar un trainer, liberar sus horarios y rutas asignadas
DELIMITER $$
CREATE TRIGGER trig_liberar_asignaciones_trainer
BEFORE DELETE ON trainer
FOR EACH ROW
BEGIN
    -- Establecer fecha_fin para las rutas asignadas
    UPDATE rutaTrainer 
    SET fecha_fin = CURDATE()
    WHERE id_trainer = OLD.id AND fecha_fin IS NULL;
    
    -- Eliminar los horarios asignados
    DELETE FROM horarioTrainer WHERE id_trainer = OLD.id;
    
    -- Crear notificación
    INSERT INTO notificacion (titulo, mensaje, tipo, estado)
    VALUES (
        'Cambio en asignación de trainer',
        CONCAT('Se han liberado las asignaciones del trainer ', OLD.nombres, ' ', OLD.apellidos, ' (ID: ', OLD.id, ')'),
        'Informativa',
        'Pendiente'
    );
END $$
DELIMITER ;

-- 13. Al cambiar la ruta de un camper, actualizar automáticamente sus módulos
DELIMITER $$
CREATE TRIGGER trig_actualizar_modulos_camper
AFTER UPDATE ON inscripciones
FOR EACH ROW
BEGIN
    -- Solo si cambia la ruta y la inscripción está aprobada
    IF NEW.id_ruta != OLD.id_ruta AND NEW.estado = 'Aprobada' THEN
        -- Eliminar módulos anteriores que no estén aprobados
        DELETE FROM campersModulosAsignados
        WHERE doc_camper = NEW.doc_camper
        AND estado NOT IN ('Aprobado')
        AND id_modulo IN (
            SELECT id_modulo FROM rutaModulo WHERE id_ruta = OLD.id_ruta
        );
        
        -- Insertar nuevos módulos de la nueva ruta
        INSERT INTO campersModulosAsignados (doc_camper, id_modulo, estado)
        SELECT NEW.doc_camper, rm.id_modulo, 'Pendiente'
        FROM rutaModulo rm
        WHERE rm.id_ruta = NEW.id_ruta
        AND NOT EXISTS (
            SELECT 1 FROM campersModulosAsignados
            WHERE doc_camper = NEW.doc_camper AND id_modulo = rm.id_modulo
        );
    END IF;
END $$
DELIMITER ;

-- 14. Al insertar un nuevo camper, verificar si ya existe por número de documento
DELIMITER $$
CREATE TRIGGER trig_verificar_duplicado_camper
BEFORE INSERT ON camper
FOR EACH ROW
BEGIN
    DECLARE count_campers INT;
    
    -- Verificar si ya existe un camper con el mismo documento
    SELECT COUNT(*) INTO count_campers FROM camper WHERE documento = NEW.documento;
    
    -- Si existe, lanzar un error
    IF count_campers > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Ya existe un camper con este número de documento';
    END IF;
END $$
DELIMITER ;

-- 15. Al actualizar la nota final, recalcular el estado del módulo automáticamente
DELIMITER $$
CREATE TRIGGER trig_actualizar_estado_modulo
AFTER UPDATE ON notaFinal
FOR EACH ROW
BEGIN
    -- Si cambió el estado de aprobación
    IF NEW.aprobado != OLD.aprobado THEN
        -- Actualizar estado en campersModulosAsignados
        UPDATE campersModulosAsignados
        SET estado = CASE WHEN NEW.aprobado = TRUE THEN 'Aprobado' ELSE 'Reprobado' END
        WHERE doc_camper = NEW.doc_camper AND id_modulo = NEW.id_modulo;
    END IF;
END $$
DELIMITER ;

-- 16. Al asignar un módulo, verificar que el trainer tenga ese conocimiento
DELIMITER $$
CREATE TRIGGER trig_verificar_skills_trainer
BEFORE INSERT ON rutaTrainer
FOR EACH ROW
BEGIN
    DECLARE count_skills INT;
    DECLARE total_skills INT;
    
    -- Contar cuántas skills requeridas por la ruta tiene el trainer
    SELECT COUNT(*) INTO count_skills
    FROM skillModulo sm
    JOIN rutaModulo rm ON rm.id_modulo = sm.id_modulo
    JOIN trainerSkills ts ON ts.id_skill = sm.id_skill
    WHERE rm.id_ruta = NEW.id_ruta
    AND ts.id_trainer = NEW.id_trainer;
    
    -- Contar total de skills requeridas por la ruta
    SELECT COUNT(DISTINCT sm.id_skill) INTO total_skills
    FROM skillModulo sm
    JOIN rutaModulo rm ON rm.id_modulo = sm.id_modulo
    WHERE rm.id_ruta = NEW.id_ruta;
    
    -- Si no tiene al menos el 70% de las skills, lanzar error
    IF count_skills < (total_skills * 0.7) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El trainer no tiene suficientes habilidades para esta ruta';
    END IF;
END $$
DELIMITER ;

-- 17. Al cambiar el estado de un área a inactiva, liberar campers asignados
DELIMITER $$
CREATE TRIGGER trig_liberar_campers_area_inactiva
AFTER UPDATE ON areaSalon
FOR EACH ROW
BEGIN
    -- Si el área pasa a estado inactivo o en mantenimiento
    IF NEW.estado != 'Activa' AND OLD.estado = 'Activa' THEN
        -- Finalizar las asignaciones de campers
        UPDATE asignacionCamper
        SET fecha_fin = CURDATE()
        WHERE id_area = NEW.id AND fecha_fin IS NULL;
        
        -- Notificar el cambio
        INSERT INTO notificacion (titulo, mensaje, tipo, estado)
        VALUES (
            CONCAT('Área ', NEW.nombre, ' ahora en estado ', NEW.estado),
            CONCAT('Se han liberado todas las asignaciones de campers del área ', NEW.nombre, ' debido a cambio de estado.'),
            'Alerta',
            'Pendiente'
        );
    END IF;
END $$
DELIMITER ;

-- 18. Al crear una nueva ruta, clonar la plantilla base de módulos y SGDBs
DELIMITER $$
CREATE TRIGGER trig_clonar_plantilla_ruta
AFTER INSERT ON rutaAprendizaje
FOR EACH ROW
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id_modulo INT;
    DECLARE v_orden INT;
    DECLARE v_id_sgbd INT;
    
    -- Cursor para recorrer módulos de la plantilla
    DECLARE cur_modulos CURSOR FOR
        SELECT id_modulo, COUNT(*) + 1 as orden
        FROM plantillaModulos
        GROUP BY id_modulo;
    
    -- Cursor para recorrer SGBDs asociados a la ruta plantilla
    DECLARE cur_sgbd CURSOR FOR
        SELECT DISTINCT id_sgbd
        FROM moduloSGBD ms
        JOIN plantillaModulos pm ON pm.id_modulo = ms.id_modulo;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Clonar módulos de la plantilla
    OPEN cur_modulos;
    read_modulos: LOOP
        FETCH cur_modulos INTO v_id_modulo, v_orden;
        IF done THEN
            LEAVE read_modulos;
        END IF;
        
        -- Insertar módulos en la ruta
        INSERT INTO rutaModulo (id_ruta, id_modulo, orden)
        VALUES (NEW.id, v_id_modulo, v_orden);
    END LOOP;
    CLOSE cur_modulos;
    
    -- Resetear el indicador para el siguiente cursor
    SET done = FALSE;
    
    -- Asociar SGBDs a la nueva ruta
    OPEN cur_sgbd;
    read_sgbd: LOOP
        FETCH cur_sgbd INTO v_id_sgbd;
        IF done THEN
            LEAVE read_sgbd;
        END IF;
        
        -- Insertar SGBDs en la ruta
        INSERT INTO bdAsociados (id_ruta, id_sgbd, es_principal)
        VALUES (NEW.id, v_id_sgbd, FALSE);
    END LOOP;
    CLOSE cur_sgbd;
END $$
DELIMITER ;

-- 19. Al registrar la nota práctica, verificar que no supere 60% del total
DELIMITER $$
CREATE TRIGGER trig_verificar_limite_nota_practica
BEFORE INSERT ON skillsNotas
FOR EACH ROW
BEGIN
    DECLARE tipo_eval VARCHAR(50);
    DECLARE porcentaje_tipo DECIMAL(5,2);
    
    -- Obtener tipo y porcentaje de la evaluación
    SELECT nombre, porcentaje INTO tipo_eval, porcentaje_tipo
    FROM tipoEvaluacion WHERE id = NEW.id_tipo_evaluacion;
    
    -- Si es evaluación práctica y supera el 60%
    IF tipo_eval = 'Práctica' AND porcentaje_tipo > 60.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El porcentaje de la evaluación práctica no puede superar el 60% del total';
    END IF;
END $$
DELIMITER ;

-- 20. Al modificar una ruta, notificar cambios a los trainers asignados
DELIMITER $$
CREATE TRIGGER trig_notificar_cambios_ruta
AFTER UPDATE ON rutaAprendizaje
FOR EACH ROW
BEGIN
    -- Verificar si hubo cambios significativos
    IF NEW.nombre != OLD.nombre OR NEW.descripcion != OLD.descripcion OR NEW.duracion_meses != OLD.duracion_meses THEN
        -- Registrar el cambio
        INSERT INTO cambiosRuta (id_ruta, descripcion)
        VALUES (NEW.id, CONCAT(
            'Cambios en la ruta: ',
            CASE WHEN NEW.nombre != OLD.nombre 
                THEN CONCAT('Nombre antiguo: ', OLD.nombre, ', Nuevo: ', NEW.nombre, '. ') 
                ELSE '' END,
            CASE WHEN NEW.descripcion != OLD.descripcion 
                THEN 'Descripción actualizada. ' 
                ELSE '' END,
            CASE WHEN NEW.duracion_meses != OLD.duracion_meses 
                THEN CONCAT('Duración antigua: ', OLD.duracion_meses, ' meses, Nueva: ', NEW.duracion_meses, ' meses.') 
                ELSE '' END
        ));
        
        -- Enviar notificación a cada trainer asignado
        INSERT INTO notificacionesAutomatizadas (id_ruta, id_trainer, mensaje)
        SELECT 
            NEW.id, 
            rt.id_trainer,
            CONCAT('La ruta "', NEW.nombre, '" ha sido actualizada. Por favor, revise los cambios.')
        FROM rutaTrainer rt
        WHERE rt.id_ruta = NEW.id AND (rt.fecha_fin IS NULL OR rt.fecha_fin > CURDATE());
    END IF;
END $$
DELIMITER ;