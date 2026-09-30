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
  BELT_CORAIL   = "BD Excel/EXCEL/SUIVI_GCRMN_BELT_CORAIL_2026.xlsx",
  # comptage dedie des gorgones (6 sections de 10 m = 60 m par station)
  GORGONES      = "BD Excel/EXCEL/SUIVI_GCRMN_GORGONES_2026.xlsx",
  HISTORIQUE_ATE = "BD Excel/Data_Bouchon/250975_ATE_GCRMN_EVOL_BENTHOS_C_BOUCHON.xlsx",
  ECORECIF_2024  = "BD Excel/Data_Bouchon/Rapport_Bouchon_2024_donnees.xlsx",
  # suivi LIT C. Bouchon 2002-2011 (format IUCN : % par espece et par groupe)
  HISTORIQUE_IUCN = "BD Excel/Data_Bouchon/GCRMN_IUCN_StBarth_2002-2011.xlsx",
  # effectifs de gorgones / 60 m (comptage dedie), lus sur les graphiques
  # C. Bouchon 2002-2018 - completer ici les comptages dedies ulterieurs
  GORGONES_HISTORIQUE = "BD Excel/Data_Bouchon/Gorgones_historique_2002-2018.xlsx"
)
FICHIERS_OBLIGATOIRES <- c("LIT_BENTHOS", "RECRUES", "OURSINS", "MACROALGUES", "POISSONS", "LISTE_POISSONS")

FEUILLE_BELT_CORAIL <- "FICHE DE SAISIE BELT CORAIL"

# --- 2. Dossiers de sortie ----------------------------------------------
# Arborescence des graphiques : THEME / PROTOCOLE / SITE / PERIODE
#   R_PLOT/1_BENTHOS/1_LIT/BALEINE/1_Annee_en_cours/
#                             BALEINE/2_Evolution/
#                             COCO/...
#                             COMPARAISON_STATIONS/1_Annee_en_cours | 2_Evolution
#   R_PLOT/1_BENTHOS/2_MACROALGUES/...   3_OURSINS/...   4_RECRUES/...   5_BELT_CORAUX/...
#   R_PLOT/2_POISSONS/1_BELT_POISSONS/<site>/...   2_ANALYSES_MULTIVARIEES/
# Chaque graphique est enregistre UNE SEULE FOIS.
DOSSIER_GRAPHS      <- "R_PLOT"
DOSSIER_BDD         <- "R_BDD"              # classeurs Excel
DOSSIER_BANCARISATION <- "Historique de bancarisation"

# Themes et protocoles, dans l'ordre de l'arborescence (le rang donne le
# numero du dossier : 1_LIT, 2_MACROALGUES...). Modifier l'ordre ici suffit.
ARBORESCENCE <- list(
  BENTHOS  = c("LIT", "MACROALGUES", "OURSINS", "RECRUES", "BELT_CORAUX"),
  POISSONS = c("BELT_POISSONS", "ANALYSES_MULTIVARIEES")
)
NOM_DOSSIER_COMPARAISON <- "COMPARAISON_STATIONS"
NOMS_PERIODES <- c(annee = "1_Annee_en_cours", evolution = "2_Evolution",
                   # series completees par les donnees historiques 2002-2018
                   # (IUCN, graphiques gorgones) : graphiques SUPPLEMENTAIRES,
                   # ceux de 2_Evolution sont inchanges
                   historique = "3_Donnees_historiques")

# Au lancement, l'ancien dossier R_PLOT est renomme en R_PLOT_ANCIEN (le
# precedent R_PLOT_ANCIEN est remplace) : plus de graphiques obsoletes
# laisses par d'anciennes versions du script. FALSE = on ecrit par-dessus.
ARCHIVER_ANCIEN_R_PLOT <- TRUE

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

# Station couverte par le rapport Eco Récif Environnement 2024
STATION_RAPPORT_ECORECIF <- "Baleine de Pain de Sucre"
# Dates approximatives des campagnes du rapport Eco Récif Environnement (aucune date
# exacte n'est donnee pour le benthos dans le rapport)
DATES_CAMPAGNES_ECORECIF <- tibble::tibble(
  Annee = c(2018, 2020, 2023, 2024),
  Date  = as.Date(c("2018-12-01", "2020-01-01", "2023-03-01", "2024-11-01"))
)

# --- 4. Protocoles -------------------------------------------------------
LONGUEUR_TRANSECT_LIT_M       <- 30    # longueur nominale des transects LIT
SURFACE_QUADRAT_RECRUES_M2    <- 0.5   # nb recrues / surface = recrues/m2
SURFACE_QUADRAT_OURSINS_M2    <- 1
SURFACE_BELT_PAR_DEFAUT_M2    <- 10    # 10 m x 1 m si non renseigne
SURFACE_HISTO_OURSINS_M2      <- 60    # rapport Eco Récif Environnement : effectifs / 60 m2
SURFACE_HISTO_RECRUES_M2      <- 30    # rapport Eco Récif Environnement : juveniles / 30 m2

# BELT CORAIL - etats de sante
#  - atteintes (colonies VIVANTES atteintes) : peuvent se cumuler sur une
#    meme colonie (ex. une colonie SCTLD est aussi necrosee)
#  - mortes : colonies mortes, exclues de l'abondance et de la diversite
ETATS_ATTEINTE_BELT <- c("Necrose", "SCTLD", "Autres_Maladies", "Blanchissement")
ETATS_MORTS_BELT    <- c("Mort_Recent", "Mort_Ancien")

# BELT CORAIL - nombre de colonies atteintes sur une ligne ou plusieurs
# atteintes sont renseignees (ex. Nb_Necrose = 6 et Nb_SCTLD = 2) :
#   "cumul" : une colonie peut cumuler plusieurs atteintes -> colonies
#             atteintes = le plus grand des comptages (6 ici)
#   "somme" : chaque atteinte concerne des colonies differentes (8 ici)
BELT_MODE_COMPTAGE <- "cumul"

# BELT CORAIL - taille minimale des colonies comptees, par annee de suivi.
# Deux annees de protocoles differents ne sont PAS comparables (abondance,
# richesse, % de colonies atteintes) : pas de test ni d'evolution affichee
# entre elles, et le protocole est indique sous chaque annee des graphiques.
# Ajouter chaque nouvelle annee de suivi ici.
BELT_PROTOCOLE_TAILLE <- c(
  "2022" = "toutes colonies",
  "2026" = "colonies > 10 cm"
)

# Categories LIT comptees comme "algues" dans l'indicateur Algues/Corail.
# Les algues calcaires encroutantes (corallinacees) en sont exclues : ce
# sont des algues "favorables" (substrat de fixation des larves de corail)
# qui ne signalent pas une derive vers la dominance algale. Pour revenir
# a l'ancien calcul, ajouter "Algues calcaires encroutantes".
CATEGORIES_ALGUES_RATIO <- c("Macroalgues molles", "Turf algal", "Macroalgues calcaires")

# Poissons : taille (cm) attribuee a la classe "> 40 cm" pour le calcul de
# biomasse (a x L^b). 40 = borne basse (hypothese prudente, biomasse des
# gros individus sous-estimee) ; 45 ou 50 sont aussi utilises selon les
# protocoles - a harmoniser avec le rapport Eco Récif Environnement pour comparer.
TAILLE_CLASSE_PLUS_40_CM <- 40

# Poissons : correspondance nom ReefDB -> nom du referentiel
# Liste_147_Poissons.xlsx (fautes d'orthographe du referentiel ou
# synonymes). Mieux : corriger directement le referentiel, puis retirer
# la ligne correspondante ici.
SYNONYMES_TAXONS_POISSONS <- c(
  "Haemulon plumierii"       = "Haemulon plumieri",
  "Diodon holocanthus"       = "Diodon holacanthus",
  "Holocentrus adscensionis" = "Holocentrus adscencionis",
  "Rhinesomus triqueter"     = "Lactophrys triqueter",
  "Prognathodes aculeatus"   = "Chaetodon aculeatus"
)

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

# --- 6. Graphiques pour Canva ----------------------------------------------
GRAPHS_SANS_TITRE       <- TRUE    # titre retire des graphiques (ecrit dans Canva)
GRAPHS_SANS_SOUS_TITRE  <- FALSE   # les sous-titres portent souvent une info utile

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
