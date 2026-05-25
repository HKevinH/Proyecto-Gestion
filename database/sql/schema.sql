/*
  Esquema SQL Server - Sistema de Gobernanza de IA
  Proyecto-Gestion

  Uso:
    1. Crear la base de datos en el servidor (o usar una existente).
    2. Ejecutar este script en SQL Server Management Studio, Azure Data Studio
       o el panel SQL de Site4Now.
    3. Configurar las variables DB_* en el archivo .env de Laravel.
    4. Ejecutar: php artisan migrate --force
       (crea tablas auxiliares de Laravel: sessions, cache, jobs, etc.)

  Nota: Si ya tienes datos en Site4Now, NO ejecutes DROP.
        Este script solo CREA tablas que no existan (IF NOT EXISTS).
*/

/* ============================================================
   TABLAS DE NEGOCIO
   ============================================================ */

IF OBJECT_ID(N'dbo.usuario', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.usuario (
        Id                  INT IDENTITY(1,1) NOT NULL,
        Nombre_Usuario      NVARCHAR(150)     NOT NULL,
        Empresa             NVARCHAR(200)     NULL,
        NIT                 NVARCHAR(50)      NULL,
        Tipo_Documento      NVARCHAR(20)      NULL,
        Numero_Documento    NVARCHAR(50)      NULL,
        Sector              NVARCHAR(100)     NULL,
        Pais                NVARCHAR(100)     NULL,
        Correo              NVARCHAR(255)     NOT NULL,
        Telefono            NVARCHAR(30)      NULL,
        Contrasena          NVARCHAR(255)     NOT NULL,
        Rol                 NVARCHAR(20)      NOT NULL CONSTRAINT DF_usuario_Rol DEFAULT ('usuario'),
        Activate            VARCHAR(5)        NOT NULL CONSTRAINT DF_usuario_Activate DEFAULT ('False'),
        FechaCrea               DATETIME2         NULL CONSTRAINT DF_usuario_FechaCrea DEFAULT (SYSUTCDATETIME()),
        Fecha_Actualizacion     DATETIME2         NULL,
        Fecha_Ultima_Conexion   DATETIME2         NULL,
        Foto_Perfil             NVARCHAR(500)     NULL,
        CONSTRAINT PK_usuario PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT UQ_usuario_Correo UNIQUE (Correo),
        CONSTRAINT CK_usuario_Activate_TrueFalse CHECK (Activate IN ('True', 'False')),
        CONSTRAINT CK_usuario_Rol CHECK (Rol IN ('usuario', 'admin'))
    );
END;
GO

IF OBJECT_ID(N'dbo.Evaluacion', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Evaluacion (
        Id_Evaluacion   INT IDENTITY(1,1) NOT NULL,
        Id_Usuario      INT               NOT NULL,
        Fecha           DATETIME2         NOT NULL CONSTRAINT DF_Evaluacion_Fecha DEFAULT (SYSUTCDATETIME()),
        Tiempo          DECIMAL(10,2)     NULL,
        Puntuacion      DECIMAL(10,2)     NULL,
        Nombre          NVARCHAR(200)     NULL,
        Marco           NVARCHAR(150)     NULL,
        Framework       NVARCHAR(150)     NULL,
        Estado          NVARCHAR(50)      NULL CONSTRAINT DF_Evaluacion_Estado DEFAULT ('En proceso'),
        PDF_Path        NVARCHAR(500)     NULL,
        CONSTRAINT PK_Evaluacion PRIMARY KEY CLUSTERED (Id_Evaluacion),
        CONSTRAINT FK_Evaluacion_usuario FOREIGN KEY (Id_Usuario)
            REFERENCES dbo.usuario (Id) ON DELETE CASCADE
    );

    CREATE INDEX IX_Evaluacion_Id_Usuario ON dbo.Evaluacion (Id_Usuario);
    CREATE INDEX IX_Evaluacion_Fecha ON dbo.Evaluacion (Fecha DESC);
END;
GO

IF OBJECT_ID(N'dbo.Respuestas', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Respuestas (
        Id_Respuesta        INT IDENTITY(1,1) NOT NULL,
        Id_Evaluacion       INT               NOT NULL,
        Id_Pregunta         INT               NOT NULL,
        Respuesta_Usuario   NVARCHAR(MAX)     NOT NULL,
        Fecha_Creacion      DATETIME2         NULL CONSTRAINT DF_Respuestas_Fecha_Creacion DEFAULT (SYSUTCDATETIME()),
        Fecha_Actualizacion DATETIME2         NULL,
        CONSTRAINT PK_Respuestas PRIMARY KEY CLUSTERED (Id_Respuesta),
        CONSTRAINT FK_Respuestas_Evaluacion FOREIGN KEY (Id_Evaluacion)
            REFERENCES dbo.Evaluacion (Id_Evaluacion) ON DELETE CASCADE,
        CONSTRAINT UQ_Respuestas_Evaluacion_Pregunta UNIQUE (Id_Evaluacion, Id_Pregunta)
    );

    CREATE INDEX IX_Respuestas_Id_Evaluacion ON dbo.Respuestas (Id_Evaluacion);
END;
GO

IF OBJECT_ID(N'dbo.Resultados', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Resultados (
        Id_Resultado    INT IDENTITY(1,1) NOT NULL,
        Id_Evaluacion   INT               NOT NULL,
        Resultado       NVARCHAR(MAX)     NULL,
        Puntuacion      DECIMAL(10,2)     NULL,
        PDF_Path        NVARCHAR(500)     NULL,
        Fecha_Creacion  DATETIME2         NULL CONSTRAINT DF_Resultados_Fecha_Creacion DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_Resultados PRIMARY KEY CLUSTERED (Id_Resultado),
        CONSTRAINT FK_Resultados_Evaluacion FOREIGN KEY (Id_Evaluacion)
            REFERENCES dbo.Evaluacion (Id_Evaluacion) ON DELETE CASCADE,
        CONSTRAINT UQ_Resultados_Id_Evaluacion UNIQUE (Id_Evaluacion)
    );
END;
GO

IF OBJECT_ID(N'dbo.Documentos_Adjuntos', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Documentos_Adjuntos (
        Id_Documento    INT IDENTITY(1,1) NOT NULL,
        Id_Evaluacion   INT               NOT NULL,
        Nombre_Archivo  NVARCHAR(500)     NOT NULL,
        Tipo            NVARCHAR(20)      NOT NULL CONSTRAINT DF_Documentos_Adjuntos_Tipo DEFAULT ('pdf'),
        Fecha_Creacion  DATETIME2         NULL CONSTRAINT DF_Documentos_Adjuntos_Fecha_Creacion DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_Documentos_Adjuntos PRIMARY KEY CLUSTERED (Id_Documento),
        CONSTRAINT FK_Documentos_Adjuntos_Evaluacion FOREIGN KEY (Id_Evaluacion)
            REFERENCES dbo.Evaluacion (Id_Evaluacion) ON DELETE CASCADE
    );

    CREATE INDEX IX_Documentos_Adjuntos_Id_Evaluacion ON dbo.Documentos_Adjuntos (Id_Evaluacion);
END;
GO
