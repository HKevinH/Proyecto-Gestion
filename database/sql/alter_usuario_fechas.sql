/*
  Ejecutar en Site4Now si la tabla usuario ya existe sin estas columnas.
  Corrige el error: Invalid column name 'Fecha_Actualizacion'
*/

IF COL_LENGTH('dbo.usuario', 'Fecha_Actualizacion') IS NULL
BEGIN
    ALTER TABLE dbo.usuario ADD Fecha_Actualizacion DATETIME2 NULL;
END;
GO

IF COL_LENGTH('dbo.usuario', 'Fecha_Ultima_Conexion') IS NULL
BEGIN
    ALTER TABLE dbo.usuario ADD Fecha_Ultima_Conexion DATETIME2 NULL;
END;
GO
