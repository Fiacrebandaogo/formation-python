# Formation Python pour l'analyse de données

Programme complet de **20 séances de 2h30 (50 heures)** destiné à des participants sans aucune connaissance préalable de Python ni de la programmation. Objectif de sortie : l'autonomie opérationnelle — prendre un jeu de données brut (CSV, Excel, SQL), le nettoyer, l'explorer, produire statistiques et graphiques, et restituer ses conclusions sans assistance.

Principe pédagogique directeur : **ratio 30/70** — au plus 45 minutes d'exposé par séance, le reste au clavier.

## Contenu du dépôt

| Élément | Rôle |
|---|---|
| [`PROGRAMME_FORMATION_PYTHON_DATA.md`](PROGRAMME_FORMATION_PYTHON_DATA.md) | Programme détaillé : cadrage, 6 modules, déroulé séance par séance, grille d'évaluation, recommandations opérationnelles |
| [`Guide_installation_Anaconda.tex`](Guide_installation_Anaconda.tex) | Source du guide d'installation remis aux participants avant la séance 1. Le PDF est publié sur [fiacrebandaogo.github.io](https://fiacrebandaogo.github.io/Guide_installation_Anaconda.pdf) |
| [`formation_python/`](formation_python/) | Kit d'installation clé en main : `installer`, `lancer_jupyterlab`, `diagnostic` (versions `.bat` Windows et `.command` macOS) + `environment.yml` |
| [`seances/`](seances/) | Notebooks de séance, en version participant et en version corrigée, avec le script générateur |
| [`environment.yml`](environment.yml) | Environnement conda de référence (Python 3.12, JupyterLab, NumPy, pandas, Matplotlib, Seaborn, SciPy, statsmodels) |

## Parcours

| Module | Séances | Thème |
|---|---|---|
| 0 | avant la séance 1 | Installation d'Anaconda + JupyterLab |
| 1 | 1 à 5 | Fondamentaux du langage : variables, listes, fonctions, conditions, dictionnaires, boucles |
| 2 | 6 et 7 | NumPy : tableaux et statistiques |
| 3 | 8 à 12 | pandas : DataFrames, filtrage, agrégation, jointures, consolidation |
| 4 | 13 et 14 | Import depuis toutes les sources et nettoyage de données réelles |
| 5 | 15 à 17 | Visualisation : Matplotlib, Seaborn, communiquer par le graphique |
| 6 | 18 et 19 | Statistiques descriptives et démarche exploratoire complète |
| — | 20 | Restitution du projet final |

Un fil transversal, présent dès la séance 1, porte sur le **code réplicable et le dossier de travail organisé**.

## Installation (participants)

1. Installer Anaconda (ou Miniforge) en suivant le [guide d'installation](https://fiacrebandaogo.github.io/Guide_installation_Anaconda.pdf).
2. Télécharger le dépôt : bouton vert **Code** en haut de cette page, puis **Download ZIP**. Décompresser l'archive, ouvrir le sous-dossier `formation_python/` et double-cliquer sur `lancer_jupyterlab.bat` (Windows) ou `lancer_jupyterlab.command` (macOS). Le lanceur crée l'environnement au premier démarrage, puis ouvre JupyterLab.
3. En cas de problème, lancer `diagnostic.bat` / `diagnostic.command` et transmettre le fichier `installation.log`.

Installation manuelle équivalente :

```bash
conda env create -f environment.yml
conda activate formation-python
jupyter lab
```

## Notebooks de séance

Chaque séance existe en deux versions générées par un même script (`seances/_generateur_seanceNN.py`) : `NN_titre.ipynb` (participant, avec exercices à compléter et erreurs volontaires à corriger) et `NN_titre_CORRIGE.ipynb` (formateur). Pour régénérer les deux fichiers après modification du script :

```bash
python seances/_generateur_seance01.py
```

## Note sur les supports tiers

Le programme s'appuie, pour le contenu et le séquencement, sur des cours DataCamp. Ces supports sont protégés et **ne font pas partie de ce dépôt** ; seul le matériel original de la formation est publié ici.

## Licence

Contenu pédagogique (programme, guide, notebooks) sous licence [CC BY-NC-SA 4.0](LICENSE) ; scripts d'installation sous licence MIT. Voir le fichier `LICENSE`.

## Auteur

Fiacre Bandaogo — CERDI, Université Clermont Auvergne.
