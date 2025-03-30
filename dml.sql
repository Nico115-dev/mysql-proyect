-- Execute each table's inserts as a separate transaction
-- This helps isolate errors and ensures proper execution

-- 1. sede (base tables with no dependencies)
INSERT INTO sede (nombre, direccion, ciudad, capacidad_total, nit, telefono_principal, email_contacto) VALUES
('Sede Principal', 'Av. Tecnología 456', 'Bucaramanga', 500, '900123456-7', '6017654321', 'principal@campuslands.com'),
('Sede Norte', 'Calle Innovación 789', 'Bogotá', 350, '900123456-8', '6017654322', 'norte@campuslands.com'),
('Campus Central', 'Carrera 27 #30-15', 'Medellín', 400, '900123456-9', '6017654323', 'central@campuslands.com'),
('Centro de Formación', 'Avenida 5 #10-45', 'Cali', 300, '900123457-0', '6017654324', 'cali@campuslands.com'),
('Tech Hub', 'Calle 72 #10-34', 'Barranquilla', 250, '900123457-1', '6017654325', 'barranquilla@campuslands.com'),
('Edificio Innovación', 'Carrera 43 #65-28', 'Pereira', 200, '900123457-2', '6017654326', 'pereira@campuslands.com'),
('Centro Digital', 'Avenida Bolívar #45-12', 'Manizales', 180, '900123457-3', '6017654327', 'manizales@campuslands.com'),
('Campus Oriente', 'Calle 15 #23-56', 'Cúcuta', 220, '900123457-4', '6017654328', 'cucuta@campuslands.com'),
('Sede Caribe', 'Avenida del Mar #10-20', 'Cartagena', 280, '900123457-5', '6017654329', 'cartagena@campuslands.com'),
('Centro Tecnológico', 'Carrera 5 #12-34', 'Ibagué', 190, '900123457-6', '6017654330', 'ibague@campuslands.com');

-- 2. estadoActual
INSERT INTO estadoActual (nombre, descripcion) VALUES
('En proceso de ingreso', 'Camper en proceso de admisión'),
('Inscrito', 'Camper inscrito pero aún no inicia'),
('Aprobado', 'Camper aprobado para iniciar el programa'),
('Cursando', 'Camper actualmente en formación'),
('Graduado', 'Camper que completó exitosamente el programa'),
('Expulsado', 'Camper expulsado por incumplimiento'),
('Retirado', 'Camper que decidió retirarse voluntariamente'),
('En práctica', 'Camper realizando prácticas profesionales'),
('En espera', 'Camper en lista de espera para iniciar'),
('Suspendido', 'Camper temporalmente suspendido');

-- 3. nivelRiesgo
INSERT INTO nivelRiesgo (nivel, descripcion) VALUES
('A', 'Riesgo bajo - Buen rendimiento'),
('B', 'Riesgo medio - Requiere atención'),
('C', 'Riesgo alto - Intervención urgente'),
('A+', 'Rendimiento excepcional - Sin riesgo'),
('A-', 'Rendimiento bueno con pequeñas alertas'),
('B+', 'Riesgo medio-bajo - Seguimiento regular'),
('B-', 'Riesgo medio-alto - Seguimiento frecuente'),
('C+', 'Riesgo alto con potencial de mejora'),
('C-', 'Riesgo crítico - Intervención inmediata'),
('D', 'Riesgo extremo - Evaluación para continuidad');

-- 4. rutaAprendizaje
INSERT INTO rutaAprendizaje (nombre, descripcion, duracion_meses, fecha_creacion) VALUES
('Desarrollo Web Full Stack', 'Formación completa en desarrollo web frontend y backend', 9, '2023-01-15'),
('Desarrollo de Aplicaciones Móviles', 'Especialización en desarrollo de apps para iOS y Android', 7, '2023-02-20'),
('Ciencia de Datos', 'Formación en análisis y procesamiento de datos', 10, '2023-03-10'),
('DevOps y Cloud Computing', 'Especialización en infraestructura y despliegue', 8, '2023-04-05'),
('Desarrollo de Videojuegos', 'Formación en diseño y programación de videojuegos', 11, '2023-05-12'),
('Inteligencia Artificial', 'Especialización en machine learning y deep learning', 12, '2023-06-18'),
('Ciberseguridad', 'Formación en seguridad informática y protección de datos', 9, '2023-07-22'),
('Blockchain y Criptomonedas', 'Especialización en tecnologías blockchain', 8, '2023-08-30'),
('UX/UI Design', 'Formación en diseño de experiencia e interfaz de usuario', 6, '2023-09-15'),
('IoT y Sistemas Embebidos', 'Especialización en Internet de las Cosas', 10, '2023-10-20');

-- 5. sgbd
INSERT INTO sgbd (nombre, version, descripcion) VALUES
('MySQL', '8.0', 'Sistema de gestión de bases de datos relacional'),
('MongoDB', '6.0', 'Base de datos NoSQL orientada a documentos'),
('PostgreSQL', '15.0', 'Sistema de gestión de bases de datos relacional avanzado'),
('SQLite', '3.40', 'Sistema de gestión de bases de datos SQL ligero'),
('Oracle Database', '19c', 'Sistema de gestión de bases de datos empresarial'),
('Microsoft SQL Server', '2022', 'Sistema de gestión de bases de datos de Microsoft'),
('Redis', '7.0', 'Almacén de estructura de datos en memoria'),
('Cassandra', '4.1', 'Base de datos NoSQL distribuida'),
('MariaDB', '10.11', 'Fork de MySQL con licencia GPL'),
('Firebase Firestore', '9.17', 'Base de datos NoSQL en la nube');

-- 6. moduloAprendizaje
INSERT INTO moduloAprendizaje (nombre, descripcion, duracion_semanas, tipo) VALUES
('Introducción a la Algoritmia', 'Fundamentos de lógica y algoritmos', 3, 'Fundamentos'),
('PSeInt', 'Pseudocódigo e introducción a la programación', 2, 'Fundamentos'),
('Python Básico', 'Fundamentos de programación con Python', 4, 'Fundamentos'),
('HTML y CSS', 'Fundamentos de desarrollo web', 3, 'Web'),
('Bootstrap', 'Framework CSS para diseño responsive', 2, 'Web'),
('JavaScript', 'Lenguaje de programación para web', 5, 'Programación'),
('Java', 'Programación orientada a objetos con Java', 6, 'Programación'),
('C#', 'Desarrollo de aplicaciones con C#', 5, 'Programación'),
('MySQL Fundamentals', 'Gestión de bases de datos relacionales', 3, 'Bases de datos'),
('MongoDB Basics', 'Introducción a bases de datos NoSQL', 3, 'Bases de datos');

-- 7. tipoEvaluacion
INSERT INTO tipoEvaluacion (nombre, porcentaje, descripcion) VALUES
('Teórica', 30.00, 'Evaluación de conocimientos teóricos'),
('Práctica', 60.00, 'Evaluación de habilidades prácticas'),
('Trabajos/Quizzes', 10.00, 'Evaluaciones cortas y trabajos asignados'),
('Proyecto Final', 40.00, 'Proyecto integrador de conocimientos'),
('Examen Parcial', 25.00, 'Evaluación intermedia del módulo'),
('Examen Final', 35.00, 'Evaluación final del módulo'),
('Participación', 5.00, 'Participación activa en clases'),
('Trabajo en Equipo', 15.00, 'Evaluación de habilidades colaborativas'),
('Autoevaluación', 5.00, 'Evaluación personal del aprendizaje'),
('Coevaluación', 5.00, 'Evaluación entre compañeros');

-- 8. horarios
INSERT INTO horarios (hora_inicio, hora_fin, descripcion) VALUES
('08:00:00', '12:00:00', 'Jornada mañana'),
('13:00:00', '17:00:00', 'Jornada tarde'),
('18:00:00', '22:00:00', 'Jornada noche'),
('07:30:00', '11:30:00', 'Jornada mañana temprana'),
('12:30:00', '16:30:00', 'Jornada tarde temprana'),
('17:30:00', '21:30:00', 'Jornada noche temprana'),
('09:00:00', '13:00:00', 'Jornada mañana extendida'),
('14:00:00', '18:00:00', 'Jornada tarde extendida'),
('19:00:00', '23:00:00', 'Jornada noche extendida'),
('08:30:00', '12:30:00', 'Jornada mañana alternativa');

-- 9. skills
INSERT INTO skills (nombre, descripcion) VALUES
('JavaScript', 'Programación frontend y backend con JavaScript'),
('Java', 'Desarrollo de aplicaciones empresariales'),
('Python', 'Programación general y análisis de datos'),
('HTML/CSS', 'Maquetación y estilizado web'),
('SQL', 'Gestión de bases de datos relacionales'),
('NoSQL', 'Gestión de bases de datos no relacionales'),
('React', 'Desarrollo de interfaces de usuario'),
('Angular', 'Framework para aplicaciones web'),
('Node.js', 'Entorno de ejecución para JavaScript'),
('Spring', 'Framework Java para desarrollo backend');

-- 10. notificacion
INSERT INTO notificacion (titulo, mensaje, fecha_creacion, tipo, estado) VALUES
('Bienvenida al programa', 'Te damos la bienvenida al programa intensivo de programación de CampusLands.', '2023-01-15 08:00:00', 'Informativa', 'Enviada'),
('Cambio de horario', 'Se ha modificado el horario de clases para el módulo de JavaScript.', '2023-02-01 10:30:00', 'Informativa', 'Enviada'),
('Evaluación próxima', 'Recordatorio: La evaluación práctica de Python será el próximo viernes.', '2023-02-15 09:15:00', 'Alerta', 'Enviada'),
('Taller adicional', 'Se realizará un taller adicional de bases de datos el sábado.', '2023-03-01 14:00:00', 'Informativa', 'Enviada'),
('Problema técnico', 'Estamos experimentando problemas con el servidor de prácticas.', '2023-03-10 11:45:00', 'Urgente', 'Enviada'),
('Actualización de plataforma', 'La plataforma de aprendizaje ha sido actualizada con nuevas funcionalidades.', '2023-03-20 16:30:00', 'Informativa', 'Enviada'),
('Cambio de trainer', 'Se ha asignado un nuevo trainer para el módulo de React.', '2023-04-01 09:00:00', 'Alerta', 'Enviada'),
('Evento especial', 'Invitación al hackathon anual de CampusLands.', '2023-04-15 13:20:00', 'Informativa', 'Enviada'),
('Mantenimiento programado', 'La plataforma estará en mantenimiento el domingo de 00:00 a 06:00.', '2023-05-01 17:45:00', 'Alerta', 'Enviada'),
('Alerta de rendimiento', 'Tu rendimiento en el módulo actual está por debajo del mínimo requerido.', '2023-05-15 10:10:00', 'Urgente', 'Enviada');

-- 11. bdAsociados (tables with foreign key dependencies)
INSERT INTO bdAsociados (id_ruta, id_sgbd, es_principal) VALUES
(1, 1, 1), (1, 3, 0),
(2, 2, 1), (2, 10, 0),
(3, 3, 1), (3, 1, 0),
(4, 1, 1), (4, 2, 0),
(5, 3, 1), (5, 1, 0),
(6, 2, 1), (6, 5, 0),
(7, 1, 1), (7, 5, 0),
(8, 2, 1), (8, 7, 0),
(9, 3, 1), (9, 1, 0),
(10, 1, 1), (10, 2, 0);

-- 12. rutaModulo
INSERT INTO rutaModulo (id_ruta, id_modulo, orden) VALUES
(1, 1, 1), (1, 2, 2), (1, 3, 3), (1, 4, 4), (1, 5, 5),
(2, 1, 1), (2, 3, 2), (2, 6, 3), (2, 4, 4), (2, 7, 5),
(3, 1, 1), (3, 3, 2), (3, 9, 3), (3, 10, 4), (3, 6, 5),
(4, 1, 1), (4, 3, 2), (4, 6, 3), (4, 7, 4), (4, 9, 5),
(5, 1, 1), (5, 3, 2), (5, 6, 3), (5, 8, 4), (5, 9, 5),
(6, 1, 1), (6, 3, 2), (6, 6, 3), (6, 10, 4), (6, 7, 5),
(7, 1, 1), (7, 3, 2), (7, 6, 3), (7, 7, 4), (7, 9, 5),
(8, 1, 1), (8, 3, 2), (8, 6, 3), (8, 10, 4), (8, 7, 5),
(9, 1, 1), (9, 4, 2), (9, 5, 3), (9, 6, 4), (9, 7, 5),
(10, 1, 1), (10, 3, 2), (10, 6, 3), (10, 9, 4), (10, 10, 5);

-- 13. camper
INSERT INTO camper (documento, nombres, apellidos, fecha_nacimiento, email, id_estado, id_nivel_riesgo, fecha_registro, id_sede) VALUES
('1001234567', 'Carlos Andrés', 'Gómez Pérez', '2000-05-15', 'carlos.gomez@email.com', 4, 1, '2023-01-10', 1),
('1002345678', 'María Fernanda', 'López Rodríguez', '1999-08-22', 'maria.lopez@email.com', 4, 2, '2023-01-15', 1),
('1003456789', 'Juan David', 'Martínez Sánchez', '2001-03-10', 'juan.martinez@email.com', 4, 1, '2023-02-01', 2),
('1004567890', 'Ana Sofía', 'Ramírez Torres', '2000-11-05', 'ana.ramirez@email.com', 5, 1, '2022-07-20', 1),
('1005678901', 'Diego Alejandro', 'Hernández Castro', '1998-06-30', 'diego.hernandez@email.com', 6, 3, '2022-08-15', 2),
('1006789012', 'Valentina', 'García Morales', '2002-01-25', 'valentina.garcia@email.com', 4, 2, '2023-03-05', 1),
('1007890123', 'Santiago', 'Díaz Vargas', '1999-12-12', 'santiago.diaz@email.com', 7, 3, '2022-09-10', 3),
('1008901234', 'Camila Andrea', 'Ortiz Jiménez', '2001-07-08', 'camila.ortiz@email.com', 4, 1, '2023-02-20', 2),
('1009012345', 'Sebastián', 'Rojas Medina', '2000-04-18', 'sebastian.rojas@email.com', 4, 2, '2023-01-25', 1),
('1010123456', 'Isabella', 'Mendoza Quintero', '1999-09-27', 'isabella.mendoza@email.com', 5, 1, '2022-06-15', 3);

-- 14. areaSalon
INSERT INTO areaSalon (nombre, capacidad, descripcion, id_sede) VALUES
('Sala Turing', 33, 'Sala principal de formación', 1),
('Sala Jobs', 33, 'Sala de desarrollo web', 1),
('Sala Gates', 33, 'Sala de programación avanzada', 1),
('Sala Hopper', 33, 'Sala de bases de datos', 2),
('Sala Lovelace', 33, 'Sala de desarrollo backend', 2),
('Sala Berners-Lee', 33, 'Sala de desarrollo frontend', 1),
('Sala Torvalds', 33, 'Sala de sistemas operativos', 2),
('Sala Ritchie', 33, 'Sala de lenguajes de programación', 3),
('Sala Gosling', 33, 'Sala de Java y tecnologías relacionadas', 3),
('Sala Knuth', 33, 'Sala de algoritmos avanzados', 1);

-- 15. trainer
INSERT INTO trainer (documento, nombres, apellidos, email, telefono, fecha_contratacion, especialidad, id_sede) VALUES
('80123456', 'Juan Carlos', 'Rodríguez Pérez', 'juan.rodriguez@campuslands.com', '3101234567', '2022-01-10', 'Desarrollo Web', 1),
('81234567', 'María Alejandra', 'Gómez Sánchez', 'maria.gomez@campuslands.com', '3202345678', '2022-02-15', 'Bases de Datos', 1),
('82345678', 'Carlos Andrés', 'López Martínez', 'carlos.lopez@campuslands.com', '3303456789', '2022-03-20', 'Programación Backend', 2),
('83456789', 'Ana María', 'Pérez Ramírez', 'ana.perez@campuslands.com', '3404567890', '2022-04-25', 'Desarrollo Frontend', 2),
('84567890', 'Luis Fernando', 'Martínez Gómez', 'luis.martinez@campuslands.com', '3505678901', '2022-05-30', 'Inteligencia Artificial', 3),
('85678901', 'Patricia', 'Sánchez López', 'patricia.sanchez@campuslands.com', '3606789012', '2022-06-05', 'Desarrollo Móvil', 3),
('86789012', 'Roberto', 'Hernández Pérez', 'roberto.hernandez@campuslands.com', '3707890123', '2022-07-10', 'DevOps', 1),
('87890123', 'Claudia', 'Ramírez Martínez', 'claudia.ramirez@campuslands.com', '3808901234', '2022-08-15', 'Ciberseguridad', 2),
('88901234', 'Jorge', 'Díaz Sánchez', 'jorge.diaz@campuslands.com', '3909012345', '2022-09-20', 'Blockchain', 3),
('89012345', 'Mónica', 'Torres Gómez', 'monica.torres@campuslands.com', '3010123456', '2022-10-25', 'UX/UI Design', 1);

-- 16. datosCamper
INSERT INTO datosCamper (doc_camper, direccion, ciudad, fecha_actualizacion) VALUES
('1001234567', 'Calle 45 #23-67', 'Bucaramanga', '2023-01-10'),
('1002345678', 'Carrera 30 #15-45', 'Bucaramanga', '2023-01-15'),
('1003456789', 'Avenida 68 #78-23', 'Bogotá', '2023-02-01'),
('1004567890', 'Calle 80 #45-12', 'Bucaramanga', '2022-07-20'),
('1005678901', 'Carrera 7 #120-35', 'Bogotá', '2022-08-15'),
('1006789012', 'Avenida Santander #56-78', 'Bucaramanga', '2023-03-05'),
('1007890123', 'Calle 33 #25-40', 'Medellín', '2022-09-10'),
('1008901234', 'Carrera 52 #70-15', 'Bogotá', '2023-02-20'),
('1009012345', 'Avenida Oriental #45-67', 'Bucaramanga', '2023-01-25'),
('1010123456', 'Calle 10 #15-30', 'Medellín', '2022-06-15');

-- 17. telefonos
INSERT INTO telefonos (telefono, tipo, doc_camper) VALUES
('3001234567', 'Móvil', '1001234567'),
('3112345678', 'Móvil', '1002345678'),
('3223456789', 'Móvil', '1003456789'),
('3334567890', 'Móvil', '1004567890'),
('3445678901', 'Móvil', '1005678901'),
('3556789012', 'Móvil', '1006789012'),
('3667890123', 'Móvil', '1007890123'),
('3778901234', 'Móvil', '1008901234'),
('3889012345', 'Móvil', '1009012345'),
('3990123456', 'Móvil', '1010123456');

-- 18. acudiente
INSERT INTO acudiente (doc_acudiente, nombres, apellidos, parentesco, telefono, email, doc_camper) VALUES
('52123456', 'Pedro Antonio', 'Gómez Ramírez', 'Padre', '3101234567', 'pedro.gomez@email.com', '1001234567'),
('53234567', 'Carmen Elena', 'López Sánchez', 'Madre', '3202345678', 'carmen.lopez@email.com', '1002345678'),
('54345678', 'Roberto Carlos', 'Martínez Pérez', 'Padre', '3303456789', 'roberto.martinez@email.com', '1003456789'),
('55456789', 'Luz Marina', 'Ramírez Gómez', 'Madre', '3404567890', 'luz.ramirez@email.com', '1004567890'),
('56567890', 'Jorge Luis', 'Hernández Vargas', 'Padre', '3505678901', 'jorge.hernandez@email.com', '1005678901'),
('57678901', 'María Teresa', 'García López', 'Madre', '3606789012', 'maria.garcia@email.com', '1006789012'),
('58789012', 'Carlos Alberto', 'Díaz Martínez', 'Padre', '3707890123', 'carlos.diaz@email.com', '1007890123'),
('59890123', 'Ana María', 'Ortiz Hernández', 'Madre', '3808901234', 'ana.ortiz@email.com', '1008901234'),
('60901234', 'José Manuel', 'Rojas García', 'Padre', '3909012345', 'jose.rojas@email.com', '1009012345'),
('61012345', 'Patricia', 'Mendoza Díaz', 'Madre', '3010123456', 'patricia.mendoza@email.com', '1010123456');

-- 19. asignacionArea
INSERT INTO asignacionArea (id_area, id_horario, fecha_inicio, fecha_fin) VALUES
(1, 1, '2023-01-15', '2023-04-15'),
(2, 2, '2023-01-15', '2023-04-15'),
(3, 3, '2023-01-15', '2023-04-15'),
(4, 1, '2023-01-15', '2023-04-15'),
(5, 2, '2023-01-15', '2023-04-15'),
(6, 3, '2023-01-15', '2023-04-15'),
(7, 1, '2023-01-15', '2023-04-15'),
(8, 2, '2023-01-15', '2023-04-15'),
(9, 3, '2023-01-15', '2023-04-15'),
(10, 1, '2023-01-15', '2023-04-15');

-- 20. trainerSkills
INSERT INTO trainerSkills (id_trainer, id_skill, nivel) VALUES
(1, 1, 'Experto'), (1, 4, 'Experto'), (1, 7, 'Avanzado'), (1, 9, 'Intermedio'),
(2, 5, 'Experto'), (2, 6, 'Avanzado'), (2, 3, 'Intermedio'), (2, 10, 'Básico'),
(3, 2, 'Experto'), (3, 10, 'Experto'), (3, 5, 'Avanzado'), (3, 1, 'Intermedio'),
(4, 4, 'Experto'), (4, 7, 'Experto'), (4, 1, 'Avanzado'), (4, 8, 'Avanzado'),
(5, 3, 'Experto'), (5, 6, 'Experto'), (5, 6, 'Avanzado'), (5, 10, 'Intermedio'),
(6, 1, 'Experto'), (6, 7, 'Avanzado'), (6, 9, 'Avanzado'), (6, 3, 'Intermedio'),
(7, 2, 'Experto'), (7, 3, 'Experto'), (7, 4, 'Experto'), (7, 9, 'Avanzado'),
(8, 4, 'Experto'), (8, 2, 'Avanzado'), (8, 3, 'Avanzado'), (8, 5, 'Intermedio'),
(9, 1, 'Avanzado'), (9, 6, 'Experto'), (9, 9, 'Avanzado'), (9, 2, 'Intermedio'),
(10, 4, 'Experto'), (10, 7, 'Experto'), (10, 8, 'Avanzado'), (10, 1, 'Avanzado');

-- 21. rutaTrainer
INSERT INTO rutaTrainer (id_trainer, id_ruta, fecha_asignacion, fecha_fin) VALUES
(1, 1, '2023-01-15', '2023-04-15'),
(2, 1, '2023-01-15', '2023-04-15'),
(3, 2, '2023-01-15', '2023-04-15'),
(4, 2, '2023-01-15', '2023-04-15'),
(5, 3, '2023-01-15', '2023-04-15'),
(6, 3, '2023-01-15', '2023-04-15'),
(7, 4, '2023-01-15', '2023-04-15'),
(8, 5, '2023-01-15', '2023-04-15'),
(9, 6, '2023-01-15', '2023-04-15'),
(10, 7, '2023-01-15', '2023-04-15');

-- 22. inscripciones
INSERT INTO inscripciones (doc_camper, id_ruta, fecha_inscripcion, fecha_inicio, fecha_fin_estimada, fecha_fin_real, estado) VALUES
('1001234567', 1, '2023-01-05', '2023-01-15', '2023-10-15', NULL, 'Aprobada'),
('1002345678', 1, '2023-01-05', '2023-01-15', '2023-10-15', NULL, 'Aprobada'),
('1003456789', 2, '2023-01-10', '2023-01-15', '2023-08-15', NULL, 'Aprobada'),
('1004567890', 1, '2022-07-10', '2022-07-20', '2023-04-20', '2023-04-15', 'Completada'),
('1005678901', 2, '2022-08-05', '2022-08-15', '2023-03-15', NULL, 'Cancelada'),
('1006789012', 1, '2023-02-25', '2023-03-05', '2023-12-05', NULL, 'Aprobada'),
('1007890123', 3, '2022-09-01', '2022-09-10', '2023-07-10', NULL, 'Cancelada'),
('1008901234', 2, '2023-02-10', '2023-02-20', '2023-09-20', NULL, 'Aprobada'),
('1009012345', 1, '2023-01-15', '2023-01-25', '2023-10-25', NULL, 'Aprobada'),
('1010123456', 3, '2022-06-05', '2022-06-15', '2023-04-15', '2023-04-10', 'Completada');

-- 23. moduloNotas
INSERT INTO moduloNotas (doc_camper, id_modulo, id_tipo_evaluacion, nota, fecha_evaluacion, observaciones) VALUES
('1001234567', 1, 1, 85.50, '2023-02-10', 'Buen dominio de conceptos básicos'),
('1001234567', 1, 2, 78.30, '2023-02-15', 'Necesita mejorar en implementación de algoritmos'),
('1001234567', 1, 3, 90.00, '2023-02-20', 'Excelente participación en actividades'),
('1002345678', 1, 1, 92.30, '2023-02-10', 'Excelente comprensión de conceptos algorítmicos'),
('1002345678', 1, 2, 88.70, '2023-02-15', 'Buena implementación de soluciones algorítmicas'),
('1002345678', 1, 3, 95.50, '2023-02-20', 'Trabajos destacados y bien presentados'),
('1003456789', 1, 1, 75.40, '2023-02-10', 'Comprensión básica de conceptos'),
('1003456789', 1, 2, 68.20, '2023-02-15', 'Dificultades en implementación práctica'),
('1003456789', 1, 3, 82.00, '2023-02-20', 'Buena participación en clase'),
('1004567890', 1, 1, 88.60, '2022-08-10', 'Buen dominio teórico');

-- 24. horarioTrainer
INSERT INTO horarioTrainer (id_trainer, id_horario, id_area, dia_semana) VALUES
(1, 1, 1, 'Lunes'), (1, 1, 1, 'Miércoles'), (1, 1, 1, 'Viernes'),
(2, 2, 2, 'Lunes'), (2, 2, 2, 'Miércoles'), (2, 2, 2, 'Viernes'),
(3, 3, 3, 'Martes'), (3, 3, 3, 'Jueves'), (3, 3, 3, 'Sábado'),
(4, 1, 4, 'Martes'), (4, 1, 4, 'Jueves'), (4, 1, 4, 'Sábado'),
(5, 2, 5, 'Lunes'), (5, 2, 5, 'Miércoles'), (5, 2, 5, 'Viernes'),
(6, 3, 6, 'Martes'), (6, 3, 6, 'Jueves'), (6, 3, 6, 'Sábado'),
(7, 1, 7, 'Lunes'), (7, 1, 7, 'Miércoles'), (7, 1, 7, 'Viernes'),
(8, 2, 8, 'Martes'), (8, 2, 8, 'Jueves'), (8, 2, 8, 'Sábado'),
(9, 3, 9, 'Lunes'), (9, 3, 9, 'Miércoles'), (9, 3, 9, 'Viernes'),
(10, 1, 10, 'Martes'), (10, 1, 10, 'Jueves'), (10, 1, 10, 'Sábado');

-- 25. asignacionCamper
INSERT INTO asignacionCamper (doc_camper, id_area, id_horario, fecha_inicio, fecha_fin) VALUES
('1001234567', 1, 1, '2023-01-15', '2023-04-15'),
('1002345678', 1, 1, '2023-01-15', '2023-04-15'),
('1003456789', 3, 3, '2023-01-15', '2023-04-15'),
('1004567890', 2, 2, '2022-07-20', '2022-10-20'),
('1005678901', 3, 3, '2022-08-15', '2022-11-15'),
('1006789012', 1, 1, '2023-03-05', '2023-06-05'),
('1007890123', 5, 2, '2022-09-10', '2022-12-10'),
('1008901234', 3, 3, '2023-02-20', '2023-05-20'),
('1009012345', 2, 2, '2023-01-25', '2023-04-25'),
('1010123456', 5, 2, '2022-06-15', '2022-09-15');

-- 26. notificacionDestinatario
INSERT INTO notificacionDestinatario (id_notificacion, doc_camper, id_trainer, fecha_lectura) VALUES
(1, '1001234567', NULL, '2023-01-15 09:30:00'),
(1, '1002345678', NULL, '2023-01-15 10:15:00'),
(1, '1003456789', NULL, '2023-01-15 11:45:00'),
(2, NULL, 1, '2023-02-01 11:00:00'),
(2, NULL, 2, '2023-02-01 11:30:00'),
(3, '1001234567', NULL, '2023-02-15 10:00:00'),
(3, '1002345678', NULL, '2023-02-15 10:30:00'),
(3, '1006789012', NULL, '2023-02-15 11:15:00'),
(4, NULL, 3, '2023-03-01 14:30:00'),
(4, NULL, 4, '2023-03-01 15:00:00');

-- 27. asistencia
INSERT INTO asistencia (doc_camper, fecha, estado, observaciones) VALUES
('1001234567', '2023-01-16', 'Presente', 'Participación activa'),
('1002345678', '2023-01-16', 'Presente', 'Participación activa'),
('1003456789', '2023-01-16', 'Presente', 'Llegó 5 minutos tarde'),
('1001234567', '2023-01-17', 'Presente', 'Participación activa'),
('1002345678', '2023-01-17', 'Ausente', 'No justificó'),
('1003456789', '2023-01-17', 'Presente', 'Participación activa'),
('1001234567', '2023-01-18', 'Presente', 'Participación activa'),
('1002345678', '2023-01-18', 'Presente', 'Participación activa'),
('1003456789', '2023-01-18', 'Tardanza', 'Llegó 15 minutos tarde'),
('1001234567', '2023-01-19', 'Presente', 'Participación activa');

-- 28. seguimientoRendimiento
INSERT INTO seguimientoRendimiento (doc_camper, id_modulo, semana, observaciones, recomendaciones, fecha_registro, id_trainer) VALUES
('1001234567', 1, 1, 'Buen desempeño en conceptos básicos', 'Practicar más ejercicios de lógica', '2023-01-22', 1),
('1002345678', 1, 1, 'Excelente comprensión de algoritmos', 'Continuar con el mismo ritmo de estudio', '2023-01-22', 1),
('1003456789', 1, 1, 'Dificultades con algoritmos complejos', 'Dedicar más tiempo a ejercicios prácticos', '2023-01-22', 3),
('1001234567', 1, 2, 'Mejora en implementación de algoritmos', 'Revisar conceptos de eficiencia algorítmica', '2023-01-29', 1),
('1002345678', 1, 2, 'Mantiene buen rendimiento', 'Explorar algoritmos avanzados', '2023-01-29', 1),
('1003456789', 1, 2, 'Progreso lento pero constante', 'Sesiones adicionales de tutoría', '2023-01-29', 3),
('1001234567', 1, 3, 'Dominio de conceptos fundamentales', 'Prepararse para evaluación final del módulo', '2023-02-05', 1),
('1002345678', 1, 3, 'Rendimiento sobresaliente', 'Ayudar a compañeros con dificultades', '2023-02-05', 1),
('1003456789', 1, 3, 'Mejora significativa', 'Continuar con práctica diaria', '2023-02-05', 3),
('1004567890', 1, 1, 'Buen nivel de comprensión inicial', 'Profundizar en estructuras de datos', '2022-07-25', 2);