#' @title Convertir Tweets o Usuarios a Data Frame
#' @description Convierte una lista de tweets o usuarios a data.frame usando purrr::map_dfr
#' @param x Lista de tweets o usuarios
#' @return data.frame o tibble
#' @export
#' @examples
#' \dontrun{
#' tweets <- search_tweets("rstats", n = 100)
#' df <- to_dataframe(tweets)
#'
#' users <- get_followers("rstudio", n = 100)
#' df <- to_dataframe(users)
#' }
to_dataframe <- function(x) {
  # Check if it's a single user object (has 12 elements with class twscraper_user)
  if (inherits(x, "twscraper_user")) {
    # Single user object with 12 fields - convert with as_tibble
    if (requireNamespace("tibble", quietly = TRUE)) {
      return(tibble::as_tibble(x))
    } else {
      return(as.data.frame(x, stringsAsFactors = FALSE))
    }
  }

  # Check if it's a single tweet object
  if (inherits(x, "twscraper_tweet")) {
    # Single tweet object - convert with as_tibble
    if (requireNamespace("tibble", quietly = TRUE)) {
      return(tibble::as_tibble(x))
    } else {
      return(as.data.frame(x, stringsAsFactors = FALSE))
    }
  }

  if (length(x) == 0) {
    cli::cli_alert_warning("No hay elementos para convertir")
    if (requireNamespace("tibble", quietly = TRUE)) {
      return(tibble::tibble())
    } else {
      return(data.frame())
    }
  }

  # Check if single element list - use as_tibble directly
  if (length(x) == 1) {
    if (requireNamespace("tibble", quietly = TRUE)) {
      return(tibble::as_tibble(x[[1]]))
    } else {
      return(as.data.frame(x[[1]], stringsAsFactors = FALSE))
    }
  }

  # Use purrr::map_dfr if available with as_tibble, otherwise fallback to base R
  if (requireNamespace("purrr", quietly = TRUE) && requireNamespace("tibble", quietly = TRUE)) {
    df <- purrr::map_dfr(x, ~tibble::as_tibble(.x))
  } else {
    # Fallback to base R - detect if users or tweets
    first_elem <- x[[1]]
    is_users <- !is.null(first_elem$displayname) && is.null(first_elem$text)

    if (is_users) {
      df <- data.frame(
        user_id = sapply(x, function(u) u$id %||% NA_character_),
        username = sapply(x, function(u) u$username %||% NA_character_),
        displayname = sapply(x, function(u) u$displayname %||% NA_character_),
        description = sapply(x, function(u) u$description %||% NA_character_),
        followers_count = sapply(x, function(u) as.numeric(u$followers_count %||% 0)),
        following_count = sapply(x, function(u) as.numeric(u$following_count %||% 0)),
        tweets_count = sapply(x, function(u) as.numeric(u$tweets_count %||% 0)),
        verified = sapply(x, function(u) isTRUE(u$verified)),
        created = sapply(x, function(u) u$created %||% NA_character_),
        location = sapply(x, function(u) u$location %||% NA_character_),
        url = sapply(x, function(u) u$url %||% NA_character_),
        profile_image_url = sapply(x, function(u) u$profile_image_url %||% NA_character_),
        stringsAsFactors = FALSE
      )
    } else {
      df <- data.frame(
        tweet_id = sapply(x, function(t) t$id %||% NA_character_),
        date = as.POSIXct(sapply(x, function(t) as.character(t$date %||% NA))),
        username = sapply(x, function(t) t$username %||% NA_character_),
        user_displayname = sapply(x, function(t) t$user_displayname %||% NA_character_),
        user_id = sapply(x, function(t) t$user_id %||% NA_character_),
        text = sapply(x, function(t) t$text %||% NA_character_),
        reply_count = as.numeric(sapply(x, function(t) t$reply_count %||% 0)),
        retweet_count = as.numeric(sapply(x, function(t) t$retweet_count %||% 0)),
        like_count = as.numeric(sapply(x, function(t) t$like_count %||% 0)),
        quote_count = as.numeric(sapply(x, function(t) t$quote_count %||% 0)),
        views_count = as.numeric(sapply(x, function(t) t$views_count %||% 0)),
        lang = sapply(x, function(t) t$lang %||% NA_character_),
        url = sapply(x, function(t) t$url %||% NA_character_),
        user_followers = as.numeric(sapply(x, function(t) t$user_followers %||% 0)),
        user_verified = as.logical(sapply(x, function(t) t$user_verified %||% FALSE)),
        stringsAsFactors = FALSE
      )
    }
  }

  return(df)
}

#' @title Guardar Tweets como CSV
#' @description Guarda tweets en formato CSV
#' @param tweets Lista de tweets
#' @param file Nombre del archivo
#' @export
#' @examples
#' \dontrun{
#' tweets <- search_tweets("rstats", n = 100)
#' save_csv(tweets, "tweets_rstats.csv")
#' }
save_csv <- function(tweets, file) {
  df <- to_dataframe(tweets)
  write.csv(df, file, row.names = FALSE, fileEncoding = "UTF-8")
  cli::cli_alert_success("Guardado en: {file}")
  cli::cli_text("  {nrow(df)} tweets")
  return(invisible(file))
}

#' @title Guardar Tweets como JSON
#' @description Guarda tweets en formato JSON
#' @param tweets Lista de tweets
#' @param file Nombre del archivo
#' @export
#' @examples
#' \dontrun{
#' tweets <- search_tweets("rstats", n = 100)
#' save_json(tweets, "tweets_rstats.json")
#' }
save_json <- function(tweets, file) {
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("El paquete 'jsonlite' es necesario. Instálelo con: install.packages('jsonlite')")
  }

  jsonlite::write_json(tweets, file, pretty = TRUE, auto_unbox = TRUE)
  cli::cli_alert_success("Guardado en: {file}")
  cli::cli_text("  {length(tweets)} tweets")
  return(invisible(file))
}

#' @title Método Print para Tweets
#' @description Imprime resumen de tweets
#' @param x Lista de tweets
#' @param ... Argumentos adicionales
#' @export
print.twscraper_tweets <- function(x, ...) {
  cli::cli_h2("Tweets de twscrapeR")
  cli::cli_text("")
  cli::cli_alert_info("Total: {length(x)} tweets")

  if (length(x) > 0) {
    cli::cli_text("")
    cli::cli_text("{.strong Primeros 3 tweets:}")
    cli::cli_text("")

    for (i in 1:min(3, length(x))) {
      tw <- x[[i]]
      cli::cli_text("{i}. @{tw$username} ({tw$user_displayname})")
      cli::cli_text("   {substr(tw$text, 1, 70)}...")
      cli::cli_text("   ❤ {tw$like_count} | 🔁 {tw$retweet_count} | 👁 {tw$views_count}")
      cli::cli_text("")
    }

    if (length(x) > 3) {
      cli::cli_text("   ... y {length(x) - 3} tweets más")
    }

    cli::cli_text("")
    cli::cli_text("{.emph Usa to_dataframe() para convertir a data.frame}")
  }

  invisible(x)
}

#' @title Método Print para Usuario
#' @description Imprime información de usuario
#' @param x Información de usuario
#' @param ... Argumentos adicionales
#' @export
print.twscraper_user <- function(x, ...) {
  cli::cli_h2("Usuario de Twitter")
  cli::cli_text("")

  cli::cli_dl(c(
    "Username" = paste0("@", x$username),
    "Nombre" = x$displayname,
    "ID" = x$id,
    "Descripción" = substr(x$description, 1, 100),
    "Seguidores" = format(x$followers_count, big.mark = ","),
    "Siguiendo" = format(x$following_count, big.mark = ","),
    "Tweets" = format(x$tweets_count, big.mark = ","),
    "Verificado" = if (x$verified) "Sí" else "No",
    "Ubicación" = x$location,
    "URL" = x$url
  ))

  invisible(x)
}

#' @title Método Print para Lista de Usuarios
#' @description Imprime resumen de usuarios
#' @param x Lista de usuarios
#' @param ... Argumentos adicionales
#' @export
print.twscraper_users <- function(x, ...) {
  cli::cli_h2("Usuarios de twscrapeR")
  cli::cli_text("")
  cli::cli_alert_info("Total: {length(x)} usuarios")

  if (length(x) > 0) {
    cli::cli_text("")
    cli::cli_text("{.strong Primeros 5 usuarios:}")
    cli::cli_text("")

    for (i in 1:min(5, length(x))) {
      user <- x[[i]]
      cli::cli_text("{i}. @{user$username} ({user$displayname})")

      # Descripción truncada
      desc <- user$description %||% ""
      if (nchar(desc) > 60) {
        desc <- paste0(substr(desc, 1, 60), "...")
      }
      if (nchar(desc) > 0) {
        cli::cli_text("   {desc}")
      }

      cli::cli_text("   👥 {format(user$followers_count, big.mark = ',')} seguidores | 📝 {format(user$tweets_count, big.mark = ',')} tweets")
      cli::cli_text("")
    }

    if (length(x) > 5) {
      cli::cli_text("   ... y {length(x) - 5} usuarios más")
    }

    cli::cli_text("")
    cli::cli_text("{.emph Usa to_dataframe() para convertir a data.frame}")
  }

  invisible(x)
}

#' @title Método Print para Tweet Individual
#' @description Imprime información de un tweet individual
#' @param x Información de un tweet
#' @param ... Argumentos adicionales
#' @export
print.twscraper_tweet <- function(x, ...) {
  cli::cli_h2("Tweet de Twitter")
  cli::cli_text("")

  cli::cli_text("{.strong Autor:} @{x$username} ({x$user_displayname})")
  cli::cli_text("{.strong ID:} {x$id}")
  cli::cli_text("{.strong Fecha:} {format(x$date, '%Y-%m-%d %H:%M:%S')}")
  cli::cli_text("")

  # Mostrar el texto completo
  cli::cli_text("{.strong Texto:}")
  cli::cli_text("  {x$text}")
  cli::cli_text("")

  # Estadísticas
  cli::cli_text("{.strong Estadísticas:}")
  cli::cli_text("  ❤  Likes: {format(x$like_count, big.mark = ',')}")
  cli::cli_text("  🔁 Retweets: {format(x$retweet_count, big.mark = ',')}")
  cli::cli_text("  💬 Respuestas: {format(x$reply_count, big.mark = ',')}")
  cli::cli_text("  🔖 Quotes: {format(x$quote_count, big.mark = ',')}")
  cli::cli_text("  👁  Vistas: {format(x$views_count, big.mark = ',')}")
  cli::cli_text("")

  cli::cli_text("{.strong Idioma:} {x$lang}")
  cli::cli_text("{.strong URL:} {x$url}")
  cli::cli_text("")
  cli::cli_text("{.emph Usa to_dataframe() para convertir a data.frame}")

  invisible(x)
}

#' @title Convertir Usuario a Data Frame
#' @description Convierte un usuario individual a data.frame de una fila
#' @param x Usuario de get_user()
#' @param ... Argumentos adicionales
#' @return data.frame
#' @export
as.data.frame.twscraper_user <- function(x, ...) {
  data.frame(
    user_id = x$id %||% NA_character_,
    username = x$username %||% NA_character_,
    displayname = x$displayname %||% NA_character_,
    description = x$description %||% NA_character_,
    followers_count = as.numeric(x$followers_count %||% 0),
    following_count = as.numeric(x$following_count %||% 0),
    tweets_count = as.numeric(x$tweets_count %||% 0),
    verified = isTRUE(x$verified),
    created = x$created %||% NA_character_,
    location = x$location %||% NA_character_,
    url = x$url %||% NA_character_,
    profile_image_url = x$profile_image_url %||% NA_character_,
    stringsAsFactors = FALSE
  )
}

#' @title Filtrar Tweets por Idioma
#' @description Filtra tweets por idioma
#' @param tweets Lista de tweets
#' @param lang Código de idioma (ej: "es", "en", "pt")
#' @return Lista filtrada de tweets
#' @export
#' @examples
#' \dontrun{
#' tweets <- search_tweets("Milei", n = 100)
#' tweets_es <- filter_by_lang(tweets, "es")
#' }
filter_by_lang <- function(tweets, lang) {
  filtered <- Filter(function(tw) tw$lang == lang, tweets)
  cli::cli_alert_info("Filtrados {length(filtered)} tweets en idioma '{lang}'")
  class(filtered) <- class(tweets)
  return(filtered)
}

#' @title Filtrar Tweets por Fecha
#' @description Filtra tweets por rango de fechas
#' @param tweets Lista de tweets
#' @param from Fecha inicial (POSIXct o character)
#' @param to Fecha final (POSIXct o character)
#' @return Lista filtrada de tweets
#' @export
#' @examples
#' \dontrun{
#' tweets <- search_tweets("Milei", n = 100)
#' tweets_recent <- filter_by_date(tweets, from = "2025-10-01")
#' }
filter_by_date <- function(tweets, from = NULL, to = NULL) {
  if (!is.null(from)) {
    from <- as.POSIXct(from)
    tweets <- Filter(function(tw) tw$date >= from, tweets)
  }

  if (!is.null(to)) {
    to <- as.POSIXct(to)
    tweets <- Filter(function(tw) tw$date <= to, tweets)
  }

  cli::cli_alert_info("Filtrados {length(tweets)} tweets por fecha")
  class(tweets) <- c("twscraper_tweets", "list")
  return(tweets)
}

#' @title Ordenar Tweets
#' @description Ordena tweets por algún criterio
#' @param tweets Lista de tweets
#' @param by Campo por el cual ordenar ("date", "like_count", "retweet_count", "views_count")
#' @param decreasing Orden descendente (default: TRUE)
#' @return Lista ordenada de tweets
#' @export
#' @examples
#' \dontrun{
#' tweets <- search_tweets("Milei", n = 100)
#' top_tweets <- sort_tweets(tweets, by = "like_count")
#' }
sort_tweets <- function(tweets, by = "date", decreasing = TRUE) {
  sorted <- tweets[order(sapply(tweets, function(x) x[[by]]), decreasing = decreasing)]
  class(sorted) <- class(tweets)
  return(sorted)
}
