#' @keywords internal
.onLoad <- function(libname, pkgname) {
  # Suprimir avisos de cli sobre tema desconocido de RStudio
  options(cli.ignore_unknown_rstudio_theme = TRUE)

  # Mensaje de bienvenida
  packageStartupMessage("twscrapeR v", utils::packageVersion(pkgname), " - Twitter/X Scraping via Python")
  packageStartupMessage("Use setup_twscraper() para comenzar")
}

#' @keywords internal
.onAttach <- function(libname, pkgname) {
  # Verificar si ya está configurado
  if (.twscraper_env$configured) {
    packageStartupMessage("\u2713 twscrapeR configurado y listo")
  }
}
