# =====================================================================
# FONCTIONS GRAPHIQUES
# ---------------------------------------------------------------------
# Tous les graphiques du script passent par ces fonctions : un
# changement de style (police, tailles, etiquettes...) s'applique donc
# partout d'un coup.
#   theme_fiche()        theme commun
#   sauver_graph()       export PNG (+ copie dans le dossier des fiches Canva)
#   graph_empile()       barres empilees (compositions en %)
#   graph_barres_sd()    barres moyenne +/- ecart-type (+ etoiles de test)
#   graph_serie()        series temporelles (+ droite de tendance, R2, p)
#   graph_camembert()    diagramme circulaire
# =====================================================================

# --- Theme ------------------------------------------------------------------
# Fond transparent (panneau, figure, legende et bandeaux de facette)
fond_transparent <- ggplot2::theme(
  panel.background  = ggplot2::element_rect(fill = "transparent", colour = NA),
  plot.background   = ggplot2::element_rect(fill = "transparent", colour = NA),
  legend.background = ggplot2::element_rect(fill = "transparent", colour = NA),
  legend.key        = ggplot2::element_rect(fill = "transparent", colour = NA),
  strip.background  = ggplot2::element_rect(fill = "transparent", colour = NA)
)

theme_fiche <- function(base_size = TAILLE_POLICE_BASE, legende = "bottom") {
  ggplot2::theme_classic(base_size = base_size, base_family = POLICE_GRAPHS) +
    ggplot2::theme(
      plot.title          = ggplot2::element_text(face = "bold", size = ggplot2::rel(1.2), hjust = 0.5, lineheight = 1.1),
      plot.title.position = "plot",
      plot.subtitle       = ggplot2::element_text(size = ggplot2::rel(0.8), hjust = 0.5, face = "italic", lineheight = 1.1),
      plot.caption        = ggplot2::element_text(size = ggplot2::rel(0.72), hjust = 0, face = "italic", lineheight = 1.15),
      plot.caption.position = "plot",
      axis.text           = ggplot2::element_text(size = ggplot2::rel(0.95), face = "bold"),
      axis.title.y        = ggplot2::element_text(size = ggplot2::rel(0.95), face = "bold"),
      axis.title.x        = ggplot2::element_blank(),
      legend.position     = legende,
      legend.title        = ggplot2::element_blank(),
      legend.text         = ggplot2::element_text(size = ggplot2::rel(0.85)),
      legend.key.size     = ggplot2::unit(0.4, "cm"),
      strip.text          = ggplot2::element_text(face = "bold", size = ggplot2::rel(0.95)),
      plot.margin         = ggplot2::margin(6, 10, 6, 6)
    ) +
    fond_transparent
}

scale_shape_source <- function() {
  ggplot2::scale_shape_manual(values = Formes_source, labels = Libelles_source, name = NULL)
}

# --- Export -------------------------------------------------------------------
nettoyer_nom_fichier <- function(x) {
  x <- iconv(x, to = "ASCII//TRANSLIT")
  gsub("_+", "_", gsub("[^A-Za-z0-9._-]+", "_", x))
}

enregistrer_png <- function(plot, chemin, dims) {
  if (requireNamespace("ragg", quietly = TRUE)) {
    # ragg : rendu plus net et acces aux polices installees (POLICE_GRAPHS)
    ggplot2::ggsave(chemin, plot, width = dims[1], height = dims[2], units = "cm",
                    dpi = DPI_EXPORT, bg = "transparent", device = ragg::agg_png, limitsize = FALSE)
  } else {
    ggplot2::ggsave(chemin, plot, width = dims[1], height = dims[2], units = "cm",
                    dpi = DPI_EXPORT, bg = "transparent", limitsize = FALSE)
  }
}

# Dossiers des fiches Canva
fiche_station  <- function(station, partie) file.path(nom_court_station(station), partie)
fiche_synthese <- function(partie) paste0("Synthese_", partie)

# Enregistre le graphique dans R_PLOT/<dossier>/<nom>.png et, si `fiche`
# est renseigne, une copie SANS titre dans R_PLOT/FICHES/<fiche>/NN_<nom>.png
# (NN = ordre d'apparition sur la fiche). `plot_fiche` permet de fournir
# une version specifique pour la fiche (ex. figure combinee).
sauver_graph <- function(plot, dossier, nom, format = "standard", fiche = NULL, ordre = NULL,
                         largeur = NULL, hauteur = NULL, plot_fiche = NULL) {
  dims <- FORMATS_EXPORT[[format]]
  if (is.null(dims)) stop("Format d'export inconnu : ", format)
  if (!is.null(largeur)) dims[1] <- largeur
  if (!is.null(hauteur)) dims[2] <- hauteur
  nom <- nettoyer_nom_fichier(nom)

  dossier_complet <- file.path(DOSSIER_GRAPHS, dossier)
  dir.create(dossier_complet, showWarnings = FALSE, recursive = TRUE)
  chemin <- file.path(dossier_complet, paste0(nom, ".png"))
  enregistrer_png(plot, chemin, dims)

  if (EXPORT_FICHES && !is.null(fiche)) {
    p_fiche <- if (!is.null(plot_fiche)) plot_fiche else plot
    if (inherits(p_fiche, "ggplot") && is.null(plot_fiche)) {
      if (FICHES_SANS_TITRE)      p_fiche <- p_fiche + ggplot2::labs(title = NULL)
      if (FICHES_SANS_SOUS_TITRE) p_fiche <- p_fiche + ggplot2::labs(subtitle = NULL)
    }
    dossier_fiche <- file.path(DOSSIER_FICHES, fiche)
    dir.create(dossier_fiche, showWarnings = FALSE, recursive = TRUE)
    nom_fiche <- if (!is.null(ordre)) sprintf("%02d_%s", ordre, nom) else nom
    enregistrer_png(p_fiche, file.path(dossier_fiche, paste0(nom_fiche, ".png")), dims)
  }
  invisible(chemin)
}

# --- Etiquettes -----------------------------------------------------------------
# Position verticale du centre de chaque segment d'une barre empilee
# (calcul manuel : plus fiable que position_stack() sur geom_text/label)
ajouter_position_etiquettes <- function(df, groupe_var, fill_var, valeur_var) {
  df %>%
    dplyr::arrange({{ groupe_var }}, {{ fill_var }}) %>%
    dplyr::group_by({{ groupe_var }}) %>%
    dplyr::mutate(
      .total  = sum({{ valeur_var }}),
      .cum    = cumsum({{ valeur_var }}),
      y_label = .total - (.cum - {{ valeur_var }} / 2)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(-.total, -.cum)
}

# Texte noir ou blanc selon la luminance du fond (lisible sans encart)
choisir_couleur_texte <- function(couleurs) {
  couleurs <- ifelse(is.na(couleurs), "grey50", couleurs)
  rgb_vals <- grDevices::col2rgb(couleurs)
  luminance <- (0.299 * rgb_vals[1, ] + 0.587 * rgb_vals[2, ] + 0.114 * rgb_vals[3, ]) / 255
  ifelse(luminance > 0.6, "black", "white")
}

# Etiquette affichee SEULEMENT s'il y a la place de l'ecrire dans la case
etiquette_si_place <- function(valeur, hauteur_axe, texte, frac_min = FRACTION_MIN_ETIQUETTE) {
  ifelse(!is.na(valeur) & valeur > 0 & valeur >= frac_min * hauteur_axe, texte, "")
}

# Hauteur de l'axe d'un graphique empile = total de la plus haute barre
hauteur_empilee <- function(valeur, x) {
  max(tapply(valeur, x, sum, na.rm = TRUE), na.rm = TRUE)
}

# Lignes de reference optionnelles (SEUILS_REFERENCE dans 00_parametres.R)
couches_seuils <- function(seuils) {
  if (is.null(seuils) || length(seuils) == 0) return(NULL)
  d <- tibble::tibble(nom = names(seuils), valeur = unname(seuils))
  list(
    ggplot2::geom_hline(data = d, ggplot2::aes(yintercept = valeur), linetype = "dotted",
                        colour = "grey20", linewidth = 0.6, inherit.aes = FALSE),
    ggplot2::geom_text(data = d, ggplot2::aes(x = -Inf, y = valeur, label = nom), hjust = -0.05, vjust = -0.4,
                       size = 2.8, colour = "grey20", fontface = "italic", inherit.aes = FALSE)
  )
}

# --- Barres empilees ------------------------------------------------------------
graph_empile <- function(df, x, y, fill, palette, labels_fill = ggplot2::waiver(),
                         titre = NULL, sous_titre = NULL, legende_titre = NULL,
                         y_lab = "Pourcentage (%)", decimales = 1, suffixe = "%",
                         legende_nrow = NULL, legende_ncol = NULL, inverser_legende = FALSE,
                         legende_italique = FALSE, largeur_barre = 0.7, taille_etiquette = 3) {
  df <- df %>% dplyr::filter(!is.na(.data[[y]]), !is.na(.data[[fill]]))
  palette <- completer_palette(palette, df[[fill]])
  niveaux <- intersect(names(palette), unique(as.character(df[[fill]])))

  df <- df %>%
    dplyr::mutate(.x = factor(.data[[x]]),
                  .fill = factor(as.character(.data[[fill]]), levels = niveaux),
                  .y = .data[[y]]) %>%
    ajouter_position_etiquettes(.x, .fill, .y)
  h <- hauteur_empilee(df$.y, df$.x)
  df <- df %>%
    dplyr::mutate(.etiq = etiquette_si_place(.y, h, paste0(formater_nombre(.y, decimales), suffixe)),
                  .coul = choisir_couleur_texte(palette[as.character(.fill)]))

  p <- ggplot2::ggplot(df, ggplot2::aes(x = .x, y = .y, fill = .fill)) +
    ggplot2::geom_col(width = largeur_barre) +
    ggplot2::geom_text(data = ~ subset(., .etiq != ""),
                       ggplot2::aes(y = y_label, label = .etiq, colour = .coul),
                       size = taille_etiquette, fontface = "bold", show.legend = FALSE) +
    ggplot2::scale_colour_identity() +
    ggplot2::scale_fill_manual(values = palette, labels = labels_fill, drop = TRUE, name = legende_titre) +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.03))) +
    ggplot2::labs(title = titre, subtitle = sous_titre, y = y_lab) +
    theme_fiche() +
    ggplot2::guides(fill = ggplot2::guide_legend(nrow = legende_nrow, ncol = legende_ncol,
                                                 byrow = TRUE, reverse = inverser_legende))
  if (legende_italique) p <- p + ggplot2::theme(legend.text = ggplot2::element_text(face = "italic", size = ggplot2::rel(0.8)))
  p
}

# --- Barres moyenne +/- ecart-type -----------------------------------------------
# fill = NULL -> une seule couleur (`couleur`) ; sinon barres cote a cote
# par modalite de `fill` (ex. Station, Source).
# comparaisons = sortie de comparer_annees() (colonnes Annee, Signif) :
# etoiles au-dessus de l'annee testee (vs annee de suivi precedente).
graph_barres_sd <- function(df, x, y, sd = NULL, fill = NULL, palette = NULL, labels_fill = ggplot2::waiver(),
                            couleur = "lightsalmon3", titre = NULL, sous_titre = NULL, legende_titre = NULL,
                            y_lab = "", decimales = 1, suffixe = "", comparaisons = NULL,
                            seuils = NULL, n_col = NULL, largeur_barre = 0.7) {
  df <- df %>% dplyr::filter(!is.na(.data[[y]]))
  df <- df %>%
    dplyr::mutate(.x = factor(.data[[x]]),
                  .y = .data[[y]],
                  .sd = if (!is.null(sd)) .data[[sd]] else NA_real_,
                  .fill = if (!is.null(fill)) factor(.data[[fill]]) else factor("unique"),
                  .haut = .y + ifelse(is.na(.sd), 0, .sd),
                  .etiq = paste0(formater_nombre(.y, decimales), suffixe))
  dodge <- ggplot2::position_dodge(width = 0.8)
  y_max <- max(df$.haut, na.rm = TRUE)

  p <- ggplot2::ggplot(df, ggplot2::aes(x = .x, y = .y, fill = .fill, group = .fill)) +
    ggplot2::geom_col(position = dodge, width = largeur_barre) +
    ggplot2::geom_errorbar(ggplot2::aes(ymin = pmax(.y - .sd, 0), ymax = .y + .sd),
                           position = dodge, width = 0.2, linewidth = 0.45, na.rm = TRUE) +
    # etiquette de valeur au-dessus de la barre (ou de la barre d'erreur)
    ggplot2::geom_text(ggplot2::aes(y = .haut, label = .etiq), position = dodge,
                       vjust = -0.5, size = 3, fontface = "bold") +
    ggplot2::labs(title = titre, subtitle = sous_titre, y = y_lab) +
    theme_fiche()

  if (is.null(fill)) {
    p <- p + ggplot2::scale_fill_manual(values = c("unique" = couleur), guide = "none")
  } else {
    pal <- if (is.null(palette)) NULL else completer_palette(palette, df$.fill)
    p <- p + ggplot2::scale_fill_manual(values = pal, labels = labels_fill, name = legende_titre)
  }

  # effectif (n replicats) rappele DANS la barre, si la place
  if (!is.null(n_col) && is.null(fill)) {
    p <- p + ggplot2::geom_text(data = ~ subset(., .y >= 0.15 * y_max),
                                ggplot2::aes(y = .y / 2, label = paste0("n = ", .data[[n_col]])),
                                size = 2.6, colour = "white", fontface = "italic")
  }

  marge_haute <- 0.15
  if (!is.null(comparaisons) && nrow(comparaisons) > 0) {
    # etoile centree sur l'annee, au-dessus de la plus haute barre de l'annee
    comp <- comparaisons %>%
      dplyr::filter(Signif != "") %>%
      dplyr::mutate(.x = factor(Annee, levels = levels(df$.x))) %>%
      dplyr::left_join(df %>% dplyr::group_by(.x) %>% dplyr::summarise(.haut = max(.haut), .groups = "drop"),
                       by = ".x") %>%
      dplyr::filter(!is.na(.haut))
    if (nrow(comp) > 0) {
      p <- p + ggplot2::geom_text(data = comp, ggplot2::aes(x = .x, y = .haut + 0.1 * y_max, label = Signif),
                                  inherit.aes = FALSE, size = 3.6, colour = "grey25", fontface = "bold")
      marge_haute <- 0.25
    }
  }
  p <- p + ggplot2::scale_y_continuous(limits = c(0, NA), expand = ggplot2::expansion(mult = c(0, marge_haute))) +
    couches_seuils(seuils)
  p
}

# --- Series temporelles -------------------------------------------------------------
# Une courbe par modalite de `couleur` ; forme des points = source de la
# donnee ; droite de tendance lineaire (+ IC 95 %) et statistiques de
# tendance en legende sous le graphique. La table des tendances est
# renvoyee en attribut : attr(p, "tendances").
graph_serie <- function(df, x, y, couleur, palette = NULL, forme = "Source", sd = NULL,
                        tendance = TRUE, etiquettes = TRUE, titre = NULL, sous_titre = NULL,
                        y_lab = "", unite = "", decimales = 1, seuils = NULL, relier = TRUE) {
  df <- df %>% dplyr::filter(!is.na(.data[[y]])) %>%
    dplyr::mutate(.x = .data[[x]], .y = .data[[y]], .col = .data[[couleur]],
                  .sd = if (!is.null(sd)) .data[[sd]] else NA_real_)
  pal <- if (is.null(palette)) NULL else completer_palette(palette, df$.col)

  p <- ggplot2::ggplot(df, ggplot2::aes(x = .x, y = .y, colour = .col))
  if (relier) p <- p + ggplot2::geom_line(ggplot2::aes(group = .col), linewidth = 0.7, alpha = 0.45)

  tendances <- NULL
  if (tendance) {
    tendances <- tendances_par_groupe(df, ".x", ".y", .col)
    groupes_ok <- tendances$.col[!is.na(tendances$Pente_an)]
    if (length(groupes_ok) > 0) {
      p <- p + ggplot2::geom_smooth(data = ~ subset(., .col %in% groupes_ok),
                                    ggplot2::aes(group = .col, fill = .col), method = "lm", formula = y ~ x,
                                    se = TRUE, linetype = "dashed", linewidth = 0.8, alpha = 0.1,
                                    show.legend = FALSE)
    }
  }

  p <- p +
    ggplot2::geom_errorbar(ggplot2::aes(ymin = pmax(.y - .sd, 0), ymax = .y + .sd),
                           width = if (inherits(df$.x, "Date")) 120 else 0.3,
                           alpha = 0.5, na.rm = TRUE, show.legend = FALSE)
  if (!is.null(forme) && forme %in% names(df)) {
    p <- p + ggplot2::geom_point(ggplot2::aes(shape = .data[[forme]]), size = 2.8) + scale_shape_source()
  } else {
    p <- p + ggplot2::geom_point(size = 2.8)
  }
  if (etiquettes) {
    p <- p + ggrepel::geom_text_repel(ggplot2::aes(label = formater_nombre(.y, decimales)),
                                      size = 2.6, fontface = "bold", show.legend = FALSE,
                                      min.segment.length = 0.3, seed = 1)
  }
  if (!is.null(pal)) {
    p <- p + ggplot2::scale_colour_manual(values = pal) + ggplot2::scale_fill_manual(values = pal, guide = "none")
  }

  legende <- NULL
  if (!is.null(tendances) && any(!is.na(tendances$Pente_an))) {
    t_ok <- tendances %>% dplyr::filter(!is.na(Pente_an))
    legende <- paste(vapply(seq_len(nrow(t_ok)), function(i) {
      texte_tendance(t_ok[i, ], unite, prefixe = paste0(t_ok$.col[i], " : "))
    }, character(1)), collapse = "\n")
  }

  p <- p +
    ggplot2::scale_y_continuous(limits = c(0, NA), expand = ggplot2::expansion(mult = c(0, 0.1)),
                                oob = scales::squish) +
    couches_seuils(seuils) +
    ggplot2::labs(title = titre, subtitle = sous_titre, y = y_lab,
                  caption = if (!is.null(legende)) paste0("Tirets = tendance lineaire (IC 95 %)\n", legende) else NULL) +
    theme_fiche() +
    ggplot2::theme(legend.box = "vertical")

  if (!is.null(tendances)) tendances <- dplyr::rename(tendances, Groupe = .col)
  attr(p, "tendances") <- tendances
  p
}

# --- Camembert ----------------------------------------------------------------------
graph_camembert <- function(df, valeur, fill, palette, labels_fill = ggplot2::waiver(),
                            titre = NULL, sous_titre = NULL, frac_min = 0.04, legende_nrow = 2) {
  df <- df %>% dplyr::filter(!is.na(.data[[valeur]]), .data[[valeur]] > 0)
  palette <- completer_palette(palette, df[[fill]])
  niveaux <- intersect(names(palette), unique(as.character(df[[fill]])))
  df <- df %>%
    dplyr::mutate(.fill = factor(as.character(.data[[fill]]), levels = niveaux),
                  .v = 100 * .data[[valeur]] / sum(.data[[valeur]]), .g = 1) %>%
    ajouter_position_etiquettes(.g, .fill, .v) %>%
    dplyr::mutate(.etiq = etiquette_si_place(.v, 100, paste0(round(.v), "%"), frac_min),
                  .coul = choisir_couleur_texte(palette[as.character(.fill)]))

  ggplot2::ggplot(df, ggplot2::aes(x = 1, y = .v, fill = .fill)) +
    ggplot2::geom_col(width = 1, colour = "white") +
    ggplot2::geom_text(data = ~ subset(., .etiq != ""),
                       ggplot2::aes(x = 1.15, y = y_label, label = .etiq, colour = .coul),
                       size = 3.3, fontface = "bold", show.legend = FALSE) +
    ggplot2::scale_colour_identity() +
    ggplot2::coord_polar(theta = "y") +
    ggplot2::scale_fill_manual(values = palette, labels = labels_fill, drop = TRUE) +
    ggplot2::labs(title = titre, subtitle = sous_titre) +
    ggplot2::theme_void(base_family = POLICE_GRAPHS) +
    ggplot2::theme(plot.title = ggplot2::element_text(face = "bold", hjust = 0.5, size = 12),
                   plot.subtitle = ggplot2::element_text(hjust = 0.5, size = 9, face = "italic"),
                   legend.position = "bottom", legend.title = ggplot2::element_blank()) +
    fond_transparent +
    ggplot2::guides(fill = ggplot2::guide_legend(nrow = legende_nrow, byrow = TRUE))
}
