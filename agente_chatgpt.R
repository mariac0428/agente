# ===============================
# AGENTE CHATGPT EN R (portátil)
# ===============================

# Librerías necesarias
if(!require(httr)) install.packages("httr", repos='https://cloud.r-project.org')
if(!require(jsonlite)) install.packages("jsonlite", repos='https://cloud.r-project.org')

library(httr)
library(jsonlite)

# ---- FUNCIONES ----

# Cargar clave desde variable de entorno o pedirla al usuario
obtener_api_key <- function() {
  key <- Sys.getenv("OPENAI_API_KEY")
  if (key == "") {
    key <- readline("Introduce tu clave API de OpenAI: ")
    Sys.setenv(OPENAI_API_KEY = key)
  }
  return(key)
}

# Función principal que llama al modelo
llamar_chatgpt <- function(prompt) {
  api_key <- obtener_api_key()
  url <- "https://api.openai.com/v1/chat/completions"

  body <- list(
    model = "gpt-5",  # usa "gpt-4o" si no tienes acceso a 5
    messages = list(list(role = "user", content = prompt))
  )

  response <- POST(
    url,
    add_headers(
      Authorization = paste("Bearer", api_key),
      `Content-Type` = "application/json"
    ),
    body = toJSON(body, auto_unbox = TRUE)
  )

  result <- content(response, "parsed")
  
  if (!is.null(result$error)) {
    cat("❌ Error:", result$error$message, "\n")
  } else {
    cat("\n🧠 Respuesta:\n")
    cat(result$choices[[1]]$message$content, "\n")
  }
}

# ---- USO ----
# Si se llama directamente:
if (sys.nframe() == 0) {
  prompt_usuario <- readline("Escribe tu prompt: ")
  llamar_chatgpt(prompt_usuario)
}
