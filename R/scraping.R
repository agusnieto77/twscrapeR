#' @title Buscar Tweets
#' @description Busca tweets usando una consulta
#' @param query Consulta de búsqueda (ej: "rstats", "#datascience", "from:usuario")
#' @param n Número máximo de tweets a retornar (default: 100)
#' @param progress Mostrar barra de progreso (default: TRUE)
#' @return Lista de tweets
#' @export
#' @examples
#' \dontrun{
#' tweets <- search_tweets("rstats", n = 50)
#' df <- to_dataframe(tweets)
#' }
search_tweets <- function(query, n = 100, progress = TRUE) {
  ensure_configured()

  if (progress) {
    cli::cli_alert_info("Buscando tweets: '{query}'")
    cli::cli_progress_step("Obteniendo tweets...")
  }

  # Ejecutar búsqueda Python
  result <- reticulate::py_run_string(sprintf("
import asyncio
from twscrape import API

async def search():
    api = API()
    tweets = []
    async for tweet in api.search('%s', limit=%d):
        tweets.append({
            'id': str(tweet.id),
            'date': str(tweet.date),
            'text': tweet.rawContent,
            'username': tweet.user.username,
            'user_displayname': tweet.user.displayname,
            'user_id': str(tweet.user.id),
            'reply_count': tweet.replyCount or 0,
            'retweet_count': tweet.retweetCount or 0,
            'like_count': tweet.likeCount or 0,
            'quote_count': tweet.quoteCount or 0,
            'views_count': tweet.viewCount or 0,
            'lang': tweet.lang or 'und',
            'url': tweet.url,
            'user_followers': getattr(tweet.user, 'followersCount', 0) or 0,
            'user_verified': getattr(tweet.user, 'verified', False) or False
        })
    return tweets

_search_result = asyncio.run(search())
  ", query, n))

  tweets <- result$`_search_result`

  if (progress) {
    cli::cli_progress_done()
    cli::cli_alert_success("Encontrados {length(tweets)} tweets")
  }

  # Convertir a estructura R
  tweets_list <- lapply(tweets, function(tw) {
    list(
      id = tw$id,
      date = as.POSIXct(tw$date),
      text = tw$text,
      username = tw$username,
      user_displayname = tw$user_displayname,
      user_id = tw$user_id,
      reply_count = tw$reply_count,
      retweet_count = tw$retweet_count,
      like_count = tw$like_count,
      quote_count = tw$quote_count,
      views_count = tw$views_count,
      lang = tw$lang,
      url = tw$url,
      user_followers = tw$user_followers,
      user_verified = tw$user_verified
    )
  })

  class(tweets_list) <- c("twscraper_tweets", "list")
  return(tweets_list)
}

#' @title Obtener Tweets de un Usuario
#' @description Obtiene los tweets recientes de un usuario específico
#' @param username Nombre de usuario (sin @)
#' @param n Número máximo de tweets (default: 100)
#' @param progress Mostrar progreso (default: TRUE)
#' @return Lista de tweets
#' @export
#' @examples
#' \dontrun{
#' tweets <- user_tweets("hadleywickham", n = 50)
#' }
user_tweets <- function(username, n = 100, progress = TRUE) {
  ensure_configured()

  if (progress) {
    cli::cli_alert_info("Obteniendo tweets de @{username}")
  }

  result <- reticulate::py_run_string(sprintf("
import asyncio
from twscrape import API

async def get_user_tweets():
    api = API()

    # Primero obtener el user_id a partir del username
    user = await api.user_by_login('%s')
    user_id = user.id

    tweets = []
    async for tweet in api.user_tweets(user_id, limit=%d):
        tweets.append({
            'id': str(tweet.id),
            'date': str(tweet.date),
            'text': tweet.rawContent,
            'username': tweet.user.username,
            'user_displayname': tweet.user.displayname,
            'user_id': str(tweet.user.id),
            'reply_count': tweet.replyCount or 0,
            'retweet_count': tweet.retweetCount or 0,
            'like_count': tweet.likeCount or 0,
            'quote_count': tweet.quoteCount or 0,
            'views_count': tweet.viewCount or 0,
            'lang': tweet.lang or 'und',
            'url': tweet.url,
            'user_followers': getattr(tweet.user, 'followersCount', 0) or 0,
            'user_verified': getattr(tweet.user, 'verified', False) or False
        })
    return tweets

_user_tweets_result = asyncio.run(get_user_tweets())
  ", username, n))

  tweets <- result$`_user_tweets_result`

  if (progress) {
    cli::cli_alert_success("Encontrados {length(tweets)} tweets de @{username}")
  }

  tweets_list <- lapply(tweets, function(tw) {
    list(
      id = tw$id,
      date = as.POSIXct(tw$date),
      text = tw$text,
      username = tw$username,
      user_displayname = tw$user_displayname,
      user_id = tw$user_id,
      reply_count = tw$reply_count,
      retweet_count = tw$retweet_count,
      like_count = tw$like_count,
      quote_count = tw$quote_count,
      views_count = tw$views_count,
      lang = tw$lang,
      url = tw$url,
      user_followers = tw$user_followers,
      user_verified = tw$user_verified
    )
  })

  class(tweets_list) <- c("twscraper_tweets", "list")
  return(tweets_list)
}

#' @title Obtener Información de Usuario
#' @description Obtiene información detallada de un usuario
#' @param username Nombre de usuario (sin @)
#' @param progress Mostrar progreso (default: TRUE)
#' @return Lista con información del usuario
#' @export
#' @examples
#' \dontrun{
#' user <- get_user("hadleywickham")
#' }
get_user <- function(username, progress = TRUE) {
  ensure_configured()

  if (progress) {
    cli::cli_alert_info("Obteniendo información de @{username}")
  }

  result <- reticulate::py_run_string(sprintf("
import asyncio
from twscrape import API

async def get_user_info():
    api = API()
    user = await api.user_by_login('%s')
    return {
        'id': str(user.id),
        'username': getattr(user, 'username', ''),
        'displayname': getattr(user, 'displayname', ''),
        'description': getattr(user, 'rawDescription', '') or getattr(user, 'description', ''),
        'followers_count': getattr(user, 'followersCount', 0) or 0,
        'following_count': getattr(user, 'friendsCount', 0) or 0,
        'tweets_count': getattr(user, 'statusesCount', 0) or 0,
        'verified': getattr(user, 'verified', False) or False,
        'created': str(getattr(user, 'created', '')),
        'location': getattr(user, 'location', '') or '',
        'url': getattr(user, 'url', '') or '',
        'profile_image_url': getattr(user, 'profileImageUrl', '') or ''
    }

_user_info_result = asyncio.run(get_user_info())
  ", username))

  user_info <- result$`_user_info_result`

  if (progress) {
    cli::cli_alert_success("Información obtenida de @{username}")
  }

  user_data <- list(
    id = user_info$id,
    username = user_info$username,
    displayname = user_info$displayname,
    description = user_info$description,
    followers_count = user_info$followers_count,
    following_count = user_info$following_count,
    tweets_count = user_info$tweets_count,
    verified = user_info$verified,
    created = user_info$created,
    location = user_info$location,
    url = user_info$url,
    profile_image_url = user_info$profile_image_url
  )

  class(user_data) <- c("twscraper_user", "list")
  return(user_data)
}

#' @title Buscar por Hashtag
#' @description Busca tweets que contengan un hashtag específico
#' @param hashtag Hashtag (con o sin #)
#' @param n Número máximo de tweets (default: 100)
#' @param progress Mostrar progreso (default: TRUE)
#' @return Lista de tweets
#' @export
#' @examples
#' \dontrun{
#' tweets <- search_hashtag("rstats", n = 50)
#' tweets <- search_hashtag("#datascience", n = 100)
#' }
search_hashtag <- function(hashtag, n = 100, progress = TRUE) {
  # Limpiar hashtag
  hashtag <- gsub("^#", "", hashtag)
  query <- paste0("#", hashtag)

  return(search_tweets(query, n = n, progress = progress))
}

#' @title Buscar Menciones de un Usuario
#' @description Busca tweets que mencionen a un usuario específico
#' @param username Nombre de usuario (sin @)
#' @param n Número máximo de tweets (default: 100)
#' @param progress Mostrar progreso (default: TRUE)
#' @return Lista de tweets
#' @export
#' @examples
#' \dontrun{
#' mentions <- search_mentions("hadleywickham", n = 50)
#' }
search_mentions <- function(username, n = 100, progress = TRUE) {
  username <- gsub("^@", "", username)
  query <- paste0("@", username)

  return(search_tweets(query, n = n, progress = progress))
}
