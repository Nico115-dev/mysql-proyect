INSERT INTO estadoActual (nombre, descripcion) VALUES 
('Inscrito', 'Camper que ha completado el proceso de inscripción'),
('En proceso', 'Camper que está cursando actualmente'),
('Egresado', 'Camper que ha completado satisfactoriamente su formación'),
('Retirado', 'Camper que abandonó el programa'),
('En espera', 'Camper en lista de espera para iniciar'),
('Suspendido', 'Camper temporalmente suspendido'),
('Aplazado', 'Camper que ha aplazado su formación'),
('Expulsado', 'Camper expulsado por incumplimiento de normas'),
('Pre-inscrito', 'Camper que ha iniciado el proceso de inscripción'),
('Graduado', 'Camper que ha recibido su certificación oficial');

INSERT INTO nivelRiesgo (nivel, descripcion) VALUES 
('A', 'Riesgo bajo - Excelente rendimiento'),
('B', 'Riesgo moderado bajo - Buen rendimiento'),
('C', 'Riesgo moderado - Rendimiento aceptable'),
('D', 'Riesgo moderado alto - Rendimiento por debajo del promedio'),
('E', 'Riesgo alto - Rendimiento deficiente'),
('F', 'Riesgo muy alto - En peligro de expulsión'),
('G', 'Seguimiento especial - Casos particulares'),
('H', 'Riesgo académico - Problemas con evaluaciones'),
('I', 'Riesgo asistencia - Problemas de asistencia'),
('J', 'Riesgo actitudinal - Problemas de comportamiento');

INSERT INTO rutaAprendizaje (nombre, descripcion, duracion_meses, fecha_creacion) VALUES 
('Desarrollo Web Full Stack', 'Formación completa en desarrollo web frontend y backend', 12, '2023-01-15'),
('Desarrollo Backend Java', 'Especialización en desarrollo backend con Java y Spring', 9, '2023-02-20'),
('Desarrollo Frontend React', 'Especialización en desarrollo frontend con React', 6, '2023-03-10'),
('Ciencia de Datos', 'Formación en análisis y ciencia de datos', 10, '2023-04-05'),
('DevOps', 'Formación en metodologías y herramientas DevOps', 8, '2023-05-12'),
('Desarrollo Móvil', 'Formación en desarrollo de aplicaciones móviles', 9, '2023-06-18'),
('Inteligencia Artificial', 'Formación en IA y machine learning', 12, '2023-07-22'),
('Ciberseguridad', 'Formación en seguridad informática', 10, '2023-08-30'),
('Blockchain', 'Formación en tecnologías blockchain', 8, '2023-09-15'),
('UX/UI Design', 'Formación en diseño de experiencia e interfaz de usuario', 7, '2023-10-20');


INSERT INTO sgbd (nombre, version, descripcion) VALUES 
('MySQL', '8.0', 'Sistema de gestión de bases de datos relacional de código abierto'),
('PostgreSQL', '14.0', 'Sistema de gestión de bases de datos relacional orientado a objetos'),
('MongoDB', '5.0', 'Sistema de gestión de bases de datos NoSQL orientado a documentos'),
('SQLite', '3.36', 'Sistema de gestión de bases de datos SQL ligero'),
('Oracle', '19c', 'Sistema de gestión de bases de datos relacional comercial'),
('SQL Server', '2019', 'Sistema de gestión de bases de datos relacional de Microsoft'),
('MariaDB', '10.6', 'Fork de MySQL de código abierto'),
('Redis', '6.2', 'Almacén de estructura de datos en memoria'),
('Cassandra', '4.0', 'Base de datos NoSQL distribuida'),
('Firebase', '9.0', 'Plataforma de desarrollo de aplicaciones móviles y web');


INSERT INTO moduloAprendizaje (nombre, descripcion, duracion_semanas, tipo) VALUES 
('Fundamentos de Programación', 'Conceptos básicos de programación y lógica', 4, 'Fundamentos'),
('HTML y CSS', 'Fundamentos de desarrollo web con HTML y CSS', 3, 'Web'),
('JavaScript Básico', 'Introducción a JavaScript y programación web', 4, 'Programación'),
('Bases de Datos Relacionales', 'Fundamentos de bases de datos SQL', 3, 'Bases de datos'),
('Node.js', 'Desarrollo backend con Node.js', 5, 'Backend'),
('React Fundamentals', 'Desarrollo frontend con React', 4, 'Web'),
('Python Básico', 'Introducción a la programación con Python', 3, 'Programación'),
('API REST', 'Diseño e implementación de APIs REST', 3, 'Backend'),
('MongoDB', 'Bases de datos NoSQL con MongoDB', 2, 'Bases de datos'),
('Git y Control de Versiones', 'Gestión de código fuente con Git', 2, 'Fundamentos');

INSERT INTO tipoEvaluacion (nombre, porcentaje, descripcion) VALUES 
('Quiz', 10.00, 'Evaluación rápida de conocimientos'),
('Examen Teórico', 20.00, 'Evaluación completa de conocimientos teóricos'),
('Proyecto Práctico', 30.00, 'Desarrollo de proyecto aplicando conocimientos'),
('Exposición', 15.00, 'Presentación oral de un tema específico'),
('Trabajo en Equipo', 15.00, 'Evaluación de habilidades de trabajo colaborativo'),
('Autoevaluación', 5.00, 'Evaluación personal del aprendizaje'),
('Coevaluación', 5.00, 'Evaluación entre pares'),
('Examen Final', 25.00, 'Evaluación final del módulo'),
('Participación', 10.00, 'Evaluación de la participación activa'),
('Reto Técnico', 35.00, 'Desafío técnico para evaluar habilidades específicas');

INSERT INTO horarios (hora_inicio, hora_fin, descripcion) VALUES 
('07:00:00', '12:00:00', 'Jornada mañana'),
('13:00:00', '18:00:00', 'Jornada tarde'),
('18:00:00', '22:00:00', 'Jornada noche'),
('08:00:00', '13:00:00', 'Jornada mañana extendida'),
('14:00:00', '19:00:00', 'Jornada tarde extendida'),
('07:30:00', '12:30:00', 'Jornada mañana alternativa'),
('13:30:00', '18:30:00', 'Jornada tarde alternativa'),
('09:00:00', '12:00:00', 'Media jornada mañana'),
('14:00:00', '17:00:00', 'Media jornada tarde'),
('08:00:00', '17:00:00', 'Jornada completa');

INSERT INTO skills (nombre, descripcion) VALUES 
('JavaScript', 'Lenguaje de programación para desarrollo web'),
('HTML', 'Lenguaje de marcado para páginas web'),
('CSS', 'Lenguaje de estilos para páginas web'),
('Python', 'Lenguaje de programación multipropósito'),
('Java', 'Lenguaje de programación orientado a objetos'),
('SQL', 'Lenguaje para gestión de bases de datos relacionales'),
('React', 'Biblioteca JavaScript para interfaces de usuario'),
('Node.js', 'Entorno de ejecución para JavaScript'),
('Git', 'Sistema de control de versiones'),
('MongoDB', 'Base de datos NoSQL orientada a documentos');

INSERT INTO skillModulo (id_skill, id_modulo, orden) VALUES 
(1, 3, 1),
(2, 2, 1),
(3, 2, 2),
(4, 7, 1),
(6, 4, 1),
(7, 6, 1),
(8, 5, 1),
(9, 10, 1),
(10, 9, 1),
(1, 6, 2);

INSERT INTO sesionTrabajo (id_modulo, nombre, descripcion, duracion_horas, orden) VALUES 
(1, 'Introducción a la Programación', 'Conceptos básicos y lógica de programación', 4, 1),
(1, 'Variables y Tipos de Datos', 'Manejo de variables y tipos de datos', 4, 2),
(2, 'Estructura HTML', 'Elementos básicos de HTML', 3, 1),
(2, 'Estilos CSS', 'Aplicación de estilos con CSS', 3, 2),
(3, 'Sintaxis JavaScript', 'Fundamentos de la sintaxis de JavaScript', 4, 1),
(4, 'Modelo Relacional', 'Conceptos del modelo relacional', 3, 1),
(5, 'Introducción a Node.js', 'Fundamentos de Node.js', 4, 1),
(6, 'Componentes en React', 'Creación de componentes en React', 4, 1),
(7, 'Sintaxis Python', 'Fundamentos de la sintaxis de Python', 3, 1),
(8, 'Diseño de APIs', 'Principios de diseño de APIs REST', 3, 1);

INSERT INTO notificacion (titulo, mensaje, tipo, estado) VALUES 
('Bienvenida al Campus', 'Bienvenido a Campuslands, estamos felices de tenerte con nosotros', 'Informativa', 'Enviada'),
('Cambio de Horario', 'Se ha modificado el horario de clases para el próximo mes', 'Informativa', 'Enviada'),
('Evaluación Pendiente', 'Tienes una evaluación pendiente para mañana', 'Alerta', 'Pendiente'),
('Mantenimiento Plataforma', 'La plataforma estará en mantenimiento este fin de semana', 'Informativa', 'Enviada'),
('Entrega de Proyecto', 'La fecha límite para la entrega del proyecto es el viernes', 'Alerta', 'Enviada'),
('Reunión Urgente', 'Se convoca a reunión urgente mañana a las 10:00', 'Urgente', 'Pendiente'),
('Nuevo Recurso Disponible', 'Se ha añadido nuevo material de estudio a la plataforma', 'Informativa', 'Enviada'),
('Cambio de Trainer', 'Se ha asignado un nuevo trainer para el módulo actual', 'Informativa', 'Pendiente'),
('Problema Técnico', 'Estamos experimentando problemas técnicos en la plataforma', 'Alerta', 'Enviada'),
('Felicitaciones', 'Felicitaciones por completar el módulo con excelentes calificaciones', 'Informativa', 'Enviada');

INSERT INTO sede (nombre, direccion, ciudad, capacidad_total, nit, telefono_principal, email_contacto) VALUES 
('Campus Central', 'Calle 123 #45-67', 'Bucaramanga', 500, '900123456-7', '6017654321', 'central@campuslands.com'),
('Campus Norte', 'Avenida 89 #12-34', 'Bogotá', 350, '900123456-8', '6017654322', 'norte@campuslands.com'),
('Campus Sur', 'Carrera 56 #78-90', 'Medellín', 300, '900123456-9', '6017654323', 'sur@campuslands.com'),
('Campus Este', 'Diagonal 12 #34-56', 'Cali', 250, '900123457-0', '6017654324', 'este@campuslands.com'),
('Campus Oeste', 'Transversal 78 #90-12', 'Barranquilla', 200, '900123457-1', '6017654325', 'oeste@campuslands.com'),
('Campus Virtual', 'En línea', 'Nacional', 1000, '900123457-2', '6017654326', 'virtual@campuslands.com'),
('Campus Empresarial', 'Calle 45 #67-89', 'Bucaramanga', 150, '900123457-3', '6017654327', 'empresarial@campuslands.com'),
('Campus Tecnológico', 'Avenida 23 #45-67', 'Bogotá', 300, '900123457-4', '6017654328', 'tecnologico@campuslands.com'),
('Campus Innovación', 'Carrera 78 #90-12', 'Medellín', 200, '900123457-5', '6017654329', 'innovacion@campuslands.com'),
('Campus Internacional', 'Calle 34 #56-78', 'Cali', 180, '900123457-6', '6017654330', 'internacional@campuslands.com');

INSERT INTO bdAsociados (id_ruta, id_sgbd, es_principal) VALUES 
(1, 1, TRUE),
(1, 2, FALSE),
(2, 5, TRUE),
(3, 1, TRUE),
(4, 3, TRUE),
(5, 2, TRUE),
(6, 1, TRUE),
(7, 3, TRUE),
(8, 6, TRUE),
(9, 3, FALSE);

INSERT INTO rutaModulo (id_ruta, id_modulo, orden) VALUES 
(1, 1, 1),
(1, 2, 2),
(1, 3, 3),
(1, 4, 4),
(2, 1, 1),
(2, 4, 2),
(2, 5, 3),
(3, 1, 1),
(3, 2, 2),
(3, 6, 3);

INSERT INTO camper (documento, nombres, apellidos, fecha_nacimiento, email, id_estado, id_nivel_riesgo, fecha_registro, id_sede) VALUES 
('1001234567', 'Juan Carlos', 'Pérez Gómez', '2000-05-15', 'juan.perez@example.com', 1, 1, '2023-01-10', 1),
('1001234568', 'María Fernanda', 'López Rodríguez', '2001-07-20', 'maria.lopez@example.com', 1, 2, '2023-01-12', 1),
('1001234569', 'Carlos Andrés', 'Martínez Vargas', '1999-03-25', 'carlos.martinez@example.com', 2, 1, '2023-01-15', 2),
('1001234570', 'Ana María', 'García Sánchez', '2002-11-10', 'ana.garcia@example.com', 2, 3, '2023-01-18', 2),
('1001234571', 'Luis Felipe', 'Hernández Torres', '2000-09-05', 'luis.hernandez@example.com', 1, 2, '2023-01-20', 3),
('1001234572', 'Laura Valentina', 'Díaz Castro', '2001-04-30', 'laura.diaz@example.com', 3, 1, '2023-01-22', 3),
('1001234573', 'Andrés Felipe', 'Ramírez Moreno', '1999-12-15', 'andres.ramirez@example.com', 2, 4, '2023-01-25', 4),
('1001234574', 'Sofía Alejandra', 'Torres Medina', '2002-08-20', 'sofia.torres@example.com', 1, 2, '2023-01-28', 4),
('1001234575', 'Daniel Eduardo', 'Rojas Vargas', '2000-06-25', 'daniel.rojas@example.com', 2, 3, '2023-01-30', 5),
('1001234576', 'Valentina', 'Morales Gutiérrez', '2001-02-14', 'valentina.morales@example.com', 1, 1, '2023-02-01', 5);

INSERT INTO areaSalon (nombre, capacidad, descripcion, id_sede, estado) VALUES 
('Sala Apolo', 30, 'Sala principal para clases teóricas', 1, 'Activa'),
('Sala Artemis', 25, 'Sala para talleres prácticos', 1, 'Activa'),
('Sala Atenea', 35, 'Sala para conferencias y eventos', 2, 'Activa'),
('Sala Hermes', 20, 'Sala para trabajo en equipo', 2, 'Activa'),
('Sala Zeus', 40, 'Sala principal para clases teóricas', 3, 'Activa'),
('Sala Poseidón', 30, 'Sala para talleres prácticos', 3, 'En mantenimiento'),
('Sala Hades', 25, 'Sala para trabajo en equipo', 4, 'Activa'),
('Sala Afrodita', 35, 'Sala para conferencias y eventos', 4, 'Activa'),
('Sala Hefesto', 30, 'Sala para talleres prácticos', 5, 'Activa'),
('Sala Dionisio', 20, 'Sala para trabajo en equipo', 5, 'Inactiva');

INSERT INTO trainer (documento, nombres, apellidos, email, telefono, fecha_contratacion, especialidad, id_sede) VALUES 
('2001234567', 'Roberto', 'González Pérez', 'roberto.gonzalez@campuslands.com', '3001234567', '2022-01-15', 'Desarrollo Web', 1),
('2001234568', 'Carolina', 'Martínez López', 'carolina.martinez@campuslands.com', '3001234568', '2022-02-20', 'Bases de Datos', 1),
('2001234569', 'Javier', 'Rodríguez García', 'javier.rodriguez@campuslands.com', '3001234569', '2022-03-10', 'Programación Backend', 2),
('2001234570', 'Patricia', 'Sánchez Hernández', 'patricia.sanchez@campuslands.com', '3001234570', '2022-04-05', 'Programación Frontend', 2),
('2001234571', 'Miguel', 'Torres Ramírez', 'miguel.torres@campuslands.com', '3001234571', '2022-05-12', 'Ciencia de Datos', 3),
('2001234572', 'Lucía', 'Vargas Díaz', 'lucia.vargas@campuslands.com', '3001234572', '2022-06-18', 'Inteligencia Artificial', 3),
('2001234573', 'Fernando', 'Castro Rojas', 'fernando.castro@campuslands.com', '3001234573', '2022-07-22', 'DevOps', 4),
('2001234574', 'Mónica', 'Medina Morales', 'monica.medina@campuslands.com', '3001234574', '2022-08-30', 'Ciberseguridad', 4),
('2001234575', 'Ricardo', 'Gutiérrez Ortiz', 'ricardo.gutierrez@campuslands.com', '3001234575', '2022-09-15', 'Desarrollo Móvil', 5),
('2001234576', 'Natalia', 'Ortiz Jiménez', 'natalia.ortiz@campuslands.com', '3001234576', '2022-10-20', 'UX/UI Design', 5);

INSERT INTO datosCamper (doc_camper, direccion, ciudad, fecha_actualizacion) VALUES 
('1001234567', 'Calle 45 #23-67', 'Bucaramanga', '2023-01-10 10:30:00'),
('1001234568', 'Carrera 78 #34-56', 'Bucaramanga', '2023-01-12 11:45:00'),
('1001234569', 'Avenida 23 #67-89', 'Bogotá', '2023-01-15 09:15:00'),
('1001234570', 'Diagonal 56 #78-90', 'Bogotá', '2023-01-18 14:20:00'),
('1001234571', 'Transversal 34 #12-34', 'Medellín', '2023-01-20 16:30:00'),
('1001234572', 'Calle 67 #45-67', 'Medellín', '2023-01-22 10:10:00'),
('1001234573', 'Carrera 12 #23-45', 'Cali', '2023-01-25 11:25:00'),
('1001234574', 'Avenida 45 #56-78', 'Cali', '2023-01-28 15:40:00'),
('1001234575', 'Diagonal 78 #90-12', 'Barranquilla', '2023-01-30 09:50:00'),
('1001234576', 'Transversal 90 #12-34', 'Barranquilla', '2023-02-01 13:15:00');

INSERT INTO telefonos (telefono, tipo, doc_camper) VALUES 
('3101234567', 'Móvil', '1001234567'),
('6017654321', 'Fijo', '1001234567'),
('3101234568', 'Móvil', '1001234568'),
('3101234569', 'Móvil', '1001234569'),
('6017654322', 'Fijo', '1001234569'),
('3101234570', 'Móvil', '1001234570'),
('3101234571', 'Móvil', '1001234571'),
('6017654323', 'Fijo', '1001234571'),
('3101234572', 'Móvil', '1001234572'),
('3101234573', 'Móvil', '1001234573');

INSERT INTO acudiente (doc_acudiente, nombres, apellidos, parentesco, telefono, email, doc_camper) VALUES 
('3001234567', 'Pedro', 'Pérez Martínez', 'Padre', '3201234567', 'pedro.perez@example.com', '1001234567'),
('3001234568', 'María', 'López García', 'Madre', '3201234568', 'maria.lopez@example.com', '1001234568'),
('3001234569', 'José', 'Martínez Rodríguez', 'Padre', '3201234569', 'jose.martinez@example.com', '1001234569'),
('3001234570', 'Ana', 'García Sánchez', 'Madre', '3201234570', 'ana.garcia@example.com', '1001234570'),
('3001234571', 'Carlos', 'Hernández Vargas', 'Padre', '3201234571', 'carlos.hernandez@example.com', '1001234571'),
('3001234572', 'Laura', 'Díaz Torres', 'Madre', '3201234572', 'laura.diaz@example.com', '1001234572'),
('3001234573', 'Andrés', 'Ramírez Castro', 'Padre', '3201234573', 'andres.ramirez@example.com', '1001234573'),
('3001234574', 'Sofía', 'Torres Medina', 'Madre', '3201234574', 'sofia.torres@example.com', '1001234574'),
('3001234575', 'Daniel', 'Rojas Morales', 'Padre', '3201234575', 'daniel.rojas@example.com', '1001234575'),
('3001234576', 'Valentina', 'Morales Gutiérrez', 'Madre', '3201234576', 'valentina.morales@example.com', '1001234576');

INSERT INTO asignacionArea (id_area, id_horario, fecha_inicio, fecha_fin) VALUES 
(1, 1, '2023-01-15', '2023-06-15'),
(2, 2, '2023-01-15', '2023-06-15'),
(3, 1, '2023-01-20', '2023-06-20'),
(4, 2, '2023-01-20', '2023-06-20'),
(5, 1, '2023-01-25', '2023-06-25'),
(6, 2, '2023-01-25', '2023-06-25'),
(7, 1, '2023-02-01', '2023-07-01'),
(8, 2, '2023-02-01', '2023-07-01'),
(9, 1, '2023-02-05', '2023-07-05'),
(10, 2, '2023-02-05', '2023-07-05');

INSERT INTO trainerSkills (id_trainer, id_skill, nivel) VALUES 
(1, 1, 'Experto'),
(1, 2, 'Experto'),
(1, 3, 'Avanzado'),
(2, 6, 'Experto'),
(3, 1, 'Experto'),
(3, 8, 'Avanzado'),
(4, 2, 'Experto'),
(4, 3, 'Experto'),
(5, 4, 'Experto'),
(6, 7, 'Experto');

INSERT INTO inscripciones (doc_camper, id_ruta, fecha_inscripcion, fecha_inicio, fecha_fin_estimada, fecha_fin_real, estado) VALUES 
('1001234567', 1, '2023-01-05', '2023-01-15', '2024-01-15', NULL, 'Aprobada'),
('1001234568', 1, '2023-01-05', '2023-01-15', '2024-01-15', NULL, 'Aprobada'),
('1001234569', 2, '2023-01-10', '2023-01-20', '2023-10-20', NULL, 'Aprobada'),
('1001234570', 2, '2023-01-10', '2023-01-20', '2023-10-20', NULL, 'Aprobada'),
('1001234571', 3, '2023-01-15', '2023-01-25', '2023-07-25', NULL, 'Aprobada'),
('1001234572', 3, '2023-01-15', '2023-01-25', '2023-07-25', '2023-07-20', 'Completada'),
('1001234573', 4, '2023-01-20', '2023-02-01', '2023-12-01', NULL, 'Aprobada'),
('1001234574', 4, '2023-01-20', '2023-02-01', '2023-12-01', NULL, 'Aprobada'),
('1001234575', 5, '2023-01-25', '2023-02-05', '2023-10-05', NULL, 'Aprobada'),
('1001234576', 5, '2023-01-25', '2023-02-05', '2023-10-05', NULL, 'Aprobada');

INSERT INTO skillsNotas (doc_camper, id_modulo, id_tipo_evaluacion, nota, fecha_evaluacion, observaciones) VALUES 
('1001234567', 1, 1, 85.50, '2023-02-15', 'Buen desempeño en conceptos básicos'),
('1001234567', 1, 2, 90.00, '2023-02-20', 'Excelente comprensión teórica'),
('1001234568', 1, 1, 78.50, '2023-02-15', 'Necesita reforzar algunos conceptos'),
('1001234568', 1, 2, 82.00, '2023-02-20', 'Mejoró en la evaluación teórica'),
('1001234569', 2, 1, 92.00, '2023-02-25', 'Dominio excepcional de los temas'),
('1001234569', 2, 2, 95.50, '2023-03-01', 'Desempeño sobresaliente'),
('1001234570', 2, 1, 80.00, '2023-02-25', 'Buen manejo de conceptos'),
('1001234570', 2, 2, 85.00, '2023-03-01', 'Mejoró en la comprensión teórica'),
('1001234571', 3, 1, 75.00, '2023-03-05', 'Necesita más práctica'),
('1001234571', 3, 2, 78.50, '2023-03-10', 'Avance moderado en comprensión teórica');

INSERT INTO horarioTrainer (id_trainer, id_horario, id_area, dia_semana) VALUES 
(1, 1, 1, 'Lunes'),
(1, 1, 1, 'Miércoles'),
(2, 2, 2, 'Martes'),
(2, 2, 2, 'Jueves'),
(3, 1, 3, 'Lunes'),
(3, 1, 3, 'Viernes'),
(4, 2, 4, 'Martes'),
(4, 2, 4, 'Jueves'),
(5, 1, 5, 'Miércoles'),
(5, 1, 5, 'Viernes');

INSERT INTO asignacionCamper (doc_camper, id_area, id_horario, fecha_inicio, fecha_fin) VALUES 
('1001234567', 1, 1, '2023-01-15', '2023-06-15'),
('1001234568', 1, 1, '2023-01-15', '2023-06-15'),
('1001234569', 3, 1, '2023-01-20', '2023-06-20'),
('1001234570', 3, 1, '2023-01-20', '2023-06-20'),
('1001234571', 5, 1, '2023-01-25', '2023-06-25'),
('1001234572', 5, 1, '2023-01-25', '2023-06-25'),
('1001234573', 7, 1, '2023-02-01', '2023-07-01'),
('1001234574', 7, 1, '2023-02-01', '2023-07-01'),
('1001234575', 9, 1, '2023-02-05', '2023-07-05'),
('1001234576', 9, 1, '2023-02-05', '2023-07-05');

INSERT INTO moduloSGBD (id_modulo, id_sgbd) VALUES 
(4, 1),
(4, 2),
(4, 6),
(9, 3),
(4, 5),
(4, 7),
(9, 8),
(9, 9),
(4, 4),
(9, 10);

INSERT INTO egresados (documento, nombres, apellidos, email, fecha_graduacion, id_ruta) VALUES 
('9001234567', 'Felipe', 'Gómez Martínez', 'felipe.gomez@example.com', '2022-12-15', 1),
('9001234568', 'Gabriela', 'Vargas López', 'gabriela.vargas@example.com', '2022-12-15', 1),
('9001234569', 'Alejandro', 'Ruiz Sánchez', 'alejandro.ruiz@example.com', '2022-12-20', 2),
('9001234570', 'Isabella', 'Mendoza García', 'isabella.mendoza@example.com', '2022-12-20', 2),
('9001234571', 'Santiago', 'Ortega Hernández', 'santiago.ortega@example.com', '2023-01-10', 3),
('9001234572', 'Valeria', 'Castro Torres', 'valeria.castro@example.com', '2023-01-10', 3),
('9001234573', 'Mateo', 'Ríos Ramírez', 'mateo.rios@example.com', '2023-01-15', 4),
('9001234574', 'Camila', 'Pardo Medina', 'camila.pardo@example.com', '2023-01-15', 4),
('9001234575', 'Sebastián', 'Navarro Rojas', 'sebastian.navarro@example.com', '2023-01-20', 5),
('9001234576', 'Mariana', 'Quintero Morales', 'mariana.quintero@example.com', '2023-01-20', 5);

INSERT INTO cambiosRuta (id_ruta, descripcion, fecha_cambio) VALUES 
(1, 'Actualización de contenidos del módulo de JavaScript', '2023-02-10 09:30:00'),
(1, 'Incorporación de nuevas prácticas en React', '2023-02-15 11:45:00'),
(2, 'Cambio en la duración del módulo de Java', '2023-02-20 14:20:00'),
(2, 'Actualización de versiones de Spring', '2023-02-25 16:10:00'),
(3, 'Incorporación de nuevas herramientas de diseño', '2023-03-01 10:30:00'),
(3, 'Cambio en la metodología de evaluación', '2023-03-05 13:15:00'),
(4, 'Actualización de bibliotecas de análisis de datos', '2023-03-10 15:40:00'),
(4, 'Incorporación de nuevos datasets para prácticas', '2023-03-15 09:50:00'),
(5, 'Cambio en las herramientas de CI/CD', '2023-03-20 11:25:00'),
(5, 'Actualización de contenidos de Docker y Kubernetes', '2023-03-25 14:30:00');

INSERT INTO campersModulosAsignados (doc_camper, id_modulo, estado) VALUES 
('1001234567', 1, 'En curso'),
('1001234567', 2, 'Pendiente'),
('1001234568', 1, 'En curso'),
('1001234568', 2, 'Pendiente'),
('1001234569', 5, 'En curso'),
('1001234569', 8, 'Pendiente'),
('1001234570', 5, 'En curso'),
('1001234570', 8, 'Pendiente'),
('1001234571', 2, 'En curso'),
('1001234571', 6, 'Pendiente');

INSERT INTO plantillaModulos (id_ruta_base, id_modulo) VALUES 
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(2, 1),
(2, 4),
(2, 5),
(3, 1),
(3, 2),
(3, 6);

INSERT INTO notificacionesAutomatizadas (id_ruta, id_trainer, mensaje, fecha_envio) VALUES 
(1, 1, 'Actualización en el módulo de JavaScript', '2023-02-10 10:00:00'),
(1, 2, 'Cambio en horario de clases', '2023-02-15 12:30:00'),
(2, 3, 'Nuevo material disponible para Java', '2023-02-20 15:00:00'),
(2, 3, 'Recordatorio de entrega de proyecto', '2023-02-25 17:15:00'),
(3, 4, 'Actualización de herramientas de diseño', '2023-03-01 11:00:00'),
(3, 4, 'Cambio en criterios de evaluación', '2023-03-05 14:30:00'),
(4, 5, 'Nuevos datasets para análisis', '2023-03-10 16:45:00'),
(4, 5, 'Recordatorio de presentación final', '2023-03-15 10:15:00'),
(5, 7, 'Actualización de herramientas DevOps', '2023-03-20 12:00:00'),
(5, 7, 'Nuevo material sobre Docker', '2023-03-25 15:30:00');

INSERT INTO notaFinal (doc_camper, id_modulo, nota_teorica, nota_practica, nota_quizzes, nota_final, aprobado, fecha_calculo) VALUES 
('1001234567', 1, 85.00, 90.00, 88.00, 87.50, TRUE, '2023-03-01 10:00:00'),
('1001234568', 1, 80.00, 85.00, 82.00, 82.50, TRUE, '2023-03-01 10:30:00'),
('1001234569', 5, 92.00, 95.00, 90.00, 92.50, TRUE, '2023-03-05 11:00:00'),
('1001234570', 5, 78.00, 82.00, 80.00, 80.00, TRUE, '2023-03-05 11:30:00'),
('1001234571', 2, 75.00, 78.00, 76.00, 76.50, TRUE, '2023-03-10 12:00:00'),
('1001234572', 2, 88.00, 92.00, 90.00, 90.00, TRUE, '2023-03-10 12:30:00'),
('1001234573', 5, 82.00, 85.00, 83.00, 83.50, TRUE, '2023-03-15 13:00:00'),
('1001234574', 5, 90.00, 93.00, 91.00, 91.50, TRUE, '2023-03-15 13:30:00'),
('1001234575', 2, 70.00, 72.00, 68.00, 70.00, FALSE, '2023-03-20 14:00:00'),
('1001234576', 2, 95.00, 98.00, 96.00, 96.50, TRUE, '2023-03-20 14:30:00');


INSERT INTO historicoEstadoCamper (doc_camper, id_estado_anterior, id_estado_nuevo, fecha_cambio, motivo) VALUES 
('1001234567', 1, 2, '2023-01-15 09:00:00', 'Inicio de formación'),
('1001234568', 1, 2, '2023-01-15 09:30:00', 'Inicio de formación'),
('1001234569', 1, 2, '2023-01-20 10:00:00', 'Inicio de formación'),
('1001234570', 1, 2, '2023-01-20 10:30:00', 'Inicio de formación'),
('1001234571', 1, 2, '2023-01-25 11:00:00', 'Inicio de formación'),
('1001234572', 1, 2, '2023-01-25 11:30:00', 'Inicio de formación'),
('1001234572', 2, 3, '2023-07-20 15:00:00', 'Finalización exitosa del programa'),
('1001234573', 1, 2, '2023-02-01 12:00:00', 'Inicio de formación'),
('1001234574', 1, 2, '2023-02-01 12:30:00', 'Inicio de formación'),
('1001234575', 1, 2, '2023-02-05 13:00:00', 'Inicio de formación');