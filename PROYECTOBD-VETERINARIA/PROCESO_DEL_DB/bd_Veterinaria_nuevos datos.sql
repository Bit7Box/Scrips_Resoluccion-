USE [master]
GO


CREATE DATABASE [VeterinariaBD1];
GO

USE [VeterinariaBD1]
GO

-- CREACIÓN DE TABLAS PRIMARIAS (Sin Claves Foráneas)

CREATE TABLE [dbo].[CLIENTE](
	[id_cliente] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](100) NOT NULL,
	[apellido] [varchar](100) NOT NULL,
	[telefono] [varchar](15) NULL,
	[email] [varchar](100) NULL,
	[direccion] [varchar](200) NULL,
	CONSTRAINT [PK_CLIENTE] PRIMARY KEY CLUSTERED ([id_cliente] ASC),
	CONSTRAINT [UQ_CLIENTE_EMAIL] UNIQUE ([email])
);
GO

CREATE TABLE [dbo].[VETERINARIO](
	[id_veterinario] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](100) NOT NULL,
	[apellido] [varchar](100) NOT NULL,
	[especialidad] [varchar](100) NULL,
	[telefono] [varchar](15) NULL,
	CONSTRAINT [PK_VETERINARIO] PRIMARY KEY CLUSTERED ([id_veterinario] ASC)
);
GO

-- CREACIÓN DE TABLAS CON DEPENDENCIAS (Claves Foráneas)

CREATE TABLE [dbo].[MASCOTA](
	[id_mascota] [int] IDENTITY(1,1) NOT NULL,
	[id_cliente] [int] NOT NULL,
	[nombre] [varchar](100) NOT NULL,
	[especie] [varchar](50) NOT NULL,
	[raza] [varchar](100) NULL,
	[fecha_nacimiento] [date] NULL,
	[sexo] [varchar](10) NOT NULL,
	CONSTRAINT [PK_MASCOTA] PRIMARY KEY CLUSTERED ([id_mascota] ASC),
	CONSTRAINT [FK_MASCOTA_CLIENTE] FOREIGN KEY ([id_cliente]) REFERENCES [dbo].[CLIENTE] ([id_cliente]),
	CONSTRAINT [CK_MASCOTA_SEXO] CHECK ([sexo]='Hembra' OR [sexo]='Macho')
);
GO

CREATE TABLE [dbo].[CITA](
	[id_cita] [int] IDENTITY(1,1) NOT NULL,
	[id_mascota] [int] NOT NULL,
	[id_veterinario] [int] NOT NULL,
	[fecha_hora] [datetime] NOT NULL,
	[motivo] [varchar](255) NULL,
	[estado] [varchar](20) NULL DEFAULT ('Pendiente'),
	CONSTRAINT [PK_CITA] PRIMARY KEY CLUSTERED ([id_cita] ASC),
	CONSTRAINT [FK_CITA_MASCOTA] FOREIGN KEY ([id_mascota]) REFERENCES [dbo].[MASCOTA] ([id_mascota]),
	CONSTRAINT [FK_CITA_VETERINARIO] FOREIGN KEY ([id_veterinario]) REFERENCES [dbo].[VETERINARIO] ([id_veterinario]),
	CONSTRAINT [CK_CITA_ESTADO] CHECK ([estado]='Cancelada' OR [estado]='Atendida' OR [estado]='Pendiente')
);
GO

CREATE TABLE [dbo].[HISTORIA_CLINICA](
	[id_historia] [int] IDENTITY(1,1) NOT NULL,
	[id_cita] [int] NOT NULL,
	[diagnostico] [varchar](max) NULL,
	[observaciones] [varchar](max) NULL,
	[fecha_registro] [date] NOT NULL,
	CONSTRAINT [PK_HISTORIA_CLINICA] PRIMARY KEY CLUSTERED ([id_historia] ASC),
	CONSTRAINT [UQ_HISTORIA_CITA] UNIQUE ([id_cita]),
	CONSTRAINT [FK_HISTORIA_CITA] FOREIGN KEY ([id_cita]) REFERENCES [dbo].[CITA] ([id_cita])
);
GO

CREATE TABLE [dbo].[PAGO](
	[id_pago] [int] IDENTITY(1,1) NOT NULL,
	[id_cita] [int] NOT NULL,
	[monto] [decimal](10, 2) NOT NULL,
	[metodo_pago] [varchar](20) NOT NULL,
	[fecha_pago] [date] NOT NULL,
	[estado] [varchar](20) NULL DEFAULT ('Pendiente'),
	CONSTRAINT [PK_PAGO] PRIMARY KEY CLUSTERED ([id_pago] ASC),
	CONSTRAINT [UQ_PAGO_CITA] UNIQUE ([id_cita]),
	CONSTRAINT [FK_PAGO_CITA] FOREIGN KEY ([id_cita]) REFERENCES [dbo].[CITA] ([id_cita]),
	CONSTRAINT [CK_PAGO_ESTADO] CHECK ([estado]='Pagado' OR [estado]='Pendiente'),
	CONSTRAINT [CK_PAGO_METODO] CHECK ([metodo_pago]='Transferencia' OR [metodo_pago]='Tarjeta' OR [metodo_pago]='Efectivo')
);
GO

CREATE TABLE [dbo].[TRATAMIENTO](
	[id_tratamiento] [int] IDENTITY(1,1) NOT NULL,
	[id_historia] [int] NOT NULL,
	[descripcion] [varchar](255) NULL,
	[medicamento] [varchar](150) NULL,
	[dosis] [varchar](100) NULL,
	[duracion_dias] [int] NULL,
	CONSTRAINT [PK_TRATAMIENTO] PRIMARY KEY CLUSTERED ([id_tratamiento] ASC),
	CONSTRAINT [FK_TRATAMIENTO_HISTORIA] FOREIGN KEY ([id_historia]) REFERENCES [dbo].[HISTORIA_CLINICA] ([id_historia])
);
GO

CREATE TABLE [dbo].[VACUNA](
	[id_vacuna] [int] IDENTITY(1,1) NOT NULL,
	[id_mascota] [int] NOT NULL,
	[id_veterinario] [int] NOT NULL,
	[nombre_vacuna] [varchar](150) NOT NULL,
	[fecha_aplicacion] [date] NOT NULL,
	[proxima_dosis] [date] NULL,
	CONSTRAINT [PK_VACUNA] PRIMARY KEY CLUSTERED ([id_vacuna] ASC),
	CONSTRAINT [FK_VACUNA_MASCOTA] FOREIGN KEY ([id_mascota]) REFERENCES [dbo].[MASCOTA] ([id_mascota]),
	CONSTRAINT [FK_VACUNA_VETERINARIO] FOREIGN KEY ([id_veterinario]) REFERENCES [dbo].[VETERINARIO] ([id_veterinario])
);
GO


-- CLIENTE
SET IDENTITY_INSERT [dbo].[CLIENTE] ON;
INSERT [dbo].[CLIENTE] ([id_cliente], [nombre], [apellido], [telefono], [email], [direccion]) VALUES 
(1, N'Carlos', N'Mendoza', N'987654321', N'carlos.mendoza@gmail.com', N'Av. Los Pinos 123, Lima'),
(2, N'Lucía', N'Ramírez', N'976543210', N'lucia.ramirez@gmail.com', N'Jr. Las Flores 456, Lima'),
(3, N'Jorge', N'Torres', N'965432109', N'jorge.torres@gmail.com', N'Calle Real 789, Lima'),
(4, N'Ana', N'Vargas', N'954321098', N'ana.vargas@gmail.com', N'Av. Colonial 321, Lima'),
(5, N'Miguel', N'Quispe', N'943210987', N'miguel.quispe@gmail.com', N'Jr. Tacna 654, Lima');
SET IDENTITY_INSERT [dbo].[CLIENTE] OFF;
GO

-- VETERINARIO
SET IDENTITY_INSERT [dbo].[VETERINARIO] ON;
INSERT [dbo].[VETERINARIO] ([id_veterinario], [nombre], [apellido], [especialidad], [telefono]) VALUES 
(1, N'Roberto', N'Salinas', N'Medicina general', N'911111111'),
(2, N'Patricia', N'León', N'Cirugía veterinaria', N'922222222'),
(3, N'Eduardo', N'Chávez', N'Dermatología animal', N'933333333');
SET IDENTITY_INSERT [dbo].[VETERINARIO] OFF;
GO

-- MASCOTA
SET IDENTITY_INSERT [dbo].[MASCOTA] ON;
INSERT [dbo].[MASCOTA] ([id_mascota], [id_cliente], [nombre], [especie], [raza], [fecha_nacimiento], [sexo]) VALUES 
(1, 1, N'Max', N'Perro', N'Labrador', CAST(N'2020-03-15' AS Date), N'Macho'),
(2, 1, N'Luna', N'Gato', N'Siamés', CAST(N'2021-07-20' AS Date), N'Hembra'),
(3, 2, N'Rocky', N'Perro', N'Pastor Alemán', CAST(N'2019-11-10' AS Date), N'Macho'),
(4, 3, N'Mia', N'Gato', N'Persa', CAST(N'2022-01-05' AS Date), N'Hembra'),
(5, 4, N'Toby', N'Perro', N'Beagle', CAST(N'2020-08-25' AS Date), N'Macho'),
(6, 5, N'Bella', N'Perro', N'Golden Retriever', CAST(N'2021-04-18' AS Date), N'Hembra');
SET IDENTITY_INSERT [dbo].[MASCOTA] OFF;
GO

-- CITA
SET IDENTITY_INSERT [dbo].[CITA] ON;
INSERT [dbo].[CITA] ([id_cita], [id_mascota], [id_veterinario], [fecha_hora], [motivo], [estado]) VALUES 
(1, 1, 1, CAST(N'2024-10-01T09:00:00.000' AS DateTime), N'Control general', N'Atendida'),
(2, 2, 3, CAST(N'2024-10-05T10:30:00.000' AS DateTime), N'Problemas de piel', N'Atendida'),
(3, 3, 1, CAST(N'2024-10-08T11:00:00.000' AS DateTime), N'Revisión de cadera', N'Atendida'),
(4, 4, 2, CAST(N'2024-10-12T09:30:00.000' AS DateTime), N'Cirugía de esterilización', N'Atendida'),
(5, 5, 1, CAST(N'2024-10-15T08:00:00.000' AS DateTime), N'Vacunación anual', N'Atendida'),
(6, 6, 3, CAST(N'2024-10-20T16:00:00.000' AS DateTime), N'Alergia en la piel', N'Pendiente');
SET IDENTITY_INSERT [dbo].[CITA] OFF;
GO

-- HISTORIA CLINICA
SET IDENTITY_INSERT [dbo].[HISTORIA_CLINICA] ON;
INSERT [dbo].[HISTORIA_CLINICA] ([id_historia], [id_cita], [diagnostico], [observaciones], [fecha_registro]) VALUES 
(1, 1, N'Estado de salud óptimo', N'Se recomienda dieta balanceada y ejercicio diario.', CAST(N'2024-10-01' AS Date)),
(2, 2, N'Dermatitis alérgica leve', N'Se prescribe shampoo medicado y antihistamínico oral.', CAST(N'2024-10-05' AS Date)),
(3, 3, N'Displasia de cadera incipiente', N'Se recomienda control cada 3 meses y evitar ejercicio brusco.', CAST(N'2024-10-08' AS Date)),
(4, 4, N'Esterilización exitosa', N'Paciente estable. Reposo por 7 días.', CAST(N'2024-10-12' AS Date)),
(5, 5, N'Vacunas al día', N'Se aplicaron vacunas anuales sin reacciones adversas.', CAST(N'2024-10-15' AS Date));
SET IDENTITY_INSERT [dbo].[HISTORIA_CLINICA] OFF;
GO

-- PAGO
SET IDENTITY_INSERT [dbo].[PAGO] ON;
INSERT [dbo].[PAGO] ([id_pago], [id_cita], [monto], [metodo_pago], [fecha_pago], [estado]) VALUES 
(1, 1, CAST(80.00 AS Decimal(10, 2)), N'Efectivo', CAST(N'2024-10-01' AS Date), N'Pagado'),
(2, 2, CAST(120.00 AS Decimal(10, 2)), N'Tarjeta', CAST(N'2024-10-05' AS Date), N'Pagado'),
(3, 3, CAST(90.00 AS Decimal(10, 2)), N'Transferencia', CAST(N'2024-10-08' AS Date), N'Pagado'),
(4, 4, CAST(350.00 AS Decimal(10, 2)), N'Tarjeta', CAST(N'2024-10-12' AS Date), N'Pagado'),
(5, 5, CAST(75.00 AS Decimal(10, 2)), N'Efectivo', CAST(N'2024-10-15' AS Date), N'Pagado');
SET IDENTITY_INSERT [dbo].[PAGO] OFF;
GO

-- TRATAMIENTO
SET IDENTITY_INSERT [dbo].[TRATAMIENTO] ON;
INSERT [dbo].[TRATAMIENTO] ([id_tratamiento], [id_historia], [descripcion], [medicamento], [dosis], [duracion_dias]) VALUES 
(1, 1, N'Suplemento vitamínico', N'Nutri-Canin', N'1 tableta diaria', 30),
(2, 2, N'Tratamiento antiparasitario', N'Cetirizina', N'5mg cada 24 horas', 15),
(3, 2, N'Shampoo medicado', N'DermaPet', N'Baño cada 3 días', 21),
(4, 3, N'Antiinflamatorio', N'Meloxicam', N'0.1mg/kg cada 24h', 10),
(5, 4, N'Antibiótico postoperatorio', N'Amoxicilina', N'250mg cada 12 horas', 7);
SET IDENTITY_INSERT [dbo].[TRATAMIENTO] OFF;
GO

-- VACUNA
SET IDENTITY_INSERT [dbo].[VACUNA] ON;
INSERT [dbo].[VACUNA] ([id_vacuna], [id_mascota], [id_veterinario], [nombre_vacuna], [fecha_aplicacion], [proxima_dosis]) VALUES 
(1, 1, 1, N'Parvovirus + Distemper', CAST(N'2024-10-01' AS Date), CAST(N'2025-10-01' AS Date)),
(2, 3, 1, N'Rabia', CAST(N'2024-10-08' AS Date), CAST(N'2025-10-08' AS Date)),
(3, 5, 1, N'Polivalente canina', CAST(N'2024-10-15' AS Date), CAST(N'2025-10-15' AS Date)),
(4, 2, 3, N'Triple felina', CAST(N'2024-10-05' AS Date), CAST(N'2025-10-05' AS Date)),
(5, 4, 2, N'Leucemia felina', CAST(N'2024-10-12' AS Date), CAST(N'2025-10-12' AS Date));
SET IDENTITY_INSERT [dbo].[VACUNA] OFF;
GO


USE [VeterinariaBD1]
GO

-- AMPLIACIÓN DE DATOS HISTÓRICOS

-- NUEVOS CLIENTES

SET IDENTITY_INSERT [dbo].[CLIENTE] ON;

INSERT [dbo].[CLIENTE]
([id_cliente], [nombre], [apellido], [telefono], [email], [direccion])
VALUES
(6, N'Fernando', N'Castillo', N'932111111', N'fernando.castillo@gmail.com', N'Av. Primavera 125, Lima'),
(7, N'Carla', N'Paredes', N'931222222', N'carla.paredes@gmail.com', N'Jr. Los Olivos 245, Lima'),
(8, N'Daniel', N'Rojas', N'930333333', N'daniel.rojas@gmail.com', N'Av. Brasil 580, Lima'),
(9, N'Valeria', N'Flores', N'929444444', N'valeria.flores@gmail.com', N'Calle Los Cedros 315, Lima'),
(10, N'Ricardo', N'Navarro', N'928555555', N'ricardo.navarro@gmail.com', N'Av. Arequipa 720, Lima'),
(11, N'Paola', N'Mendoza', N'927666666', N'paola.mendoza@gmail.com', N'Jr. Amazonas 410, Lima'),
(12, N'Sergio', N'Vega', N'926777777', N'sergio.vega@gmail.com', N'Av. Universitaria 890, Lima');

SET IDENTITY_INSERT [dbo].[CLIENTE] OFF;
GO

-- NUEVAS MASCOTAS

SET IDENTITY_INSERT [dbo].[MASCOTA] ON;

INSERT [dbo].[MASCOTA]
([id_mascota], [id_cliente], [nombre], [especie], [raza], [fecha_nacimiento], [sexo])
VALUES
(7, 6, N'Bruno', N'Perro', N'Bulldog francés', CAST(N'2021-02-10' AS Date), N'Macho'),
(8, 7, N'Nala', N'Gato', N'Angora', CAST(N'2020-06-18' AS Date), N'Hembra'),
(9, 8, N'Simba', N'Perro', N'Pug', CAST(N'2022-04-12' AS Date), N'Macho'),
(10, 9, N'Kira', N'Perro', N'Border Collie', CAST(N'2021-09-25' AS Date), N'Hembra'),
(11, 10, N'Zeus', N'Perro', N'Rottweiler', CAST(N'2019-05-14' AS Date), N'Macho'),
(12, 11, N'Molly', N'Gato', N'Maine Coon', CAST(N'2022-03-20' AS Date), N'Hembra'),
(13, 12, N'Oliver', N'Perro', N'Cocker Spaniel', CAST(N'2020-12-08' AS Date), N'Macho'),
(14, 6, N'Lola', N'Gato', N'British Shorthair', CAST(N'2023-01-15' AS Date), N'Hembra'),
(15, 8, N'Rocky', N'Perro', N'Golden Retriever', CAST(N'2020-09-17' AS Date), N'Macho');

SET IDENTITY_INSERT [dbo].[MASCOTA] OFF;
GO

-- NUEVAS CITAS

-- Las nuevas citas comienzan en noviembre de 2024.
-- Se incluyen clientes recurrentes y clientes de baja actividad.

SET IDENTITY_INSERT [dbo].[CITA] ON;

INSERT [dbo].[CITA]
([id_cita], [id_mascota], [id_veterinario], [fecha_hora], [motivo], [estado])
VALUES

-- NOVIEMBRE 2024
(7, 1, 1, CAST(N'2024-11-10T09:00:00.000' AS DateTime), N'Control general', N'Atendida'),
(8, 7, 2, CAST(N'2024-11-18T10:00:00.000' AS DateTime), N'Problemas digestivos', N'Atendida'),
(9, 3, 1, CAST(N'2024-11-25T11:30:00.000' AS DateTime), N'Control de cadera', N'Atendida'),

-- DICIEMBRE 2024
(10, 2, 3, CAST(N'2024-12-08T09:30:00.000' AS DateTime), N'Control dermatológico', N'Atendida'),
(11, 8, 3, CAST(N'2024-12-15T14:00:00.000' AS DateTime), N'Problemas de piel', N'Atendida'),
(12, 9, 1, CAST(N'2024-12-20T10:00:00.000' AS DateTime), N'Control general', N'Atendida'),

-- ENERO 2025
(13, 4, 2, CAST(N'2025-01-12T09:00:00.000' AS DateTime), N'Control postoperatorio', N'Atendida'),
(14, 10, 1, CAST(N'2025-01-18T11:00:00.000' AS DateTime), N'Control general', N'Atendida'),
(15, 11, 2, CAST(N'2025-01-25T15:00:00.000' AS DateTime), N'Problema muscular', N'Atendida'),

-- FEBRERO 2025
(16, 7, 1, CAST(N'2025-02-15T09:30:00.000' AS DateTime), N'Control digestivo', N'Atendida'),
(17, 12, 3, CAST(N'2025-02-22T10:30:00.000' AS DateTime), N'Problemas dermatológicos', N'Atendida'),

-- MARZO 2025
(18, 1, 1, CAST(N'2025-03-10T09:00:00.000' AS DateTime), N'Control general', N'Atendida'),
(19, 6, 2, CAST(N'2025-03-16T11:00:00.000' AS DateTime), N'Vacunación anual', N'Atendida'),
(20, 13, 1, CAST(N'2025-03-22T16:00:00.000' AS DateTime), N'Control preventivo', N'Atendida'),

-- MAYO 2025
(21, 3, 1, CAST(N'2025-05-11T09:30:00.000' AS DateTime), N'Revisión de cadera', N'Atendida'),
(22, 8, 3, CAST(N'2025-05-20T10:00:00.000' AS DateTime), N'Control de piel', N'Atendida'),
(23, 10, 1, CAST(N'2025-05-28T14:30:00.000' AS DateTime), N'Vacunación anual', N'Atendida'),

-- JULIO 2025
(24, 7, 2, CAST(N'2025-07-05T09:00:00.000' AS DateTime), N'Control general', N'Atendida'),
(25, 11, 2, CAST(N'2025-07-18T11:30:00.000' AS DateTime), N'Control muscular', N'Atendida'),
(26, 14, 3, CAST(N'2025-07-25T15:00:00.000' AS DateTime), N'Control dermatológico', N'Atendida'),

-- SEPTIEMBRE 2025
(27, 2, 3, CAST(N'2025-09-06T10:00:00.000' AS DateTime), N'Control dermatológico', N'Atendida'),
(28, 9, 1, CAST(N'2025-09-14T09:00:00.000' AS DateTime), N'Control general', N'Atendida'),
(29, 13, 1, CAST(N'2025-09-22T11:00:00.000' AS DateTime), N'Control preventivo', N'Atendida'),

-- NOVIEMBRE 2025
(30, 1, 1, CAST(N'2025-11-08T09:00:00.000' AS DateTime), N'Control general', N'Atendida'),
(31, 8, 3, CAST(N'2025-11-15T10:30:00.000' AS DateTime), N'Problemas de piel', N'Atendida'),
(32, 10, 1, CAST(N'2025-11-22T14:00:00.000' AS DateTime), N'Control general', N'Atendida'),

-- ENERO 2026
(33, 7, 2, CAST(N'2026-01-10T09:30:00.000' AS DateTime), N'Control general', N'Atendida'),
(34, 11, 2, CAST(N'2026-01-18T11:00:00.000' AS DateTime), N'Revisión muscular', N'Atendida'),
(35, 15, 1, CAST(N'2026-01-25T15:30:00.000' AS DateTime), N'Control general', N'Atendida'),

-- MARZO 2026
(36, 1, 1, CAST(N'2026-03-07T09:00:00.000' AS DateTime), N'Vacunación anual', N'Atendida'),
(37, 8, 3, CAST(N'2026-03-15T10:00:00.000' AS DateTime), N'Control dermatológico', N'Atendida'),
(38, 10, 1, CAST(N'2026-03-22T14:30:00.000' AS DateTime), N'Control preventivo', N'Atendida'),

-- MAYO 2026
(39, 7, 2, CAST(N'2026-05-09T09:30:00.000' AS DateTime), N'Control digestivo', N'Atendida'),
(40, 13, 1, CAST(N'2026-05-20T11:00:00.000' AS DateTime), N'Control general', N'Atendida'),

-- JULIO 2026
(41, 8, 3, CAST(N'2026-07-11T10:00:00.000' AS DateTime), N'Control de piel', N'Atendida'),

-- SEPTIEMBRE 2026
(42, 1, 1, CAST(N'2026-09-20T09:00:00.000' AS DateTime), N'Control general', N'Atendida');

SET IDENTITY_INSERT [dbo].[CITA] OFF;
GO


-- NUEVAS HISTORIAS CLÍNICAS

SET IDENTITY_INSERT [dbo].[HISTORIA_CLINICA] ON;

INSERT [dbo].[HISTORIA_CLINICA]
([id_historia], [id_cita], [diagnostico], [observaciones], [fecha_registro])
VALUES
(6, 7, N'Estado de salud estable', N'Se recomienda continuar controles periódicos.', CAST(N'2024-11-10' AS Date)),
(7, 8, N'Gastritis leve', N'Se recomienda dieta blanda durante cinco días.', CAST(N'2024-11-18' AS Date)),
(8, 9, N'Displasia de cadera en seguimiento', N'Se mantiene control periódico.', CAST(N'2024-11-25' AS Date)),
(9, 10, N'Dermatitis controlada', N'Se mantiene tratamiento preventivo.', CAST(N'2024-12-08' AS Date)),
(10, 11, N'Dermatitis leve', N'Se prescribe tratamiento tópico.', CAST(N'2024-12-15' AS Date)),
(11, 12, N'Estado de salud normal', N'Se recomienda control anual.', CAST(N'2024-12-20' AS Date)),
(12, 13, N'Evolución postoperatoria favorable', N'Paciente recuperado satisfactoriamente.', CAST(N'2025-01-12' AS Date)),
(13, 14, N'Estado de salud normal', N'Se recomienda continuar controles.', CAST(N'2025-01-18' AS Date)),
(14, 15, N'Molestia muscular leve', N'Se recomienda reposo y observación.', CAST(N'2025-01-25' AS Date)),
(15, 16, N'Problema digestivo controlado', N'Se recomienda mantener alimentación balanceada.', CAST(N'2025-02-15' AS Date)),
(16, 17, N'Dermatitis leve', N'Se indica tratamiento dermatológico.', CAST(N'2025-02-22' AS Date)),
(17, 18, N'Estado de salud normal', N'Se mantiene seguimiento preventivo.', CAST(N'2025-03-10' AS Date)),
(18, 19, N'Vacunación preventiva', N'Sin reacciones posteriores a la aplicación.', CAST(N'2025-03-16' AS Date)),
(19, 20, N'Estado de salud normal', N'Se recomienda control periódico.', CAST(N'2025-03-22' AS Date)),
(20, 21, N'Displasia de cadera en seguimiento', N'Se recomienda evitar actividad física intensa.', CAST(N'2025-05-11' AS Date)),
(21, 22, N'Dermatitis controlada', N'La evolución es favorable.', CAST(N'2025-05-20' AS Date)),
(22, 23, N'Vacunación preventiva', N'Se aplicaron vacunas sin complicaciones.', CAST(N'2025-05-28' AS Date)),
(23, 24, N'Estado de salud estable', N'Se recomienda control periódico.', CAST(N'2025-07-05' AS Date)),
(24, 25, N'Molestia muscular controlada', N'Se recomienda actividad moderada.', CAST(N'2025-07-18' AS Date)),
(25, 26, N'Problema dermatológico leve', N'Se recomienda tratamiento preventivo.', CAST(N'2025-07-25' AS Date)),
(26, 27, N'Dermatitis controlada', N'Se mantiene seguimiento.', CAST(N'2025-09-06' AS Date)),
(27, 28, N'Estado de salud normal', N'Se recomienda continuar controles.', CAST(N'2025-09-14' AS Date)),
(28, 29, N'Estado de salud normal', N'Se mantiene seguimiento preventivo.', CAST(N'2025-09-22' AS Date)),
(29, 30, N'Estado de salud estable', N'Se recomienda control periódico.', CAST(N'2025-11-08' AS Date)),
(30, 31, N'Dermatitis controlada', N'Se mantiene tratamiento preventivo.', CAST(N'2025-11-15' AS Date)),
(31, 32, N'Estado de salud normal', N'Se recomienda continuar controles.', CAST(N'2025-11-22' AS Date)),
(32, 33, N'Estado de salud estable', N'Se mantiene seguimiento preventivo.', CAST(N'2026-01-10' AS Date)),
(33, 34, N'Molestia muscular controlada', N'Se recomienda continuar controles.', CAST(N'2026-01-18' AS Date)),
(34, 35, N'Estado de salud normal', N'Se recomienda control anual.', CAST(N'2026-01-25' AS Date)),
(35, 36, N'Vacunación preventiva', N'Se aplicó vacuna sin complicaciones.', CAST(N'2026-03-07' AS Date)),
(36, 37, N'Dermatitis controlada', N'Se mantiene seguimiento dermatológico.', CAST(N'2026-03-15' AS Date)),
(37, 38, N'Estado de salud normal', N'Se recomienda seguimiento preventivo.', CAST(N'2026-03-22' AS Date)),
(38, 39, N'Problema digestivo controlado', N'Se recomienda dieta balanceada.', CAST(N'2026-05-09' AS Date)),
(39, 40, N'Estado de salud normal', N'Se recomienda continuar controles.', CAST(N'2026-05-20' AS Date)),
(40, 41, N'Dermatitis controlada', N'Se mantiene seguimiento.', CAST(N'2026-07-11' AS Date)),
(41, 42, N'Estado de salud estable', N'Se recomienda continuar controles periódicos.', CAST(N'2026-09-20' AS Date));

SET IDENTITY_INSERT [dbo].[HISTORIA_CLINICA] OFF;
GO


-- NUEVOS PAGOS

SET IDENTITY_INSERT [dbo].[PAGO] ON;

INSERT [dbo].[PAGO]
([id_pago], [id_cita], [monto], [metodo_pago], [fecha_pago], [estado])
VALUES
(6, 7, CAST(85.00 AS Decimal(10,2)), N'Efectivo', CAST(N'2024-11-10' AS Date), N'Pagado'),
(7, 8, CAST(130.00 AS Decimal(10,2)), N'Tarjeta', CAST(N'2024-11-18' AS Date), N'Pagado'),
(8, 9, CAST(95.00 AS Decimal(10,2)), N'Transferencia', CAST(N'2024-11-25' AS Date), N'Pagado'),
(9, 10, CAST(110.00 AS Decimal(10,2)), N'Tarjeta', CAST(N'2024-12-08' AS Date), N'Pagado'),
(10, 11, CAST(125.00 AS Decimal(10,2)), N'Efectivo', CAST(N'2024-12-15' AS Date), N'Pagado'),
(11, 12, CAST(80.00 AS Decimal(10,2)), N'Transferencia', CAST(N'2024-12-20' AS Date), N'Pagado'),
(12, 13, CAST(90.00 AS Decimal(10,2)), N'Tarjeta', CAST(N'2025-01-12' AS Date), N'Pagado'),
(13, 14, CAST(85.00 AS Decimal(10,2)), N'Efectivo', CAST(N'2025-01-18' AS Date), N'Pagado'),
(14, 15, CAST(140.00 AS Decimal(10,2)), N'Tarjeta', CAST(N'2025-01-25' AS Date), N'Pagado'),
(15, 16, CAST(100.00 AS Decimal(10,2)), N'Transferencia', CAST(N'2025-02-15' AS Date), N'Pagado'),
(16, 17, CAST(120.00 AS Decimal(10,2)), N'Tarjeta', CAST(N'2025-02-22' AS Date), N'Pagado'),
(17, 18, CAST(85.00 AS Decimal(10,2)), N'Efectivo', CAST(N'2025-03-10' AS Date), N'Pagado'),
(18, 19, CAST(75.00 AS Decimal(10,2)), N'Transferencia', CAST(N'2025-03-16' AS Date), N'Pagado'),
(19, 20, CAST(80.00 AS Decimal(10,2)), N'Efectivo', CAST(N'2025-03-22' AS Date), N'Pagado'),
(20, 21, CAST(95.00 AS Decimal(10,2)), N'Tarjeta', CAST(N'2025-05-11' AS Date), N'Pagado'),
(21, 22, CAST(115.00 AS Decimal(10,2)), N'Tarjeta', CAST(N'2025-05-20' AS Date), N'Pagado'),
(22, 23, CAST(90.00 AS Decimal(10,2)), N'Efectivo', CAST(N'2025-05-28' AS Date), N'Pagado'),
(23, 24, CAST(85.00 AS Decimal(10,2)), N'Transferencia', CAST(N'2025-07-05' AS Date), N'Pagado'),
(24, 25, CAST(130.00 AS Decimal(10,2)), N'Tarjeta', CAST(N'2025-07-18' AS Date), N'Pagado'),
(25, 26, CAST(105.00 AS Decimal(10,2)), N'Efectivo', CAST(N'2025-07-25' AS Date), N'Pagado'),
(26, 27, CAST(115.00 AS Decimal(10,2)), N'Tarjeta', CAST(N'2025-09-06' AS Date), N'Pagado'),
(27, 28, CAST(85.00 AS Decimal(10,2)), N'Transferencia', CAST(N'2025-09-14' AS Date), N'Pagado'),
(28, 29, CAST(80.00 AS Decimal(10,2)), N'Efectivo', CAST(N'2025-09-22' AS Date), N'Pagado'),
(29, 30, CAST(85.00 AS Decimal(10,2)), N'Tarjeta', CAST(N'2025-11-08' AS Date), N'Pagado'),
(30, 31, CAST(120.00 AS Decimal(10,2)), N'Transferencia', CAST(N'2025-11-15' AS Date), N'Pagado'),
(31, 32, CAST(90.00 AS Decimal(10,2)), N'Efectivo', CAST(N'2025-11-22' AS Date), N'Pagado'),
(32, 33, CAST(85.00 AS Decimal(10,2)), N'Tarjeta', CAST(N'2026-01-10' AS Date), N'Pagado'),
(33, 34, CAST(135.00 AS Decimal(10,2)), N'Transferencia', CAST(N'2026-01-18' AS Date), N'Pagado'),
(34, 35, CAST(85.00 AS Decimal(10,2)), N'Efectivo', CAST(N'2026-01-25' AS Date), N'Pagado'),
(35, 36, CAST(80.00 AS Decimal(10,2)), N'Tarjeta', CAST(N'2026-03-07' AS Date), N'Pagado'),
(36, 37, CAST(120.00 AS Decimal(10,2)), N'Transferencia', CAST(N'2026-03-15' AS Date), N'Pagado'),
(37, 38, CAST(85.00 AS Decimal(10,2)), N'Efectivo', CAST(N'2026-03-22' AS Date), N'Pagado'),
(38, 39, CAST(105.00 AS Decimal(10,2)), N'Tarjeta', CAST(N'2026-05-09' AS Date), N'Pagado'),
(39, 40, CAST(85.00 AS Decimal(10,2)), N'Efectivo', CAST(N'2026-05-20' AS Date), N'Pagado'),
(40, 41, CAST(115.00 AS Decimal(10,2)), N'Transferencia', CAST(N'2026-07-11' AS Date), N'Pagado'),
(41, 42, CAST(85.00 AS Decimal(10,2)), N'Tarjeta', CAST(N'2026-09-20' AS Date), N'Pagado');

SET IDENTITY_INSERT [dbo].[PAGO] OFF;
GO


-- NUEVOS TRATAMIENTOS

SET IDENTITY_INSERT [dbo].[TRATAMIENTO] ON;

INSERT [dbo].[TRATAMIENTO]
([id_tratamiento], [id_historia], [descripcion], [medicamento], [dosis], [duracion_dias])
VALUES
(6, 7, N'Tratamiento digestivo', N'Omeprazol veterinario', N'1 dosis cada 24 horas', 7),
(7, 9, N'Control articular', N'Condroprotector', N'1 tableta diaria', 30),
(8, 10, N'Tratamiento dermatológico', N'Shampoo medicado', N'Baño cada 3 días', 21),
(9, 11, N'Tratamiento tópico', N'Crema dermatológica', N'Aplicar dos veces al día', 14),
(10, 12, N'Suplemento vitamínico', N'Complejo vitamínico', N'1 tableta diaria', 30),
(11, 14, N'Control preventivo', N'Suplemento articular', N'1 tableta diaria', 30),
(12, 15, N'Antiinflamatorio', N'Meloxicam', N'0.1mg/kg cada 24h', 7),
(13, 16, N'Tratamiento digestivo', N'Probiótico veterinario', N'1 dosis diaria', 10),
(14, 17, N'Tratamiento dermatológico', N'Shampoo medicado', N'Baño cada 3 días', 21),
(15, 20, N'Suplemento preventivo', N'Complejo vitamínico', N'1 tableta diaria', 30),
(16, 21, N'Control articular', N'Condroprotector', N'1 tableta diaria', 30),
(17, 22, N'Tratamiento dermatológico', N'DermaPet', N'Aplicar según indicación', 15),
(18, 24, N'Suplemento vitamínico', N'Complejo vitamínico', N'1 tableta diaria', 30),
(19, 25, N'Antiinflamatorio', N'Meloxicam', N'0.1mg/kg cada 24h', 7),
(20, 26, N'Tratamiento dermatológico', N'Shampoo medicado', N'Baño cada 3 días', 21),
(21, 27, N'Tratamiento preventivo', N'DermaPet', N'Aplicar según indicación', 15),
(22, 29, N'Suplemento vitamínico', N'Complejo vitamínico', N'1 tableta diaria', 30),
(23, 31, N'Tratamiento dermatológico', N'Shampoo medicado', N'Baño cada 3 días', 21),
(24, 33, N'Suplemento preventivo', N'Complejo vitamínico', N'1 tableta diaria', 30),
(25, 34, N'Control muscular', N'Condroprotector', N'1 tableta diaria', 30),
(26, 37, N'Tratamiento dermatológico', N'DermaPet', N'Aplicar según indicación', 15),
(27, 38, N'Suplemento preventivo', N'Probiótico veterinario', N'1 dosis diaria', 10),
(28, 40, N'Suplemento vitamínico', N'Complejo vitamínico', N'1 tableta diaria', 30);

SET IDENTITY_INSERT [dbo].[TRATAMIENTO] OFF;
GO


-- NUEVAS VACUNAS

SET IDENTITY_INSERT [dbo].[VACUNA] ON;

INSERT [dbo].[VACUNA]
([id_vacuna], [id_mascota], [id_veterinario], [nombre_vacuna], [fecha_aplicacion], [proxima_dosis])
VALUES
(6, 7, 2, N'Vacuna séxtuple canina', CAST(N'2024-11-18' AS Date), CAST(N'2025-11-18' AS Date)),
(7, 8, 3, N'Triple felina', CAST(N'2024-12-15' AS Date), CAST(N'2025-12-15' AS Date)),
(8, 9, 1, N'Rabia', CAST(N'2024-12-20' AS Date), CAST(N'2025-12-20' AS Date)),
(9, 10, 1, N'Vacuna séxtuple canina', CAST(N'2025-01-18' AS Date), CAST(N'2026-01-18' AS Date)),
(10, 11, 2, N'Rabia', CAST(N'2025-01-25' AS Date), CAST(N'2026-01-25' AS Date)),
(11, 12, 3, N'Triple felina', CAST(N'2025-02-22' AS Date), CAST(N'2026-02-22' AS Date)),
(12, 13, 1, N'Vacuna séxtuple canina', CAST(N'2025-03-22' AS Date), CAST(N'2026-03-22' AS Date)),
(13, 7, 2, N'Rabia', CAST(N'2025-07-05' AS Date), CAST(N'2026-07-05' AS Date)),
(14, 10, 1, N'Rabia', CAST(N'2025-05-28' AS Date), CAST(N'2026-05-28' AS Date)),
(15, 11, 2, N'Vacuna séxtuple canina', CAST(N'2025-07-18' AS Date), CAST(N'2026-07-18' AS Date)),
(16, 8, 3, N'Leucemia felina', CAST(N'2025-09-06' AS Date), CAST(N'2026-09-06' AS Date)),
(17, 13, 1, N'Rabia', CAST(N'2025-09-22' AS Date), CAST(N'2026-09-22' AS Date)),
(18, 1, 1, N'Vacuna séxtuple canina', CAST(N'2026-03-07' AS Date), CAST(N'2027-03-07' AS Date)),
(19, 7, 2, N'Vacuna séxtuple canina', CAST(N'2026-05-09' AS Date), CAST(N'2027-05-09' AS Date)),
(20, 8, 3, N'Triple felina', CAST(N'2026-07-11' AS Date), CAST(N'2027-07-11' AS Date));

SET IDENTITY_INSERT [dbo].[VACUNA] OFF;
GO