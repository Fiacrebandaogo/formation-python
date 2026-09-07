#!/usr/bin/env bash
# =============================================================================
#  installer.command — Installation / réparation de l'environnement (macOS)
#  Formation Python pour l'analyse de données
#
#  Appelé automatiquement par lancer_jupyterlab.command (avec --auto) quand
#  l'environnement est absent, incomplet, ou que environment.yml a changé.
#  Peut aussi être lancé seul pour réparer une installation.
#
#  Architecture :
#    - Source de vérité : environment.yml (dans ce même dossier)
#    - Environnement créé dans ~/.local/share/formation_python
#      (jamais dans un dossier synchronisé : iCloud/Drive corrompent conda)
#    - Sentinelle : <env>/.install_complete
#    - Journal : installation.log (dans ce même dossier)
# =============================================================================

set -uo pipefail

# Appele avec --auto par lancer_jupyterlab.command : on supprime les pauses,
# c'est le lanceur qui prend la main a la fin.
AUTO=""
[[ "${1:-}" == "--auto" ]] && AUTO="1"

ENV_NAME="formation_python"
KERNEL_NAME="formation_python"
KERNEL_LABEL="Python 3 (formation)"
SENTINEL_NAME=".install_complete"

DOSSIER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_YML="$DOSSIER/environment.yml"
LOGFILE="$DOSSIER/installation.log"
ENV_PATH="$HOME/.local/share/$ENV_NAME"
SENTINEL="$ENV_PATH/$SENTINEL_NAME"

log()  { echo "[$(date +%H:%M:%S)] $*" >> "$LOGFILE"; }
err()  { echo; echo "  ERREUR: $*"; log "ERREUR: $*"; }

fatal() {
    echo
    echo "============================================================"
    echo "  INSTALLATION INTERROMPUE"
    echo "============================================================"
    echo
    echo "  Journal détaillé : $LOGFILE"
    echo "  Envoyez ce fichier au formateur, il contient la cause exacte."
    echo
    [[ -z "$AUTO" ]] && read -r -p "Appuyez sur Entrée pour fermer..." _
    exit 1
}

# Journal en mode AJOUT : on ne perd pas les traces des essais précédents
{
  echo
  echo "============================================================"
  echo "=== installer.command - $(date) ==="
  echo "============================================================"
} >> "$LOGFILE"
log "DOSSIER  = $DOSSIER"
log "ENV_PATH = $ENV_PATH"

AVERTIS="$DOSSIER/avertissements.txt"
rm -f "$AVERTIS"

# Empreinte d'un fichier (portable macOS / Linux)
empreinte() {
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" 2>/dev/null | awk '{print $1}'
    elif command -v md5 >/dev/null 2>&1; then
        md5 -q "$1" 2>/dev/null
    else
        cksum "$1" 2>/dev/null | awk '{print $1}'
    fi
}

avertir() {
    echo
    echo "  NOTE: $*"
    echo "  - $*" >> "$AVERTIS"
    log "AVERTISSEMENT: $*"
}

echo
echo "============================================================"
echo "  FORMATION PYTHON - INSTALLATION"
echo "============================================================"
echo
echo "  Cette opération prend 5 à 15 minutes."
echo "  Beaucoup de texte va défiler : c'est normal."
echo "  Ne fermez pas cette fenêtre avant le message de fin."
echo

# === Vérifications préalables ===============================================
if [[ ! -f "$ENV_YML" ]]; then
    err "Le fichier environment.yml est introuvable."
    err "  Attendu ici : $ENV_YML"
    err "  Vérifiez que vous avez bien décompressé le dossier complet."
    fatal
fi

# === Création de l'arborescence de travail ==================================
echo "[1/6] Création du dossier de travail..."
mkdir -p "$DOSSIER/seances" \
         "$DOSSIER/donnees/brut" \
         "$DOSSIER/donnees/propre" \
         "$DOSSIER/resultats/figures" \
         "$DOSSIER/resultats/tableaux" \
         "$DOSSIER/projet_final"
echo "      OK"

# === Détection de conda =====================================================
echo "[2/6] Recherche d'Anaconda sur votre ordinateur..."
CONDA_BIN=""
for candidat in \
    "$HOME/anaconda3/bin/conda" \
    "$HOME/miniconda3/bin/conda" \
    "$HOME/miniforge3/bin/conda" \
    "$HOME/mambaforge/bin/conda" \
    "/opt/anaconda3/bin/conda" \
    "/opt/homebrew/Caskroom/miniforge/base/bin/conda" \
    "/opt/homebrew/Caskroom/miniconda/base/bin/conda" \
    "/usr/local/anaconda3/bin/conda" \
    "/opt/conda/bin/conda"; do
    if [[ -x "$candidat" ]]; then CONDA_BIN="$candidat"; break; fi
done
if [[ -z "$CONDA_BIN" ]] && command -v conda >/dev/null 2>&1; then
    CONDA_BIN="$(command -v conda)"
fi
if [[ -z "$CONDA_BIN" ]]; then
    err "Anaconda est introuvable sur cet ordinateur."
    err "  Reprenez les étapes 1 et 2 du guide d'installation,"
    err "  puis relancez ce fichier."
    fatal
fi
log "Conda détecté : $CONDA_BIN"
echo "      OK"

# Rend « conda activate » utilisable dans ce script
CONDA_BASE="$("$CONDA_BIN" info --base)"
# shellcheck disable=SC1091
source "$CONDA_BASE/etc/profile.d/conda.sh"

# === Configuration de conda =================================================
echo "[3/6] Configuration de conda..."
"$CONDA_BIN" config --set solver libmamba          >> "$LOGFILE" 2>&1 || true
"$CONDA_BIN" config --add channels conda-forge     >> "$LOGFILE" 2>&1 || true
"$CONDA_BIN" config --set channel_priority strict  >> "$LOGFILE" 2>&1 || true
echo "      OK"

# === Création / mise à jour de l'environnement ==============================
diagnostic_reseau() {
    echo
    echo "  Causes les plus fréquentes :"
    echo "    - Pas de connexion internet"
    echo "    - Réseau d'entreprise avec inspection HTTPS (erreur SSL)"
    echo "      Solution : ouvrez le Terminal et tapez"
    echo "          conda config --set ssl_verify false"
    echo "      puis relancez ce fichier."
    echo "    - Espace disque insuffisant (prévoir 3 Go)"
    echo
    echo "  Envoyez le fichier installation.log au formateur."
    fatal
}

if [[ -x "$ENV_PATH/bin/python" ]]; then
    echo "[4/6] Environnement existant détecté - mise à jour..."
    log "conda env update -p $ENV_PATH --prune"
    if ! "$CONDA_BIN" env update -p "$ENV_PATH" -f "$ENV_YML" --prune >> "$LOGFILE" 2>&1; then
        err "La mise à jour de l'environnement a échoué."
        diagnostic_reseau
    fi
else
    echo "[4/6] Création de l'environnement - patientez 5 à 15 minutes..."
    log "conda env create -p $ENV_PATH"
    mkdir -p "$(dirname "$ENV_PATH")"
    if ! "$CONDA_BIN" env create -p "$ENV_PATH" -f "$ENV_YML" >> "$LOGFILE" 2>&1; then
        err "La création de l'environnement a échoué."
        diagnostic_reseau
    fi
fi
echo "      OK"

# === Test des imports =======================================================
echo "[5/6] Vérification des outils installés..."
if ! "$ENV_PATH/bin/python" -c "
import pandas, numpy, scipy, statsmodels
import matplotlib, seaborn
import openpyxl, sqlalchemy, jupyterlab
" >> "$LOGFILE" 2>&1; then
    err "Certains outils ne fonctionnent pas - installation incomplète."
    fatal
fi
echo "      OK"

# === Enregistrement du noyau Jupyter ========================================
echo "[6/6] Enregistrement du noyau Jupyter..."
if "$ENV_PATH/bin/python" -m ipykernel install --user \
        --name "$KERNEL_NAME" --display-name "$KERNEL_LABEL" >> "$LOGFILE" 2>&1; then
    echo "      OK"
else
    avertir "Le noyau Jupyter n'a pas pu être enregistré. Si un notebook affiche « No module named ... », voir diagnostic.command."
fi

# === Détection d'un noyau « python3 » concurrent ============================
for KJ in "$HOME/Library/Jupyter/kernels/python3/kernel.json" \
          "$HOME/.local/share/jupyter/kernels/python3/kernel.json"; do
    if [[ -f "$KJ" ]] && ! grep -q "$ENV_PATH" "$KJ" 2>/dev/null; then
        avertir "Un ancien noyau Jupyter est présent sur cet ordinateur. Si un notebook affiche « No module named ... », allez dans JupyterLab : Kernel > Change Kernel > \"$KERNEL_LABEL\""
        log "Noyau concurrent détecté : $KJ"
    fi
done

# === Sentinelle + empreinte d'environment.yml ===============================
#   L'empreinte permet au lanceur de détecter que la liste des outils a changé,
#   et de relancer la mise à jour tout seul.
EMP="$(empreinte "$ENV_YML")"
{
  echo "Installé le $(date)"
  echo "empreinte=$EMP"
} > "$SENTINEL"
log "Sentinelle écrite : $SENTINEL (empreinte=$EMP)"

echo
echo "============================================================"
echo "  INSTALLATION TERMINÉE"
echo "============================================================"
echo
if [[ -f "$AVERTIS" ]]; then
    echo "  ------------------------------------------------------------"
    echo "  POINTS À SIGNALER - à lire, l'installation a bien abouti :"
    echo "  ------------------------------------------------------------"
    cat "$AVERTIS"
    echo "  ------------------------------------------------------------"
    echo
fi
if [[ -z "$AUTO" ]]; then
    echo "  Vous pouvez maintenant double-cliquer sur :"
    echo "      lancer_jupyterlab.command"
    echo
fi
echo "  En cas de problème : double-cliquez sur diagnostic.command"
echo "============================================================"
echo
[[ -z "$AUTO" ]] && read -r -p "Appuyez sur Entrée pour fermer..." _
exit 0
