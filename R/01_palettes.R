# =====================================================================
# PALETTES DE COULEURS ET FORMES (une seule definition pour tout le script)
# =====================================================================

# --- Stations (definies dans 00_parametres.R) -----------------------------
Palette_stations <- setNames(STATIONS$couleur, STATIONS$nom)

# --- Indicateurs "compartiment" (series temporelles) ----------------------
Palette_indicateurs <- c(
  "Corail dur"  = "lightsalmon3",
  "Macroalgues" = "seagreen4",
  "Recrues"     = "sienna3",
  "Oursins"     = "grey25"
)

# --- Sources de donnees ------------------------------------------------------
# Formes FIXEES explicitement (sinon ggplot attribue rond/triangle/carre
# dans l'ordre alphabetique des sources presentes sur chaque graphique).
#   rond = extraction ReefDB ; triangle = historique ATE ; carre = Bouchon 2024
Formes_source <- c(
  "Extraction_ReefDB_LIT"     = 16,
  "Extraction_ReefDB_Quadrat" = 16,
  "Extraction_ReefDB_BELT"    = 16,
  "Historique_ATE"            = 17,
  "Rapport_Bouchon_2024"      = 15
)
Libelles_source <- c(
  "Extraction_ReefDB_LIT"     = "Extraction ReefDB",
  "Extraction_ReefDB_Quadrat" = "Extraction ReefDB",
  "Extraction_ReefDB_BELT"    = "Extraction ReefDB",
  "Historique_ATE"            = "Historique ATE",
  "Rapport_Bouchon_2024"      = "Rapport Bouchon 2024"
)
Couleurs_source <- c(
  "Extraction_ReefDB_LIT"     = "steelblue3",
  "Extraction_ReefDB_Quadrat" = "steelblue3",
  "Extraction_ReefDB_BELT"    = "steelblue3",
  "Historique_ATE"            = "grey60",
  "Rapport_Bouchon_2024"      = "darkorange2"
)

# --- Benthos LIT -------------------------------------------------------------
Palette_nature_recouvrement <- c(
  "Autres algues" = 'seagreen2',
  "Algues indicatrices d'eutrophisation (NIA)" = 'seagreen4',
  "Autres invertébrés" = 'midnightblue',
  "Zoanthaires" = 'coral',
  "Coraux durs" = 'lightsalmon1',
  "Non vivant" = 'lightsteelblue4',
  "Herbiers" = 'darkseagreen1'
)

# Une couleur distincte par categorie fine (graphique Composition detaillee)
Palette_categorie_detail <- c(
  "Coraux durs" = 'lightsalmon1',
  "Corail mort récent" = 'grey30',
  "Macroalgues molles" = 'seagreen4',
  "Turf algal" = 'darkolivegreen3',
  "Macroalgues calcaires" = 'seagreen3',
  "Algues calcaires encroutantes" = 'palegreen3',
  "Cyanophycées" = 'gold3',
  "Eponges" = 'midnightblue',
  "Gorgones" = 'slateblue3',
  "Zoanthaires" = 'coral',
  "Herbiers" = 'darkseagreen1',
  "Roche" = 'azure4',
  "Sable" = 'azure1',
  "Débris" = 'azure2'
)

Palette_taxons_coralliens <- c(
  "Acropora cervicornis" = 'lightpink',
  "Acropora palmata" = 'lightblue',
  "Agaricia agaricites" = 'green3',
  "Agaricia lamarcki" = 'green4',
  "Agaricia humilis" = 'green2',
  "Agaricia sp." = 'darkgreen',
  "Agariciidae" = 'lightgreen',
  "Colpophyllia natans" = 'blue1',
  "Corallimorpharia" = 'purple3',
  "Dendrogyra cylindrus" = 'yellow4',
  "Dichocoenia stokesii" = 'chartreuse',
  "Dichocoenia" = 'chartreuse',
  "Diploria" = '#FF7F00',
  "Diploria labyrinthiformis" = '#FF7F33',
  "Eusmilia fastigiata" = 'yellow3',
  "Favia fragum" = 'gray',
  "Helioseris cucullata" = 'mediumseagreen',
  "Isophyllia" = 'seagreen',
  "Madracis auretenra" = 'yellow',
  "Madracis decactis" = 'yellow2',
  "Madracis myriaster" = 'yellow2',
  "Madracis" = 'yellow2',
  "Meandrina meandrites" = 'gray',
  "Meandrina" = 'gray',
  "Meandrina jacksoni" = 'gray',
  "Millepora" = 'gold',
  "Millepora alcicornis" = 'gold',
  "Millepora squarrosa" = 'goldenrod',
  "Montastraea cavernosa" = 'lightblue',
  "Montastraea" = 'lightblue',
  "Mycetophyllia" = '#6A3D9A',
  "Orbicella" = '#6A3D9A',
  "Orbicella annularis" = '#7A4DAA',
  "Orbicella faveolata" = 'purple',
  "Orbicella franksi" = 'plum',
  "Porites astreoides" = '#FDBF6F',
  "Porites porites" = 'orange',
  "Porites divaricata" = 'orange3',
  "Porites branneri" = 'orange4',
  "Porites furcata" = 'darkorange3',
  "Porites" = 'darkorange',
  "Pseudodiploria" = 'royalblue',
  "Pseudodiploria strigosa" = 'royalblue',
  "Pseudodiploria clivosa" = 'royalblue',
  "Siderastrea" = '#FB9A99',
  "Siderastrea radians" = '#E31A1C',
  "Siderastrea siderea" = '#FA7A79',
  "Solenastrea bournoni" = 'magenta',
  "Solenastrea" = 'magenta',
  "Stephanocoenia" = 'tomato',
  "Stephanocoenia intersepta" = 'tomato4',
  "Stylaster roseus" = 'pink',
  "NA" = 'black'
)

# --- BELT CORAIL : etat de sante ---------------------------------------------
Palette_etat_sante <- c("Sain" = "seagreen3", "Necrose" = "khaki2", "SCTLD" = "darkorange2",
                        "Autres_Maladies" = "orange3", "Blanchissement" = "lightskyblue1",
                        "Mort_Recent" = "orangered3", "Mort_Ancien" = "grey30")
Libelles_etat_sante <- c("Sain" = "Sain", "Necrose" = "Necrose", "SCTLD" = "SCTLD",
                         "Autres_Maladies" = "Autres maladies", "Blanchissement" = "Blanchissement",
                         "Mort_Recent" = "Mort recent", "Mort_Ancien" = "Mort ancien")

# --- Macroalgues (quadrats) et oursins -----------------------------------------
Palette_taxons_macroalgues <- c(
  "Dictyota"    = "seagreen4",
  "Turbinaria"  = "darkolivegreen3",
  "Stypopodium" = "goldenrod3",
  "Lobophora"   = "palegreen3",
  "Wrangelia"   = "orchid3",
  "Sargassum"   = "chocolate3"
)

Palette_oursin <- c(
  "Diadema antillarum" = 'lightgoldenrod3',
  "Echinometra lucunter" = 'peachpuff3',
  "Echinometra viridis" = 'peachpuff2',
  "Eucidaris tribuloides" = 'peachpuff4',
  "Tripneustes ventricosus" = 'papayawhip',
  "Lytechinus variegatus" = 'peachpuff1',
  "Meoma ventricosa" = 'gray32'
)

# --- Poissons ------------------------------------------------------------------
Palette_regime_trophique <- c("Herbivore" = 'yellowgreen',
                              "Planctonophage" = 'lightblue',
                              "Omnivore" = 'dodgerblue',
                              "Carnivore1" = 'khaki1',
                              "Carnivore2" = 'burlywood1',
                              "Piscivore" = 'firebrick1')
Ordre_regime_trophique <- c("Herbivore", "Omnivore", "Planctonophage",
                            "Carnivore1", "Carnivore2", "Piscivore")

# Abreviations du rapport Bouchon (He, Om...) -> memes couleurs
Abreviations_trophiques <- c("He" = "Herbivore", "Om" = "Omnivore", "Pl" = "Planctonophage",
                             "C1" = "Carnivore1", "C2" = "Carnivore2", "Pi" = "Piscivore")

Palette_taille <- c("< 5 cm" = 'lightblue', "5 - 10 cm" = 'skyblue2',
                    "10 - 20 cm" = 'dodgerblue3', "20 - 30 cm" = 'steelblue4',
                    "30 - 40 cm" = 'mediumblue', "> 40 cm" = 'midnightblue')

# Completer une palette pour des modalites non prevues (couleurs
# automatiques distinctes) plutot que de laisser des barres grises/NA
completer_palette <- function(palette, modalites) {
  modalites <- unique(as.character(modalites[!is.na(modalites)]))
  manquantes <- setdiff(modalites, names(palette))
  if (length(manquantes) > 0) {
    palette <- c(palette, setNames(
      grDevices::hcl.colors(max(length(manquantes), 2), "Dark 3")[seq_along(manquantes)],
      manquantes))
  }
  palette
}
