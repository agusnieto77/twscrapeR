#' @title Setup twscrapeR - Instalación Guiada Completa
#' @description Configura Python y twscrape automáticamente con instalación guiada
#' @param python_path Ruta a Python (opcional, se detecta automáticamente)
#' @param install_python Si TRUE, ofrece instalar Python si no se encuentra
#' @param ask Si TRUE, pregunta antes de instalar (default: TRUE)
#' @export
setup_twscraper <- function(python_path = NULL, install_python = TRUE, ask = TRUE) {

  cli::cli_h1("Configuración de twscrapeR")
  cli::cli_text("")

  # ═══════════════════════════════════════════════════════════════════
  # PASO 1: Verificar/Instalar Python
  # ═══════════════════════════════════════════════════════════════════

  cli::cli_h2("Paso 1: Verificación de Python")

  # Intentar encontrar Python
  python_found <- FALSE

  if (!is.null(python_path)) {
    cli::cli_alert_info("Usando Python especificado: {python_path}")
    if (file.exists(python_path)) {
      reticulate::use_python(python_path, required = TRUE)
      python_found <- TRUE
    } else {
      cli::cli_alert_danger("Python no encontrado en: {python_path}")
    }
  }

  # Intentar detectar Python automáticamente
  if (!python_found) {
    cli::cli_alert_info("Buscando Python en el sistema...")

    tryCatch({
      reticulate::py_available(initialize = TRUE)
      python_found <- TRUE
      python_path <- reticulate::py_config()$python
      cli::cli_alert_success("Python encontrado: {python_path}")
    }, error = function(e) {
      cli::cli_alert_warning("Python no detectado automáticamente")
    })
  }

  # Verificar versión de Python si se encontró
  python_version_ok <- FALSE
  if (python_found) {
    tryCatch({
      py_version <- as.character(reticulate::py_config()$version)
      version_parts <- as.numeric(strsplit(py_version, "\\.")[[1]][1:2])
      python_version_ok <- (version_parts[1] > 3) || (version_parts[1] == 3 && version_parts[2] >= 10)

      if (!python_version_ok) {
        cli::cli_text("")
        cli::cli_alert_warning("Python {py_version} encontrado, pero twscrape requiere Python >= 3.10")
        python_found <- FALSE  # Marcar como no encontrado para ofrecer instalación
      }
    }, error = function(e) {
      cli::cli_alert_warning("No se pudo verificar la versión de Python, continuando...")
      python_version_ok <- TRUE  # Asumir que está bien si no se puede verificar
    })
  }

  # Si no se encuentra Python o versión incorrecta, ofrecer instalación
  if (!python_found && install_python) {
    cli::cli_text("")
    cli::cli_alert_warning("Se necesita Python 3.10 o superior")
    cli::cli_text("")
    cli::cli_text("twscrapeR requiere Python 3.10+ para funcionar correctamente.")
    cli::cli_text("")

    if (ask) {
      cli::cli_text("{.strong Opciones de instalación:}")
      cli::cli_ol(c(
        "Crear environment conda 'twscraper_env' con Python 3.11 (RECOMENDADO)",
        "Instalar Miniconda completo (si no lo tienes)",
        "Usar Python del sistema (si ya tienes Python 3.10+)",
        "Cancelar y instalar Python manualmente"
      ))
      cli::cli_text("")

      choice <- readline("Selecciona una opción (1/2/3/4): ")

      if (choice == "1") {
        cli::cli_text("")
        cli::cli_alert_info("Creando environment conda 'twscraper_env' con Python 3.11...")
        cli::cli_text("Esto puede tomar varios minutos...")

        tryCatch({
          # Verificar si conda existe
          conda_path <- tryCatch(reticulate::conda_binary(), error = function(e) NULL)

          if (is.null(conda_path)) {
            cli::cli_alert_warning("Conda no encontrado. Instalando Miniconda primero...")
            reticulate::install_miniconda()
            Sys.sleep(2)
          }

          # Crear environment con Python 3.11
          reticulate::conda_create("twscraper_env", python_version = "3.11")
          cli::cli_alert_success("Environment 'twscraper_env' creado correctamente")

          # Usar el nuevo environment
          reticulate::use_condaenv("twscraper_env", required = TRUE)
          python_path <- reticulate::py_config()$python
          python_found <- TRUE

        }, error = function(e) {
          cli::cli_alert_danger("Error creando environment: {e$message}")
          cli::cli_text("")
          cli::cli_text("Intenta la opción 2 para instalar Miniconda completo")
          return(invisible(FALSE))
        })

      } else if (choice == "2") {
        cli::cli_text("")
        cli::cli_alert_info("Instalando Miniconda...")
        cli::cli_text("Esto puede tomar varios minutos...")

        tryCatch({
          reticulate::install_miniconda()
          cli::cli_alert_success("Miniconda instalado correctamente")

          # Crear environment con Python 3.11
          cli::cli_alert_info("Creando environment 'twscraper_env'...")
          reticulate::conda_create("twscraper_env", python_version = "3.11")
          reticulate::use_condaenv("twscraper_env", required = TRUE)
          python_path <- reticulate::py_config()$python
          python_found <- TRUE

        }, error = function(e) {
          cli::cli_alert_danger("Error instalando Miniconda: {e$message}")
          cli::cli_text("")
          cli::cli_text("Por favor, instala Python manualmente desde:")
          cli::cli_text("  https://www.python.org/downloads/")
          return(invisible(FALSE))
        })

      } else if (choice == "3") {
        cli::cli_text("")
        cli::cli_alert_info("Por favor, especifica la ruta a Python 3.10+:")
        new_path <- readline("Ruta completa a python.exe: ")

        if (file.exists(new_path)) {
          python_path <- new_path
          reticulate::use_python(python_path, required = TRUE)
          python_found <- TRUE
          cli::cli_alert_success("Python configurado: {python_path}")
        } else {
          cli::cli_alert_danger("Archivo no encontrado: {new_path}")
          return(invisible(FALSE))
        }

      } else {
        cli::cli_alert_info("Instalación cancelada")
        cli::cli_text("")
        cli::cli_text("Para instalar Python manualmente:")
        cli::cli_text("  1. Descarga Python 3.10+ desde: https://www.python.org/downloads/")
        cli::cli_text("  2. Instala marcando 'Add Python to PATH'")
        cli::cli_text("  3. Reinicia R y ejecuta setup_twscraper() nuevamente")
        return(invisible(FALSE))
      }
    } else {
      # No preguntar, crear environment automáticamente
      cli::cli_alert_info("Creando environment conda automáticamente...")
      tryCatch({
        reticulate::conda_create("twscraper_env", python_version = "3.11")
        reticulate::use_condaenv("twscraper_env", required = TRUE)
        python_path <- reticulate::py_config()$python
        python_found <- TRUE
      }, error = function(e) {
        cli::cli_alert_danger("Error creando environment: {e$message}")
        return(invisible(FALSE))
      })
    }
  }

  if (!python_found) {
    cli::cli_alert_danger("No se pudo configurar Python")
    return(invisible(FALSE))
  }

  # ═══════════════════════════════════════════════════════════════════
  # PASO 2: Instalar twscrape
  # ═══════════════════════════════════════════════════════════════════

  cli::cli_text("")
  cli::cli_h2("Paso 2: Instalación de twscrape (Python)")

  # Verificar si twscrape está instalado
  has_twscrape <- reticulate::py_module_available("twscrape")

  if (!has_twscrape) {
    cli::cli_alert_info("Instalando twscrape...")

    if (ask) {
      install_confirm <- readline("¿Instalar twscrape de Python? (s/n): ")
      if (tolower(install_confirm) != "s") {
        cli::cli_alert_warning("Instalación cancelada")
        return(invisible(FALSE))
      }
    }

    tryCatch({
      reticulate::py_install("twscrape", pip = TRUE)
      cli::cli_alert_success("twscrape instalado correctamente")
    }, error = function(e) {
      cli::cli_alert_danger("Error instalando twscrape: {e$message}")
      return(invisible(FALSE))
    })
  } else {
    cli::cli_alert_success("twscrape ya está instalado")
  }

  # ═══════════════════════════════════════════════════════════════════
  # PASO 3: Configurar entorno global
  # ═══════════════════════════════════════════════════════════════════

  cli::cli_text("")
  cli::cli_h2("Paso 3: Configuración final")

  # Guardar configuración en entorno global
  .twscraper_env$python_path <- python_path
  .twscraper_env$twscrape <- reticulate::import("twscrape")
  .twscraper_env$configured <- TRUE

  cli::cli_alert_success("Configuración completada")
  cli::cli_text("")

  # ═══════════════════════════════════════════════════════════════════
  # Mostrar resumen
  # ═══════════════════════════════════════════════════════════════════

  cli::cli_rule("Resumen de Configuración")
  cli::cli_text("")
  cli::cli_dl(c(
    "Python" = python_path,
    "Versión Python" = as.character(reticulate::py_config()$version),
    "twscrape" = "Instalado y listo"
  ))
  cli::cli_text("")

  cli::cli_alert_success("¡twscrapeR está listo para usar!")
  cli::cli_text("")
  cli::cli_text("{.strong Próximos pasos:}")
  cli::cli_ol(c(
    "Agregar cuenta: add_account_from_env() o add_account('usuario', 'password', 'email', 'email_pass', cookies='...')",
    "Buscar tweets: search_tweets('query', n = 100)",
    "Ver ayuda: ?twscrapeR"
  ))
  cli::cli_text("")

  return(invisible(TRUE))
}

#' @title Verificar si twscrapeR está configurado
#' @description Verifica si Python y twscrape están configurados
#' @export
check_setup <- function() {
  if (!exists(".twscraper_env") || !.twscraper_env$configured) {
    cli::cli_alert_warning("twscrapeR no está configurado")
    cli::cli_text("Ejecuta: setup_twscraper()")
    return(FALSE)
  }

  cli::cli_alert_success("twscrapeR está configurado correctamente")
  cli::cli_dl(c(
    "Python" = .twscraper_env$python_path,
    "twscrape" = "Activo"
  ))
  return(TRUE)
}

#' Entorno global para almacenar configuración
#' @keywords internal
.twscraper_env <- new.env(parent = emptyenv())
.twscraper_env$configured <- FALSE
.twscraper_env$python_path <- NULL
.twscraper_env$twscrape <- NULL

#' @title Asegurar que twscrapeR está configurado
#' @description Uso interno - verifica configuración antes de operaciones
#' @keywords internal
ensure_configured <- function() {
  if (!.twscraper_env$configured) {
    cli::cli_alert_warning("twscrapeR no está configurado")
    cli::cli_text("Ejecutando configuración automática...")
    setup_twscraper(ask = FALSE)
  }

  if (!.twscraper_env$configured) {
    stop("No se pudo configurar twscrapeR. Ejecuta setup_twscraper() manualmente.")
  }
}
