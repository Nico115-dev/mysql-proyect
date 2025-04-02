-- 1. Calcular el promedio ponderado de evaluaciones de un camper.
DELIMITER $$

CREATE FUNCTION calcularPromedioPonderado(doc_camper VARCHAR(11), id_modulo INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2) DEFAULT 0;
    DECLARE nota_teorica DECIMAL(5,2);
    DECLARE nota_practica DECIMAL(5,2);
    DECLARE nota_quizzes DECIMAL(5,2);
    DECLARE porcentaje_teorico DECIMAL(5,2);
    DECLARE porcentaje_practico DECIMAL(5,2);
    DECLARE porcentaje_quizzes DECIMAL(5,2);

    -- Obtener las notas de cada tipo de evaluación
    SELECT nota 
    INTO nota_teorica
    FROM skillsNotas
    WHERE doc_camper = doc_camper
    AND id_modulo = id_modulo
    AND id_tipo_evaluacion = (SELECT id FROM tipoEvaluacion WHERE nombre = 'Examen Teórico')
    LIMIT 1;

    SELECT nota 
    INTO nota_practica
    FROM skillsNotas
    WHERE doc_camper = doc_camper
    AND id_modulo = id_modulo
    AND id_tipo_evaluacion = (SELECT id FROM tipoEvaluacion WHERE nombre = 'Evaluación Práctica')
    LIMIT 1;

    SELECT nota 
    INTO nota_quizzes
    FROM skillsNotas
    WHERE doc_camper = doc_camper
    AND id_modulo = id_modulo
    AND id_tipo_evaluacion = (SELECT id FROM tipoEvaluacion WHERE nombre = 'Quiz')
    LIMIT 1;

    -- Obtener los porcentajes de las evaluaciones
    SELECT porcentaje
    INTO porcentaje_teorico
    FROM tipoEvaluacion
    WHERE nombre = 'Examen Teórico';

    SELECT porcentaje
    INTO porcentaje_practico
    FROM tipoEvaluacion
    WHERE nombre = 'Evaluación Práctica';

    SELECT porcentaje
    INTO porcentaje_quizzes
    FROM tipoEvaluacion
    WHERE nombre = 'Quiz';

    -- Calcular el promedio ponderado
    SET promedio = (nota_teorica * porcentaje_teorico / 100) + 
                   (nota_practica * porcentaje_practico / 100) + 
                   (nota_quizzes * porcentaje_quizzes / 100);

    RETURN promedio;
END$$

DELIMITER ;

-- 2. Determinar si un camper aprueba o no un módulo específico.
DELIMITER $$

CREATE FUNCTION aprobarModulo(doc_camper VARCHAR(11), id_modulo INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);
    DECLARE umbral_aprobacion DECIMAL(5,2) DEFAULT 60.00; -- Umbral de aprobación (60%)

    -- Llamar a la función calcularPromedioPonderado para obtener el promedio del camper en el módulo
    SET promedio = calcularPromedioPonderado(doc_camper, id_modulo);

    -- Comparar el promedio con el umbral de aprobación
    IF promedio >= umbral_aprobacion THEN
        RETURN 'Aprobado';
    ELSE
        RETURN 'Reprobado';
    END IF;
END$$

DELIMITER ;

-- 3. Evaluar el nivel de riesgo de un camper según su rendimiento promedio.
DELIMITER $$

CREATE FUNCTION evaluarRiesgoCamper(doc_camper VARCHAR(11), id_modulo INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);
    DECLARE nivel_riesgo VARCHAR(50);

    -- Llamar a la función calcularPromedioPonderado para obtener el promedio del camper en el módulo
    SET promedio = calcularPromedioPonderado(doc_camper, id_modulo);

    -- Evaluar el nivel de riesgo según el promedio
    IF promedio >= 80 THEN
        SET nivel_riesgo = 'Bajo riesgo';
    ELSEIF promedio >= 60 THEN
        SET nivel_riesgo = 'Riesgo medio';
    ELSE
        SET nivel_riesgo = 'Alto riesgo';
    END IF;

    -- Devolver el nivel de riesgo
    RETURN nivel_riesgo;
END$$

DELIMITER ;

-- 4. Obtener el total de campers asignados a una ruta específica.
DELIMITER $$

CREATE FUNCTION obtenerTotalCampersPorRuta(id_ruta INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_camper INT;
    
    SELECT COUNT(doc_camper) 
    INTO total_camper
    FROM inscripciones
    WHERE id_ruta = id_ruta
    AND estado = 'Aprobada';
    
    RETURN total_camper;
END$$

DELIMITER ;

-- 5. Consultar la cantidad de módulos que ha aprobado un camper.
DELIMITER $$

CREATE FUNCTION obtenerCantidadModulosAprobados(doc_camper VARCHAR(11)) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_modulos_aprobados INT;
    
    SELECT COUNT(*) 
    INTO total_modulos_aprobados
    FROM campersModulosAsignados
    WHERE doc_camper = doc_camper
    AND estado = 'Aprobado';
    
    RETURN total_modulos_aprobados;
END$$

DELIMITER ;

-- 6. Validar si hay cupos disponibles en una determinada área.
DELIMITER $$

CREATE FUNCTION validarCuposDisponibles(id_area INT) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE cupos_disponibles BOOLEAN;
    DECLARE capacidad_area INT;
    DECLARE total_camper_asignados INT;
    
    -- Obtener la capacidad máxima del área
    SELECT capacidad INTO capacidad_area
    FROM areaSalon
    WHERE id = id_area;
    
    -- Obtener el total de campers asignados a esa área
    SELECT COUNT(*) INTO total_camper_asignados
    FROM asignacionCamper
    WHERE id_area = id_area AND fecha_fin IS NULL;
    
    -- Validar si hay cupos disponibles
    IF total_camper_asignados < capacidad_area THEN
        SET cupos_disponibles = TRUE;
    ELSE
        SET cupos_disponibles = FALSE;
    END IF;
    
    RETURN cupos_disponibles;
END$$

DELIMITER ;

-- 7. Calcular el porcentaje de ocupación de un área de entrenamiento.
DELIMITER $$

CREATE FUNCTION calcularPorcentajeOcupacion(id_area INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE porcentaje_ocupacion DECIMAL(5,2);
    DECLARE capacidad_area INT;
    DECLARE total_camper_asignados INT;
    
    -- Obtener la capacidad máxima del área
    SELECT capacidad INTO capacidad_area
    FROM areaSalon
    WHERE id = id_area;
    
    -- Obtener el total de campers asignados a esa área
    SELECT COUNT(*) INTO total_camper_asignados
    FROM asignacionCamper
    WHERE id_area = id_area AND fecha_fin IS NULL;
    
    -- Calcular el porcentaje de ocupación
    IF capacidad_area > 0 THEN
        SET porcentaje_ocupacion = (total_camper_asignados / capacidad_area) * 100;
    ELSE
        SET porcentaje_ocupacion = 0; -- En caso de que la capacidad sea 0 o no exista el área
    END IF;
    
    RETURN porcentaje_ocupacion;
END$$

DELIMITER ;

-- 8. Determinar la nota más alta obtenida en un módulo.
DELIMITER $$

CREATE FUNCTION obtenerNotaMasAlta(id_modulo INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE nota_maxima DECIMAL(5,2);
    
    -- Obtener la nota más alta en el módulo especificado
    SELECT MAX(nota) INTO nota_maxima
    FROM skillsNotas
    WHERE id_modulo = id_modulo;
    
    -- Si no hay notas, retornamos 0
    IF nota_maxima IS NULL THEN
        SET nota_maxima = 0;
    END IF;
    
    RETURN nota_maxima;
END$$

DELIMITER ;

-- 9. Calcular la tasa de aprobación de una ruta.
DELIMITER $$

CREATE FUNCTION calcularTasaAprobacion(id_ruta INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE total_aprobados INT;
    DECLARE total_inscritos INT;
    DECLARE tasa_aprobacion DECIMAL(5,2);

    -- Obtener el total de campers aprobados en la ruta
    SELECT COUNT(*) INTO total_aprobados
    FROM inscripciones i
    JOIN campersModulosAsignados cma ON i.doc_camper = cma.doc_camper
    WHERE i.id_ruta = id_ruta AND cma.estado = 'Aprobado';

    -- Obtener el total de campers inscritos en la ruta
    SELECT COUNT(*) INTO total_inscritos
    FROM inscripciones
    WHERE id_ruta = id_ruta AND estado = 'Completada';

    -- Calcular la tasa de aprobación, si no hay inscritos, retornamos 0
    IF total_inscritos > 0 THEN
        SET tasa_aprobacion = (total_aprobados / total_inscritos) * 100;
    ELSE
        SET tasa_aprobacion = 0;
    END IF;

    RETURN tasa_aprobacion;
END$$

DELIMITER ;

-- 10. Verificar si un trainer tiene horario disponible.
DELIMITER $$

CREATE FUNCTION verificarHorarioDisponible(id_trainer INT, id_area INT, dia_semana ENUM('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE horario_disponible BOOLEAN;

    -- Verificamos si el trainer tiene un horario asignado para el día y área especificados
    SELECT COUNT(*)
    INTO horario_disponible
    FROM horarioTrainer ht
    WHERE ht.id_trainer = id_trainer
      AND ht.id_area = id_area
      AND ht.dia_semana = dia_semana;

    -- Si hay un horario asignado, retornamos FALSE (no disponible), de lo contrario, TRUE (disponible)
    IF horario_disponible > 0 THEN
        RETURN FALSE;  -- No disponible
    ELSE
        RETURN TRUE;   -- Disponible
    END IF;
END$$

DELIMITER ;

-- 11. Obtener el promedio de notas por ruta.
DELIMITER $$

CREATE FUNCTION promedioNotasPorRuta(id_ruta INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);

    -- Calculamos el promedio de las notas finales de todos los campers inscritos en la ruta
    SELECT AVG(nf.nota_final)
    INTO promedio
    FROM notaFinal nf
    JOIN campersModulosAsignados cma ON cma.id_modulo = nf.id_modulo
    JOIN inscripciones i ON i.doc_camper = cma.doc_camper
    WHERE i.id_ruta = id_ruta AND nf.nota_final > 0;

    -- Si no hay notas registradas para esa ruta, devolvemos 0
    IF promedio IS NULL THEN
        SET promedio = 0;
    END IF;

    RETURN promedio;
END$$

DELIMITER ;

-- 12. Calcular cuántas rutas tiene asignadas un trainer.
DELIMITER $$

CREATE FUNCTION contarRutasPorTrainer(id_trainer INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE cantidad INT;

    -- Contamos cuántas rutas están asignadas al trainer
    SELECT COUNT(*) INTO cantidad
    FROM rutaTrainer
    WHERE id_trainer = id_trainer;

    RETURN cantidad;
END$$

DELIMITER ;

-- 13. Verificar si un camper puede ser graduado.
DELIMITER $$

CREATE FUNCTION verificarGraduacion(doc_camper VARCHAR(11))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE aprobado INT;
    DECLARE total_modulos INT;

    -- Contamos la cantidad total de módulos asignados al camper
    SELECT COUNT(*) INTO total_modulos
    FROM campersModulosAsignados
    WHERE doc_camper = doc_camper;

    -- Contamos la cantidad de módulos que ha aprobado el camper
    SELECT COUNT(*) INTO aprobado
    FROM campersModulosAsignados
    WHERE doc_camper = doc_camper AND estado = 'Aprobado';

    -- Si el número de módulos aprobados es igual al total de módulos asignados, el camper puede ser graduado
    IF aprobado = total_modulos THEN
        RETURN TRUE;  -- El camper puede ser graduado
    ELSE
        RETURN FALSE; -- El camper no puede ser graduado
    END IF;
END$$

DELIMITER ;

-- 14. Obtener el estado actual de un camper en función de sus evaluaciones.
DELIMITER $$

CREATE FUNCTION obtenerEstadoCamper(doc_camper VARCHAR(11))
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);
    DECLARE total_modulos INT;
    DECLARE modulos_completados INT;
    DECLARE estado_final VARCHAR(50);

    -- Calculamos el promedio ponderado de las evaluaciones del camper
    SELECT AVG(nota) INTO promedio
    FROM skillsNotas
    WHERE doc_camper = doc_camper;

    -- Contamos cuántos módulos tiene asignados el camper
    SELECT COUNT(*) INTO total_modulos
    FROM campersModulosAsignados
    WHERE doc_camper = doc_camper;

    -- Contamos cuántos módulos ha completado (estado Aprobado o Reprobado)
    SELECT COUNT(*) INTO modulos_completados
    FROM campersModulosAsignados
    WHERE doc_camper = doc_camper AND estado IN ('Aprobado', 'Reprobado');

    -- Determinamos el estado final del camper
    IF modulos_completados = total_modulos THEN
        IF promedio >= 6.00 THEN  -- Consideramos 6.00 como el mínimo para aprobar
            SET estado_final = 'Aprobado';
        ELSE
            SET estado_final = 'Reprobado';
        END IF;
    ELSE
        SET estado_final = 'En curso';  -- El camper todavía tiene módulos por completar
    END IF;

    RETURN estado_final;
END$$

DELIMITER ;

-- 15. Calcular la carga horaria semanal de un trainer.
DELIMITER $$

CREATE FUNCTION calcularCargaHorariaSemanal(id_trainer INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE carga_horaria INT DEFAULT 0;
    DECLARE horas INT;

    -- Recorremos los horarios asignados al trainer para calcular su carga horaria semanal
    DECLARE horario_cursor CURSOR FOR
        SELECT h.hora_inicio, h.hora_fin
        FROM horarioTrainer ht
        JOIN horarios h ON ht.id_horario = h.id
        WHERE ht.id_trainer = id_trainer;

    -- Variables para el cursor
    OPEN horario_cursor;
    FETCH horario_cursor INTO horas_inicio, horas_fin;

    -- Mientras haya horarios asignados, calculamos la carga horaria
    WHILE (FOUND) DO
        SET carga_horaria = carga_horaria + TIMESTAMPDIFF(HOUR, horas_inicio, horas_fin);
        FETCH horario_cursor INTO horas_inicio, horas_fin;
    END WHILE;

    -- Cerramos el cursor
    CLOSE horario_cursor;

    RETURN carga_horaria;
END$$

DELIMITER ;

-- 16. Determinar si una ruta tiene módulos pendientes por evaluación.
DELIMITER $$

CREATE FUNCTION tieneModulosPendientes(id_ruta INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE resultado BOOLEAN DEFAULT FALSE;

    -- Verificar si hay algún módulo pendiente de evaluación en la ruta especificada
    IF EXISTS (
        SELECT 1
        FROM rutaModulo rm
        JOIN campersModulosAsignados cma ON rm.id_modulo = cma.id_modulo
        WHERE rm.id_ruta = id_ruta
        AND cma.estado = 'Pendiente'
    ) THEN
        SET resultado = TRUE;
    ELSE
        SET resultado = FALSE;
    END IF;

    RETURN resultado;
END$$

DELIMITER ;

-- 17. Calcular el promedio general del programa.
DELIMITER $$

CREATE FUNCTION promedioGeneralPrograma()
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);

    -- Calcular el promedio de todas las notas finales
    SELECT AVG(nota_final)
    INTO promedio
    FROM notaFinal
    WHERE aprobado = TRUE;

    -- Retornar el promedio calculado
    RETURN promedio;
END$$

DELIMITER ;


-- 18. Verificar si un horario choca con otros entrenadores en el área.
DELIMITER $$

CREATE FUNCTION verificarHorarioChoca(
    p_id_trainer INT, 
    p_id_area INT, 
    p_id_horario INT
)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE horario_choca BOOLEAN DEFAULT FALSE;

    -- Verificamos si el horario del nuevo entrenador choca con otros entrenadores en el área especificada
    SELECT COUNT(*) > 0
    INTO horario_choca
    FROM horarioTrainer ht1
    JOIN horarios h1 ON ht1.id_horario = h1.id
    WHERE ht1.id_area = p_id_area
    AND ht1.id_trainer != p_id_trainer
    AND (
        (h1.hora_inicio < (SELECT hora_fin FROM horarios WHERE id = p_id_horario) 
         AND h1.hora_fin > (SELECT hora_inicio FROM horarios WHERE id = p_id_horario))
    );

    -- Retornar TRUE si el horario choca, FALSE si no
    RETURN horario_choca;
END$$

DELIMITER ;

-- 19. Calcular cuántos campers están en riesgo en una ruta específica.
DELIMITER $$

CREATE FUNCTION calcularCampersEnRiesgoRuta(p_id_ruta INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_en_riesgo INT;

    -- Contamos cuántos campers asignados a la ruta tienen un nivel de riesgo
    SELECT COUNT(*)
    INTO total_en_riesgo
    FROM camper c
    JOIN inscripciones i ON c.documento = i.doc_camper
    JOIN nivelRiesgo nr ON c.id_nivel_riesgo = nr.id
    WHERE i.id_ruta = p_id_ruta
    AND nr.nivel = 'Alto';  -- Suponemos que 'Alto' es el nivel de riesgo alto

    RETURN total_en_riesgo;
END$$

DELIMITER ;

-- 20. Consultar el número de módulos evaluados por un camper.
DELIMITER $$

CREATE FUNCTION consultarModulosEvaluadosCamper(p_doc_camper VARCHAR(11))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_modulos_evaluados INT;

    -- Contamos cuántos módulos han sido evaluados para el camper
    SELECT COUNT(DISTINCT id_modulo)
    INTO total_modulos_evaluados
    FROM skillsNotas
    WHERE doc_camper = p_doc_camper;

    RETURN total_modulos_evaluados;
END$$

DELIMITER ;
