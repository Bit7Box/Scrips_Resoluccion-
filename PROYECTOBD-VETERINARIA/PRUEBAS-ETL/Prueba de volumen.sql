
USE tempdb;
GO

SET NOCOUNT ON;

-- eliminamos las tablas temporales de pruebas anteriores
DROP TABLE IF EXISTS #CITAS_PRUEBA;
DROP TABLE IF EXISTS #MEDICIONES;
DROP TABLE IF EXISTS #VOLUMENES;

-- creamos la tabla temporal de citas sinteticas
CREATE TABLE #CITAS_PRUEBA (
    id_cita BIGINT NOT NULL,
    estado VARCHAR(20) NOT NULL
);

-- creamos la tabla de mediciones
CREATE TABLE #MEDICIONES (
    registros INT,
    repeticion INT,
    tiempo_segundos FLOAT
);

-- definimos los volumenes de prueba
CREATE TABLE #VOLUMENES (
    registros INT
);

INSERT INTO #VOLUMENES VALUES
(42), (420), (4200), (42000), (420000);

DECLARE @REGISTROS INT;
DECLARE @REPETICION INT;
DECLARE @INICIO DATETIME2(7);
DECLARE @FIN DATETIME2(7);
DECLARE @TIEMPO FLOAT;

-- recorremos los cinco volumenes
DECLARE CURSOR_VOLUMENES CURSOR LOCAL FAST_FORWARD FOR
SELECT registros
FROM #VOLUMENES
ORDER BY registros;

OPEN CURSOR_VOLUMENES;
FETCH NEXT FROM CURSOR_VOLUMENES INTO @REGISTROS;

WHILE @@FETCH_STATUS = 0
BEGIN

    -- limpiamos los datos sinteticos del volumen anterior
    TRUNCATE TABLE #CITAS_PRUEBA;

    -- generamos registros con identificadores unicos
    ;WITH NUMEROS AS (
        SELECT TOP (@REGISTROS)
            ROW_NUMBER() OVER (ORDER BY a.object_id, b.object_id) - 1 AS id
        FROM sys.all_objects a
        CROSS JOIN sys.all_objects b
    )
    INSERT INTO #CITAS_PRUEBA (id_cita, estado)
    SELECT
        id,
        CASE
            WHEN id % 42 = 41 THEN 'Pendiente'
            ELSE 'Atendida'
        END
    FROM NUMEROS;

    -- repetimos la misma agrupacion cinco veces
    SET @REPETICION = 1;

    WHILE @REPETICION <= 5
    BEGIN

        SET @INICIO = SYSDATETIME();

        -- ejecutamos la agrupacion por estado
        SELECT estado, COUNT(*) AS total_citas
        INTO #RESULTADO
        FROM #CITAS_PRUEBA
        GROUP BY estado;

        SET @FIN = SYSDATETIME();

        -- calculamos el tiempo de ejecucion
        SET @TIEMPO =
            DATEDIFF_BIG(NANOSECOND, @INICIO, @FIN) / 1000000000.0;

        -- guardamos el tiempo de cada repeticion
        INSERT INTO #MEDICIONES
        VALUES (@REGISTROS, @REPETICION, @TIEMPO);

        DROP TABLE #RESULTADO;

        SET @REPETICION = @REPETICION + 1;
    END;

    FETCH NEXT FROM CURSOR_VOLUMENES INTO @REGISTROS;
END;

CLOSE CURSOR_VOLUMENES;
DEALLOCATE CURSOR_VOLUMENES;

-- mostramos las 25 mediciones individuales
SELECT
    registros,
    repeticion,
    tiempo_segundos
FROM #MEDICIONES
ORDER BY registros, repeticion;

-- mostramos el resumen estadistico
SELECT
    registros,
    AVG(tiempo_segundos) AS promedio,
    MIN(tiempo_segundos) AS minimo,
    MAX(tiempo_segundos) AS maximo,
    STDEV(tiempo_segundos) AS desviacion_estandar
FROM #MEDICIONES
GROUP BY registros
ORDER BY registros;



USE DATAMARTVETERINARIA;
GO

-- mostramos las columnas y los primeros registros
SELECT TOP 10 *
FROM dbo.FAC_VENTAS;

-- contamos los registros de la tabla de hechos
SELECT COUNT(*) AS TOTAL_REGISTROS
FROM dbo.FAC_VENTAS;

-- comprobamos los indicadores reales del data mart
SELECT
    COUNT(*) AS TOTAL_REGISTROS,
    SUM(CANTIDAD_CITAS) AS TOTAL_CITAS,
    SUM(CANTIDAD_ATENCIONES) AS TOTAL_ATENCIONES,
    SUM(MONTO_ATENCION) AS INGRESOS_TOTALES
FROM dbo.FAC_VENTAS;


