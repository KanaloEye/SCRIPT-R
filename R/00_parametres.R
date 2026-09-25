# =====================================================================
# PARAMETRES DU SCRIPT GCRMN SBH
# ---------------------------------------------------------------------
# Tout ce qui peut changer d'une annee a l'autre (chemins, dimensions des
# protocoles, formats d'export, seuils...) est regroupe ICI. Le reste du
# script ne contient plus de valeur "en dur" a modifier.
# =====================================================================

# --- 1. Fichiers d'entree ----------------------------------------------
# Obligatoires : le script s'ARRETE avec un message clair s'ils manquent.
FICHIERS <- list(
  LIT_BENTHOS   = "Extractions BD Recif/reefdb-extraction-simple-GCRMN_SBH_LIT-BENTHOS.csv",
  RECRUES       = "Extractions BD Recif/reefdb-extraction-simple-GCRMN_SBH_RECRUES.csv",
  OURSINS       = "Extractions BD Recif/reefdb-extraction-simple-GCRMN_SBH_OURSINS.csv",
  MACROALGUES   = "Extractions BD Recif/reefdb-extraction-simple-GCRMN_SBH_MACROALGUES.csv",
  POISSONS      = "Extractions BD Recif/reefdb-extraction-simple-GCRMN_SBH_POISSONS.csv",
  LISTE_POISSONS = "BD Excel/Liste_147_Poissons.xlsx",
  # Optionnels : un avertissement explicite s'ils manquent, et les
  # graphiques retombent sur les seules donnees d'extraction ReefDB.
  BELT_CORAIL   = "BD Excel/SUIVI_GCRMN_BELT_CORAIL_2026.xlsx",
  HISTORIQUE_ATE = "BD Excel/Data_Bouchon/250975_ATE_GCRMN_EVOL_BENTHOS_C_BOUCHON.xlsx",
  BOUCHON_2024  = "BD Excel/Data_Bouchon/Rapport_Bouchon_2024_donnees.xlsx"
)
FICHIERS_OBLIGATOIRES <- c("LIT_BENTHOS", "RECRUES", "OURSINS", "MACROALGUES", "POISSONS", "LISTE_POISSONS")

FEUILLE_BELT_CORAIL <- "FICHE DE SAISIE BELT CORAIL"

# --- 2. Dossiers de sortie ----------------------------------------------
DOSSIER_GRAPHS      <- "R_PLOT"             # tous les graphiques (avec titres)
DOSSIER_FICHES      <- "R_PLOT/FICHES"      # copies rangees par fiche Canva
DOSSIER_BDD         <- "R_BDD"              # classeurs Excel
DOSSIER_BANCARISATION <- "Historique de bancarisation"

# --- 3. Stations ----------------------------------------------------------
# nom       = nom de reference utilise partout dans le script
# motif     = expression reguliere reconnaissant les variantes de saisie
#             ("Baleine Pain de Sucre", "Coco"...)
# court     = nom court (dossiers des fiches)
# couleur   = couleur de la station sur TOUS les graphiques (a caler sur
#             la charte Canva)
STATIONS <- tibble::tribble(
  ~nom,                        ~motif,     ~court,     ~couleur,
  "Baleine de Pain de Sucre",  "baleine",  "Baleine",  "#2A6F97",
  "Ilet Coco",                 "coco",     "Coco",     "#E07A5F"
)

# Station couverte par le rapport Bouchon & Bouchon-Navaro 2024
STATION_RAPPORT_BOUCHON <- "Baleine de Pain de Sucre"
# Dates approximatives des campagnes du rapport Bouchon (aucune date
# exacte n'est donnee pour le benthos dans le rapport)
DATES_CAMPAGNES_BOUCHON <- tibble::tibble(
  Annee = c(2018, 2020, 2023, 2024),
  Date  = as.Date(c("2018-12-01", "2020-01-01", "2023-03-01", "2024-11-01"))
)

# --- 4. Protocoles -------------------------------------------------------
LONGUEUR_TRANSECT_LIT_M       <- 30    # longueur nominale des transects LIT
SURFACE_QUADRAT_RECRUES_M2    <- 0.5   # nb recrues / surface = recrues/m2
SURFACE_QUADRAT_OURSINS_M2    <- 1
SURFACE_BELT_PAR_DEFAUT_M2    <- 10    # 10 m x 1 m si non renseigne
SURFACE_HISTO_OURSINS_M2      <- 60    # rapport Bouchon : effectifs / 60 m2
SURFACE_HISTO_RECRUES_M2      <- 30    # rapport Bouchon : juveniles / 30 m2

# BELT CORAIL - etats exclus de l'abondance / de la diversite (colonies
# mortes depuis longtemps = squelettes). character(0) pour tout compter.
ETATS_EXCLUS_ABONDANCE <- c("Mort_Ancien")

# BELT CORAIL - lecture d'une ligne ou PLUSIEURS etats sont renseignes
# (ex. Nb_Sain = 1 et Nb_Necrose = 1 pour une meme espece d'un transect) :
#   "somme" : les etats sont des colonies DIFFERENTES (1 saine + 1 necrosee = 2 colonies)
#   "max"   : une colonie peut cumuler plusieurs etats (colonies = plus grand des comptages)
# A FAIRE CONFIRMER selon la fiche de terrain.
BELT_MODE_COMPTAGE <- "somme"

# Categories LIT comptees comme "algues" dans l'indicateur Algues/Corail.
# Les algues calcaires encroutantes (corallinacees) en sont exclues : ce
# sont des algues "favorables" (substrat de fixation des larves de corail)
# qui ne signalent pas une derive vers la dominance algale. Pour revenir
# a l'ancien calcul, ajouter "Algues calcaires encroutantes".
CATEGORIES_ALGUES_RATIO <- c("Macroalgues molles", "Turf algal", "Macroalgues calcaires")

# Poissons : taille (cm) attribuee a la classe "> 40 cm" pour le calcul de
# biomasse (a x L^b). 40 = borne basse (hypothese prudente, biomasse des
# gros individus sous-estimee) ; 45 ou 50 sont aussi utilises selon les
# protocoles - a harmoniser avec le rapport Bouchon pour comparer.
TAILLE_CLASSE_PLUS_40_CM <- 40

# --- 5. Mise en forme des graphiques -------------------------------------
POLICE_GRAPHS      <- "sans"   # ex. "Montserrat" si installee sur l'ordinateur
TAILLE_POLICE_BASE <- 10
DPI_EXPORT         <- 300

# Gabarits de taille (largeur, hauteur en cm) : un graphique = un gabarit,
# pour que tous les graphiques d'une meme case Canva aient la meme taille.
FORMATS_EXPORT <- list(
  carre       = c(12, 12),
  standard    = c(16, 12),
  large       = c(18, 10),
  pleine      = c(18, 13),
  panoramique = c(24, 12),
  haute       = c(18, 26)
)

# Etiquettes de valeur dans les barres empilees : affichees seulement si
# le segment fait au moins cette fraction de la hauteur de l'axe.
FRACTION_MIN_ETIQUETTE <- 0.05

# --- 6. Export "fiches" Canva ---------------------------------------------
EXPORT_FICHES           <- TRUE
FICHES_SANS_TITRE       <- TRUE    # le titre est ecrit dans Canva
FICHES_SANS_SOUS_TITRE  <- FALSE   # les sous-titres portent souvent une info utile

# --- 7. Statistiques ------------------------------------------------------
SEUIL_P <- 0.05
N_MIN_TENDANCE <- 4    # nb minimal d'annees pour calculer une tendance

# Lignes de reference optionnelles sur les graphiques (valeurs a VALIDER
# avec les references GCRMN/IFRECOR utilisees dans le rapport). Laisser
# vide = pas de ligne. Exemple :
#   SEUILS_REFERENCE <- list(
#     `Corail dur`  = c("Seuil degrade" = 10),
#     Macroalgues   = c("Seuil alerte" = 25)
#   )
SEUILS_REFERENCE <- list()
