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
  Bouchon_rapport = c(2018, 2020, 2023, 2024),  # Baleine uniquement
  Bouchon_Coco_vide = 2024,                     # ligne vide dans l'ATE
  Creocean        = c(2022, 2026)
)

# Libelles et couleurs des sources (ordre de la legende)
Sources_inventaire <- c(
  "BD Recif - donnees brutes"                          = "#1B7837",
  "Excel Creocean - donnees brutes non bancarisees"    = "#7FBF7B",
  "Rapport Bouchon 2024 - valeurs retranscrites du PDF" = "#F4A261",
  "Historique ATE - valeurs compilees des rapports"    = "#FFE08A",
  "Donnees Bouchon a priori existantes, non transmises" = "#D9D9D9"
)
S <- names(Sources_inventaire)

construire_inventaire <- function() {
  ligne <- function(protocole, station, annees, source, inclus = TRUE) {
    if (length(annees) == 0) return(NULL)
    tibble::tibble(Protocole = protocole, Station = station, Annee = annees, Source = source, Inclus = inclus)
  }
  B <- CAMPAGNES$ATE_Baleine; C <- CAMPAGNES$ATE_Coco; R <- CAMPAGNES$Bouchon_rapport; N <- CAMPAGNES$Creocean
  hist_B <- setdiff(B, c(R, N)); hist_C <- setdiff(C, N)
  dplyr::bind_rows(
    # LIT - recouvrement benthique
    ligne("LIT - recouvrement benthique", "Baleine", hist_B, S[4]),
    ligne("LIT - recouvrement benthique", "Baleine", R, S[3]),
    ligne("LIT - recouvrement benthique", "Baleine", N, S[1]),
    ligne("LIT - recouvrement benthique", "Coco", hist_C, S[4]),
    ligne("LIT - recouvrement benthique", "Coco", CAMPAGNES$Bouchon_Coco_vide, S[5], FALSE),
    ligne("LIT - recouvrement benthique", "Coco", N, S[1]),
    # Recrues coralliennes
    ligne("Recrues coralliennes", "Baleine", hist_B, S[4]),
    ligne("Recrues coralliennes", "Baleine", R, S[3]),
    ligne("Recrues coralliennes", "Baleine", N, S[1]),
    ligne("Recrues coralliennes", "Coco", setdiff(hist_C, CAMPAGNES$ATE_Coco_sans_recrues), S[4]),
    ligne("Recrues coralliennes", "Coco", c(CAMPAGNES$ATE_Coco_sans_recrues, CAMPAGNES$Bouchon_Coco_vide), S[5], FALSE),
    ligne("Recrues coralliennes", "Coco", N, S[1]),
    # Oursins
    ligne("Oursins", "Baleine", hist_B, S[5], FALSE),
    ligne("Oursins", "Baleine", R, S[3]),
    ligne("Oursins", "Baleine", N, S[1]),
    ligne("Oursins", "Coco", c(hist_C, CAMPAGNES$Bouchon_Coco_vide), S[5], FALSE),
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
    ligne("Poissons (BELT)", "Coco", c(hist_C, CAMPAGNES$Bouchon_Coco_vide), S[5], FALSE),
    ligne("Poissons (BELT)", "Coco", N, S[1])
  ) %>%
    dplyr::mutate(
      Double = (Station == "Baleine" & Annee %in% CAMPAGNES$Double_campagne$Baleine |
                Station == "Coco" & Annee %in% CAMPAGNES$Double_campagne$Coco) &
               Source == S[4],
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
                                   "Suivi Bouchon 2002-2024 (donnees brutes Excel non transmises) ; campagnes 2022 et 2026 Creocean."),
                  x = NULL, y = NULL) +
    theme_fiche(legende = "bottom") +
    ggplot2::theme(axis.line = ggplot2::element_blank(), axis.ticks = ggplot2::element_blank(),
                   axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust = 1, size = 8.5),
                   axis.text.y = ggplot2::element_text(size = 8.5),
                   legend.text = ggplot2::element_text(size = 8)) +
    ggplot2::guides(fill = ggplot2::guide_legend(ncol = 2, byrow = FALSE))
}
