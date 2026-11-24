USE DATAMARTVETERINARIA
GO

CREATE OR ALTER PROCEDURE USP_ETL_DATAMARTVETERINARIA
AS
BEGIN

    SET NOCOUNT ON

    -- Limpiamos las tablas para volver a cargar los datos desde el origen

    DELETE FROM FAC_VENTAS
    IF @@ROWCOUNT <> 0
        DBCC CHECKIDENT ('FAC_VENTAS', RESEED, 0)

    DELETE FROM DIM_MASCOTA
    IF @@ROWCOUNT <> 0
        DBCC CHECKIDENT ('DIM_MASCOTA', RESEED, 0)

    DELETE FROM DIM_VETERINARIO
    IF @@ROWCOUNT <> 0
        DBCC CHECKIDENT ('DIM_VETERINARIO', RESEED, 0)

    DELETE FROM DIM_SERVICIO
    IF @@ROWCOUNT <> 0
        DBCC CHECKIDENT ('DIM_SERVICIO', RESEED, 0)

    DELETE FROM DIM_CLIENTE
    IF @@ROWCOUNT <> 0
        DBCC CHECKIDENT ('DIM_CLIENTE', RESEED, 0)

    DELETE FROM DIM_FECHA

    TRUNCATE TABLE STG_CLIENTE
    TRUNCATE TABLE STG_UBICACION


    -- Extraemos los datos de los clientes de la base de datos
    -- Estos datos se guardan temporalmente en STG_CLIENTE

    INSERT INTO STG_CLIENTE
    (
        ID_CLIENTE,
        NOMBRE,
        APELLIDO,
        TELEFONO,
        EMAIL
    )
    SELECT
        ID_CLIENTE,
        NOMBRE,
        APELLIDO,
        TELEFONO,
        EMAIL
    FROM VETERINARIABD1.DBO.CLIENTE


    -- Cargamos el archivo txt de ubicaciones
    -- El archivo contiene el ID del cliente, el país y el distrito.
    -- Los datos se guardan temporalmente en STG_UBICACION

    BULK INSERT STG_UBICACION
    FROM 'C:\txt\ubicacion_clientes.txt'
    WITH
    (
        FIRSTROW = 2,
        FIELDTERMINATOR = '|',
        ROWTERMINATOR = '\n'
    )


    -- Completamos DIM_CLIENTE combinando los datos de ambas fuentes
    -- Los datos personales vienen de STG_CLIENTE y la ubicación del TXT,
    -- que previamente se cargaron en STG_UBICACION

    INSERT INTO DIM_CLIENTE
    (
        PK_CLIENTE,
        NOM_CLIENTE,
        APE_CLIENTE,
        PAIS_CLIENTE,
        DISTRITO_CLIENTE,
        TELEFONO_CLIENTE,
        EMAIL_CLIENTE
    )
    SELECT
        C.ID_CLIENTE,
        C.NOMBRE,
        C.APELLIDO,
        U.PAIS,
        U.DISTRITO,
        C.TELEFONO,
        C.EMAIL
    FROM STG_CLIENTE C
    INNER JOIN STG_UBICACION U
        ON C.ID_CLIENTE = U.ID_CLIENTE


    -- Cargamos las mascotas registradas en la base de datos

    INSERT INTO DIM_MASCOTA
    (
        PK_MASCOTA,
        NOM_MASCOTA,
        ESPECIE_MASCOTA,
        RAZA_MASCOTA,
        SEXO_MASCOTA
    )
    SELECT
        ID_MASCOTA,
        NOMBRE,
        ESPECIE,
        RAZA,
        SEXO
    FROM VETERINARIABD1.DBO.MASCOTA


    -- Cargamos los veterinarios con sus respectivas especialidades

    INSERT INTO DIM_VETERINARIO
    (
        PK_VETERINARIO,
        NOM_VETERINARIO,
        APE_VETERINARIO,
        ESPECIALIDAD_VETERINARIO
    )
    SELECT
        ID_VETERINARIO,
        NOMBRE,
        APELLIDO,
        ESPECIALIDAD
    FROM VETERINARIABD1.DBO.VETERINARIO


    -- Generamos las fechas a partir de las citas registradas
    -- Se crea una fila por cada día comprendido entre la primera
    -- y la última cita de la base de datos

    DECLARE @INICIO DATE, @FIN DATE

    SELECT
        @INICIO = MIN(CAST(FECHA_HORA AS DATE)),
        @FIN = MAX(CAST(FECHA_HORA AS DATE))
    FROM VETERINARIABD1.DBO.CITA

    WHILE (@INICIO <= @FIN)
    BEGIN

        INSERT INTO DIM_FECHA
        (
            FECHA,
            AÑO,
            TRIMESTRE,
            MES,
            DIA_MES,
            DIA_SEMANA
        )
        SELECT
            @INICIO,
            DATEPART(YEAR, @INICIO),
            DATEPART(QUARTER, @INICIO),
            DATEPART(MONTH, @INICIO),
            DATEPART(DAY, @INICIO),
            CASE DATEPART(WEEKDAY, @INICIO)
                WHEN 1 THEN 'Domingo'
                WHEN 2 THEN 'Lunes'
                WHEN 3 THEN 'Martes'
                WHEN 4 THEN 'Miércoles'
                WHEN 5 THEN 'Jueves'
                WHEN 6 THEN 'Viernes'
                WHEN 7 THEN 'Sábado'
            END

        SET @INICIO = DATEADD(DAY, 1, @INICIO)

    END


    -- Cargamos los servicios a partir de los motivos de las citas
    -- El tipo de servicio se obtiene clasificando el motivo registrado

    INSERT INTO DIM_SERVICIO
    (
        PK_SERVICIO,
        TIPO_SERVICIO,
        MOTIVO_CITA
    )
    SELECT DISTINCT
        ID_CITA,
        CASE
            WHEN MOTIVO LIKE '%Vacun%' THEN 'Vacunacion'
            WHEN MOTIVO LIKE '%Cirug%' THEN 'Cirugia'
            WHEN MOTIVO LIKE '%Dermatol%'
                 OR MOTIVO LIKE '%piel%' THEN 'Dermatologia'
            WHEN MOTIVO LIKE '%Digest%' THEN 'Gastroenterologia'
            WHEN MOTIVO LIKE '%Cadera%'
                 OR MOTIVO LIKE '%articular%' THEN 'Traumatologia'
            WHEN MOTIVO LIKE '%Muscular%' THEN 'Rehabilitacion'
            WHEN MOTIVO LIKE '%Prevent%' THEN 'Prevencion'
            WHEN MOTIVO LIKE '%Control%' THEN 'Consulta general'
            ELSE 'Consulta general'
        END,
        MOTIVO
    FROM VETERINARIABD1.DBO.CITA


    -- Cargamos FAC_VENTAS relacionando las citas con sus dimensiones
    -- El monto se obtiene de PAGO y se relaciona mediante ID_CITA
    -- Cada fila de la tabla de hechos representa una cita

    INSERT INTO FAC_VENTAS
    (
        ID_CLIENTE,
        ID_MASCOTA,
        ID_VETERINARIO,
        ID_SERVICIO,
        FECHA,
        CANTIDAD_ATENCIONES,
        MONTO_ATENCION,
        CANTIDAD_CITAS,
        CANTIDAD_MASCOTAS
    )
    SELECT
        D_CL.ID_CLIENTE,
        D_MA.ID_MASCOTA,
        D_VE.ID_VETERINARIO,
        D_SE.ID_SERVICIO,
        CAST(C.FECHA_HORA AS DATE),

        CASE
            WHEN C.ESTADO = 'Atendida' THEN 1
            ELSE 0
        END,

        ISNULL(P.MONTO, 0),

        1,

        CASE
            WHEN C.ESTADO = 'Atendida' THEN 1
            ELSE 0
        END

    FROM VETERINARIABD1.DBO.CITA C

    INNER JOIN VETERINARIABD1.DBO.MASCOTA M
        ON C.ID_MASCOTA = M.ID_MASCOTA

    INNER JOIN DIM_CLIENTE D_CL
        ON M.ID_CLIENTE = D_CL.PK_CLIENTE

    INNER JOIN DIM_MASCOTA D_MA
        ON C.ID_MASCOTA = D_MA.PK_MASCOTA

    INNER JOIN DIM_VETERINARIO D_VE
        ON C.ID_VETERINARIO = D_VE.PK_VETERINARIO

    INNER JOIN DIM_SERVICIO D_SE
        ON C.ID_CITA = D_SE.PK_SERVICIO

    INNER JOIN DIM_FECHA D_F
        ON CAST(C.FECHA_HORA AS DATE) = D_F.FECHA

    LEFT JOIN VETERINARIABD1.DBO.PAGO P
        ON C.ID_CITA = P.ID_CITA

END
GO


-- Probamos

EXEC USP_ETL_DATAMARTVETERINARIA
GO

SELECT * FROM STG_CLIENTE
SELECT * FROM STG_UBICACION

SELECT * FROM DIM_CLIENTE
SELECT * FROM DIM_MASCOTA
SELECT * FROM DIM_VETERINARIO
SELECT * FROM DIM_SERVICIO
SELECT * FROM DIM_FECHA

SELECT * FROM FAC_VENTAS
GO
