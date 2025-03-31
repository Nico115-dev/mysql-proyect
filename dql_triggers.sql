-- 1. Al insertar una evaluación, calcular automáticamente la nota final
DELIMITER //
CREATE TRIGGER calcular_nota_final_insert
AFTER INSERT ON moduloNotas
FOR EACH ROW
BEGIN
    DECLARE v_nota_teorica DECIMAL(5,2);
    DECLARE v_nota_practica DECIMAL(5,2);
    DECLARE v_nota_quizzes DECIMAL(5,2);
    DECLARE v_nota_final DECIMAL(5,2);
    DECLARE v_aprobado BOOLEAN;
    
    -- Obtener notas actuales
    SELECT COALESCE(nota, 0) INTO v_nota_teorica
    FROM moduloNotas 
    WHERE doc_camper = NEW.doc_camper 
    AND id_modulo = NEW.id_modulo
    AND id_tipo_evaluacion = (SELECT id FROM tipoEvaluacion WHERE nombre = 'Teórica');
    
    SELECT COALESCE(nota, 0) INTO v_nota_practica
    FROM moduloNotas 
    WHERE doc_camper = NEW.doc_camper 
    AND id_modulo = NEW.id_modulo
    AND id_tipo_evaluacion = (SELECT id FROM tipoEvaluacion WHERE nombre = 'Práctica');
    
    SELECT COALESCE(nota, 0) INTO v_nota_quizzes
    FROM moduloNotas 
    WHERE doc_camper = NEW.doc_camper 
    AND id_modulo = NEW.id_modulo
    AND id_tipo_evaluacion = (SELECT id FROM tipoEvaluacion WHERE nombre = 'Quizzes/Trabajos');
    
    -- Calcular nota final (30% teórica + 60% práctica + 10% quizzes)
    SET v_nota_final = (v_nota_teorica * 0.3) + (v_nota_practica * 0.6) + (v_nota_quizzes * 0.1);
    SET v_aprobado = (v_nota_final >= 60);
    
    -- Insertar o actualizar en la tabla notaFinal
    INSERT INTO notaFinal (doc_camper, id_modulo, nota_teorica, nota_practica, nota_quizzes, nota_final, aprobado)
    VALUES (NEW.doc_camper, NEW.id_modulo, v_nota_teorica, v_nota_practica, v_nota_quizzes, v_nota_final, v_aprobado)
    ON DUPLICATE KEY UPDATE
        nota_teorica = v_nota_teorica,
        nota_practica = v_nota_practica,
        nota_quizzes = v_nota_quizzes,
        nota_final = v_nota_final,
        aprobado = v_aprobado;
END //
DELIMITER ;

-- 2. Al actualizar la nota final de un módulo, verificar si el camper aprueba o reprueba
DELIMITER //
CREATE TRIGGER verificar_aprobacion_modulo
AFTER UPDATE ON notaFinal
FOR EACH ROW
BEGIN
    IF NEW.nota_final >= 60 AND NEW.nota_final != OLD.nota_final THEN
        UPDATE campersModulosAsignados 
        SET estado = 'Aprobado'
        WHERE doc_camper = NEW.doc_camper AND id_modulo = NEW.id_modulo;
    ELSEIF NEW.nota_final < 60 AND NEW.nota_final != OLD.nota_final THEN
        UPDATE campersModulosAsignados 
        SET estado = 'Reprobado'
        WHERE doc_camper = NEW.doc_camper AND id_modulo = NEW.id_modulo;
        
        -- Actualizar nivel de riesgo del camper
        UPDATE camper
        SET id_nivel_riesgo = (SELECT id FROM nivelRiesgo WHERE nivel = 'A1')
        WHERE documento = NEW.doc_camper;
    END IF;
END //
DELIMITER ;

-- 3. Al insertar una inscripción, cambiar el estado del camper a "Inscrito"
DELIMITER //
CREATE TRIGGER cambiar_estado_inscrito
AFTER INSERT ON inscripciones
FOR EACH ROW
BEGIN
    DECLARE v_estado_inscrito INT;
    DECLARE v_estado_actual INT;
    
    -- Obtener ID del estado "Inscrito"
    SELECT id INTO v_estado_inscrito FROM estadoActual WHERE nombre = 'Inscrito';
    
    -- Obtener estado actual del camper
    SELECT id_estado INTO v_estado_actual FROM camper WHERE documento = NEW.doc_camper;
    
    -- Registrar cambio en histórico
    INSERT INTO historicoEstadoCamper (doc_camper, id_estado_anterior, id_estado_nuevo, motivo)
    VALUES (NEW.doc_camper, v_estado_actual, v_estado_inscrito, 'Inscripción automática');
    
    -- Actualizar estado del camper
    UPDATE camper SET id_estado = v_estado_inscrito WHERE documento = NEW.doc_camper;
END //
DELIMITER ;

-- 4. Al actualizar una evaluación, recalcular su promedio inmediatamente
DELIMITER //
CREATE TRIGGER recalcular_promedio_update
AFTER UPDATE ON moduloNotas
FOR EACH ROW
BEGIN
    DECLARE v_nota_teorica DECIMAL(5,2);
    DECLARE v_nota_practica DECIMAL(5,2);
    DECLARE v_nota_quizzes DECIMAL(5,2);
    DECLARE v_nota_final DECIMAL(5,2);
    DECLARE v_aprobado BOOLEAN;
    
    -- Obtener notas actuales
    SELECT COALESCE(nota, 0) INTO v_nota_teorica
    FROM moduloNotas 
    WHERE doc_camper = NEW.doc_camper 
    AND id_modulo = NEW.id_modulo
    AND id_tipo_evaluacion = (SELECT id FROM tipoEvaluacion WHERE nombre = 'Teórica');
    
    SELECT COALESCE(nota, 0) INTO v_nota_practica
    FROM moduloNotas 
    WHERE doc_camper = NEW.doc_camper 
    AND id_modulo = NEW.id_modulo
    AND id_tipo_evaluacion = (SELECT id FROM tipoEvaluacion WHERE nombre = 'Práctica');
    
    SELECT COALESCE(nota, 0) INTO v_nota_quizzes
    FROM moduloNotas 
    WHERE doc_camper = NEW.doc_camper 
    AND id_modulo = NEW.id_modulo
    AND id_tipo_evaluacion = (SELECT id FROM tipoEvaluacion WHERE nombre = 'Quizzes/Trabajos');
    
    -- Calcular nota final
    SET v_nota_final = (v_nota_teorica * 0.3) + (v_nota_practica * 0.6) + (v_nota_quizzes * 0.1);
    SET v_aprobado = (v_nota_final >= 60);
    
    -- Actualizar en la tabla notaFinal
    UPDATE notaFinal
    SET nota_teorica = v_nota_teorica,
        nota_practica = v_nota_practica,
        nota_quizzes = v_nota_quizzes,
        nota_final = v_nota_final,
        aprobado = v_aprobado
    WHERE doc_camper = NEW.doc_camper AND id_modulo = NEW.id_modulo;
END //
DELIMITER ;

-- 5. Al eliminar una inscripción, marcar al camper como "Retirado"
DELIMITER //
CREATE TRIGGER marcar_camper_retirado
BEFORE DELETE ON inscripciones
FOR EACH ROW
BEGIN
    DECLARE v_estado_retirado INT;
    DECLARE v_estado_actual INT;
    
    -- Obtener ID del estado "Retirado"
    SELECT id INTO v_estado_retirado FROM estadoActual WHERE nombre = 'Retirado';
    
    -- Obtener estado actual del camper
    SELECT id_estado INTO v_estado_actual FROM camper WHERE documento = OLD.doc_camper;
    
    -- Registrar cambio en histórico
    INSERT INTO historicoEstadoCamper (doc_camper, id_estado_anterior, id_estado_nuevo, motivo)
    VALUES (OLD.doc_camper, v_estado_actual, v_estado_retirado, 'Eliminación de inscripción');
    
    -- Actualizar estado del camper
    UPDATE camper SET id_estado = v_estado_retirado WHERE documento = OLD.doc_camper;
END //
DELIMITER ;

-- 6. Al insertar un nuevo módulo, registrar automáticamente su SGDB asociado
DELIMITER //
CREATE TRIGGER registrar_sgbd_modulo
AFTER INSERT ON moduloAprendizaje
FOR EACH ROW
BEGIN
    -- Si es un módulo de bases de datos, asociar automáticamente los SGBD correspondientes
    IF NEW.tipo = 'Bases de datos' THEN
        -- Obtener IDs de los SGBD (asumiendo que ya existen)
        DECLARE v_mysql_id INT;
        DECLARE v_mongodb_id INT;
        DECLARE v_postgresql_id INT;
        
        SELECT id INTO v_mysql_id FROM sgbd WHERE nombre = 'MySQL' LIMIT 1;
        SELECT id INTO v_mongodb_id FROM sgbd WHERE nombre = 'MongoDB' LIMIT 1;
        SELECT id INTO v_postgresql_id FROM sgbd WHERE nombre = 'PostgreSQL' LIMIT 1;
        
        -- Insertar asociaciones en moduloSGBD
        IF v_mysql_id IS NOT NULL THEN
            INSERT INTO moduloSGBD (id_modulo, id_sgbd) VALUES (NEW.id, v_mysql_id);
        END IF;
        
        IF v_mongodb_id IS NOT NULL THEN
            INSERT INTO moduloSGBD (id_modulo, id_sgbd) VALUES (NEW.id, v_mongodb_id);
        END IF;
        
        IF v_postgresql_id IS NOT NULL THEN
            INSERT INTO moduloSGBD (id_modulo, id_sgbd) VALUES (NEW.id, v_postgresql_id);
        END IF;
    END IF;
END //
DELIMITER ;

-- 7. Al insertar un nuevo trainer, verificar duplicados por identificación
DELIMITER //
CREATE TRIGGER verificar_duplicado_trainer
BEFORE INSERT ON trainer
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    
    -- Verificar si ya existe un trainer con el mismo documento
    SELECT COUNT(*) INTO v_count FROM trainer WHERE documento = NEW.documento;
    
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un trainer con este número de documento';
    END IF;
END //
DELIMITER ;

-- 8. Al asignar un área, validar que no exceda su capacidad
DELIMITER //
CREATE TRIGGER validar_capacidad_area
BEFORE INSERT ON asignacionCamper
FOR EACH ROW
BEGIN
    DECLARE v_capacidad INT;
    DECLARE v_asignados INT;
    
    -- Obtener capacidad del área
    SELECT capacidad INTO v_capacidad 
    FROM areaSalon 
    WHERE id = NEW.id_area;
    
    -- Contar campers ya asignados a esa área en ese horario
    SELECT COUNT(*) INTO v_asignados 
    FROM asignacionCamper 
    WHERE id_area = NEW.id_area 
    AND id_horario = NEW.id_horario
    AND (fecha_fin IS NULL OR fecha_fin >= CURDATE());
    
    -- Verificar si excede la capacidad
    IF v_asignados >= v_capacidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La asignación excede la capacidad máxima del área';
    END IF;
END //
DELIMITER ;

-- 9. Al insertar una evaluación con nota < 60, marcar al camper como "Bajo rendimiento"
DELIMITER //
CREATE TRIGGER marcar_bajo_rendimiento
AFTER INSERT ON notaFinal
FOR EACH ROW
BEGIN
    DECLARE v_estado_bajo_rendimiento INT;
    DECLARE v_estado_actual INT;
    
    IF NEW.nota_final < 60 THEN
        -- Obtener ID del estado "Bajo rendimiento"
        SELECT id INTO v_estado_bajo_rendimiento FROM estadoActual WHERE nombre = 'Bajo rendimiento';
        
        -- Obtener estado actual del camper
        SELECT id_estado INTO v_estado_actual FROM camper WHERE documento = NEW.doc_camper;
        
        -- Registrar cambio en histórico
        INSERT INTO historicoEstadoCamper (doc_camper, id_estado_anterior, id_estado_nuevo, motivo)
        VALUES (NEW.doc_camper, v_estado_actual, v_estado_bajo_rendimiento, 'Nota final inferior a 60');
        
        -- Actualizar estado del camper
        UPDATE camper SET id_estado = v_estado_bajo_rendimiento WHERE documento = NEW.doc_camper;
    END IF;
END //
DELIMITER ;

-- 10. Al cambiar de estado a "Graduado", mover registro a la tabla de egresados
DELIMITER //
CREATE TRIGGER mover_a_egresados
AFTER UPDATE ON camper
FOR EACH ROW
BEGIN
    DECLARE v_estado_graduado INT;
    DECLARE v_id_ruta INT;
    
    -- Obtener ID del estado "Graduado"
    SELECT id INTO v_estado_graduado FROM estadoActual WHERE nombre = 'Graduado';
    
    -- Si el nuevo estado es "Graduado" y antes no lo era
    IF NEW.id_estado = v_estado_graduado AND OLD.id_estado != v_estado_graduado THEN
        -- Obtener la ruta del camper
        SELECT id_ruta INTO v_id_ruta 
        FROM inscripciones 
        WHERE doc_camper = NEW.documento 
        ORDER BY fecha_inscripcion DESC 
        LIMIT 1;
        
        -- Insertar en la tabla de egresados
        INSERT INTO egresados (documento, nombres, apellidos, email, fecha_graduacion, id_ruta)
        VALUES (NEW.documento, NEW.nombres, NEW.apellidos, NEW.email, CURDATE(), v_id_ruta);
    END IF;
END //
DELIMITER ;

-- 11. Al modificar horarios de trainer, verificar solapamiento con otros
DELIMITER //
CREATE TRIGGER verificar_solapamiento_horarios
BEFORE INSERT ON horarioTrainer
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    
    -- Verificar si el trainer ya tiene asignado otro horario que se solape
    SELECT COUNT(*) INTO v_count
    FROM horarioTrainer ht
    JOIN horarios h1 ON ht.id_horario = h1.id
    JOIN horarios h2 ON NEW.id_horario = h2.id
    WHERE ht.id_trainer = NEW.id_trainer
    AND ht.dia_semana = NEW.dia_semana
    AND (
        (h1.hora_inicio <= h2.hora_inicio AND h1.hora_fin > h2.hora_inicio) OR
        (h1.hora_inicio < h2.hora_fin AND h1.hora_fin >= h2.hora_fin) OR
        (h1.hora_inicio >= h2.hora_inicio AND h1.hora_fin <= h2.hora_fin)
    );
    
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El horario se solapa con otro ya asignado al mismo trainer';
    END IF;
END //
DELIMITER ;

-- 12. Al eliminar un trainer, liberar sus horarios y rutas asignadas
DELIMITER //
CREATE TRIGGER liberar_asignaciones_trainer
BEFORE DELETE ON trainer
FOR EACH ROW
BEGIN
    -- Liberar horarios asignados
    DELETE FROM horarioTrainer WHERE id_trainer = OLD.id;
    
    -- Actualizar rutas asignadas (marcar como finalizadas)
    UPDATE rutaTrainer 
    SET fecha_fin = CURDATE()
    WHERE id_trainer = OLD.id AND fecha_fin IS NULL;
END //
DELIMITER ;

-- 13. Al cambiar la ruta de un camper, actualizar automáticamente sus módulos
DELIMITER //
CREATE TRIGGER actualizar_modulos_cambio_ruta
AFTER UPDATE ON inscripciones
FOR EACH ROW
BEGIN
    -- Si cambió la ruta
    IF NEW.id_ruta != OLD.id_ruta THEN
        -- Eliminar asignaciones de módulos anteriores
        DELETE FROM campersModulosAsignados 
        WHERE doc_camper = NEW.doc_camper 
        AND id_modulo IN (
            SELECT id_modulo 
            FROM rutaModulo 
            WHERE id_ruta = OLD.id_ruta
        );
        
        -- Insertar nuevas asignaciones de módulos
        INSERT INTO campersModulosAsignados (doc_camper, id_modulo, estado)
        SELECT NEW.doc_camper, id_modulo, 'Pendiente'
        FROM rutaModulo
        WHERE id_ruta = NEW.id_ruta;
    END IF;
END //
DELIMITER ;

-- 14. Al insertar un nuevo camper, verificar si ya existe por número de documento
DELIMITER //
CREATE TRIGGER verificar_duplicado_camper
BEFORE INSERT ON camper
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    
    -- Verificar si ya existe un camper con el mismo documento
    SELECT COUNT(*) INTO v_count FROM camper WHERE documento = NEW.documento;
    
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un camper con este número de documento';
    END IF;
END //
DELIMITER ;

-- 15. Al actualizar la nota final, recalcular el estado del módulo automáticamente
DELIMITER //
CREATE TRIGGER actualizar_estado_modulo
AFTER UPDATE ON notaFinal
FOR EACH ROW
BEGIN
    -- Si cambió la nota final
    IF NEW.nota_final != OLD.nota_final THEN
        IF NEW.nota_final >= 60 THEN
            UPDATE campersModulosAsignados
            SET estado = 'Aprobado'
            WHERE doc_camper = NEW.doc_camper AND id_modulo = NEW.id_modulo;
        ELSE
            UPDATE campersModulosAsignados
            SET estado = 'Reprobado'
            WHERE doc_camper = NEW.doc_camper AND id_modulo = NEW.id_modulo;
        END IF;
    END IF;
END //
DELIMITER ;

-- 16. Al asignar un módulo, verificar que el trainer tenga ese conocimiento
DELIMITER //
CREATE TRIGGER verificar_conocimiento_trainer
BEFORE INSERT ON rutaTrainer
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    DECLARE v_modulos_count INT;
    DECLARE v_skills_count INT;
    
    -- Contar módulos de la ruta
    SELECT COUNT(*) INTO v_modulos_count
    FROM rutaModulo
    WHERE id_ruta = NEW.id_ruta;
    
    -- Contar habilidades del trainer relacionadas con los módulos de la ruta
    SELECT COUNT(DISTINCT rm.id_modulo) INTO v_skills_count
    FROM rutaModulo rm
    JOIN moduloAprendizaje ma ON rm.id_modulo = ma.id
    JOIN skills s ON ma.nombre LIKE CONCAT('%', s.nombre, '%')
    JOIN trainerSkills ts ON s.id = ts.id_skill
    WHERE rm.id_ruta = NEW.id_ruta
    AND ts.id_trainer = NEW.id_trainer;
    
    -- Si el trainer no tiene al menos el 50% de las habilidades necesarias
    IF v_skills_count < (v_modulos_count * 0.5) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El trainer no tiene suficientes conocimientos para esta ruta';
    END IF;
END //
DELIMITER ;

-- 17. Al cambiar el estado de un área a inactiva, liberar campers asignados
DELIMITER //
CREATE TRIGGER liberar_campers_area_inactiva
AFTER UPDATE ON areaSalon
FOR EACH ROW
BEGIN
    -- Si el área pasó a estado inactivo
    IF NEW.estado = 'Inactiva' AND OLD.estado != 'Inactiva' THEN
        -- Marcar como finalizadas las asignaciones de campers
        UPDATE asignacionCamper
        SET fecha_fin = CURDATE()
        WHERE id_area = NEW.id AND fecha_fin IS NULL;
    END IF;
END //
DELIMITER ;

-- 18. Al crear una nueva ruta, clonar la plantilla base de módulos y SGDBs
DELIMITER //
CREATE TRIGGER clonar_plantilla_ruta
AFTER INSERT ON rutaAprendizaje
FOR EACH ROW
BEGIN
    DECLARE v_ruta_base INT;
    
    -- Obtener una ruta base (la más reciente)
    SELECT id INTO v_ruta_base
    FROM rutaAprendizaje
    WHERE id != NEW.id
    ORDER BY fecha_creacion DESC
    LIMIT 1;
    
    -- Si existe una ruta base, clonar sus módulos
    IF v_ruta_base IS NOT NULL THEN
        -- Clonar módulos
        INSERT INTO rutaModulo (id_ruta, id_modulo, orden)
        SELECT NEW.id, id_modulo, orden
        FROM rutaModulo
        WHERE id_ruta = v_ruta_base;
        
        -- Clonar SGBDs asociados
        INSERT INTO bdAsociados (id_ruta, id_sgbd, es_principal)
        SELECT NEW.id, id_sgbd, es_principal
        FROM bdAsociados
        WHERE id_ruta = v_ruta_base;
    END IF;
END //
DELIMITER ;

-- 19. Al registrar la nota práctica, verificar que no supere 60% del total
DELIMITER //
CREATE TRIGGER validar_porcentaje_practica
BEFORE INSERT ON moduloNotas
FOR EACH ROW
BEGIN
    DECLARE v_tipo_evaluacion VARCHAR(50);
    DECLARE v_porcentaje DECIMAL(5,2);
    
    -- Obtener tipo y porcentaje de la evaluación
    SELECT te.nombre, te.porcentaje INTO v_tipo_evaluacion, v_porcentaje
    FROM tipoEvaluacion te
    WHERE te.id = NEW.id_tipo_evaluacion;
    
    -- Si es evaluación práctica y supera el 60%
    IF v_tipo_evaluacion = 'Práctica' AND v_porcentaje > 60 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La evaluación práctica no puede superar el 60% del total';
    END IF;
    
    -- Validar que la nota esté en el rango correcto (0-100)
    IF NEW.nota < 0 OR NEW.nota > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La nota debe estar entre 0 y 100';
    END IF;
END //
DELIMITER ;

-- 20. Al modificar una ruta, notificar cambios a los trainers asignados
DELIMITER //
CREATE TRIGGER notificar_cambios_ruta
AFTER UPDATE ON rutaAprendizaje
FOR EACH ROW
BEGIN
    -- Si hubo cambios en la ruta
    IF NEW.nombre != OLD.nombre OR NEW.descripcion != OLD.descripcion THEN
        -- Registrar el cambio
        INSERT INTO cambiosRuta (id_ruta, descripcion)
        VALUES (NEW.id, CONCAT('Cambios en la ruta: ', NEW.nombre));
        
        -- Notificar a los trainers asignados
        INSERT INTO notificacionesAutomatizadas (id_ruta, id_trainer, mensaje)
        SELECT NEW.id, rt.id_trainer, 
               CONCAT('La ruta "', NEW.nombre, '" ha sido modificada. Por favor revise los cambios.')
        FROM rutaTrainer rt
        WHERE rt.id_ruta = NEW.id
        AND rt.fecha_fin IS NULL;
    END IF;
END //
DELIMITER ;