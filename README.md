
# Veterinaria San Francisco
## Solución integrada de Inteligencia de Negocios y Big Data

### Descripción del proyecto
Proyecto académico orientado a la integración, procesamiento y análisis de información de la Veterinaria San Francisco mediante herramientas de bases de datos, Inteligencia de Negocios y Big Data.

La solución integra una base de datos operacional, un Data Mart dimensional, procesos ETL, visualizaciones en Power BI y análisis de datos con Apache Spark.

### Objetivo general
Implementar una solución de Inteligencia de Negocios y Big Data que permita organizar, transformar y analizar los datos de la veterinaria para apoyar la toma de decisiones mediante indicadores de gestión.

### Tecnologías utilizadas
- Microsoft SQL Server 2025 (17.0.1155.3).
- SQL Server Management Studio 22.6.0.
- Power BI Desktop 2.159.883.0 (octubre de 2026).
- Apache Spark y Databricks.
- Google Colab.
- SQL, T-SQL, DAX y Python.

### Componentes del proyecto
**1. Base de datos operacional**
Base de datos `VeterinariaBD1` para gestionar clientes, mascotas, veterinarios, citas, historias clínicas, tratamientos, vacunas y pagos.

**2. Data Mart**
Base de datos `DATAMARTVETERINARIA`, organizada mediante un modelo dimensional con una tabla de hechos y cinco dimensiones:
- FAC_VENTAS
- DIM_CLIENTE
- DIM_MASCOTA
- DIM_VETERINARIO
- DIM_SERVICIO
- DIM_FECHA

**3. Proceso ETL**
Procedimiento `USP_ETL_DATAMARTVETERINARIA1`, encargado de ejecutar las operaciones de extracción, transformación y carga hacia el Data Mart.

**4. Inteligencia de Negocios**
Dashboard desarrollado en Power BI para analizar:
- Citas y atenciones realizadas.
- Ingresos y ticket promedio.
- Frecuencia de atención.
- Recurrencia de clientes.
- Clientes nuevos e inactivos.
- Evolución de los indicadores.

**5. Big Data**
Procesamiento y análisis de datos con Apache Spark mediante notebooks y operaciones sobre DataFrames y RDD.

**6. Pruebas y validaciones**
Scripts SQL para comprobar:
- Calidad e integridad de datos.
- Consistencia entre origen y Data Mart.
- Seguridad y permisos.
- Rendimiento del proceso ETL.
- Escalabilidad ante distintos volúmenes de registros.

### Ejecución general
1. Crear la base de datos operacional `VeterinariaBD1`.
2. Ejecutar los scripts de creación y carga de datos.
3. Crear `DATAMARTVETERINARIA`.
4. Ejecutar el procedimiento ETL correspondiente.
5. Verificar los indicadores mediante los scripts SQL.
6. Abrir el archivo `.pbix` en Power BI Desktop.
7. Ejecutar los notebooks en los entornos correspondientes.

**Nota:** La ejecución requiere configurar previamente las conexiones y rutas de archivos según el entorno local.

### Versión
v1.0 — Versión académica del proyecto.

### Alcance
Proyecto desarrollado con fines académicos. Los resultados y las pruebas de rendimiento corresponden al entorno y a los conjuntos de datos utilizados durante su elaboración.
