# Funciones Avanzadas de twscrapeR
# Implementación de funciones adicionales de twscrape

#' @title Obtener Detalles de un Tweet
#' @description Obtiene información detallada de un tweet específico por su ID
#' @param tweet_id ID del tweet (número o string)
#' @param progress Mostrar progreso (default: TRUE)
#' @return Lista con información del tweet o NULL si no se encuentra
#' @export
#' @examples
#' \dontrun{
#' tweet <- tweet_details(1234567890)
#' }
tweet_details <- function(tweet_id, progress = TRUE) {
  ensure_configured()

  if (progress) {
    cli::cli_alert_info("Obteniendo detalles del tweet {tweet_id}")
  }

  result <- reticulate::py_run_string(sprintf("
import asyncio
from twscrape import API

async def get_tweet_details():
    api = API()
    tweet = await api.tweet_details(%s)
    if tweet is None:
        return None
    return {
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
    }

_tweet_details_result = asyncio.run(get_tweet_details())
  ", tweet_id))

  tweet_info <- result$`_tweet_details_result`

  if (is.null(tweet_info)) {
    if (progress) cli::cli_alert_warning("Tweet no encontrado")
    return(NULL)
  }

  if (progress) {
    cli::cli_alert_success("Tweet obtenido")
  }

  # Convertir fecha a POSIXct
  tweet_info$date <- as.POSIXct(tweet_info$date)

  class(tweet_info) <- c("twscraper_tweet", "list")
  return(tweet_info)
}

#' @title Obtener Respuestas a un Tweet
#' @description Obtiene las respuestas (replies) a un tweet específico
#' @param tweet_id ID del tweet
#' @param n Número máximo de respuestas (default: 100)
#' @param progress Mostrar progreso (default: TRUE)
#' @return Lista de tweets (respuestas)
#' @export
#' @examples
#' \dontrun{
#' replies <- tweet_replies(1234567890, n = 50)
#' }
tweet_replies <- function(tweet_id, n = 100, progress = TRUE) {
  ensure_configured()

  if (progress) {
    cli::cli_alert_info("Obteniendo respuestas al tweet {tweet_id}")
  }

  result <- reticulate::py_run_string(sprintf("
import asyncio
from twscrape import API

async def get_replies():
    api = API()
    replies = []
    async for tweet in api.tweet_replies(%s, limit=%d):
        replies.append({
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
    return replies

_replies_result = asyncio.run(get_replies())
  ", tweet_id, n))

  replies_list <- result$`_replies_result`

  if (progress) {
    cli::cli_alert_success("Encontradas {length(replies_list)} respuestas")
  }

  # Convertir a objetos Tweet
  tweets_list <- lapply(replies_list, function(tw) {
    structure(list(
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
    ), class = c("twscraper_tweet", "list"))
  })

  class(tweets_list) <- c("twscraper_tweets", "list")
  return(tweets_list)
}

#' @title Obtener Seguidores de un Usuario
#' @description Obtiene la lista de seguidores de un usuario
#' @param username Nombre de usuario (sin @)
#' @param n Número máximo de seguidores (default: 100)
#' @param progress Mostrar progreso (default: TRUE)
#' @return Lista de usuarios
#' @export
#' @examples
#' \dontrun{
#' followers <- get_followers("elonmusk", n = 100)
#' }
get_followers <- function(username, n = 100, progress = TRUE) {
  ensure_configured()

  if (progress) {
    cli::cli_alert_info("Obteniendo seguidores de @{username}")
  }

  result <- reticulate::py_run_string(sprintf("
import asyncio
from twscrape import API

async def get_user_followers():
    api = API()

    # Primero obtener el user_id
    user = await api.user_by_login('%s')
    user_id = user.id

    followers = []
    async for user in api.followers(user_id, limit=%d):
        followers.append({
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
        })
    return followers

_followers_result = asyncio.run(get_user_followers())
  ", username, n))

  followers_list <- result$`_followers_result`

  if (progress) {
    cli::cli_alert_success("Encontrados {length(followers_list)} seguidores")
  }

  class(followers_list) <- c("twscraper_users", "list")
  return(followers_list)
}

#' @title Obtener Usuarios Seguidos
#' @description Obtiene la lista de usuarios que sigue un usuario
#' @param username Nombre de usuario (sin @)
#' @param n Número máximo de usuarios (default: 100)
#' @param progress Mostrar progreso (default: TRUE)
#' @return Lista de usuarios
#' @export
#' @examples
#' \dontrun{
#' following <- get_following("elonmusk", n = 100)
#' }
get_following <- function(username, n = 100, progress = TRUE) {
  ensure_configured()

  if (progress) {
    cli::cli_alert_info("Obteniendo usuarios seguidos por @{username}")
  }

  result <- reticulate::py_run_string(sprintf("
import asyncio
from twscrape import API

async def get_user_following():
    api = API()

    # Primero obtener el user_id
    user = await api.user_by_login('%s')
    user_id = user.id

    following = []
    async for user in api.following(user_id, limit=%d):
        following.append({
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
        })
    return following

_following_result = asyncio.run(get_user_following())
  ", username, n))

  following_list <- result$`_following_result`

  if (progress) {
    cli::cli_alert_success("Encontrados {length(following_list)} usuarios")
  }

  class(following_list) <- c("twscraper_users", "list")
  return(following_list)
}

#' @title Obtener Usuarios que Retuitearon
#' @description Obtiene la lista de usuarios que retuitearon un tweet específico
#' @param tweet_id ID del tweet
#' @param n Número máximo de usuarios (default: 100)
#' @param progress Mostrar progreso (default: TRUE)
#' @return Lista de usuarios
#' @export
#' @examples
#' \dontrun{
#' retweeters <- get_retweeters(1234567890, n = 100)
#' }
get_retweeters <- function(tweet_id, n = 100, progress = TRUE) {
  ensure_configured()

  if (progress) {
    cli::cli_alert_info("Obteniendo usuarios que retuitearon {tweet_id}")
  }

  result <- reticulate::py_run_string(sprintf("
import asyncio
from twscrape import API

async def get_tweet_retweeters():
    api = API()

    retweeters = []
    async for user in api.retweeters(%s, limit=%d):
        retweeters.append({
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
        })
    return retweeters

_retweeters_result = asyncio.run(get_tweet_retweeters())
  ", tweet_id, n))

  retweeters_list <- result$`_retweeters_result`

  if (progress) {
    cli::cli_alert_success("Encontrados {length(retweeters_list)} retweeters")
  }

  class(retweeters_list) <- c("twscraper_users", "list")
  return(retweeters_list)
}

#' @title Obtener Tweets y Respuestas de un Usuario
#' @description Obtiene tweets y respuestas de un usuario (timeline completo)
#' @param username Nombre de usuario (sin @)
#' @param n Número máximo de tweets (default: 100)
#' @param progress Mostrar progreso (default: TRUE)
#' @return Lista de tweets
#' @export
#' @examples
#' \dontrun{
#' all_tweets <- user_tweets_and_replies("elonmusk", n = 100)
#' }
user_tweets_and_replies <- function(username, n = 100, progress = TRUE) {
  ensure_configured()

  if (progress) {
    cli::cli_alert_info("Obteniendo tweets y respuestas de @{username}")
  }

  result <- reticulate::py_run_string(sprintf("
import asyncio
from twscrape import API

async def get_tweets_and_replies():
    api = API()

    # Primero obtener el user_id
    user = await api.user_by_login('%s')
    user_id = user.id

    tweets = []
    async for tweet in api.user_tweets_and_replies(user_id, limit=%d):
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

_tweets_and_replies_result = asyncio.run(get_tweets_and_replies())
  ", username, n))

  tweets_list <- result$`_tweets_and_replies_result`

  if (progress) {
    cli::cli_alert_success("Encontrados {length(tweets_list)} tweets")
  }

  # Convertir a objetos Tweet
  tweets_list <- lapply(tweets_list, function(tw) {
    structure(list(
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
    ), class = c("twscraper_tweet", "list"))
  })

  class(tweets_list) <- c("twscraper_tweets", "list")
  return(tweets_list)
}

#' @title Obtener Tweets con Media de un Usuario
#' @description Obtiene solo los tweets que contienen imágenes o videos
#' @param username Nombre de usuario (sin @)
#' @param n Número máximo de tweets (default: 100)
#' @param progress Mostrar progreso (default: TRUE)
#' @return Lista de tweets
#' @export
#' @examples
#' \dontrun{
#' media_tweets <- user_media("elonmusk", n = 100)
#' }
user_media <- function(username, n = 100, progress = TRUE) {
  ensure_configured()

  if (progress) {
    cli::cli_alert_info("Obteniendo tweets con media de @{username}")
  }

  result <- reticulate::py_run_string(sprintf("
import asyncio
from twscrape import API

async def get_user_media_tweets():
    api = API()

    # Primero obtener el user_id
    user = await api.user_by_login('%s')
    user_id = user.id

    tweets = []
    async for tweet in api.user_media(user_id, limit=%d):
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

_media_tweets_result = asyncio.run(get_user_media_tweets())
  ", username, n))

  tweets_list <- result$`_media_tweets_result`

  if (progress) {
    cli::cli_alert_success("Encontrados {length(tweets_list)} tweets con media")
  }

  # Convertir a objetos Tweet
  tweets_list <- lapply(tweets_list, function(tw) {
    structure(list(
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
    ), class = c("twscraper_tweet", "list"))
  })

  class(tweets_list) <- c("twscraper_tweets", "list")
  return(tweets_list)
}

#' @title Obtener Seguidores Verificados
#' @description Obtiene solo los seguidores que tienen cuenta verificada
#' @param username Nombre de usuario (sin @)
#' @param n Número máximo de seguidores (default: 100)
#' @param progress Mostrar progreso (default: TRUE)
#' @return Lista de usuarios verificados
#' @export
#' @examples
#' \dontrun{
#' verified <- verified_followers("elonmusk", n = 100)
#' }
verified_followers <- function(username, n = 100, progress = TRUE) {
  ensure_configured()

  if (progress) {
    cli::cli_alert_info("Obteniendo seguidores verificados de @{username}")
  }

  result <- reticulate::py_run_string(sprintf("
import asyncio
from twscrape import API

async def get_verified_followers():
    api = API()

    # Primero obtener el user_id
    user = await api.user_by_login('%s')
    user_id = user.id

    followers = []
    async for user in api.verified_followers(user_id, limit=%d):
        followers.append({
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
        })
    return followers

_verified_followers_result = asyncio.run(get_verified_followers())
  ", username, n))

  followers_list <- result$`_verified_followers_result`

  if (progress) {
    cli::cli_alert_success("Encontrados {length(followers_list)} seguidores verificados")
  }

  class(followers_list) <- c("twscraper_users", "list")
  return(followers_list)
}


#' @title Convertir Usuarios a Dataframe (alias de to_dataframe)
#' @description Alias interno de to_dataframe() - usar to_dataframe() directamente
#' @param users Lista de usuarios
#' @return data.frame con información de usuarios
#' @keywords internal
users_to_dataframe <- function(users) {
  to_dataframe(users)
}

# Operador helper para valores NULL
`%||%` <- function(x, y) if (is.null(x)) y else x
