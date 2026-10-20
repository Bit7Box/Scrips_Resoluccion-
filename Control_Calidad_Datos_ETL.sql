USE DATAMARTVETERINARIA
GO

CREATE PROCEDURE USP_ETL_DATAMARTVETERINARIA1
AS
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON
    SET DATEFIRST 7

    BEGIN TRY

        BEGIN TRANSACTION

        -- linpieza de tablas

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


        -- extracion de los datos del cliente al stg

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


        -- control de calidad de clientes

        IF EXISTS
        (
            SELECT 1
            FROM STG_CLIENTE
            WHERE ID_CLIENTE IS NULL
               OR NOMBRE IS NULL
               OR LTRIM(RTRIM(NOMBRE)) = ''
               OR APELLIDO IS NULL
               OR LTRIM(RTRIM(APELLIDO)) = ''
        )
        BEGIN
            RAISERROR(
                'ERROR DE CALIDAD: existen clientes sin ID, nombre o apellido.',
                16,
                1
            )
        END


        -- cargar ubicaciones desde el txt en el disco c:

        BULK INSERT STG_UBICACION
        FROM 'C:\txt\ubicacion_clientes.txt'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = '|',
            ROWTERMINATOR = '\n'
        )


        -- control de calidad  de ubicaciones incompletas

        IF EXISTS
        (
            SELECT 1
            FROM STG_UBICACION
            WHERE ID_CLIENTE IS NULL
               OR PAIS IS NULL
               OR LTRIM(RTRIM(PAIS)) = ''
               OR DISTRITO IS NULL
               OR LTRIM(RTRIM(DISTRITO)) = ''
        )
        BEGIN
            RAISERROR(
                'ERROR DE CALIDAD: existen ubicaciones con datos obligatorios faltantes.',
                16,
                1
            )
        END


        -- control de calidad de ubicaciones duplicadas (repetidas)

        IF EXISTS
        (
            SELECT ID_CLIENTE
            FROM STG_UBICACION
            GROUP BY ID_CLIENTE
            HAVING COUNT(*) > 1
        )
        BEGIN
            RAISERROR(
                'ERROR DE CALIDAD: existen ubicaciones duplicadas para un cliente.',
                16,
                1
            )
        END


        -- control de calidad de ubicaciones sin un cliente

        IF EXISTS
        (
            SELECT 1
            FROM STG_UBICACION U
            LEFT JOIN STG_CLIENTE C
                ON U.ID_CLIENTE = C.ID_CLIENTE
            WHERE C.ID_CLIENTE IS NULL
        )
        BEGIN
            RAISERROR(
                'ERROR DE CALIDAD: existen ubicaciones sin cliente correspondiente.',
                16,
                1
            )
        END


        -- control de calidad de clientes sin ubicacion

        IF EXISTS
        (
            SELECT 1
            FROM STG_CLIENTE C
            LEFT JOIN STG_UBICACION U
                ON C.ID_CLIENTE = U.ID_CLIENTE
            WHERE U.ID_CLIENTE IS NULL
        )
        BEGIN
            RAISERROR(
                'ERROR DE CALIDAD: existen clientes sin ubicacion registrada.',
                16,
                1
            )
        END


        -- carga de datos del cliente a la dimencion

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


        -- carga de datos de mascotas a la dimencion

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


        -- carga de datos del veterinario a la dimencion

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


        -- generacion de la dimencion fecha

        DECLARE @INICIO DATE
        DECLARE @FIN DATE

        SELECT
            @INICIO = MIN(CAST(FECHA_HORA AS DATE)),
            @FIN = MAX(CAST(FECHA_HORA AS DATE))
        FROM VETERINARIABD1.DBO.CITA

        WHILE @INICIO IS NOT NULL AND @INICIO <= @FIN
        BEGIN

            INSERT INTO DIM_FECHA
            (
                FECHA,
                [AÑO],
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


        -- carga de datos de servicio a la dimencion

        INSERT INTO DIM_SERVICIO
        (
            PK_SERVICIO,
            TIPO_SERVICIO,
            MOTIVO_CITA
        )
        SELECT DISTINCT
            ID_CITA,
            CASE
                WHEN MOTIVO LIKE '%Vacun%'
                    THEN 'Vacunacion'

                WHEN MOTIVO LIKE '%Cirug%'
                    THEN 'Cirugia'

                WHEN MOTIVO LIKE '%Dermatol%'
                  OR MOTIVO LIKE '%piel%'
                    THEN 'Dermatologia'

                WHEN MOTIVO LIKE '%Digest%'
                    THEN 'Gastroenterologia'

                WHEN MOTIVO LIKE '%Cadera%'
                  OR MOTIVO LIKE '%articular%'
                    THEN 'Traumatologia'

                WHEN MOTIVO LIKE '%Muscular%'
                    THEN 'Rehabilitacion'

                WHEN MOTIVO LIKE '%Prevent%'
                    THEN 'Prevencion'

                WHEN MOTIVO LIKE '%Control%'
                    THEN 'Consulta general'

                ELSE 'Consulta general'
            END,
            MOTIVO
        FROM VETERINARIABD1.DBO.CITA


        --  CARGAR TABLA DE HECHOS FAC_VENTAS

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

            -- SOLO CONTABILIZAR PAGOS PAGADOS
            CASE
                WHEN P.ESTADO = 'Pagado'
                    THEN ISNULL(P.MONTO, 0)
                ELSE 0
            END,

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


        -- validacion de citas cargadas

        IF
        (
            SELECT COUNT(*)
            FROM VETERINARIABD1.DBO.CITA
        )
        <>
        (
            SELECT COUNT(*)
            FROM FAC_VENTAS
        )
        BEGIN
            RAISERROR(
                'ERROR DE CALIDAD: la cantidad de citas del origen no coincide con FAC_VENTAS.',
                16,
                1
            )
        END


        -- confirmacion de la carga

        COMMIT TRANSACTION

        PRINT 'ETL EJECUTADO CORRECTAMENTE.'
        PRINT 'CONTROLES DE CALIDAD SUPERADOS.'

    END TRY

    BEGIN CATCH

        DECLARE @MENSAJE NVARCHAR(4000)
        DECLARE @SEVERIDAD INT
        DECLARE @ESTADO INT

        SELECT
            @MENSAJE = ERROR_MESSAGE(),
            @SEVERIDAD = ERROR_SEVERITY(),
            @ESTADO = ERROR_STATE()

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION

        PRINT 'ERROR DURANTE LA EJECUCION DEL ETL.'

        RAISERROR(
            '%s',
            @SEVERIDAD,
            @ESTADO,
            @MENSAJE
        )

    END CATCH

END
GO


-- Probamos

EXEC USP_ETL_DATAMARTVETERINARIA1
GO



--SELECT * FROM STG_CLIENTE
--SELECT * FROM STG_UBICACION

--SELECT * FROM DIM_CLIENTE
--SELECT * FROM DIM_MASCOTA
--SELECT * FROM DIM_VETERINARIO
--SELECT * FROM DIM_SERVICIO
--SELECT * FROM DIM_FECHA

--SELECT * FROM FAC_VENTAS
--GO