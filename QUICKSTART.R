# ═══════════════════════════════════════════════════════════════════════════
# QUICKSTART - twscrapeR
# Guía rápida para comenzar a usar el paquete
# ═══════════════════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────────────────────────
# PASO 1: Instalar el paquete
# ─────────────────────────────────────────────────────────────────────────────

# Si aún no está instalado:
# devtools::install_github("agusnieto77/twscrapeR")

library(twscrapeR)

# ─────────────────────────────────────────────────────────────────────────────
# PASO 2: Configuración inicial 
# ─────────────────────────────────────────────────────────────────────────────

# Esto instalará Python automáticamente si no lo tienes (SOLO UNA VEZ)
setup_twscraper()

# ─────────────────────────────────────────────────────────────────────────────
# PASO 3: Agregar cuenta de Twitter (SOLO UNA VEZ)
# ─────────────────────────────────────────────────────────────────────────────

# IMPORTANTE: Obtén tus cookies de x.com:
# 1. Abre https://x.com (con sesión iniciada)
# 2. Presiona F12 → "Application" → "Cookies" → "https://x.com"
# 3. Copia auth_token y ct0

add_account(
  username = "tu_usuario",
  password = "tu_password",
  email = "tu@email.com",
  email_password = "email_password",
  cookies = "auth_token=VALOR1; ct0=VALOR2"  # ← OBLIGATORIO
)

# ─────────────────────────────────────────────────────────────────────────────
# PASO 4: ¡Usar!
# ─────────────────────────────────────────────────────────────────────────────

# Buscar tweets
tweets <- search_tweets("rstats", n = 100)

# Ver tweets
print(tweets)

# Convertir a dataframe
df <- to_dataframe(tweets)
View(df)

# ═══════════════════════════════════════════════════════════════════════════
# EJEMPLOS ADICIONALES
# ═══════════════════════════════════════════════════════════════════════════

# ─── Búsquedas ───
tweets_ml <- search_tweets("machine learning", n = 50)
tweets_tag <- search_hashtag("datascience", n = 100)
mentions <- search_mentions("hadleywickham", n = 50)

# ─── Tweets de usuario ───
hadley_tweets <- user_tweets("hadleywickham", n = 100)
user_info <- get_user("hadleywickham")
print(user_info)

# ─── Análisis con dplyr ───
library(dplyr)

df %>%
  filter(lang == "en") %>%
  arrange(desc(like_count)) %>%
  select(username, text, like_count, retweet_count) %>%
  head(10)

# ─── Top tweets por likes ───
top_tweets <- sort_tweets(tweets, by = "like_count")
top_df <- to_dataframe(top_tweets)
head(top_df, 10)

# ─── Filtrar por idioma ───
tweets_es <- filter_by_lang(tweets, "es")
tweets_en <- filter_by_lang(tweets, "en")

# ─── Filtrar por fecha ───
tweets_recent <- filter_by_date(tweets, from = "2025-10-01")

# ─── Guardar resultados ───
save_csv(tweets, "mis_tweets.csv")
save_json(tweets, "mis_tweets.json")

# ═══════════════════════════════════════════════════════════════════════════
# TIPS Y TRUCOS
# ═══════════════════════════════════════════════════════════════════════════

# 1. Verificar configuración
check_setup()

# 2. Listar cuentas
list_accounts()

# 3. Búsquedas avanzadas
tweets <- search_tweets("rstats lang:en", n = 100)  # Solo inglés
tweets <- search_tweets("from:rstudio", n = 50)     # De un usuario
tweets <- search_tweets("rstats -python", n = 100)  # Excluir palabra

# 4. Si tienes problemas de rate limit, agrega más cuentas
add_account(username2, password2, email2, email_pass2, cookies2)

# 5. Para análisis masivos, usa múltiples búsquedas
queries <- c("rstats", "python", "datascience", "machinelearning")
all_tweets <- lapply(queries, function(q) {
  search_tweets(q, n = 100)
})

# Combinar todos
all_tweets_flat <- do.call(c, all_tweets)
all_df <- to_dataframe(all_tweets_flat)

# ═══════════════════════════════════════════════════════════════════════════
# VISUALIZACIÓN CON GGPLOT2
# ═══════════════════════════════════════════════════════════════════════════

library(ggplot2)

# Tweets por día
df %>%
  mutate(date = as.Date(date)) %>%
  count(date) %>%
  ggplot(aes(date, n)) +
  geom_line() +
  geom_point() +
  theme_minimal() +
  labs(title = "Tweets por día",
       x = "Fecha",
       y = "Número de tweets")

# Top usuarios
df %>%
  count(username, sort = TRUE) %>%
  head(15) %>%
  ggplot(aes(reorder(username, n), n)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  theme_minimal() +
  labs(title = "Top 15 usuarios más activos",
       x = "",
       y = "Tweets")

# Distribución de likes
df %>%
  ggplot(aes(like_count)) +
  geom_histogram(bins = 30, fill = "coral") +
  scale_x_log10() +
  theme_minimal() +
  labs(title = "Distribución de likes",
       x = "Likes (escala log)",
       y = "Frecuencia")

# ═══════════════════════════════════════════════════════════════════════════
# ¿NECESITAS AYUDA?
# ═══════════════════════════════════════════════════════════════════════════

# Ver documentación
?search_tweets
?user_tweets
?to_dataframe

# Ver README
# file.show(system.file("README.md", package = "twscrapeR"))

# Reportar problemas:
# https://github.com/agusnieto77/twscrapeR/issues
