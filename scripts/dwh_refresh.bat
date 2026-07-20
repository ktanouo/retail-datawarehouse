@echo off
echo 🚀 Démarrage du rafraîchissement du Data Warehouse...

:: 1. Étape Python
echo 📥 [1/2] Ingestion des fichiers CSV...
python staging_ingestion.py
if %errorlevel% neq 0 (echo ❌ Erreur Python & exit /b %errorlevel%)

:: 2. Configuration mot de passe pour psql (à adapter avec ton pass ou via variable)
set "PGPASSWORD=%DB_PASSWORD%"

:: 3. Étape SQL
echo 🔄 [2/2] Transformation vers le modèle en étoile...
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -h localhost -p 5433 -U postgres -d retail_staging -f ../sql/02_init_dwh.sql
if %errorlevel% neq 0 (echo ❌ Erreur SQL & exit /b %errorlevel%)

echo 🎉 Le Data Warehouse est à jour !
pause