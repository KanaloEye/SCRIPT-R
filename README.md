# Analyse GCRMN Saint-Barthélemy

## Organisation

```
ANALYSE_R_GCRMN_SBH_2026.Rmd   script principal (à ouvrir dans RStudio)
R/00_parametres.R              TOUT ce qui se règle : chemins, stations et couleurs,
                               dimensions des protocoles, formats d'export, seuils
R/01_palettes.R                palettes de couleurs (une seule définition)
R/02_fonctions_outils.R        lecture des fichiers, noms de stations, tendances, tests
R/03_fonctions_graphiques.R    thème et fonctions graphiques communes
```

Le dossier `R/` doit rester à côté du `.Rmd`.

## Utilisation

1. Placer les extractions ReefDB dans `Extractions BD Recif/` et les classeurs dans `BD Excel/`
   (chemins modifiables dans `R/00_parametres.R`).
2. Exécuter les blocs un par un, ou cliquer sur **Knit** pour produire le rapport HTML.

## Sorties

```
R_PLOT/
├─ 1_BENTHOS/
│  ├─ 1_LIT/
│  │  ├─ BALEINE/  1_Annee_en_cours/  2_Evolution/
│  │  ├─ COCO/     1_Annee_en_cours/  2_Evolution/
│  │  └─ COMPARAISON_STATIONS/  1_Annee_en_cours/  2_Evolution/
│  ├─ 2_MACROALGUES/   (meme structure)
│  ├─ 3_OURSINS/
│  ├─ 4_RECRUES/
│  └─ 5_BELT_CORAUX/
├─ 2_POISSONS/
│  ├─ 1_BELT_POISSONS/  (meme structure)
│  └─ 2_ANALYSES_MULTIVARIEES/
└─ CHIFFRES_CLES_FICHES.xlsx
```

Chaque graphique n'est enregistré qu'une fois. L'ordre des protocoles se règle avec `ARBORESCENCE` dans `R/00_parametres.R`.
Au lancement, l'ancien `R_PLOT` est archivé dans `R_PLOT_ANCIEN`.

| Fichier | Contenu |
|---|---|
| `R_BDD/CHIFFRES_CLES_FICHES.xlsx` | chiffres clés par station, avec un texte prêt à coller dans Canva, et les tendances |
| `R_BDD/DATA_GCRMN_BENTHOS_MODIF.xlsx`, `..._POISSONS_MODIF.xlsx` | tables de résultats |
| `ANALYSE_R_GCRMN_SBH_2026.html` | rapport (après Knit) |

## Réglages fréquents (`R/00_parametres.R`)

- `STATIONS` : couleurs des stations, à caler sur la charte Canva.
- `POLICE_GRAPHS` : police des graphiques. Il faut que la police soit installée et le paquet `ragg` aussi.
- `FORMATS_EXPORT` : tailles des graphiques (cm).
- `GRAPHS_SANS_TITRE` : titre retiré des graphiques (écrit dans Canva).
- `ARBORESCENCE` : thèmes et protocoles, dans l'ordre des dossiers de `R_PLOT`.
- `BELT_MODE_COMPTAGE` : `"cumul"` (une colonie peut cumuler plusieurs atteintes, par défaut) ou `"somme"`.
- `ANNEES_POISSONS_LISTE_RESTREINTE` : années de comptage poissons limité à une liste d'espèces (2022 : 61 espèces). Elles sont signalées sur les graphiques d'évolution, et les chiffres clés donnent aussi une évolution « à liste égale ».
- `SEUILS_REFERENCE` : lignes de seuil en pointillé sur les graphiques (vide par défaut).
