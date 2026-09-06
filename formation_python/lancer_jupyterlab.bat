@echo off
REM ============================================================================
REM  lancer_jupyterlab.bat -- Point d'entree unique (Windows)
REM  Formation Python pour l'analyse de donnees
REM
REM  A double-cliquer au debut de chaque seance. C'est le SEUL fichier que les
REM  participants utilisent :
REM    - environnement absent ou incomplet  -> appelle installer.bat /auto
REM    - environment.yml modifie (empreinte) -> appelle installer.bat /auto
REM    - sinon                               -> ouvre directement JupyterLab
REM
REM  IMPORTANT : ce script active conda AVANT de lancer jupyter, pour que les
REM  noyaux heritent du PATH de l'environnement (necessaire aux DLL natives de
REM  numpy/MKL). Sans cela, les noyaux plantent avec le code 0xC06D007F des le
REM  premier "import numpy".
REM ============================================================================

chcp 65001 >nul
SETLOCAL ENABLEDELAYEDEXPANSION

SET "ENV_NAME=formation_python"
SET "SENTINEL_NAME=.install_complete"

SET "DOSSIER=%~dp0"
IF "!DOSSIER:~-1!"=="\" SET "DOSSIER=!DOSSIER:~0,-1!"
SET "ENV_PATH=%LOCALAPPDATA%\!ENV_NAME!"
SET "SENTINEL=!ENV_PATH!\!SENTINEL_NAME!"

REM === Faut-il installer ou mettre a jour ? ==================================
SET "A_INSTALLER="
SET "MISE_A_JOUR="
IF NOT EXIST "!ENV_PATH!\python.exe" SET "A_INSTALLER=1"
IF NOT EXIST "!SENTINEL!"             SET "A_INSTALLER=1"

REM --- Empreinte : detecte une modification de environment.yml --------------
REM   En cas de doute (certutil absent, sentinelle ancienne), on ne force
REM   rien : on laisse JupyterLab demarrer normalement.
IF DEFINED A_INSTALLER GOTO :apres_empreinte
IF NOT EXIST "!DOSSIER!\environment.yml" GOTO :apres_empreinte
SET "EMP_NEW="
SET "EMP_OLD="
FOR /F "skip=1 delims=" %%h IN ('certutil -hashfile "!DOSSIER!\environment.yml" MD5 2^>nul') DO IF NOT DEFINED EMP_NEW SET "EMP_NEW=%%h"
IF DEFINED EMP_NEW SET "EMP_NEW=!EMP_NEW: =!"
FOR /F "usebackq tokens=2 delims==" %%e IN (`findstr /B "empreinte=" "!SENTINEL!" 2^>nul`) DO SET "EMP_OLD=%%e"
IF NOT DEFINED EMP_NEW GOTO :apres_empreinte
IF NOT DEFINED EMP_OLD GOTO :apres_empreinte
IF /I "!EMP_NEW!"=="!EMP_OLD!" GOTO :apres_empreinte
SET "A_INSTALLER=1"
SET "MISE_A_JOUR=1"
:apres_empreinte

REM === Installation ou mise a jour automatique ===============================
SET "TITRE=PREMIER LANCEMENT - installation des outils"
SET "DETAIL=Comptez 5 a 15 minutes. Cela n'arrivera qu'une seule fois."
IF DEFINED MISE_A_JOUR SET "TITRE=MISE A JOUR - la liste des outils a change"
IF DEFINED MISE_A_JOUR SET "DETAIL=Comptez 1 a 5 minutes. C'est une mise a jour, pas une reinstallation."

IF DEFINED A_INSTALLER (
    IF NOT EXIST "!DOSSIER!\installer.bat" (
        echo.
        echo   Le fichier installer.bat est introuvable dans ce dossier.
        echo   Verifiez que l'archive a bien ete decompressee en entier.
        echo.
        pause
        EXIT /B 1
    )
    echo.
    echo ============================================================
    echo   !TITRE!
    echo ============================================================
    echo.
    echo   !DETAIL!
    echo.
    CALL "!DOSSIER!\installer.bat" /auto
    IF ERRORLEVEL 1 (
        echo.
        echo   Operation interrompue - JupyterLab ne peut pas demarrer.
        echo   Envoyez le fichier installation.log au formateur.
        echo.
        pause
        EXIT /B 1
    )
    IF NOT EXIST "!SENTINEL!" (
        echo.
        echo   Operation interrompue - JupyterLab ne peut pas demarrer.
        echo   Double-cliquez sur diagnostic.bat.
        echo.
        pause
        EXIT /B 1
    )
    REM --- Avertissements non bloquants : on s'arrete pour qu'ils soient lus --
    IF EXIST "!DOSSIER!\avertissements.txt" (
        echo.
        echo   ------------------------------------------------------------
        echo   POINTS A SIGNALER - l'installation a abouti, mais notez ceci :
        echo   ------------------------------------------------------------
        type "!DOSSIER!\avertissements.txt"
        echo   ------------------------------------------------------------
        echo.
        echo   Appuyez sur une touche pour ouvrir JupyterLab.
        pause >nul
    )
)

REM === Detection de conda ====================================================
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
    echo.
    echo   Anaconda est introuvable. Double-cliquez sur diagnostic.bat.
    echo.
    pause
    EXIT /B 1
)

REM === Activation (CRITIQUE : sans cela les noyaux plantent) =================
CALL "!CONDA_BAT!" activate "!ENV_PATH!"
IF ERRORLEVEL 1 (
    echo.
    echo   L'activation a echoue. Double-cliquez sur diagnostic.bat.
    echo.
    pause
    EXIT /B 1
)

echo.
echo ============================================================
echo   FORMATION PYTHON - JupyterLab demarre
echo ============================================================
echo.
echo   Dossier de travail : !DOSSIER!
echo.
echo   JupyterLab va s'ouvrir dans votre navigateur.
echo   NE FERMEZ PAS cette fenetre pendant que vous travaillez :
echo   elle fait tourner JupyterLab en arriere-plan.
echo.
echo   Pour arreter en fin de seance : fermez cette fenetre.
echo ============================================================
echo.

jupyter lab --notebook-dir="!DOSSIER!"

ENDLOCAL
EXIT /B 0
