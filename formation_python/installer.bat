@echo off
REM ============================================================================
REM  installer.bat -- Installation / reparation de l'environnement (Windows)
REM  Formation Python pour l'analyse de donnees
REM
REM  Appele automatiquement par lancer_jupyterlab.bat (avec /auto) quand
REM  l'environnement est absent, incomplet, ou que environment.yml a change.
REM  Peut aussi etre lance seul pour reparer une installation.
REM
REM  Architecture :
REM    - Source de verite : environment.yml (dans ce meme dossier)
REM    - Environnement cree dans %LOCALAPPDATA%\formation_python
REM      (jamais dans un dossier synchronise : OneDrive/Drive corrompent conda)
REM    - Sentinelle d'installation : <env>\.install_complete
REM    - Journal : installation.log (dans ce meme dossier)
REM ============================================================================

chcp 65001 >nul
SETLOCAL ENABLEDELAYEDEXPANSION

REM === Mode automatique ======================================================
REM   Appele avec /auto par lancer_jupyterlab.bat : on supprime les pauses,
REM   c'est le lanceur qui prend la main a la fin.
SET "AUTO="
IF /I "%~1"=="/auto" SET "AUTO=1"

REM === Parametres ============================================================
SET "ENV_NAME=formation_python"
SET "KERNEL_NAME=formation_python"
SET "KERNEL_LABEL=Python 3 (formation)"
SET "SENTINEL_NAME=.install_complete"

REM === Chemins ===============================================================
SET "DOSSIER=%~dp0"
IF "!DOSSIER:~-1!"=="\" SET "DOSSIER=!DOSSIER:~0,-1!"
SET "ENV_YML=!DOSSIER!\environment.yml"
SET "LOGFILE=!DOSSIER!\installation.log"
SET "ENV_PATH=%LOCALAPPDATA%\!ENV_NAME!"
SET "SENTINEL=!ENV_PATH!\!SENTINEL_NAME!"

REM === Journal : mode AJOUT (on ne perd pas les traces des essais precedents)
>> "!LOGFILE!" echo.
>> "!LOGFILE!" echo ============================================================
>> "!LOGFILE!" echo === installer.bat - %DATE% %TIME% ===
>> "!LOGFILE!" echo ============================================================
call :log "DOSSIER  = !DOSSIER!"
call :log "ENV_PATH = !ENV_PATH!"

SET "AVERTIS=!DOSSIER!\avertissements.txt"
IF EXIST "!AVERTIS!" DEL "!AVERTIS!" >nul 2>&1

echo.
echo ============================================================
echo   FORMATION PYTHON - INSTALLATION
echo ============================================================
echo.
echo   Cette operation prend 5 a 15 minutes.
echo   Beaucoup de texte va defiler : c'est normal.
echo   Ne fermez pas cette fenetre avant le message de fin.
echo.

REM === Verifications prealables ==============================================
IF NOT EXIST "!ENV_YML!" (
    call :err "Le fichier environment.yml est introuvable."
    call :err "  Attendu ici : !ENV_YML!"
    call :err "  Verifiez que vous avez bien decompresse le dossier complet."
    goto :fatal
)

REM === Creation de l'arborescence de travail =================================
echo [1/6] Creation du dossier de travail...
call :mkdir "!DOSSIER!\seances"
call :mkdir "!DOSSIER!\donnees"
call :mkdir "!DOSSIER!\donnees\brut"
call :mkdir "!DOSSIER!\donnees\propre"
call :mkdir "!DOSSIER!\resultats"
call :mkdir "!DOSSIER!\resultats\figures"
call :mkdir "!DOSSIER!\resultats\tableaux"
call :mkdir "!DOSSIER!\projet_final"
echo       OK

REM === Detection de conda ====================================================
echo [2/6] Recherche d'Anaconda sur votre ordinateur...
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
    call :err "Anaconda est introuvable sur cet ordinateur."
    call :err "  Reprenez les etapes 1 et 2 du guide d'installation,"
    call :err "  puis relancez ce fichier."
    goto :fatal
)
call :log "Conda detecte : !CONDA_BAT!"
echo       OK

REM === Configuration de conda ================================================
echo [3/6] Configuration de conda...
CALL "!CONDA_BAT!" config --set solver libmamba          1>>"!LOGFILE!" 2>&1
CALL "!CONDA_BAT!" config --add channels conda-forge     1>>"!LOGFILE!" 2>&1
CALL "!CONDA_BAT!" config --set channel_priority strict  1>>"!LOGFILE!" 2>&1
echo       OK

REM === Creation / mise a jour de l'environnement =============================
IF EXIST "!ENV_PATH!\python.exe" (
    echo [4/6] Environnement existant detecte - mise a jour...
    call :log "conda env update -p !ENV_PATH! --prune"
    CALL "!CONDA_BAT!" env update -p "!ENV_PATH!" -f "!ENV_YML!" --prune 1>>"!LOGFILE!" 2>&1
    IF ERRORLEVEL 1 (
        call :err "La mise a jour de l'environnement a echoue."
        goto :diagnostic_reseau
    )
) ELSE (
    echo [4/6] Creation de l'environnement - patientez 5 a 15 minutes...
    call :log "conda env create -p !ENV_PATH!"
    CALL "!CONDA_BAT!" env create -p "!ENV_PATH!" -f "!ENV_YML!" 1>>"!LOGFILE!" 2>&1
    IF ERRORLEVEL 1 (
        call :err "La creation de l'environnement a echoue."
        goto :diagnostic_reseau
    )
)
echo       OK

REM === Test des imports (environnement active) ===============================
REM   IMPORTANT : doit tourner AVEC conda active, sinon les DLL natives de
REM   numpy/MKL manquent et python plante avec le code 0xC06D007F.
REM   On teste ERRORLEVEL NEQ 0 : "IF ERRORLEVEL 1" rate les codes negatifs.
echo [5/6] Verification des outils installes...
CALL "!CONDA_BAT!" activate "!ENV_PATH!" 1>>"!LOGFILE!" 2>&1
IF ERRORLEVEL 1 (
    call :err "L'activation de l'environnement a echoue."
    call :err "  Essayez : ouvrez Anaconda Prompt, tapez  conda init cmd.exe"
    call :err "  puis relancez ce fichier."
    goto :fatal
)
python -c "import pandas, numpy, scipy, statsmodels, matplotlib, seaborn, openpyxl, sqlalchemy, jupyterlab" 1>>"!LOGFILE!" 2>&1
IF !ERRORLEVEL! NEQ 0 (
    call :err "Certains outils ne fonctionnent pas - installation incomplete."
    call :err "  Code d'erreur : !ERRORLEVEL!"
    goto :fatal
)
echo       OK

REM === Enregistrement du noyau Jupyter =======================================
REM   Evite qu'un ancien noyau "python3" masque celui de la formation.
echo [6/6] Enregistrement du noyau Jupyter...
python -m ipykernel install --user --name !KERNEL_NAME! --display-name "!KERNEL_LABEL!" 1>>"!LOGFILE!" 2>&1
IF !ERRORLEVEL! NEQ 0 (
    call :avertir "Le noyau Jupyter n'a pas pu etre enregistre. Si un notebook affiche 'No module named ...', voir diagnostic.bat."
) ELSE (
    echo       OK
)

REM === Detection d'un noyau "python3" concurrent =============================
CALL :alerte_noyau "%APPDATA%\jupyter\kernels\python3\kernel.json"
CALL :alerte_noyau "%APPDATA%\Python\share\jupyter\kernels\python3\kernel.json"

REM === Sentinelle + empreinte d'environment.yml ==============================
REM   L'empreinte permet au lanceur de detecter que la liste des outils a
REM   change, et de relancer la mise a jour tout seul.
SET "EMP="
FOR /F "skip=1 delims=" %%h IN ('certutil -hashfile "!ENV_YML!" MD5 2^>nul') DO IF NOT DEFINED EMP SET "EMP=%%h"
IF DEFINED EMP SET "EMP=!EMP: =!"
> "!SENTINEL!" echo Installe le %DATE% a %TIME%
>> "!SENTINEL!" echo empreinte=!EMP!
call :log "Sentinelle ecrite : !SENTINEL! (empreinte=!EMP!)"

echo.
echo ============================================================
echo   INSTALLATION TERMINEE
echo ============================================================
echo.
IF EXIST "!AVERTIS!" (
    echo   ------------------------------------------------------------
    echo   POINTS A SIGNALER - a lire, l'installation a bien abouti :
    echo   ------------------------------------------------------------
    type "!AVERTIS!"
    echo   ------------------------------------------------------------
    echo.
)
IF NOT DEFINED AUTO (
    echo   Vous pouvez maintenant double-cliquer sur :
    echo       lancer_jupyterlab.bat
    echo.
)
echo   En cas de probleme : double-cliquez sur diagnostic.bat
echo ============================================================
echo.
IF NOT DEFINED AUTO pause
ENDLOCAL
EXIT /B 0

REM ===========================================================================
REM  SOUS-ROUTINES
REM ===========================================================================
:log
>> "!LOGFILE!" echo [%TIME%] %~1
EXIT /B 0

:err
echo.
echo   ERREUR: %~1
>> "!LOGFILE!" echo [%TIME%] ERREUR: %~1
EXIT /B 0

:avertir
echo.
echo   NOTE: %~1
>> "!AVERTIS!" echo   - %~1
>> "!LOGFILE!" echo [%TIME%] AVERTISSEMENT: %~1
EXIT /B 0

:mkdir
IF NOT EXIST "%~1" MKDIR "%~1" 2>nul
EXIT /B 0

:alerte_noyau
SET "KJ=%~1"
IF NOT EXIST "!KJ!" EXIT /B 0
findstr /C:"!ENV_PATH:\=\\!" "!KJ!" >nul 2>&1
IF NOT ERRORLEVEL 1 EXIT /B 0
call :avertir "Un ancien noyau Jupyter est present sur cet ordinateur. Si un notebook affiche 'No module named ...', allez dans JupyterLab : Kernel > Change Kernel > \"!KERNEL_LABEL!\""
call :log "Noyau concurrent detecte : !KJ!"
EXIT /B 0

:diagnostic_reseau
echo.
echo   Causes les plus frequentes :
echo     - Pas de connexion internet
echo     - Reseau d'entreprise avec inspection HTTPS (erreur SSL)
echo       Solution : ouvrez Anaconda Prompt et tapez
echo           conda config --set ssl_verify false
echo       puis relancez ce fichier.
echo     - Espace disque insuffisant (prevoir 3 Go)
echo.
echo   Envoyez le fichier installation.log au formateur.
goto :fatal

:fatal
echo.
echo ============================================================
echo   INSTALLATION INTERROMPUE
echo ============================================================
echo.
echo   Journal detaille : !LOGFILE!
echo   Envoyez ce fichier au formateur, il contient la cause exacte.
echo.
IF NOT DEFINED AUTO pause
ENDLOCAL
EXIT /B 1
