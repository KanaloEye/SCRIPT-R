# =====================================================================
# ETAT DE LA BANCARISATION DES DONNEES (tableau annees x protocoles)
# ---------------------------------------------------------------------
# Inventaire (a mettre a jour a chaque campagne) : pour chaque protocole,
# station et annee, la source de la donnee et son utilisation dans le
# traitement de l'annee en cours.
# =====================================================================

ANNEES_INVENTAIRE <- 2002:2026

# Campagnes connues par source
CAMPAGNES <- list(
  ATE_Baleine     = c(2002:2014, 2016, 2017, 2018, 2020, 2022, 2023, 2024),
  ATE_Coco        = c(2003:2012, 2016, 2017, 2018, 2022),
  ATE_Coco_sans_recrues = c(2007, 2010),        # recrues non renseignees
  Double_campagne = list(Baleine = 2002:2006, Coco = 2003:2006),
  EcoRecif_rapport = c(2018, 2020, 2023, 2024),  # Baleine uniquement
  EcoRecif_Coco_vide = 2024,                     # ligne vide dans l'ATE
  Creocean        = c(2022, 2026),
  # suivi LIT C. Bouchon au format IUCN (% par espece et par groupe)
  IUCN            = list(Baleine = 2002:2011, Coco = 2003:2011),
  # gorgones (comptage dedie / 60 m) lues sur les graphiques C. Bouchon
  # (campagnes sans barre : Baleine 2015 ; Coco dec. 2013, dec. 2014, 2015)
  Gorgones_graph  = list(Baleine = c(2002:2014, 2016, 2017),
                         Coco    = c(2003:2012, 2016, 2017, 2018))
)

# Libelles et couleurs des sources (ordre de la legende)
Sources_inventaire <- c(
  "BD Recif - donnees brutes"                          = "#1B7837",
  "Excel Creocean - donnees brutes non bancarisees"    = "#7FBF7B",
  "Rapport Eco Récif Environnement 2024 - valeurs retranscrites du PDF" = "#F4A261",
  "Historique ATE - valeurs compilees des rapports"    = "#FFE08A",
  "Donnees Eco Récif Environnement a priori existantes, non transmises" = "#D9D9D9",
  "Excel IUCN 2002-2011 (C. Bouchon) - % par espece, non bancarise" = "#80CDC1",
  "Graphiques C. Bouchon - valeurs lues sur les barres (+/- 1)"      = "#C2A5CF"
)
S <- names(Sources_inventaire)

construire_inventaire <- function() {
  ligne <- function(protocole, station, annees, source, inclus = TRUE) {
    if (length(annees) == 0) return(NULL)
    tibble::tibble(Protocole = protocole, Station = station, Annee = annees, Source = source, Inclus = inclus)
  }
  B <- CAMPAGNES$ATE_Baleine; C <- CAMPAGNES$ATE_Coco; R <- CAMPAGNES$EcoRecif_rapport; N <- CAMPAGNES$Creocean
  hist_B <- setdiff(B, c(R, N)); hist_C <- setdiff(C, N)
  I_B <- CAMPAGNES$IUCN$Baleine; I_C <- CAMPAGNES$IUCN$Coco
  G_B <- CAMPAGNES$Gorgones_graph$Baleine; G_C <- CAMPAGNES$Gorgones_graph$Coco
  dplyr::bind_rows(
    # LIT - recouvrement benthique : detail par espece (IUCN) jusqu'en 2011,
    # puis valeurs compilees ATE
    ligne("LIT - recouvrement benthique", "Baleine", I_B, S[6]),
    ligne("LIT - recouvrement benthique", "Baleine", setdiff(hist_B, I_B), S[4]),
    ligne("LIT - recouvrement benthique", "Baleine", R, S[3]),
    ligne("LIT - recouvrement benthique", "Baleine", N, S[1]),
    ligne("LIT - recouvrement benthique", "Coco", I_C, S[6]),
    ligne("LIT - recouvrement benthique", "Coco", setdiff(hist_C, I_C), S[4]),
    ligne("LIT - recouvrement benthique", "Coco", CAMPAGNES$EcoRecif_Coco_vide, S[5], FALSE),
    ligne("LIT - recouvrement benthique", "Coco", N, S[1]),
    # Recrues coralliennes
    ligne("Recrues coralliennes", "Baleine", hist_B, S[4]),
    ligne("Recrues coralliennes", "Baleine", R, S[3]),
    ligne("Recrues coralliennes", "Baleine", N, S[1]),
    ligne("Recrues coralliennes", "Coco", setdiff(hist_C, CAMPAGNES$ATE_Coco_sans_recrues), S[4]),
    ligne("Recrues coralliennes", "Coco", c(CAMPAGNES$ATE_Coco_sans_recrues, CAMPAGNES$EcoRecif_Coco_vide), S[5], FALSE),
    ligne("Recrues coralliennes", "Coco", N, S[1]),
    # Oursins
    ligne("Oursins", "Baleine", hist_B, S[5], FALSE),
    ligne("Oursins", "Baleine", R, S[3]),
    ligne("Oursins", "Baleine", N, S[1]),
    ligne("Oursins", "Coco", c(hist_C, CAMPAGNES$EcoRecif_Coco_vide), S[5], FALSE),
    ligne("Oursins", "Coco", N, S[1]),
    # Macroalgues (quadrats)
    ligne("Macroalgues (quadrats)", "Baleine", N, S[1]),
    ligne("Macroalgues (quadrats)", "Coco", N, S[1]),
    # Coraux (colonies) : protocole BELT uniquement en 2022 et 2026 (Creocean)
    ligne("Coraux - colonies (BELT)", "Baleine", N, S[2]),
    ligne("Coraux - colonies (BELT)", "Coco", N, S[2]),
    # Poissons
    ligne("Poissons (BELT)", "Baleine", hist_B, S[5], FALSE),
    ligne("Poissons (BELT)", "Baleine", R, S[3]),
    ligne("Poissons (BELT)", "Baleine", N, S[1]),
    ligne("Poissons (BELT)", "Coco", c(hist_C, CAMPAGNES$EcoRecif_Coco_vide), S[5], FALSE),
    ligne("Poissons (BELT)", "Coco", N, S[1]),
    # Gorgones : comptage dedie des colonies (effectifs / 60 m)
    ligne("Gorgones (comptage dedie)", "Baleine", setdiff(G_B, R), S[7]),
    ligne("Gorgones (comptage dedie)", "Baleine", R, S[3]),
    ligne("Gorgones (comptage dedie)", "Baleine", N, S[2]),
    ligne("Gorgones (comptage dedie)", "Coco", G_C, S[7]),
    ligne("Gorgones (comptage dedie)", "Coco", N, S[2])
  ) %>%
    dplyr::mutate(
      Double = (Station == "Baleine" & Annee %in% CAMPAGNES$Double_campagne$Baleine |
                Station == "Coco" & Annee %in% CAMPAGNES$Double_campagne$Coco) &
               Source %in% S[c(4, 6, 7)],
      Symbole = dplyr::case_when(Inclus & Double ~ "✓²", Inclus ~ "✓", TRUE ~ "✗")
    )
}

graph_etat_bancarisation <- function(inventaire) {
  ordre_lignes <- rev(as.vector(outer(c("Baleine", "Coco"), unique(inventaire$Protocole),
                                      function(s, p) paste0(p, " | ", s))))
  grille <- tidyr::expand_grid(Protocole = unique(inventaire$Protocole), Station = c("Baleine", "Coco"),
                               Annee = ANNEES_INVENTAIRE) %>%
    dplyr::left_join(inventaire, by = c("Protocole", "Station", "Annee")) %>%
    dplyr::mutate(Ligne = factor(paste0(Protocole, " | ", Station), levels = ordre_lignes),
                  Source = factor(Source, levels = S),
                  Couleur_texte = ifelse(Source %in% S[1], "white", "grey15"))

  ggplot2::ggplot(grille, ggplot2::aes(x = factor(Annee), y = Ligne)) +
    ggplot2::geom_tile(ggplot2::aes(fill = Source), colour = "white", linewidth = 0.8) +
    ggplot2::geom_text(ggplot2::aes(label = Symbole, colour = Couleur_texte), size = 3.2, fontface = "bold",
                       na.rm = TRUE, show.legend = FALSE) +
    ggplot2::scale_colour_identity() +
    ggplot2::scale_fill_manual(values = Sources_inventaire, na.value = "grey97", drop = FALSE, name = NULL,
                               na.translate = FALSE) +
    ggplot2::labs(title = "Etat de la bancarisation des donnees du suivi GCRMN de Saint-Barthelemy",
                  subtitle = "Source de la donnee par annee ; ✓ = utilisee dans le traitement 2026 ; ✗ = non utilisee ; case vide = pas de donnee connue",
                  caption = paste0("² deux campagnes dans l'annee (moyennees dans les graphiques).  ",
                                   "Coraux - colonies : protocole BELT realise en 2022 (toutes colonies) et 2026 (colonies > 10 cm), non comparables.\n",
                                   "LIT 2002-2011 : detail par espece (fichier IUCN) ; gorgones 2002-2018 : valeurs lues sur les graphiques C. Bouchon.\n",
                                   "Suivi Eco Récif Environnement 2002-2024 (donnees brutes Excel non transmises) ; campagnes 2022 et 2026 Creocean."),
                  x = NULL, y = NULL) +
    theme_fiche(legende = "bottom") +
    ggplot2::theme(axis.line = ggplot2::element_blank(), axis.ticks = ggplot2::element_blank(),
                   axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust = 1, size = 8.5),
                   axis.text.y = ggplot2::element_text(size = 8.5),
                   legend.text = ggplot2::element_text(size = 8)) +
    ggplot2::guides(fill = ggplot2::guide_legend(ncol = 2, byrow = FALSE))
}

# --- Version Excel modifiable ------------------------------------------------
# Meme tableau que la figure : une ligne par protocole x station, une colonne
# par annee. Chaque case contient un CODE de source + un symbole, choisi dans
# une liste deroulante ; la couleur de la case suit automatiquement le code
# (mise en forme conditionnelle) : modifier le texte suffit.
Codes_sources <- c("BDR" = S[1], "XLS" = S[2], "RPT" = S[3], "ATE" = S[4], "NT" = S[5],
                   "IUCN" = S[6], "GRA" = S[7])

exporter_etat_bancarisation_excel <- function(inventaire, chemin) {
  code <- setNames(names(Codes_sources), Codes_sources)
  lignes <- as.vector(outer(c("Baleine", "Coco"), unique(inventaire$Protocole), function(s, p) paste0(p, " | ", s)))
  tab <- inventaire %>%
    dplyr::mutate(Ligne = paste0(Protocole, " | ", Station),
                  Valeur = paste(code[Source], Symbole)) %>%
    dplyr::select(Ligne, Annee, Valeur) %>%
    tidyr::complete(Ligne = lignes, Annee = ANNEES_INVENTAIRE, fill = list(Valeur = "")) %>%
    dplyr::arrange(factor(Ligne, levels = lignes), Annee) %>%
    tidyr::pivot_wider(names_from = Annee, values_from = Valeur) %>%
    dplyr::rename(`Protocole | Station` = Ligne)

  wb <- openxlsx::createWorkbook()
  f <- "Tableau"
  openxlsx::addWorksheet(wb, f, gridLines = FALSE)
  openxlsx::writeData(wb, f, "Etat de la bancarisation des donnees du suivi GCRMN de Saint-Barthelemy",
                      startRow = 1, startCol = 1)
  openxlsx::writeData(wb, f, paste("✓ = utilisee dans le traitement 2026 ; ✗ = non utilisee ;",
                                   "² = deux campagnes dans l'annee ; case vide = pas de donnee connue.",
                                   "Modifier une case avec la liste deroulante : la couleur suit le code."),
                      startRow = 2, startCol = 1)
  openxlsx::addStyle(wb, f, openxlsx::createStyle(fontSize = 14, textDecoration = "bold"), rows = 1, cols = 1)
  openxlsx::addStyle(wb, f, openxlsx::createStyle(fontSize = 9, textDecoration = "italic"), rows = 2, cols = 1)

  debut <- 4
  openxlsx::writeData(wb, f, tab, startRow = debut, startCol = 1,
                      headerStyle = openxlsx::createStyle(textDecoration = "bold", halign = "center",
                                                          textRotation = 90, border = "Bottom"))
  n_l <- nrow(tab); n_c <- ncol(tab)
  lignes_donnees <- (debut + 1):(debut + n_l); cols_annees <- 2:n_c
  openxlsx::addStyle(wb, f, openxlsx::createStyle(halign = "center", valign = "center", fontSize = 9,
                                                  border = "TopBottomLeftRight", borderColour = "white"),
                     rows = lignes_donnees, cols = cols_annees, gridExpand = TRUE)
  openxlsx::addStyle(wb, f, openxlsx::createStyle(textDecoration = "bold", fontSize = 10),
                     rows = lignes_donnees, cols = 1, gridExpand = TRUE)
  openxlsx::setColWidths(wb, f, cols = 1, widths = 36)
  openxlsx::setColWidths(wb, f, cols = cols_annees, widths = 7.5)
  openxlsx::setRowHeights(wb, f, rows = debut, heights = 38)
  openxlsx::setRowHeights(wb, f, rows = lignes_donnees, heights = 22)
  openxlsx::freezePane(wb, f, firstActiveRow = debut + 1, firstActiveCol = 2)

  # couleur automatique selon le code
  for (k in names(Codes_sources)) {
    coul <- Sources_inventaire[[Codes_sources[[k]]]]
    police <- if (k == "BDR") "#FFFFFF" else "#262626"
    openxlsx::conditionalFormatting(wb, f, cols = cols_annees, rows = lignes_donnees, type = "beginsWith",
                                    rule = paste0(k, " "),
                                    style = openxlsx::createStyle(bgFill = coul, fontColour = police))
  }

  # feuille des listes + legende
  choix <- c(paste(rep(names(Codes_sources), each = 2), c("✓", "✗")), "ATE ✓²", "IUCN ✓²", "GRA ✓²", "")
  openxlsx::addWorksheet(wb, "Legende")
  legende <- tibble::tibble(Code = names(Codes_sources), Signification = unname(Codes_sources))
  openxlsx::writeData(wb, "Legende", legende, startRow = 1, startCol = 1,
                      headerStyle = openxlsx::createStyle(textDecoration = "bold"))
  for (i in seq_len(nrow(legende))) {
    openxlsx::addStyle(wb, "Legende", openxlsx::createStyle(fgFill = Sources_inventaire[[legende$Signification[i]]],
                                                            fontColour = if (legende$Code[i] == "BDR") "#FFFFFF" else "#262626"),
                       rows = i + 1, cols = 1:2, gridExpand = TRUE)
  }
  openxlsx::writeData(wb, "Legende", c("✓ = donnee utilisee dans le traitement 2026",
                                       "✗ = donnee non utilisee",
                                       "² = deux campagnes dans l'annee (moyennees)",
                                       "Case vide = pas de donnee connue"),
                      startRow = nrow(legende) + 3, startCol = 1)
  openxlsx::writeData(wb, "Legende", data.frame(`Valeurs possibles` = choix, check.names = FALSE),
                      startRow = 1, startCol = 4, headerStyle = openxlsx::createStyle(textDecoration = "bold"))
  openxlsx::setColWidths(wb, "Legende", cols = c(1, 2, 4), widths = c(8, 55, 18))
  openxlsx::dataValidation(wb, f, cols = cols_annees, rows = lignes_donnees, type = "list",
                           value = sprintf("'Legende'!$D$2:$D$%d", length(choix) + 1))

  openxlsx::saveWorkbook(wb, chemin, overwrite = TRUE)
  invisible(chemin)
}
