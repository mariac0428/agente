# =====================================
# 🤖 Agente ChatGPT en R (con clave pedida al momento)
# =====================================

# Instalar paquetes si no existen
if (!require(httr)) install.packages("httr", repos = "https://cloud.r-project.org")
if (!require(jsonlite)) install.packages("jsonlite", repos = "https://cloud.r-project.org")

suppressWarnings({
  library(httr)
  library(jsonlite)
})

# Función para chatear con GPT
chat_with_gpt <- function(prompt) {
  # 🔑 Pedir la API key al usuario
  api_key <- readline(prompt = "🔑 Ingresa tu API key de OpenAI: ")

  if (nchar(api_key) == 0) {
    stop("❌ No se ingresó ninguna API key. Intenta de nuevo.")
  }

  url <- "https://api.openai.com/v1/chat/completions"

  body <- list(
    model = "gpt-4o-mini",
    messages = list(list(role = "user", content = prompt))
  )

  res <- httr::POST(
    url,
    httr::add_headers(
      Authorization = paste("Bearer", api_key),
      "Content-Type" = "application/json"
    ),
    body = jsonlite::toJSON(body, auto_unbox = TRUE)
  )

  if (res$status_code != 200) {
    print(content(res, as = "text"))
    stop("⚠️ Error al llamar a la API.")
  }

  return(content(res)$choices[[1]]$message$content)
}

# =====================================
# 🚀 Parte interactiva
# =====================================

cat("=====================================\n")
cat("🤖 Bienvenido al agente ChatGPT en R\n")
cat("=====================================\n\n")

prompt <- readline("💬 Escribe tu pregunta para ChatGPT: ")
cat("\n🧠 Respuesta de ChatGPT:\n")
cat(chat_with_gpt(prompt), "\n")
