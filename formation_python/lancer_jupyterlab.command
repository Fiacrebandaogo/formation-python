#!/usr/bin/env bash
# =============================================================================
#  lancer_jupyterlab.command — Point d'entrée unique (macOS)
#  Formation Python pour l'analyse de données
#
#  À double-cliquer au début de chaque séance. C'est le SEUL fichier que les
#  participants utilisent :
#    - environnement absent ou incomplet   -> appelle installer.command --auto
#    - environment.yml modifié (empreinte) -> appelle installer.command --auto
#    - sinon                               -> ouvre directement JupyterLab
#
#  IMPORTANT : ce script active conda AVANT de lancer jupyter, pour que les
#  noyaux héritent du bon environnement.
# =============================================================================

set -uo pipefail

ENV_NAME="formation_python"
SENTINEL_NAME=".install_complete"

DOSSIER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_PATH="$HOME/.local/share/$ENV_NAME"
SENTINEL="$ENV_PATH/$SENTINEL_NAME"

stop() {
    echo
    read -r -p "Appuyez sur Entrée pour fermer..." _
    exit 1
}

# === Faut-il installer ou mettre à jour ? ===================================
empreinte() {
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" 2>/dev/null | awk '{print $1}'
    elif command -v md5 >/dev/null 2>&1; then
        md5 -q "$1" 2>/dev/null
    else
        cksum "$1" 2>/dev/null | awk '{print $1}'
    fi
}

A_INSTALLER=""
MISE_A_JOUR=""
[[ ! -x "$ENV_PATH/bin/python" || ! -f "$SENTINEL" ]] && A_INSTALLER="1"

# Empreinte : détecte une modification de environment.yml.
# En cas de doute (sentinelle ancienne, outil absent) on ne force rien.
if [[ -z "$A_INSTALLER" && -f "$DOSSIER/environment.yml" ]]; then
    EMP_NEW="$(empreinte "$DOSSIER/environment.yml")"
    EMP_OLD="$(grep '^empreinte=' "$SENTINEL" 2>/dev/null | cut -d= -f2)"
    if [[ -n "$EMP_NEW" && -n "$EMP_OLD" && "$EMP_NEW" != "$EMP_OLD" ]]; then
        A_INSTALLER="1"
        MISE_A_JOUR="1"
    fi
fi

# === Installation ou mise à jour automatique ================================
if [[ -n "$A_INSTALLER" ]]; then
    if [[ ! -f "$DOSSIER/installer.command" ]]; then
        echo
        echo "  Le fichier installer.command est introuvable dans ce dossier."
        echo "  Vérifiez que l'archive a bien été décompressée en entier."
        stop
    fi
    if [[ -n "$MISE_A_JOUR" ]]; then
        TITRE="MISE À JOUR - la liste des outils a changé"
        DETAIL="Comptez 1 à 5 minutes. C'est une mise à jour, pas une réinstallation."
    else
        TITRE="PREMIER LANCEMENT - installation des outils"
        DETAIL="Comptez 5 à 15 minutes. Cela n'arrivera qu'une seule fois."
    fi
    echo
    echo "============================================================"
    echo "  $TITRE"
    echo "============================================================"
    echo
    echo "  $DETAIL"
    echo
    if ! bash "$DOSSIER/installer.command" --auto; then
        echo
        echo "  Opération interrompue - JupyterLab ne peut pas démarrer."
        echo "  Envoyez le fichier installation.log au formateur."
        stop
    fi
    if [[ ! -f "$SENTINEL" ]]; then
        echo
        echo "  Opération interrompue - JupyterLab ne peut pas démarrer."
        echo "  Double-cliquez sur diagnostic.command."
        stop
    fi
    # Avertissements non bloquants : on s'arrête pour qu'ils soient lus
    if [[ -f "$DOSSIER/avertissements.txt" ]]; then
        echo
        echo "  ------------------------------------------------------------"
        echo "  POINTS À SIGNALER - l'installation a abouti, mais notez ceci :"
        echo "  ------------------------------------------------------------"
        cat "$DOSSIER/avertissements.txt"
        echo "  ------------------------------------------------------------"
        echo
        read -r -p "  Appuyez sur Entrée pour ouvrir JupyterLab..." _
    fi
fi

# === Détection de conda =====================================================
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
    echo
    echo "  Anaconda est introuvable. Double-cliquez sur diagnostic.command."
    stop
fi

CONDA_BASE="$("$CONDA_BIN" info --base)"
# shellcheck disable=SC1091
source "$CONDA_BASE/etc/profile.d/conda.sh"

if ! conda activate "$ENV_PATH"; then
    echo
    echo "  L'activation a échoué. Double-cliquez sur diagnostic.command."
    stop
fi

echo
echo "============================================================"
echo "  FORMATION PYTHON - JupyterLab démarre"
echo "============================================================"
echo
echo "  Dossier de travail : $DOSSIER"
echo
echo "  JupyterLab va s'ouvrir dans votre navigateur."
echo "  NE FERMEZ PAS cette fenêtre pendant que vous travaillez :"
echo "  elle fait tourner JupyterLab en arrière-plan."
echo
echo "  Pour arrêter en fin de séance : fermez cette fenêtre."
echo "============================================================"
echo

jupyter lab --notebook-dir="$DOSSIER"
