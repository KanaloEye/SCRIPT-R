# =====================================================================
# FONCTIONS OUTILS : fichiers, stations, statistiques
# =====================================================================

# --- Fichiers -------------------------------------------------------------
# Verifie la presence d'un fichier declare dans FICHIERS. Arrete le
# script avec un message clair pour un fichier obligatoire ; renvoie
# FALSE (avec avertissement) pour un fichier optionnel manquant.
verifier_fichier <- function(cle) {
  chemin <- FICHIERS[[cle]]
  if (!is.null(chemin) && file.exists(chemin)) return(TRUE)
  if (cle %in% FICHIERS_OBLIGATOIRES) {
    stop("\n\n!!! FICHIER OBLIGATOIRE INTROUVABLE (", cle, ") :\n    ", chemin,
         "\n    -> verifier le chemin dans R/00_parametres.R (liste FICHIERS)\n",
         "    -> dossier de travail actuel : ", getwd(), "\n", call. = FALSE)
  }
  warning("Fichier optionnel introuvable (", cle, ") : ", chemin,
          " - les graphiques utiliseront seulement les donnees disponibles.", call. = FALSE)
  FALSE
}

# Lecture standard d'une extraction ReefDB (csv ; separateur ;)
lire_extraction_reefdb <- function(cle) {
  verifier_fichier(cle)
  df <- read.csv2(FICHIERS[[cle]], header = TRUE, sep = ";", quote = "\"", dec = ",",
                  fill = TRUE, comment.char = "", fileEncoding = "UTF-8")
  if (nrow(df) == 0) stop("Le fichier ", FICHIERS[[cle]], " ne contient aucune ligne.", call. = FALSE)
  df
}

# --- Stations -------------------------------------------------------------
# Remplace toutes les variantes de saisie ("Baleine Pain de Sucre",
# "Coco", "Site Baleine"...) par le nom de reference (table STATIONS).
harmoniser_station <- function(x) {
  x <- as.character(x)
  resultat <- x
  for (i in seq_len(nrow(STATIONS))) {
    resultat[grepl(STATIONS$motif[i], x, ignore.case = TRUE)] <- STATIONS$nom[i]
  }
  resultat
}

nom_court_station <- function(station) {
  court <- STATIONS$court[match(station, STATIONS$nom)]
  ifelse(is.na(court), gsub("[^A-Za-z0-9]+", "_", station), court)
}

# --- Mise en forme des nombres (virgule decimale) ---------------------------
formater_nombre <- function(x, decimales = 1) {
  ifelse(is.na(x), "NA", formatC(x, format = "f", digits = decimales, decimal.mark = ","))
}

formater_p <- function(p) {
  ifelse(is.na(p), "NA", ifelse(p < 0.001, "< 0,001", paste("=", formater_nombre(p, 3))))
}

etoiles_p <- function(p) {
  dplyr::case_when(is.na(p) ~ "", p < 0.001 ~ "***", p < 0.01 ~ "**", p < 0.05 ~ "*", TRUE ~ "ns")
}

# --- Tendance temporelle ------------------------------------------------------
# Regression lineaire (pente/an, R2, p) + test de Mann-Kendall (= correlation
# de Kendall entre le temps et la valeur, plus adapte aux series ecologiques
# courtes et non normales ; base R, aucun paquet supplementaire).
calculer_tendance <- function(temps, valeur) {
  ok <- !is.na(temps) & !is.na(valeur)
  temps <- temps[ok]; valeur <- valeur[ok]
  vide <- tibble::tibble(Pente_an = NA_real_, R2 = NA_real_, p_lm = NA_real_,
                         Tau_MK = NA_real_, p_MK = NA_real_, n = length(valeur),
                         Annee_debut = NA_real_, Annee_fin = NA_real_)
  if (inherits(temps, "Date")) temps <- lubridate::decimal_date(temps)
  if (length(valeur) < N_MIN_TENDANCE || length(unique(temps)) < 3) return(vide)
  modele <- stats::lm(valeur ~ temps)
  resume <- summary(modele)
  mk <- tryCatch(suppressWarnings(stats::cor.test(temps, valeur, method = "kendall")),
                 error = function(e) NULL)
  tibble::tibble(
    Pente_an = unname(stats::coef(modele)[2]),
    R2       = resume$r.squared,
    p_lm     = stats::coef(resume)[2, 4],
    Tau_MK   = if (is.null(mk)) NA_real_ else unname(mk$estimate),
    p_MK     = if (is.null(mk)) NA_real_ else mk$p.value,
    n        = length(valeur),
    Annee_debut = floor(min(temps)),
    Annee_fin   = floor(max(temps))
  )
}

# Tendance pour chaque groupe (ex. Station x Indicateur) d'une table longue
tendances_par_groupe <- function(df, temps, valeur, ...) {
  df %>%
    dplyr::group_by(...) %>%
    dplyr::group_modify(~ calculer_tendance(.x[[temps]], .x[[valeur]])) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      Tendance = dplyr::case_when(
        is.na(p_MK) & is.na(p_lm) ~ "non calculable",
        dplyr::coalesce(p_MK, p_lm) < SEUIL_P & Pente_an > 0 ~ "hausse significative",
        dplyr::coalesce(p_MK, p_lm) < SEUIL_P & Pente_an < 0 ~ "baisse significative",
        TRUE ~ "pas de tendance significative"
      )
    )
}

texte_tendance <- function(t, unite = "", prefixe = "") {
  if (is.null(t) || nrow(t) == 0 || is.na(t$Pente_an[1])) return(NULL)
  paste0(prefixe, "pente = ", ifelse(t$Pente_an >= 0, "+", ""), formater_nombre(t$Pente_an, 2), " ", unite, "/an",
         " ; R² = ", formater_nombre(t$R2, 2), " ; p ", formater_p(t$p_lm),
         ifelse(is.na(t$Tau_MK), "",
                paste0(" (Mann-Kendall tau = ", formater_nombre(t$Tau_MK, 2), ", p ", formater_p(t$p_MK), ")")),
         " ; n = ", t$n)
}

# --- Comparaison entre annees (donnees par replicat/quadrat) ------------------
# Pour chaque station : chaque annee est comparee a l'annee de suivi
# precedente (test de Wilcoxon-Mann-Whitney, non parametrique, adapte aux
# comptages par quadrat/replicat souvent non normaux). Renvoie une ligne
# par comparaison avec p-value et etoiles (*, **, ***, ns).
comparer_annees <- function(df, valeur, groupe = "Station", annee = "Annee") {
  # Table vide mais avec toutes ses colonnes : renvoyee quand aucune
  # station n'a au moins 2 annees de suivi (sinon les filter(Station == ...)
  # plus loin plantent avec "objet 'Station' introuvable")
  vide <- tibble::tibble(!!groupe := character(0), Annee_ref = numeric(0), Annee = numeric(0),
                         Moyenne_ref = numeric(0), Moyenne = numeric(0),
                         n_ref = integer(0), n = integer(0),
                         p_wilcoxon = numeric(0), Signif = character(0))
  if (is.null(df) || nrow(df) == 0 || !valeur %in% names(df)) return(vide)
  df <- df %>% dplyr::filter(!is.na(.data[[valeur]]))
  res <- purrr::map_dfr(unique(df[[groupe]]), function(g) {
    d <- df[df[[groupe]] == g, ]
    annees <- sort(unique(as.numeric(as.character(d[[annee]]))))
    if (length(annees) < 2) return(NULL)
    purrr::map_dfr(2:length(annees), function(i) {
      x <- d[[valeur]][as.numeric(as.character(d[[annee]])) == annees[i - 1]]
      y <- d[[valeur]][as.numeric(as.character(d[[annee]])) == annees[i]]
      p <- if (length(x) >= 3 && length(y) >= 3) {
        tryCatch(suppressWarnings(stats::wilcox.test(x, y)$p.value), error = function(e) NA_real_)
      } else NA_real_
      tibble::tibble(!!groupe := g, Annee_ref = annees[i - 1], Annee = annees[i],
                     Moyenne_ref = mean(x), Moyenne = mean(y),
                     n_ref = length(x), n = length(y),
                     p_wilcoxon = p, Signif = etoiles_p(p))
    })
  })
  if (nrow(res) == 0) return(vide)
  res
}

# --- Doublons entre sources --------------------------------------------------
# Plusieurs sources reprennent les memes chiffres (ex. le fichier ATE
# integre les valeurs du rapport Bouchon 2020-2024 et la valeur ReefDB
# 2022). Pour une meme Station x Annee, une valeur IDENTIQUE (a la
# tolerance pres) deja fournie par une source plus prioritaire est retiree,
# pour ne pas afficher deux fois la meme mesure ni gonfler les tendances.
# Priorite : extraction ReefDB > historique ATE > rapport Bouchon.
PRIORITE_SOURCES <- c("Extraction_ReefDB_LIT", "Extraction_ReefDB_Quadrat", "Extraction_ReefDB_BELT",
                      "Historique_ATE", "Rapport_Bouchon_2024", "Recrutement_Bouchon_2024")

dedoublonner_sources <- function(df, valeur, groupes = c("Station", "Annee"), tolerance = 0.015, libelle = valeur) {
  if (is.null(df) || nrow(df) == 0) return(df)
  est_doublon <- function(v) vapply(seq_along(v), function(i) {
    i > 1 && !is.na(v[i]) && any(abs(v[seq_len(i - 1)] - v[i]) <= tolerance, na.rm = TRUE)
  }, logical(1))
  marque <- df %>%
    dplyr::mutate(.prio = match(Source, PRIORITE_SOURCES), .prio = ifelse(is.na(.prio), 99, .prio),
                  .ligne = dplyr::row_number(), .v = .data[[valeur]]) %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(groupes))) %>%
    dplyr::arrange(.prio, .ligne, .by_group = TRUE) %>%
    dplyr::mutate(.doublon = est_doublon(.v)) %>%
    dplyr::ungroup()
  retires <- marque %>% dplyr::filter(.doublon)
  if (nrow(retires) > 0) {
    cat("\nDoublons entre sources retires (", libelle, ") - valeur deja fournie par une source prioritaire :\n", sep = "")
    print(retires %>% dplyr::select(dplyr::all_of(groupes), Source, dplyr::all_of(valeur)), n = Inf)
  }
  marque %>% dplyr::filter(!.doublon) %>% dplyr::arrange(.ligne) %>%
    dplyr::select(-.prio, -.ligne, -.v, -.doublon)
}
