@echo off
REM ============================================================================
REM  diagnostic.bat -- Diagnostic complet (Windows)
REM  Formation Python pour l'analyse de donnees
REM
REM  Ne modifie RIEN. Affiche l'etat de l'installation et ecrit diagnostic.txt.
REM  A envoyer au formateur en cas de blocage.
REM ============================================================================

chcp 65001 >nul
SETLOCAL ENABLEDELAYEDEXPANSION

SET "ENV_NAME=formation_python"
SET "SENTINEL_NAME=.install_complete"

SET "DOSSIER=%~dp0"
IF "!DOSSIER:~-1!"=="\" SET "DOSSIER=!DOSSIER:~0,-1!"
SET "ENV_PATH=%LOCALAPPDATA%\!ENV_NAME!"
SET "RAPPORT=!DOSSIER!\diagnostic.txt"

> "!RAPPORT!" echo === DIAGNOSTIC - %DATE% %TIME% ===
>> "!RAPPORT!" echo Dossier   : !DOSSIER!
>> "!RAPPORT!" echo Env prevu : !ENV_PATH!
>> "!RAPPORT!" echo.

echo.
echo ============================================================
echo   FORMATION PYTHON - DIAGNOSTIC
echo ============================================================
echo.

REM === [1] Fichiers du dossier ===============================================
echo [1] Fichiers de la formation
call :test_fichier "!DOSSIER!\environment.yml"      "environment.yml"
call :test_fichier "!DOSSIER!\installer.bat"        "installer.bat"
call :test_fichier "!DOSSIER!\lancer_jupyterlab.bat" "lancer_jupyterlab.bat"
call :test_dossier "!DOSSIER!\seances"              "dossier seances"
call :test_dossier "!DOSSIER!\donnees\brut"         "dossier donnees\brut"
echo.

REM === [2] Anaconda ==========================================================
echo [2] Anaconda
SET "CONDA_BAT="
IF EXIST "%USERPROFILE%\anaconda3\condabin\conda.bat"   SET "CONDA_BAT=%USERPROFILE%\anaconda3\condabin\conda.bat"
IF EXIST "%USERPROFILE%\miniconda3\condabin\conda.bat"  SET "CONDA_BAT=%USERPROFILE%\miniconda3\condabin\conda.bat"
IF EXIST "%USERPROFILE%\miniforge3\condabin\conda.bat"  SET "CONDA_BAT=%USERPROFILE%\miniforge3\condabin\conda.bat"
IF EXIST "%USERPROFILE%\mambaforge\condabin\conda.bat"  SET "CONDA_BAT=%USERPROFILE%\mambaforge\condabin\conda.bat"
IF NOT DEFINED CONDA_BAT IF EXIST "C:\ProgramData\Anaconda3\condabin\conda.bat"  SET "CONDA_BAT=C:\ProgramData\Anaconda3\condabin\conda.bat"
IF NOT DEFINED CONDA_BAT IF EXIST "C:\ProgramData\Miniconda3\condabin\conda.bat" SET "CONDA_BAT=C:\ProgramData\Miniconda3\condabin\conda.bat"
IF NOT DEFINED CONDA_BAT (
    FOR /F "delims=" %%i IN ('where conda.bat 2^>nul') DO IF NOT DEFINED CONDA_BAT SET "CONDA_BAT=%%i"
)
IF NOT DEFINED CONDA_BAT (
    echo     [ECHEC] Anaconda introuvable
    >> "!RAPPORT!" echo [ECHEC] conda introuvable
    echo             -^> Reprenez les etapes 1 et 2 du guide
) ELSE (
    echo     [OK]    !CONDA_BAT!
    >> "!RAPPORT!" echo [OK] conda : !CONDA_BAT!
    FOR /F "delims=" %%v IN ('CALL "!CONDA_BAT!" --version 2^>nul') DO (
        echo             Version : %%v
        >> "!RAPPORT!" echo      version : %%v
    )
    FOR /F "delims=" %%s IN ('CALL "!CONDA_BAT!" config --get ssl_verify 2^>nul') DO (
        >> "!RAPPORT!" echo      ssl_verify : %%s
    )
)
echo.

REM === [3] Environnement =====================================================
echo [3] Environnement de la formation
IF NOT EXIST "!ENV_PATH!\python.exe" (
    echo     [ECHEC] Environnement absent
    >> "!RAPPORT!" echo [ECHEC] env absent : !ENV_PATH!
    echo             -^> Double-cliquez sur installer.bat
    goto :fin
)
echo     [OK]    !ENV_PATH!
>> "!RAPPORT!" echo [OK] env present : !ENV_PATH!

IF NOT EXIST "!ENV_PATH!\!SENTINEL_NAME!" (
    echo     [ECHEC] Installation incomplete (sentinelle absente)
    >> "!RAPPORT!" echo [ECHEC] sentinelle absente
    echo             -^> Double-cliquez sur installer.bat
) ELSE (
    echo     [OK]    Installation complete
    >> "!RAPPORT!" echo [OK] sentinelle presente
)
echo.

REM === [4] Imports ===========================================================
echo [4] Outils Python (test reel)
CALL "!CONDA_BAT!" activate "!ENV_PATH!" 1>nul 2>&1
IF ERRORLEVEL 1 (
    echo     [ECHEC] Activation impossible
    >> "!RAPPORT!" echo [ECHEC] conda activate a echoue
    goto :fin
)
call :test_import pandas
call :test_import numpy
call :test_import matplotlib
call :test_import seaborn
call :test_import scipy
call :test_import statsmodels
call :test_import openpyxl
call :test_import jupyterlab
echo.

REM === [5] Interpreteur ======================================================
echo [5] Interpreteur utilise
FOR /F "delims=" %%p IN ('python -c "import sys; print(sys.executable)" 2^>nul') DO (
    echo     %%p
    >> "!RAPPORT!" echo interpreteur : %%p
)
echo.

REM === [6] Noyaux Jupyter ====================================================
echo [6] Noyaux Jupyter
call :test_noyau "%APPDATA%\jupyter\kernels\python3\kernel.json"
call :test_noyau "%APPDATA%\Python\share\jupyter\kernels\python3\kernel.json"
IF EXIST "%APPDATA%\jupyter\kernels\!ENV_NAME!\kernel.json" (
    echo     [OK]    Noyau de la formation enregistre
    >> "!RAPPORT!" echo [OK] noyau formation enregistre
) ELSE (
    echo     [NOTE]  Noyau de la formation non enregistre
    >> "!RAPPORT!" echo [NOTE] noyau formation absent
    echo             -^> Relancez installer.bat
)

:fin
echo.
echo ============================================================
echo   Rapport ecrit dans : diagnostic.txt
echo   Envoyez ce fichier au formateur en cas de blocage.
echo ============================================================
echo.
pause
ENDLOCAL
EXIT /B 0

REM ===========================================================================
:test_fichier
IF EXIST "%~1" (
    echo     [OK]    %~2
    >> "!RAPPORT!" echo [OK] %~2
) ELSE (
    echo     [ECHEC] %~2 manquant
    >> "!RAPPORT!" echo [ECHEC] %~2 manquant
)
EXIT /B 0

:test_dossier
IF EXIST "%~1\" (
    echo     [OK]    %~2
    >> "!RAPPORT!" echo [OK] %~2
) ELSE (
    echo     [NOTE]  %~2 absent - relancez installer.bat
    >> "!RAPPORT!" echo [NOTE] %~2 absent
)
EXIT /B 0

:test_import
python -c "import %~1" 1>nul 2>&1
IF !ERRORLEVEL! NEQ 0 (
    echo     [ECHEC] %~1
    >> "!RAPPORT!" echo [ECHEC] import %~1
) ELSE (
    echo     [OK]    %~1
    >> "!RAPPORT!" echo [OK] import %~1
)
EXIT /B 0

:test_noyau
SET "KJ=%~1"
IF NOT EXIST "!KJ!" EXIT /B 0
findstr /C:"!ENV_PATH:\=\\!" "!KJ!" >nul 2>&1
IF NOT ERRORLEVEL 1 EXIT /B 0
echo     [ALERTE] Un ancien noyau 'python3' peut masquer celui de la formation
echo              Fichier : !KJ!
echo              Dans JupyterLab : Kernel ^> Change Kernel ^> "Python 3 (formation)"
>> "!RAPPORT!" echo [ALERTE] noyau concurrent : !KJ!
EXIT /B 0
