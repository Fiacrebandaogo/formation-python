#!/usr/bin/env bash
# =============================================================================
#  diagnostic.command — Diagnostic complet (macOS)
#  Formation Python pour l'analyse de données
#
#  Ne modifie RIEN. Affiche l'état de l'installation et écrit diagnostic.txt.
#  À envoyer au formateur en cas de blocage.
# =============================================================================

set -uo pipefail

ENV_NAME="formation_python"
SENTINEL_NAME=".install_complete"

DOSSIER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_PATH="$HOME/.local/share/$ENV_NAME"
RAPPORT="$DOSSIER/diagnostic.txt"

{
  echo "=== DIAGNOSTIC - $(date) ==="
  echo "Dossier   : $DOSSIER"
  echo "Env prévu : $ENV_PATH"
  echo
} > "$RAPPORT"

ok()     { echo "    [OK]    $1";     echo "[OK] $1"     >> "$RAPPORT"; }
echec()  { echo "    [ECHEC] $1";     echo "[ECHEC] $1"  >> "$RAPPORT"; }
note()   { echo "    [NOTE]  $1";     echo "[NOTE] $1"   >> "$RAPPORT"; }
alerte() { echo "    [ALERTE] $1";    echo "[ALERTE] $1" >> "$RAPPORT"; }

echo
echo "============================================================"
echo "  FORMATION PYTHON - DIAGNOSTIC"
echo "============================================================"
echo

# === [1] Fichiers ===========================================================
echo "[1] Fichiers de la formation"
for f in environment.yml installer.command lancer_jupyterlab.command; do
    [[ -f "$DOSSIER/$f" ]] && ok "$f" || echec "$f manquant"
done
for d in seances donnees/brut; do
    [[ -d "$DOSSIER/$d" ]] && ok "dossier $d" || note "dossier $d absent - relancez installer.command"
done
echo

# === [2] Anaconda ===========================================================
echo "[2] Anaconda"
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
    echec "Anaconda introuvable"
    echo "            -> Reprenez les étapes 1 et 2 du guide"
    echo
    read -r -p "Appuyez sur Entrée pour fermer..." _
    exit 0
fi
ok "$CONDA_BIN"
{
  echo "      version    : $("$CONDA_BIN" --version 2>/dev/null)"
  echo "      ssl_verify : $("$CONDA_BIN" config --get ssl_verify 2>/dev/null)"
} >> "$RAPPORT"
echo "            Version : $("$CONDA_BIN" --version 2>/dev/null)"
echo

# === [3] Environnement ======================================================
echo "[3] Environnement de la formation"
if [[ ! -x "$ENV_PATH/bin/python" ]]; then
    echec "Environnement absent"
    echo "            -> Double-cliquez sur installer.command"
    echo
    read -r -p "Appuyez sur Entrée pour fermer..." _
    exit 0
fi
ok "$ENV_PATH"
[[ -f "$ENV_PATH/$SENTINEL_NAME" ]] && ok "Installation complète" \
                                    || echec "Installation incomplète (sentinelle absente)"
echo

# === [4] Imports ============================================================
echo "[4] Outils Python (test réel)"
for m in pandas numpy matplotlib seaborn scipy statsmodels openpyxl jupyterlab; do
    if "$ENV_PATH/bin/python" -c "import $m" >/dev/null 2>&1; then ok "$m"; else echec "$m"; fi
done
echo

# === [5] Interpréteur =======================================================
echo "[5] Interpréteur utilisé"
INTERP="$("$ENV_PATH/bin/python" -c "import sys; print(sys.executable)" 2>/dev/null)"
echo "    $INTERP"
echo "interpréteur : $INTERP" >> "$RAPPORT"
echo

# === [6] Noyaux Jupyter =====================================================
echo "[6] Noyaux Jupyter"
for KJ in "$HOME/Library/Jupyter/kernels/python3/kernel.json" \
          "$HOME/.local/share/jupyter/kernels/python3/kernel.json"; do
    if [[ -f "$KJ" ]] && ! grep -q "$ENV_PATH" "$KJ" 2>/dev/null; then
        alerte "Un ancien noyau 'python3' peut masquer celui de la formation"
        echo "             Fichier : $KJ"
        echo "             Dans JupyterLab : Kernel > Change Kernel > \"Python 3 (formation)\""
    fi
done
if [[ -f "$HOME/Library/Jupyter/kernels/$ENV_NAME/kernel.json" ]] \
   || [[ -f "$HOME/.local/share/jupyter/kernels/$ENV_NAME/kernel.json" ]]; then
    ok "Noyau de la formation enregistré"
else
    note "Noyau de la formation non enregistré - relancez installer.command"
fi

echo
echo "============================================================"
echo "  Rapport écrit dans : diagnostic.txt"
echo "  Envoyez ce fichier au formateur en cas de blocage."
echo "============================================================"
echo
read -r -p "Appuyez sur Entrée pour fermer..." _
exit 0
