#' @title Agregar Cuenta de Twitter
#' @description Agrega una cuenta de Twitter con cookies y la activa automáticamente.
#' IMPORTANTE: Las cookies son obligatorias para activar la cuenta correctamente.
#' @param username Nombre de usuario
#' @param password Contraseña
#' @param email Email de la cuenta
#' @param email_password Contraseña del email
#' @param cookies Cookies de sesión (OBLIGATORIO - formato: "auth_token=...; ct0=...")
#' @param db_file Archivo de base de datos (default: "accounts.db")
#' @export
#' @examples
#' \dontrun{
#' add_account(
#'   username = "mi_usuario",
#'   password = "mi_password",
#'   email = "mi@email.com",
#'   email_password = "email_pass",
#'   cookies = "auth_token=...; ct0=..."
#' )
#' }
add_account <- function(username, password, email, email_password, cookies, db_file = "accounts.db") {
  ensure_configured()

  cli::cli_h2("Agregando Cuenta de Twitter")
  cli::cli_alert_info("Usuario: @{username}")

  # Preparar cookies
  cookies_str <- sprintf(", cookies='%s'", cookies)

  # Ejecutar Python - primero inicializar DB si es necesario
  result <- tryCatch({
    py_result <- reticulate::py_run_string(sprintf("
import asyncio
from twscrape import API
import sqlite3

async def add_account():
    # Inicializar la base de datos si no existe
    db_path = '%s'

    # Crear la conexión para asegurar que la DB existe
    conn = sqlite3.connect(db_path)
    conn.close()

    api = API(db_path)

    try:
        await api.pool.add_account(
            '%s',
            '%s',
            '%s',
            '%s'%s
        )
        return {'success': True, 'message': 'Cuenta agregada'}
    except Exception as e:
        return {'success': False, 'message': str(e)}

_add_account_result = asyncio.run(add_account())
    ", db_file, username, password, email, email_password, cookies_str))

    py_result$`_add_account_result`
  }, error = function(e) {
    list(success = FALSE, message = as.character(e))
  })

  if (result$success) {
    # Verificar el estado real de la cuenta
    accounts_check <- tryCatch({
      py_check <- reticulate::py_run_string(sprintf("
import asyncio
from twscrape import API

async def check_account():
    api = API('%s')
    accounts = await api.pool.get_all()
    target = [acc for acc in accounts if acc.username == '%s']
    if target:
        return {'active': target[0].active}
    return {'active': False}

_check_result = asyncio.run(check_account())
      ", db_file, username))
      py_check$`_check_result`
    }, error = function(e) {
      list(active = FALSE)
    })

    if (accounts_check$active) {
      cli::cli_alert_success("Cuenta @{username} agregada y activada correctamente")
      cli::cli_text("")
      cli::cli_alert_success("¡Listo! Ahora puedes usar:")
      cli::cli_ul(c(
        "search_tweets('query', n = 100)",
        "user_tweets('username', n = 50)",
        "search_hashtag('#rstats', n = 100)"
      ))
      return(invisible(TRUE))
    } else {
      cli::cli_alert_warning("Cuenta agregada pero no está activa")
      cli::cli_text("Esto puede deberse a:")
      cli::cli_ul(c(
        "Cookies inválidas o expiradas",
        "Credenciales incorrectas",
        "Cuenta suspendida o bloqueada por Twitter"
      ))
      cli::cli_text("")
      cli::cli_text("Solución: Verifica tus cookies en el navegador y vuelve a intentar")
      return(invisible(FALSE))
    }
  } else {
    if (grepl("already exists", result$message, ignore.case = TRUE)) {
      cli::cli_alert_warning("La cuenta @{username} ya existe")
      cli::cli_text("Usa list_accounts() para ver tus cuentas")
    } else {
      cli::cli_alert_danger("Error: {result$message}")
    }
    return(invisible(FALSE))
  }
}

#' @title Listar Cuentas
#' @description Lista todas las cuentas configuradas
#' @param db_file Archivo de base de datos (default: "accounts.db")
#' @export
#' @examples
#' \dontrun{
#' accounts <- list_accounts()
#' print(accounts)
#' }
list_accounts <- function(db_file = "accounts.db") {
  ensure_configured()

  result <- tryCatch({
    py_result <- reticulate::py_run_string(sprintf("
import asyncio
from twscrape import API

async def list_accounts():
    try:
        api = API('%s')
        accounts = await api.pool.get_all()
        return {
            'success': True,
            'accounts': [{
                'username': acc.username,
                'email': acc.email,
                'active': acc.active,
                'locks': acc.locks
            } for acc in accounts]
        }
    except Exception as e:
        return {'success': False, 'message': str(e), 'accounts': []}

_list_accounts_result = asyncio.run(list_accounts())
  ", db_file))

    py_result$`_list_accounts_result`
  }, error = function(e) {
    error_msg <- as.character(e)
    list(success = FALSE, message = error_msg, accounts = list())
  })

  # Manejar errores
  if (!result$success) {
    if (grepl("no such table", result$message, ignore.case = TRUE)) {
      cli::cli_alert_warning("No hay cuentas configuradas aún")
      cli::cli_text("")
      cli::cli_text("Para comenzar, agrega tu primera cuenta:")
      cli::cli_code("add_account(")
      cli::cli_code("  username = 'tu_usuario',")
      cli::cli_code("  password = 'tu_password',")
      cli::cli_code("  email = 'tu@email.com',")
      cli::cli_code("  email_password = 'email_pass',")
      cli::cli_code("  cookies = 'auth_token=...; ct0=...'")
      cli::cli_code(")")
    } else {
      cli::cli_alert_danger("Error al listar cuentas: {result$message}")
    }
    return(invisible(list()))
  }

  accounts <- result$accounts

  if (length(accounts) == 0) {
    cli::cli_alert_warning("No hay cuentas configuradas")
    cli::cli_text("Agrega una cuenta con: add_account(...)")
    return(invisible(list()))
  }

  cli::cli_alert_info("Cuentas configuradas: {length(accounts)}")

  # Convertir a dataframe para mejor visualización
  df <- data.frame(
    username = sapply(accounts, function(x) x$username),
    email = sapply(accounts, function(x) x$email),
    active = sapply(accounts, function(x) x$active),
    stringsAsFactors = FALSE
  )

  print(df)
  return(invisible(accounts))
}

#' @title Eliminar Cuenta
#' @description Elimina una cuenta de la base de datos
#' @param username Nombre de usuario a eliminar
#' @param db_file Archivo de base de datos (default: "accounts.db")
#' @export
#' @examples
#' \dontrun{
#' delete_account("mi_usuario")
#' }
delete_account <- function(username, db_file = "accounts.db") {
  ensure_configured()

  cli::cli_alert_info("Eliminando cuenta: @{username}")

  result <- reticulate::py_run_string(sprintf("
import asyncio
from twscrape import API

async def delete_account():
    api = API('%s')
    try:
        await api.pool.delete_accounts('%s')
        return {'success': True}
    except Exception as e:
        return {'success': False, 'message': str(e)}

_delete_result = asyncio.run(delete_account())
  ", db_file, username))

  res <- result$`_delete_result`

  if (res$success) {
    cli::cli_alert_success("Cuenta eliminada")
  } else {
    cli::cli_alert_danger("Error: {res$message}")
  }

  return(invisible(res$success))
}
