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

| Dossier / fichier | Contenu |
|---|---|
| `R_PLOT/...` | tous les graphiques, avec titre |
| `R_PLOT/FICHES/<Station>/Benthos` et `/Poissons` | graphiques pour les fiches station, sans titre, numérotés dans l'ordre de la fiche |
| `R_PLOT/FICHES/Synthese_Benthos` et `/Synthese_Poissons` | graphiques des fiches de synthèse (stations comparées) |
| `R_BDD/CHIFFRES_CLES_FICHES.xlsx` | chiffres clés par station, avec un texte prêt à coller dans Canva, et les tendances |
| `R_BDD/DATA_GCRMN_BENTHOS_MODIF.xlsx`, `..._POISSONS_MODIF.xlsx` | tables de résultats |
| `ANALYSE_R_GCRMN_SBH_2026.html` | rapport (après Knit) |

## Réglages fréquents (`R/00_parametres.R`)

- `STATIONS` : couleurs des stations, à caler sur la charte Canva.
- `POLICE_GRAPHS` : police des graphiques. Il faut que la police soit installée et le paquet `ragg` aussi.
- `FORMATS_EXPORT` : tailles des graphiques (cm).
- `FICHES_SANS_TITRE` : titre retiré des copies destinées aux fiches.
- `BELT_MODE_COMPTAGE` : `"somme"` ou `"max"` pour une ligne BELT avec plusieurs états. **À confirmer.**
- `SEUILS_REFERENCE` : lignes de seuil en pointillé sur les graphiques (vide par défaut).
