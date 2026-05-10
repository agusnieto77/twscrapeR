# twscrapeR

> **Twitter/X Scraping for R via Python's twscrape**

[![R](https://img.shields.io/badge/R-%3E%3D3.6.0-blue.svg)](https://www.r-project.org/)
[![Python](https://img.shields.io/badge/Python-%3E%3D3.8-green.svg)](https://www.python.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 📖 Tabla de Contenidos

- [Características](#-características)
- [Instalación](#-instalación)
- [Inicio Rápido](#-inicio-rápido-3-pasos)
- [Funciones Principales](#-funciones-principales)
- [Referencia Completa de Funciones](#-referencia-completa-de-funciones) ⭐ 26 funciones
- [Análisis de Datos](#-análisis-de-datos)
- [Solución de Problemas](#-solución-de-problemas)
- [Estructura de Datos](#-estructura-de-datos)
- [Agradecimientos](#-agradecimientos)
- [Licencia](#-licencia)

## 🌟 Características

- ✅ **Instalación Guiada**: Instala Python automáticamente si no lo tienes
- ✅ **100% Funcional**: Usa la librería Python `twscrape` que funciona perfectamente
- ✅ **Interfaz R Nativa**: Parece R puro, no necesitas saber Python
- ✅ **Multi-cuenta**: Soporta múltiples cuentas con rate limiting automático
- ✅ **26 Funciones**: Funcionalidad completa y simplificada para scraping de Twitter/X
- ✅ **Análisis de Redes**: Followers, following, retweeters, verified followers
- ✅ **Análisis de Conversaciones**: Tweet details, replies, menciones
- ✅ **Conversión Fácil**: to_dataframe() convierte tweets y usuarios a dataframes para análisis en R
- ✅ **Sin Problemas HTTP**: No depende de implementar HTTP en R

## 📦 Instalación

```r
# Instalar desde GitHub
library(devtools)
install_github("agusnieto77/twscrapeR")
```

## 🚀 Inicio Rápido (3 Pasos)

### Paso 1: Configuración Inicial

```r
library(twscrapeR)

# Configuración guiada (solo una vez)
setup_twscraper()
```

La función `setup_twscraper()` te guiará a través de:
1. Detección/instalación de Python
2. Instalación de la librería `twscrape`
3. Configuración del entorno

**Si no tienes Python instalado**, el paquete te preguntará si deseas instalarlo automáticamente.

### Paso 2: Agregar Cuenta

Opción recomendada: guardá tus credenciales en `.Renviron` y agregá la cuenta sin escribir secretos en el script.

```r
# En .Renviron
TWS_USERNAME='tu_usuario'
TWS_PASSWORD='tu_password'
TWS_EMAIL='tu@email.com'
TWS_EMAIL_PASSWORD='email_pass'
TWS_AUTH_TOKEN='valor_auth_token'
TWS_CT0='valor_ct0'

# En R
add_account_from_env()
```

Para varias cuentas podés repetir el esquema con otro prefijo y pasarlo a la función, por ejemplo `TWS2_USERNAME`, `TWS2_PASSWORD`, etc. y luego `add_account_from_env(prefix = "TWS2_")`.

También podés pasar todo explícitamente:

```r
add_account(
  username = "tu_usuario",
  password = "tu_password",
  email = "tu@email.com",
  email_password = "email_pass",
  cookies = "auth_token=...; ct0=..."
)
```

**Nota IMPORTANTE**: Las cookies son **OBLIGATORIAS** para que la cuenta se active correctamente. Sin cookies, Twitter/X bloqueará el acceso con Cloudflare.

#### ¿Cómo obtener cookies?

1. Abre https://x.com en tu navegador (con sesión iniciada)
2. Presiona F12 → "Application" → "Cookies" → "https://x.com"
3. Copia los valores de `auth_token` y `ct0`
4. Formato: `"auth_token=valor1; ct0=valor2"`

### Paso 3: ¡Usar!

```r
# Buscar tweets
tweets <- search_tweets("rstats", n = 100)

# Convertir a dataframe
df <- to_dataframe(tweets)
View(df)

# Guardar
save_csv(tweets, "tweets_rstats.csv")
```

## 📖 Funciones Principales

### Búsqueda de Tweets

```r
# Búsqueda general
tweets <- search_tweets("machine learning", n = 100)

# Por hashtag
tweets <- search_hashtag("rstats", n = 50)
tweets <- search_hashtag("#datascience", n = 100)  # Con o sin #

# Menciones de un usuario
mentions <- search_mentions("hadleywickham", n = 50)

# Búsquedas avanzadas
tweets <- search_tweets("rstats lang:en", n = 100)  # Solo inglés
tweets <- search_tweets("from:hadleywickham", n = 50)    # De un usuario específico
```

### Tweets de Usuario

```r
# Obtener tweets de un usuario
tweets <- user_tweets("hadleywickham", n = 100)

# Ver información del usuario
user <- get_user("hadleywickham")
print(user)
```

### Gestión de Cuentas

```r
# Listar cuentas configuradas
list_accounts()

# Eliminar una cuenta
delete_account("usuario")
```

### Conversión y Exportación

```r
# Convertir a dataframe
df <- to_dataframe(tweets)

# Guardar como CSV
save_csv(tweets, "tweets.csv")

# Guardar como JSON
save_json(tweets, "tweets.json")
```

### Filtrado y Ordenamiento

```r
# Filtrar por idioma
tweets_es <- filter_by_lang(tweets, "es")
tweets_en <- filter_by_lang(tweets, "en")

# Filtrar por fecha
tweets_recent <- filter_by_date(tweets, from = "2025-10-01")
tweets_range <- filter_by_date(tweets, from = "2025-10-01", to = "2025-10-26")

# Ordenar por likes
top_tweets <- sort_tweets(tweets, by = "like_count")

# Ordenar por fecha (más recientes primero)
recent_first <- sort_tweets(tweets, by = "date", decreasing = TRUE)
```

## 📚 Referencia Completa de Funciones

### 1. Configuración y Cuentas (5 funciones)

```r
# Configuración inicial del sistema
setup_twscraper()

# Agregar cuenta - se activa automáticamente con cookies
add_account_from_env()

# O pasar los datos explícitamente
add_account(
  username = "usuario",
  password = "pass",
  email = "email@example.com",
  email_password = "email_pass",
  cookies = "auth_token=...; ct0=..."  # OBLIGATORIO
)

# Listar todas las cuentas configuradas (muestra estado activo/inactivo)
accounts <- list_accounts()

# Eliminar una cuenta
delete_account("usuario")

# Verificar configuración del sistema
check_setup()
```

### 2. Búsqueda de Tweets (3 funciones)

```r
# Búsqueda general de tweets
tweets <- search_tweets("machine learning", n = 100)

# Buscar por hashtag
tweets <- search_hashtag("rstats", n = 50)
tweets <- search_hashtag("#datascience", n = 100)  # Con o sin #

# Buscar menciones a un usuario
mentions <- search_mentions("hadleywickham", n = 50)
```

### 3. Tweets de Usuario (3 funciones)

```r
# Obtener tweets de un usuario
tweets <- user_tweets("rstudio", n = 100)

# Obtener tweets Y respuestas de un usuario
tweets_replies <- user_tweets_and_replies("hadleywickham", n = 100)

# Obtener solo tweets con media (imágenes/videos)
media_tweets <- user_media("NASA", n = 50)
```

### 4. Información de Usuarios (1 función)

```r
# Obtener información detallada de un usuario
user <- get_user("hadleywickham")
print(user$followers_count)
print(user$following_count)
print(user$description)
```

### 5. Análisis de Tweets Específicos (4 funciones)

```r
# Obtener detalles completos de un tweet
tweet_id <- "1234567890123456789"
details <- tweet_details(tweet_id)

# Obtener respuestas a un tweet
replies <- tweet_replies(tweet_id, n = 50)

# Obtener quién retuiteó un tweet
retweeters <- get_retweeters(tweet_id, n = 100)

# Obtener retweeters para varios tweets
tweets <- search_tweets("rstats", n = 10)
retweeters <- get_retweeters_batch(tweets, n = 50)
retweeters_df <- to_dataframe(retweeters)  # incluye source_tweet_id

# Si querés mantenerlos agrupados por tweet
retweeters_by_tweet <- get_retweeters_batch(tweets, n = 50, flatten = FALSE)
```

### 6. Análisis de Redes (3 funciones)

```r
# Obtener seguidores de un usuario
followers <- get_followers("rstudio", n = 100)

# Obtener a quién sigue un usuario
following <- get_following("hadleywickham", n = 100)

# Obtener solo seguidores verificados
verified <- verified_followers("elonmusk", n = 50)
```

### 7. Conversión de Datos (1 función)

```r
# Convertir tweets a dataframe
tweets <- search_tweets("rstats", n = 100)
df_tweets <- to_dataframe(tweets)

# También funciona con usuarios
followers <- get_followers("rstudio", n = 50)
df_users <- to_dataframe(followers)
```

### 8. Filtrado y Ordenamiento (3 funciones)

```r
# Filtrar tweets por idioma
tweets_es <- filter_by_lang(tweets, "es")
tweets_en <- filter_by_lang(tweets, "en")

# Filtrar por fecha
tweets_recent <- filter_by_date(tweets, from = "2025-10-01")
tweets_range <- filter_by_date(
  tweets,
  from = "2025-10-01",
  to = "2025-10-26"
)

# Ordenar tweets
top_tweets <- sort_tweets(tweets, by = "like_count")
recent_tweets <- sort_tweets(tweets, by = "date", decreasing = TRUE)
```

### 9. Exportación (2 funciones)

```r
# Guardar como CSV
save_csv(tweets, "tweets.csv")

# Guardar como JSON
save_json(tweets, "tweets.json")
```


## 📊 Análisis de Datos

### Ejemplo Completo

```r
library(twscrapeR)
library(dplyr)
library(ggplot2)

# 1. Configurar
setup_twscraper()
add_account(...)

# 2. Buscar tweets
tweets <- search_tweets("#rstats", n = 1000)

# 3. Convertir a dataframe
df <- to_dataframe(tweets)

# 4. Análisis con dplyr
df %>%
  filter(lang == "en") %>%
  arrange(desc(like_count)) %>%
  select(username, text, like_count, retweet_count) %>%
  head(10)

# 5. Visualización
df %>%
  count(date = as.Date(date)) %>%
  ggplot(aes(date, n)) +
  geom_line() +
  labs(title = "Tweets sobre #rstats por día",
       x = "Fecha", y = "Número de tweets")

# 6. Top usuarios
df %>%
  count(username, sort = TRUE) %>%
  head(10) %>%
  ggplot(aes(reorder(username, n), n)) +
  geom_col() +
  coord_flip() +
  labs(title = "Top 10 usuarios", x = "", y = "Tweets")
```

## 🔧 Solución de Problemas

### Python no encontrado

Si `setup_twscraper()` no encuentra Python:

```r
# Opción 1: Instalar Miniconda automáticamente
setup_twscraper(install_python = TRUE, ask = FALSE)

# Opción 2: Especificar ruta a Python
setup_twscraper(python_path = "C:/Python/python.exe")

# Opción 3: Instalar Python manualmente
# Descarga desde: https://www.python.org/downloads/
# Luego ejecuta setup_twscraper() nuevamente
```

### Verificar configuración

```r
# Verificar si todo está correcto
check_setup()

# Ver configuración de Python
reticulate::py_config()
```

### Cuenta no activa

Si una cuenta aparece como `active = FALSE`:

```r
# 1. Listar cuentas para ver el estado
list_accounts()

# 2. Eliminar la cuenta inactiva
delete_account("usuario")

# 3. Volver a agregarla CON cookies válidas y actuales
add_account(
  username = "usuario",
  password = "pass",
  email = "email@example.com",
  email_password = "email_pass",
  cookies = "auth_token=...; ct0=..."  # OBLIGATORIO
)
```

**Importante**:
- Las cookies son OBLIGATORIAS para activar cuentas
- Si una cuenta no se activa, las cookies están expiradas o son inválidas
- Obtén nuevas cookies desde tu navegador (ver sección "¿Cómo obtener cookies?")

### Rate Limiting

Twitter/X aplica límites por tipo de consulta y `twscrape` los administra por cola. Si ves un mensaje como este:

```text
No account available for queue "Followers". Next available at 20:25:08
```

significa que todas las cuentas disponibles para esa cola llegaron temporalmente a su límite. No es un error de R: hay que esperar o distribuir mejor la carga.

Qué hacer:

1. **Bajá `n`**: empezá con valores chicos (`n = 50` o `n = 100`) y subí de a poco.
2. **Agregá más cuentas válidas**: `twscrape` rota automáticamente entre cuentas activas.
3. **Verificá tus cuentas**: usá `list_accounts()` y confirmá que aparezcan como `active = TRUE`.
4. **Esperá el reset**: el propio mensaje indica cuándo vuelve a estar disponible la cola.

Ejemplo con varias cuentas:

```r
add_account("usuario1", "pass1", "email1@example.com", "email_pass1", "auth_token=...; ct0=...")
add_account("usuario2", "pass2", "email2@example.com", "email_pass2", "auth_token=...; ct0=...")

list_accounts()
```

No hay un número universal que evite siempre el bloqueo: depende de la cola (`Search`, `Followers`, `UserTweets`, etc.), de la edad/estado de las cuentas y de la carga reciente. La regla práctica es pedir lotes más chicos y dejar que la rotación haga su trabajo.

## 📚 Estructura de Datos

### Tweet Object

```r
tweet <- tweets[[1]]
str(tweet)
```

Campos disponibles:
- `id`: ID del tweet
- `date`: Fecha y hora (POSIXct)
- `text`: Texto completo del tweet
- `username`: Usuario que publicó
- `user_displayname`: Nombre mostrado del usuario
- `user_id`: ID del usuario
- `reply_count`: Número de respuestas
- `retweet_count`: Número de retweets
- `like_count`: Número de likes
- `quote_count`: Número de quote tweets
- `views_count`: Número de vistas
- `lang`: Idioma del tweet
- `url`: URL del tweet
- `user_followers`: Seguidores del usuario
- `user_verified`: Usuario verificado (TRUE/FALSE)

### User Object

```r
user <- get_user("username")
str(user)
```

Campos:
- `id`: ID del usuario
- `username`: @usuario
- `displayname`: Nombre mostrado
- `description`: Biografía
- `followers_count`: Seguidores
- `following_count`: Siguiendo
- `tweets_count`: Total de tweets
- `verified`: Cuenta verificada
- `created`: Fecha de creación
- `location`: Ubicación
- `url`: URL del perfil
- `profile_image_url`: URL de la foto de perfil

## 🤝 Contribuciones

Las contribuciones son bienvenidas! Por favor:

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

MIT License - ver archivo [LICENSE](LICENSE)

## 🙏 Agradecimientos

**twscrapeR** es posible gracias a dos proyectos excepcionales de Python:

* **[snscrape](https://github.com/JustAnotherArchivist/snscrape)** por [JustAnotherArchivist](https://github.com/JustAnotherArchivist): Arquitectura base de scraping, parsers y modelos de datos.

* **[twscrape](https://github.com/vladkens/twscrape)** por [vladkens](https://github.com/vladkens): Sistema multi-cuenta, rate limiting y generación de X-Client-Transaction-ID.

Y al ecosistema de R:

* **[reticulate](https://rstudio.github.io/reticulate/)**: Integración perfecta entre R y Python

## 📧 Soporte

- **Issues**: https://github.com/usuario/twscrapeR/issues
- **Email**: agustin.nieto77@gmail.com

## ⚠️ Disclaimer

Este paquete es para propósitos educativos y de investigación. Asegúrate de cumplir con los términos de servicio de Twitter/X al usarlo.

---
