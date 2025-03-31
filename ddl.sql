DROP DATABASE IF EXISTS Campuslands;
CREATE DATABASE Campuslands;
USE Campuslands;

-- Tabla para registrar los diferentes estados de los campers "En proceso, inscrito, egresado, etc..." 
CREATE TABLE estadoActual (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    descripcion VARCHAR(100)
);

-- Tabla para registrar los diferentes niveles de riesgo 
CREATE TABLE nivelRiesgo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nivel VARCHAR(2) NOT NULL,
    descripcion VARCHAR(100)
);

-- Tabla para las diferentes rutas de aprendizaje
CREATE TABLE rutaAprendizaje (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    duracion_meses INT NOT NULL,
    fecha_creacion DATE NOT NULL
);

-- Tabla de Sistema De Gestiones De Bases De Datos (SGBD)
CREATE TABLE sgbd (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    version VARCHAR(20),
    descripcion TEXT
);

-- Tabla para registrar los módulos de aprendizaje
CREATE TABLE moduloAprendizaje (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    duracion_semanas INT NOT NULL,
    tipo ENUM('Fundamentos', 'Web', 'Programación', 'Backend', 'Bases de datos') NOT NULL
);

-- Tabla para registrar los tipos de evaluación "Quiz, Examen, Proyecto, etc..."
CREATE TABLE tipoEvaluacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    porcentaje DECIMAL(5,2) NOT NULL,
    descripcion TEXT
);

-- Tabla para registrar los horarios 
CREATE TABLE horarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    descripcion VARCHAR(100)
);

-- Tabla para registrar los diferentes skills "Mysql, Python, JavaScript, etc..."
CREATE TABLE skills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT
);

-- Tabla para relacionar skills con módulos
CREATE TABLE skillModulo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_skill INT NOT NULL,
    id_modulo INT NOT NULL,
    orden INT NOT NULL,
    FOREIGN KEY (id_skill) REFERENCES skills(id),
    FOREIGN KEY (id_modulo) REFERENCES moduloAprendizaje(id),
    UNIQUE KEY unique_skill_modulo (id_skill, id_modulo)
);

-- Tabla para sesiones de trabajo
CREATE TABLE sesionTrabajo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_modulo INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    duracion_horas INT NOT NULL,
    orden INT NOT NULL,
    FOREIGN KEY (id_modulo) REFERENCES moduloAprendizaje(id),
    UNIQUE KEY unique_modulo_sesion (id_modulo, orden)
);

-- Tabla para registrar las notificaciones generales
CREATE TABLE notificacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    mensaje TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo ENUM('Informativa', 'Alerta', 'Urgente') NOT NULL,
    estado ENUM('Pendiente', 'Enviada', 'Leída') NOT NULL DEFAULT 'Pendiente'
);

-- Tabla para registrar diferentes sedes de Campuslands
CREATE TABLE sede (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(100) NOT NULL,
    ciudad VARCHAR(50) NOT NULL,
    capacidad_total INT NOT NULL,
    nit VARCHAR(20) UNIQUE,
    telefono_principal VARCHAR(15),
    email_contacto VARCHAR(100)
);

-- Tabla que relaciona la ruta con la db asociada
CREATE TABLE bdAsociados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_ruta INT NOT NULL,
    id_sgbd INT NOT NULL,
    es_principal BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (id_ruta) REFERENCES rutaAprendizaje(id),
    FOREIGN KEY (id_sgbd) REFERENCES sgbd(id)
);

-- Tabla para relacionar rutas y módulos
CREATE TABLE rutaModulo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_ruta INT NOT NULL,
    id_modulo INT NOT NULL,
    orden INT NOT NULL,
    FOREIGN KEY (id_ruta) REFERENCES rutaAprendizaje(id),
    FOREIGN KEY (id_modulo) REFERENCES moduloAprendizaje(id),
    UNIQUE KEY unique_ruta_modulo_orden (id_ruta, id_modulo, orden)
);

-- Tabla camper 
CREATE TABLE camper (
    documento VARCHAR(11) PRIMARY KEY,
    nombres VARCHAR(45) NOT NULL,
    apellidos VARCHAR(45) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    id_estado INT NOT NULL,
    id_nivel_riesgo INT,
    fecha_registro DATE NOT NULL,
    id_sede INT NOT NULL,
    FOREIGN KEY (id_estado) REFERENCES estadoActual(id),
    FOREIGN KEY (id_nivel_riesgo) REFERENCES nivelRiesgo(id),
    FOREIGN KEY (id_sede) REFERENCES sede(id)
);

-- Tabla para relacional el salon a trabajar
CREATE TABLE areaSalon (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    capacidad INT NOT NULL DEFAULT 33,
    descripcion TEXT,
    id_sede INT NOT NULL,
    estado ENUM('Activa', 'Inactiva', 'En mantenimiento') NOT NULL DEFAULT 'Activa',
    FOREIGN KEY (id_sede) REFERENCES sede(id)
);


-- Tabla para registrar los trainers
CREATE TABLE trainer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    documento VARCHAR(11) NOT NULL UNIQUE,
    nombres VARCHAR(45) NOT NULL,
    apellidos VARCHAR(45) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(15),
    fecha_contratacion DATE NOT NULL,
    especialidad VARCHAR(100),
    id_sede INT NOT NULL,
    FOREIGN KEY (id_sede) REFERENCES sede(id)
);

-- Tabla para los datos que necesitamos de los campers
CREATE TABLE datosCamper (
    id INT AUTO_INCREMENT PRIMARY KEY,
    doc_camper VARCHAR(11) NOT NULL,
    direccion VARCHAR(100) NOT NULL,
    ciudad VARCHAR(50) NOT NULL,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (doc_camper) REFERENCES camper(documento)
);

-- Tabla para los teléfonos de los campers
CREATE TABLE telefonos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    telefono VARCHAR(15) NOT NULL,
    tipo ENUM('Móvil', 'Fijo', 'Trabajo', 'Otro') NOT NULL,
    doc_camper VARCHAR(11) NOT NULL,
    FOREIGN KEY (doc_camper) REFERENCES camper(documento)
);

-- Tabla de los acudientes por camper
CREATE TABLE acudiente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    doc_acudiente VARCHAR(11) NOT NULL,
    nombres VARCHAR(45) NOT NULL,
    apellidos VARCHAR(45) NOT NULL,
    parentesco VARCHAR(30) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    doc_camper VARCHAR(11) NOT NULL,
    FOREIGN KEY (doc_camper) REFERENCES camper(documento)
);

-- Tabla para registrar las áreas de trabajo
CREATE TABLE asignacionArea (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_area INT NOT NULL,
    id_horario INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    FOREIGN KEY (id_area) REFERENCES areaSalon(id),
    FOREIGN KEY (id_horario) REFERENCES horarios(id)
);

-- Tabla para registrar las habilidades de los trainers
CREATE TABLE trainerSkills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_trainer INT NOT NULL,
    id_skill INT NOT NULL,
    nivel ENUM('Básico', 'Intermedio', 'Avanzado', 'Experto') NOT NULL,
    FOREIGN KEY (id_trainer) REFERENCES trainer(id),
    FOREIGN KEY (id_skill) REFERENCES skills(id),
    UNIQUE KEY unique_trainer_skill (id_trainer, id_skill)
);

-- Tabla para registrar las rutas asignadas a los trainers
CREATE TABLE rutaTrainer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_trainer INT NOT NULL,
    id_ruta INT NOT NULL,
    fecha_asignacion DATE NOT NULL,
    fecha_fin DATE,
    FOREIGN KEY (id_trainer) REFERENCES trainer(id),
    FOREIGN KEY (id_ruta) REFERENCES rutaAprendizaje(id)
);

-- Tabla para registrar las inscripciones de los campers a las rutas
CREATE TABLE inscripciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    doc_camper VARCHAR(11) NOT NULL,
    id_ruta INT NOT NULL,
    fecha_inscripcion DATE NOT NULL,
    fecha_inicio DATE,
    fecha_fin_estimada DATE,
    fecha_fin_real DATE,
    estado ENUM('Pendiente', 'Aprobada', 'Rechazada', 'Cancelada', 'Completada') NOT NULL DEFAULT 'Pendiente',
    FOREIGN KEY (doc_camper) REFERENCES camper(documento),
    FOREIGN KEY (id_ruta) REFERENCES rutaAprendizaje(id)
);

-- Tabla para las notas de cada skill segun el camper y el modulo
CREATE TABLE skillsNotas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    doc_camper VARCHAR(11) NOT NULL,
    id_modulo INT NOT NULL,
    id_tipo_evaluacion INT NOT NULL,
    nota DECIMAL(5,2) NOT NULL,
    fecha_evaluacion DATE NOT NULL,
    observaciones TEXT,
    FOREIGN KEY (doc_camper) REFERENCES camper(documento),
    FOREIGN KEY (id_modulo) REFERENCES moduloAprendizaje(id),
    FOREIGN KEY (id_tipo_evaluacion) REFERENCES tipoEvaluacion(id)
);

-- Tabla para registrar los horarios de trabajo de los trainers
CREATE TABLE horarioTrainer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_trainer INT NOT NULL,
    id_horario INT NOT NULL,
    id_area INT NOT NULL,
    dia_semana ENUM('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado') NOT NULL,
    FOREIGN KEY (id_trainer) REFERENCES trainer(id),
    FOREIGN KEY (id_horario) REFERENCES horarios(id),
    FOREIGN KEY (id_area) REFERENCES areaSalon(id)
);

-- Tabla para registrar el camper a un determinado grupo (J1,M1,U2,etc...)
CREATE TABLE asignacionCamper (
    id INT AUTO_INCREMENT PRIMARY KEY,
    doc_camper VARCHAR(11) NOT NULL,
    id_area INT NOT NULL,
    id_horario INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    FOREIGN KEY (doc_camper) REFERENCES camper(documento),
    FOREIGN KEY (id_area) REFERENCES areaSalon(id),
    FOREIGN KEY (id_horario) REFERENCES horarios(id)
);

-- Relación entre módulos y SGBD para registrar automáticamente su asociación
CREATE TABLE moduloSGBD (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_modulo INT NOT NULL,
    id_sgbd INT NOT NULL,
    FOREIGN KEY (id_modulo) REFERENCES moduloAprendizaje(id),
    FOREIGN KEY (id_sgbd) REFERENCES sgbd(id)
);

-- Registro de campers egresados cuando se gradúan
CREATE TABLE egresados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    documento VARCHAR(11) NOT NULL UNIQUE,
    nombres VARCHAR(45) NOT NULL,
    apellidos VARCHAR(45) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    fecha_graduacion DATE NOT NULL,
    id_ruta INT NOT NULL,
    FOREIGN KEY (id_ruta) REFERENCES rutaAprendizaje(id)
);

-- Registro de cambios en rutas de aprendizaje para notificar a trainers
CREATE TABLE cambiosRuta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_ruta INT NOT NULL,
    descripcion TEXT NOT NULL,
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_ruta) REFERENCES rutaAprendizaje(id)
);

-- Tabla para registrar los módulos que cada camper tiene asignado, con su estado
CREATE TABLE campersModulosAsignados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    doc_camper VARCHAR(11) NOT NULL,
    id_modulo INT NOT NULL,
    estado ENUM('Pendiente', 'En curso', 'Aprobado', 'Reprobado') NOT NULL DEFAULT 'Pendiente',
    FOREIGN KEY (doc_camper) REFERENCES camper(documento),
    FOREIGN KEY (id_modulo) REFERENCES moduloAprendizaje(id)
);

-- Tabla de plantillas de módulos y SGBDs para clonar al crear nuevas rutas
CREATE TABLE plantillaModulos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_ruta_base INT NOT NULL,
    id_modulo INT NOT NULL,
    FOREIGN KEY (id_ruta_base) REFERENCES rutaAprendizaje(id),
    FOREIGN KEY (id_modulo) REFERENCES moduloAprendizaje(id)
);

-- Tabla para las noticicaciones "Para Trainers"
CREATE TABLE notificacionesAutomatizadas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_ruta INT NOT NULL,
    id_trainer INT NOT NULL,
    mensaje TEXT NOT NULL,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_ruta) REFERENCES rutaAprendizaje(id),
    FOREIGN KEY (id_trainer) REFERENCES trainer(id)
);

-- Tabla para almacenar las notas finales calculadas
CREATE TABLE notaFinal (
    id INT AUTO_INCREMENT PRIMARY KEY,
    doc_camper VARCHAR(11) NOT NULL,
    id_modulo INT NOT NULL,
    nota_teorica DECIMAL(5,2) DEFAULT 0,
    nota_practica DECIMAL(5,2) DEFAULT 0,
    nota_quizzes DECIMAL(5,2) DEFAULT 0,
    nota_final DECIMAL(5,2) DEFAULT 0,
    aprobado BOOLEAN DEFAULT FALSE,
    fecha_calculo TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (doc_camper) REFERENCES camper(documento),
    FOREIGN KEY (id_modulo) REFERENCES moduloAprendizaje(id),
    UNIQUE KEY unique_camper_modulo (doc_camper, id_modulo)
);

-- Tabla para registrar el historial de cambios de estado de los campers
CREATE TABLE historicoEstadoCamper (
    id INT AUTO_INCREMENT PRIMARY KEY,
    doc_camper VARCHAR(11) NOT NULL,
    id_estado_anterior INT NOT NULL,
    id_estado_nuevo INT NOT NULL,
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo TEXT,
    FOREIGN KEY (doc_camper) REFERENCES camper(documento),
    FOREIGN KEY (id_estado_anterior) REFERENCES estadoActual(id),
    FOREIGN KEY (id_estado_nuevo) REFERENCES estadoActual(id)
);