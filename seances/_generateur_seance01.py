# -*- coding: utf-8 -*-
"""Génère le notebook de la séance 1 en deux versions : participant et corrigé."""
import json, copy

CELLS = []          # (kind, source, solution|None)

def md(s):   CELLS.append(("md", s.strip("\n"), None))
def code(s): CELLS.append(("code", s.strip("\n"), None))
def err(s):  CELLS.append(("err", s.strip("\n"), None))       # erreur volontaire
def exo(placeholder, solution, casse=False):
    # casse=True : la version participant contient volontairement des erreurs
    CELLS.append(("exo_casse" if casse else "exo",
                  placeholder.strip("\n"), solution.strip("\n")))

# =============================================================================
md("""
# Séance 1 — Premiers pas en Python

**Formation Python pour l'analyse de données**

| | |
|---|---|
| **Séance** | 1 sur 20 |
| **Durée** | 2 h 30 |
| **Prérequis** | Aucun |

---

## Ce que vous saurez faire à la fin de cette séance

- Écrire et exécuter du code dans JupyterLab
- Stocker une valeur dans une variable et la réutiliser
- Reconnaître les quatre types de base et les convertir
- **Lire un message d'erreur et le corriger** — c'est le point le plus important de la séance

---

## Comment utiliser ce notebook

Ce document contient du texte et du code. Les zones grises sont des **cellules de code** :
cliquez dedans et appuyez sur **Maj + Entrée** pour les exécuter.

N'ayez aucune crainte de casser quelque chose. **Modifiez le code, relancez, observez.**
C'est exactement comme ça qu'on apprend à programmer. Si tout se dérègle, le menu
**Kernel → Restart Kernel and Clear Outputs** remet tout à zéro.
""")

# ------------------------------------------------------------------ Partie 0
md("""
---
# 0. Prendre en main JupyterLab

*Environ 15 minutes*

## Une cellule, deux natures

Ce document est une suite de **cellules** empilées.

- Les cellules **Markdown** contiennent du texte, comme celle que vous lisez.
- Les cellules **Code** contiennent des instructions Python, et affichent un résultat.

Cliquez une fois sur la cellule ci-dessous : un cadre apparaît. Puis **Maj + Entrée**.
""")

code("""
print("Bonjour")
""")

md("""
Un résultat est apparu juste en dessous. À gauche de la cellule, `[ ]` est devenu `[1]` :
c'est le **compteur d'exécution**. Il indique dans quel ordre les cellules ont été lancées.

Retenez ce nombre, il nous servira plus tard dans la formation.

## À vous

Modifiez la cellule ci-dessous pour qu'elle affiche votre prénom, puis exécutez-la.
""")

exo("""
print("Remplacez ce texte par votre prénom")
""", """
print("Fiacre")
""")

md("""
## Le noyau

Quand vous exécutez une cellule, ce n'est pas le navigateur qui calcule : c'est un programme
appelé le **noyau** (*kernel*), qui tourne sur votre ordinateur. Le noyau garde en mémoire
tout ce que vous avez exécuté depuis le début.

Deux conséquences, à connaître dès maintenant :

1. **L'ordre d'exécution compte.** Si vous exécutez la cellule 12 avant la cellule 3,
   le noyau suit l'ordre dans lequel *vous* avez lancé les cellules, pas l'ordre du document.
2. **Redémarrer le noyau efface tout.** C'est la solution quand quelque chose semble
   incohérent : **Kernel → Restart Kernel**.
""")

# ------------------------------------------------------------------ Partie 1
md("""
---
# 1. Afficher un résultat : `print()`

*Environ 10 minutes*

`print()` affiche ce qu'on lui donne. C'est l'outil qui rend le travail de l'ordinateur visible.
""")

code("""
print("Formation Python")
""")

md("""
On peut lui donner plusieurs éléments, séparés par des virgules. Python les affiche
à la suite, séparés par une espace.
""")

code("""
print("Nombre de séances :", 20)
""")

md("""
Et on peut lui donner un calcul : Python le résout **avant** d'afficher.
""")

code("""
print(20 * 2.5)
""")

md("""
> **Le piège des guillemets.** `print("20 * 2.5")` et `print(20 * 2.5)` ne font pas
> la même chose. Avec les guillemets, Python voit du texte et le recopie tel quel.
> Sans guillemets, il voit un calcul et le résout. Essayez les deux.
""")

exo("""
# Affichez le résultat de 12 * 7, puis le texte "12 * 7"
""", """
print(12 * 7)
print("12 * 7")
""")

# ------------------------------------------------------------------ Partie 2
md("""
---
# 2. Les variables

*Environ 25 minutes*

## Le problème que ça résout

Regardez ce calcul de facture. Le prix unitaire, 24.90, y apparaît trois fois.
""")

code("""
print(24.90 * 3)
print(24.90 * 3 * 0.20)
print(24.90 * 3 * 1.20)
""")

md("""
Si le prix change, il faut le corriger à trois endroits — et en oublier un est
la meilleure façon de produire une facture fausse sans s'en apercevoir.

Une **variable** est un nom qu'on donne à une valeur, pour la désigner ensuite.
""")

code("""
prix_unitaire = 24.90
quantite = 3

print(prix_unitaire * quantite)
print(prix_unitaire * quantite * 0.20)
print(prix_unitaire * quantite * 1.20)
""")

md("""
Le prix n'est plus écrit qu'**une seule fois**. Changez `24.90` en `19.90` dans la cellule
ci-dessus et réexécutez : les trois lignes se mettent à jour ensemble.

## Le signe `=` n'est pas une égalité

En mathématiques, `x = 3` affirme que x vaut 3. En Python, `=` est une **instruction** :
« range la valeur 3 dans une case appelée x ». On lit ça de droite à gauche.

Cette différence explique une ligne qui serait absurde en mathématiques :
""")

code("""
compteur = 10
compteur = compteur + 1
print(compteur)
""")

md("""
Python calcule d'abord la droite (`10 + 1`), puis range le résultat dans `compteur`.
Ce schéma — *prendre la valeur actuelle, la modifier, la ranger au même endroit* —
reviendra constamment.

## Nommer ses variables

Trois règles imposées par Python :

- Pas d'espace, pas d'accent, pas de tiret : `prix_total`, jamais `prix total` ni `prix-total`
- Ne commence pas par un chiffre : `x1` est valide, `1x` non
- **La casse compte** : `Prix` et `prix` sont deux variables différentes

Et une règle de bon sens, qui vous fera gagner beaucoup de temps :
**un nom de variable doit décrire son contenu**. Comparez.
""")

code("""
# Illisible dans trois semaines
a = 24.90
b = 3
c = a * b

# Se lit tout seul
prix_unitaire = 24.90
quantite = 3
montant_ht = prix_unitaire * quantite

print(c, montant_ht)
""")

exo("""
# Une salle contient 12 rangées de 25 places.
# Créez deux variables, puis affichez le nombre total de places.
""", """
nb_rangees = 12
places_par_rangee = 25
total_places = nb_rangees * places_par_rangee
print(total_places)
""")

# ------------------------------------------------------------------ Partie 3
md("""
---
# 3. Les quatre types de base

*Environ 20 minutes*

Toute valeur en Python a un **type**. Au début, quatre suffisent.

| Type | Nom Python | Exemple | À quoi ça sert |
|---|---|---|---|
| Nombre entier | `int` | `20` | Compter : des lignes, des personnes |
| Nombre décimal | `float` | `24.90` | Mesurer : des prix, des moyennes |
| Texte | `str` | `"Bonjour"` | Nommer : des libellés, des catégories |
| Vrai ou faux | `bool` | `True` | Décider : une condition remplie ou non |

La fonction `type()` répond à la question « qu'est-ce que c'est ? ».
""")

code("""
print(type(20))
print(type(24.90))
print(type("Bonjour"))
print(type(True))
""")

md("""
> **Attention au point décimal.** Python est anglophone : on écrit `24.90`, jamais `24,90`.
> La virgule a un autre rôle, celui de séparer des éléments.

## Pourquoi le type compte

Le même symbole `+` ne fait pas la même chose selon les types.
""")

code("""
print(10 + 5)          # deux nombres : addition
print("10" + "5")      # deux textes : mise bout à bout
""")

md("""
`"10"` avec des guillemets n'est pas le nombre dix : c'est un texte qui contient
les caractères « 1 » et « 0 ». D'où le résultat `105`, qui surprend toujours au début.
""")

exo("""
# Créez une variable contenant votre âge (un entier),
# une autre contenant votre prénom (un texte),
# puis affichez le type de chacune.
""", """
age = 34
prenom = "Fiacre"
print(type(age))
print(type(prenom))
""")

# ------------------------------------------------------------------ Partie 4
md("""
---
# 4. Calculer

*Environ 15 minutes*
""")

code("""
a = 17
b = 5

print("somme       :", a + b)
print("différence  :", a - b)
print("produit     :", a * b)
print("quotient    :", a / b)
""")

md("""
Trois opérateurs moins connus, mais très utiles en analyse de données :
""")

code("""
print("division entière :", 17 // 5)   # combien de fois 5 tient dans 17
print("reste            :", 17 % 5)    # ce qu'il reste
print("puissance        :", 2 ** 10)   # 2 à la puissance 10
""")

md("""
> **Remarquez** que `17 / 5` donne `3.4` (un `float`) alors que `17 // 5` donne `3` (un `int`).
> La division simple produit toujours un décimal, même quand le résultat semble entier :
> essayez `10 / 2`.

## Les opérateurs sur du texte
""")

code("""
prenom = "Fiacre"
nom = "Bandaogo"

print(prenom + " " + nom)
print("-" * 40)
""")

md("""
`*` sur du texte le répète. C'est le moyen le plus simple de tracer une ligne de séparation
dans un affichage.

## Priorité des opérations

Python respecte les règles mathématiques : `*` et `/` avant `+` et `-`.
En cas de doute, **mettez des parenthèses** — elles ne coûtent rien et lèvent l'ambiguïté.
""")

code("""
print(2 + 3 * 4)        # 14, pas 20
print((2 + 3) * 4)      # 20
""")

# ------------------------------------------------------------------ Partie 5
md("""
---
# 5. Convertir d'un type à l'autre

*Environ 10 minutes*

Trois fonctions portent le nom du type visé : `int()`, `float()`, `str()`.
""")

code("""
print(int("42") + 8)        # texte -> entier, puis addition
print(str(42) + " ans")     # entier -> texte, puis mise bout à bout
print(float("3.5") * 2)     # texte -> décimal
""")

md("""
`int()` sur un décimal **tronque**, il n'arrondit pas :
""")

code("""
print(int(3.9))
print(round(3.9))
""")

md("""
Cette distinction compte : sur des données réelles, tronquer au lieu d'arrondir
introduit un biais systématique vers le bas.
""")

exo("""
# La variable ci-dessous contient un nombre, mais sous forme de texte.
# Convertissez-la et calculez son double.
nombre_texte = "125"
""", """
nombre_texte = "125"
nombre = int(nombre_texte)
print(nombre * 2)
""")

# ------------------------------------------------------------------ Partie 6
md("""
---
# 6. Les erreurs

*Environ 15 minutes — la partie la plus importante de la séance*

Vous allez produire des erreurs. Beaucoup. Tous les jours, y compris dans dix ans.

Une erreur n'est **pas un échec** : c'est le seul moyen qu'a Python de vous dire
ce qu'il n'a pas compris. Apprendre à lire ces messages est la compétence qui
vous rendra autonome le plus vite.

## Comment lire un message d'erreur

Le message est long et intimidant. **Lisez la dernière ligne d'abord** : elle contient
le type de l'erreur et son explication. Le reste, au-dessus, indique où elle s'est produite.

Exécutez les trois cellules suivantes. **Elles doivent échouer** — c'est le but.
""")

md("""
### Erreur 1 — `NameError`
""")

err("""
print(prix_du_cafe)
""")

md("""
Dernière ligne : `NameError: name 'prix_du_cafe' is not defined`.

**Traduction** : « je ne connais pas de variable qui s'appelle `prix_du_cafe` ».

**Causes habituelles** : la variable n'a jamais été créée, la cellule qui la crée
n'a pas été exécutée, ou son nom est mal orthographié.
""")

md("""
### Erreur 2 — `TypeError`
""")

err("""
age = 34
print("J'ai " + age + " ans")
""")

md("""
Dernière ligne : `TypeError: can only concatenate str (not "int") to str`.

**Traduction** : « je ne sais pas coller un nombre à du texte ».

**Correction** : convertir. Essayez `"J'ai " + str(age) + " ans"`.
""")

md("""
### Erreur 3 — `SyntaxError`
""")

err("""
print("Bonjour"
""")

md("""
Dernière ligne : `SyntaxError: incomplete input` — « instruction incomplète ».
La petite flèche `^` juste au-dessus pointe l'endroit où Python s'est arrêté :
la parenthèse ouverte après `print` n'a jamais été refermée.

Les `SyntaxError` sont les plus faciles à corriger : c'est une faute de frappe.
Regardez **la ligne indiquée et celle juste avant**, l'oubli s'y trouve presque toujours.

## La méthode, en trois réflexes

1. Aller directement à la **dernière ligne** du message
2. Repérer le **type** de l'erreur — il vous dit dans quelle famille chercher
3. Repérer le **numéro de ligne** — il vous dit où regarder

Et si le message reste obscur : **recopiez-le dans un moteur de recherche**.
C'est ce que font les professionnels, tous les jours, sans aucune honte.
""")

exo("""
# La cellule ci-dessous contient trois erreurs. Corrigez-les une par une,
# en réexécutant à chaque fois pour lire le message suivant.

prix unitaire = 15.50
quantite = "4"
print("Total : " + prix_unitaire * quantite)
""", """
prix_unitaire = 15.50      # 1. pas d'espace dans un nom de variable
quantite = 4               # 2. un nombre, pas du texte
print("Total : " + str(prix_unitaire * quantite))   # 3. conversion avant la concaténation
""", casse=True)

# ------------------------------------------------------------------ Atelier
md("""
---
# Atelier

*Environ 45 minutes*

Trois exercices, difficulté croissante. Travaillez à votre rythme ; l'exercice 3
est un bonus, personne n'est en retard s'il ne l'atteint pas.

Une seule consigne : **exécutez souvent**. N'écrivez pas dix lignes avant de tester.
""")

md("""
## Exercice 1 — Calculatrice de TVA

Un article coûte **249,90 € hors taxes**. Le taux de TVA est de **20 %**.

Calculez et affichez le montant de la TVA, puis le prix TTC.
""")

exo("""
prix_ht = 249.90
taux_tva = 0.20

# Votre code ici
""", """
prix_ht = 249.90
taux_tva = 0.20

montant_tva = prix_ht * taux_tva
prix_ttc = prix_ht + montant_tva

print("Montant de la TVA :", round(montant_tva, 2), "€")
print("Prix TTC          :", round(prix_ttc, 2), "€")
""")

md("""
## Exercice 2 — Conversion d'unités

Une distance de **42,195 km** et une température de **18 °C**.

Convertissez la distance en miles (1 mile = 1,609 km) et la température
en degrés Fahrenheit (`F = C * 9/5 + 32`). Arrondissez à deux décimales.
""")

exo("""
distance_km = 42.195
temperature_c = 18

# Votre code ici
""", """
distance_km = 42.195
temperature_c = 18

distance_miles = distance_km / 1.609
temperature_f = temperature_c * 9 / 5 + 32

print("Distance    :", round(distance_miles, 2), "miles")
print("Température :", round(temperature_f, 2), "°F")
""")

md("""
## Exercice 3 — Salaire annualisé *(bonus)*

Un salaire mensuel net de **2 350 €**, versé sur **13 mois**, avec une prime
annuelle de **1 200 €**.

Affichez le revenu annuel total, puis le revenu mensuel moyen une fois
la prime lissée sur douze mois. Présentez le résultat sur deux lignes lisibles.
""")

exo("""
salaire_mensuel = 2350
nb_mois = 13
prime_annuelle = 1200

# Votre code ici
""", """
salaire_mensuel = 2350
nb_mois = 13
prime_annuelle = 1200

revenu_annuel = salaire_mensuel * nb_mois + prime_annuelle
revenu_mensuel_moyen = revenu_annuel / 12

print("Revenu annuel total   :", revenu_annuel, "€")
print("Moyenne mensuelle     :", round(revenu_mensuel_moyen, 2), "€")
""")

# ------------------------------------------------------------------ Clôture
md("""
---
# Clôture

## Aide-mémoire de la séance

| Ce que je veux faire | Comment |
|---|---|
| Afficher quelque chose | `print(valeur)` |
| Ranger une valeur | `nom = valeur` |
| Connaître un type | `type(valeur)` |
| Texte vers nombre | `int("42")` ou `float("3.5")` |
| Nombre vers texte | `str(42)` |
| Arrondir | `round(3.14159, 2)` |
| Exécuter une cellule | **Maj + Entrée** |
| Tout remettre à zéro | **Kernel → Restart Kernel** |

## Les trois erreurs de la séance

| Message | Ce qu'il veut dire | Où chercher |
|---|---|---|
| `NameError` | Ce nom m'est inconnu | Orthographe, ou cellule non exécutée |
| `TypeError` | Ces types ne vont pas ensemble | Il manque une conversion |
| `SyntaxError` | Je ne comprends pas la phrase | Parenthèse ou guillemet oublié |

---

## Comment nommer et ranger vos notebooks

À partir de maintenant, et pour toute la formation :

- Un notebook par séance, dans le dossier `seances/`
- Nommé `NN_sujet.ipynb` : `01_premiers_pas.ipynb`, `02_listes.ipynb`…
  Le numéro à deux chiffres garantit que le tri reste correct après la séance 9.
- **Aucun accent, aucun espace** dans les noms de fichiers
- Chaque notebook commence par une cellule Markdown : titre, date, votre nom, objectif en une phrase

Ce n'est pas de la coquetterie. Dans trois mois, vous chercherez « la séance où on a vu
les pourcentages » — et vous la retrouverez en dix secondes ou en dix minutes selon
que vous avez tenu cette règle.
""")

md("""
---
# Travail personnel

*Environ 1 heure, à faire avant la séance 2*

Huit exercices courts. Créez un notebook `01_exercices.ipynb` dans votre dossier
`seances/` et traitez-les un par un.

**Si vous bloquez plus de dix minutes sur un exercice, passez au suivant** et signalez-le
en début de séance 2 — c'est une information utile, pas un aveu de faiblesse.
""")

exo("""
# 1. Créez une variable `ville` contenant "Clermont-Ferrand" et affichez-la.


# 2. Affichez le nombre de secondes dans une journée, en partant de 24, 60 et 60.


# 3. Créez deux variables `a = 7` et `b = 3`.
#    Affichez leur quotient, leur division entière et leur reste.


# 4. Un article coûte 89.99 €. Affichez son prix après une remise de 15 %.


# 5. Affichez le type de chacune de ces valeurs : 42, 42.0, "42", True


# 6. La variable ci-dessous est du texte. Convertissez-la et ajoutez-lui 10.
valeur = "90"


# 7. Corrigez cette ligne pour qu'elle affiche "Total : 150" :
# print("Total : " + 150)


# 8. Affichez une ligne de 50 tirets, puis le mot "FIN" centré à la main dessous.
""", """
# 1.
ville = "Clermont-Ferrand"
print(ville)

# 2.
secondes_par_jour = 24 * 60 * 60
print(secondes_par_jour)

# 3.
a = 7
b = 3
print(a / b)
print(a // b)
print(a % b)

# 4.
prix = 89.99
prix_remise = prix * 0.85
print(round(prix_remise, 2))

# 5.
print(type(42), type(42.0), type("42"), type(True))

# 6.
valeur = "90"
print(int(valeur) + 10)

# 7.
print("Total : " + str(150))

# 8.
print("-" * 50)
print(" " * 23 + "FIN")
""")

md("""
---

**Séance 2 : les listes** — comment manipuler non plus une valeur, mais des centaines.
""")

# =============================================================================
def cellule(kind, source, tags=None):
    c = {"cell_type": "markdown" if kind == "md" else "code",
         "metadata": {} if not tags else {"tags": tags},
         "source": source.split("\n")}
    c["source"] = [l + "\n" for l in c["source"][:-1]] + [c["source"][-1]]
    if c["cell_type"] == "code":
        c["execution_count"] = None
        c["outputs"] = []
    return c

def notebook(corrige: bool):
    cells = []
    for kind, source, solution in CELLS:
        if kind == "md":
            cells.append(cellule("md", source))
        elif kind == "code":
            cells.append(cellule("code", source))
        elif kind == "err":
            cells.append(cellule("code", source, ["erreur_volontaire"]))
        elif kind in ("exo", "exo_casse"):
            if corrige:
                cells.append(cellule("code", solution, ["corrige"]))
            else:
                tags = ["exercice"] + (["erreur_volontaire"] if kind == "exo_casse" else [])
                cells.append(cellule("code", source, tags))
    return {"cells": cells,
            "metadata": {"kernelspec": {"display_name": "Python 3 (formation)",
                                        "language": "python", "name": "formation_python"},
                         "language_info": {"name": "python", "version": "3.12"}},
            "nbformat": 4, "nbformat_minor": 5}

import io, os
# Les notebooks sont ecrits a cote de ce script
SORTIE = os.path.dirname(os.path.abspath(__file__)) or "."
for nom, corr in [("01_premiers_pas.ipynb", False), ("01_premiers_pas_CORRIGE.ipynb", True)]:
    with io.open(os.path.join(SORTIE, nom), "w", encoding="utf-8") as f:
        json.dump(notebook(corr), f, ensure_ascii=False, indent=1)
    print(f"  {nom}")

n_md  = sum(1 for k,_,_ in CELLS if k=="md")
n_code= sum(1 for k,_,_ in CELLS if k=="code")
n_err = sum(1 for k,_,_ in CELLS if k=="err")
n_exo = sum(1 for k,_,_ in CELLS if k.startswith("exo"))
print(f"\n  {len(CELLS)} cellules : {n_md} markdown, {n_code} code, {n_exo} exercices, {n_err} erreurs volontaires")
