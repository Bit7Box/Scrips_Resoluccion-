
@echo off
setlocal

if not exist "C:\ETL_Veterinaria" mkdir "C:\ETL_Veterinaria"

echo ======================================== >> "C:\ETL_Veterinaria\registro_etl.txt"
echo INICIO: %date% %time% >> "C:\ETL_Veterinaria\registro_etl.txt"

sqlcmd -S localhost -E -d DATAMARTVETERINARIA -b -r 1 -Q "EXEC dbo.USP_ETL_DATAMARTVETERINARIA1;" >> "C:\ETL_Veterinaria\registro_etl.txt" 2>&1

if errorlevel 1 (
    echo RESULTADO: ERROR >> "C:\ETL_Veterinaria\registro_etl.txt"
) else (
    echo RESULTADO: CORRECTO >> "C:\ETL_Veterinaria\registro_etl.txt"
)

echo FIN: %date% %time% >> "C:\ETL_Veterinaria\registro_etl.txt"
endlocal
