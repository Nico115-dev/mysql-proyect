DROP DATABASE IF EXISTS Campuslands;
CREATE DATABASE Campuslands;
USE Campuslands;

CREATE TABLE estadoActual (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    descripcion VARCHAR(100)
);

CREATE TABLE nivelRiesgo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nivel VARCHAR(2) NOT NULL,
    descripcion VARCHAR(100)
);

CREATE TABLE rutaAprendizaje (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    duracion_meses INT NOT NULL,
    fecha_creacion DATE NOT NULL
);

CREATE TABLE sgbd (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    version VARCHAR(20),
    descripcion TEXT
);

CREATE TABLE moduloAprendizaje (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    duracion_semanas INT NOT NULL,
    tipo ENUM('Fundamentos', 'Web', 'Programación', 'Backend', 'Bases de datos') NOT NULL
);

CREATE TABLE tipoEvaluacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    porcentaje DECIMAL(5,2) NOT NULL,
    descripcion TEXT
);

CREATE TABLE horarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    descripcion VARCHAR(100)
);

CREATE TABLE skills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT
);

CREATE TABLE notificacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    mensaje TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo ENUM('Informativa', 'Alerta', 'Urgente') NOT NULL,
    estado ENUM('Pendiente', 'Enviada', 'Leída') NOT NULL DEFAULT 'Pendiente'
);

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

CREATE TABLE bdAsociados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_ruta INT NOT NULL,
    id_sgbd INT NOT NULL,
    es_principal BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (id_ruta) REFERENCES rutaAprendizaje(id),
    FOREIGN KEY (id_sgbd) REFERENCES sgbd(id)
);

CREATE TABLE rutaModulo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_ruta INT NOT NULL,
    id_modulo INT NOT NULL,
    orden INT NOT NULL,
    FOREIGN KEY (id_ruta) REFERENCES rutaAprendizaje(id),
    FOREIGN KEY (id_modulo) REFERENCES moduloAprendizaje(id),
    UNIQUE KEY unique_ruta_modulo_orden (id_ruta, id_modulo, orden)
);

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

CREATE TABLE areaSalon (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    capacidad INT NOT NULL DEFAULT 33,
    descripcion TEXT,
    id_sede INT NOT NULL,
    FOREIGN KEY (id_sede) REFERENCES sede(id)
);

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

CREATE TABLE datosCamper (
    id INT AUTO_INCREMENT PRIMARY KEY,
    doc_camper VARCHAR(11) NOT NULL,
    direccion VARCHAR(100) NOT NULL,
    ciudad VARCHAR(50) NOT NULL,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (doc_camper) REFERENCES camper(documento)
);

CREATE TABLE telefonos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    telefono VARCHAR(15) NOT NULL,
    tipo ENUM('Móvil', 'Fijo', 'Trabajo', 'Otro') NOT NULL,
    doc_camper VARCHAR(11) NOT NULL,
    FOREIGN KEY (doc_camper) REFERENCES camper(documento)
);

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

CREATE TABLE asignacionArea (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_area INT NOT NULL,
    id_horario INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    FOREIGN KEY (id_area) REFERENCES areaSalon(id),
    FOREIGN KEY (id_horario) REFERENCES horarios(id)
);

CREATE TABLE trainerSkills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_trainer INT NOT NULL,
    id_skill INT NOT NULL,
    nivel ENUM('Básico', 'Intermedio', 'Avanzado', 'Experto') NOT NULL,
    FOREIGN KEY (id_trainer) REFERENCES trainer(id),
    FOREIGN KEY (id_skill) REFERENCES skills(id),
    UNIQUE KEY unique_trainer_skill (id_trainer, id_skill)
);

CREATE TABLE rutaTrainer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_trainer INT NOT NULL,
    id_ruta INT NOT NULL,
    fecha_asignacion DATE NOT NULL,
    fecha_fin DATE,
    FOREIGN KEY (id_trainer) REFERENCES trainer(id),
    FOREIGN KEY (id_ruta) REFERENCES rutaAprendizaje(id)
);

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

CREATE TABLE moduloNotas (
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

CREATE TABLE notificacionDestinatario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_notificacion INT NOT NULL,
    doc_camper VARCHAR(11),
    id_trainer INT,
    fecha_lectura TIMESTAMP NULL,
    FOREIGN KEY (id_notificacion) REFERENCES notificacion(id),
    FOREIGN KEY (doc_camper) REFERENCES camper(documento),
    FOREIGN KEY (id_trainer) REFERENCES trainer(id),
    CHECK (doc_camper IS NOT NULL OR id_trainer IS NOT NULL)
);

CREATE TABLE asistencia (
    id INT AUTO_INCREMENT PRIMARY KEY,
    doc_camper VARCHAR(11) NOT NULL,
    fecha DATE NOT NULL,
    estado ENUM('Presente', 'Ausente', 'Tardanza', 'Justificada') NOT NULL,
    observaciones TEXT,
    FOREIGN KEY (doc_camper) REFERENCES camper(documento)
);

CREATE TABLE seguimientoRendimiento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    doc_camper VARCHAR(11) NOT NULL,
    id_modulo INT NOT NULL,
    semana INT NOT NULL,
    observaciones TEXT,
    recomendaciones TEXT,
    fecha_registro DATE NOT NULL,
    id_trainer INT NOT NULL,
    FOREIGN KEY (doc_camper) REFERENCES camper(documento),
    FOREIGN KEY (id_modulo) REFERENCES moduloAprendizaje(id),
    FOREIGN KEY (id_trainer) REFERENCES trainer(id)
);