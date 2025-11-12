# =====================================
# Agente ChatGPT interactivo en R (versión limpia)
# =====================================

# Instalar paquetes si no existen
if (!require(httr)) install.packages("httr", repos = "https://cloud.r-project.org")
if (!require(jsonlite)) install.packages("jsonlite", repos = "https://cloud.r-project.org")

suppressWarnings({
  library(httr)
  library(jsonlite)
})

# =====================================
# Función principal
# =====================================

chat_session <- function() {
  cat("=====================================\n")
  cat("Agente ChatGPT en R\n")
  cat("=====================================\n")
  cat("Escribe 'salir' para terminar la sesión.\n\n")

  # Pedir API key
  api_key <- readline(prompt = "Ingresa tu API key de OpenAI: ")
  if (nchar(api_key) == 0) stop("No se ingresó ninguna API key. Intenta de nuevo.")

  # Guardar el contexto de la conversación
  mensajes <- list(list(role = "system", content = "Eres un asistente útil y claro."))

  repeat {
    # Entrada del usuario
    user_input <- readline("\nTú: ")

    if (tolower(user_input) %in% c("salir", "exit", "quit")) {
      cat("\nSesión terminada.\n")
      break
    }

    # Agregar el mensaje del usuario al contexto
    mensajes <- append(mensajes, list(list(role = "user", content = user_input)))

    # Llamada a la API
    res <- httr::POST(
      url = "https://api.openai.com/v1/chat/completions",
      httr::add_headers(
        Authorization = paste("Bearer", api_key),
        "Content-Type" = "application/json"
      ),
      body = jsonlite::toJSON(list(
        model = "gpt-4o-mini",
        messages = mensajes
      ), auto_unbox = TRUE)
    )

    if (res$status_code != 200) {
      cat("Error en la llamada a la API:\n")
      print(content(res, as = "text"))
      break
    }

    # Respuesta
    respuesta <- content(res)$choices[[1]]$message$content
    cat("\nChatGPT:\n", respuesta, "\n")

    # Agregar respuesta al contexto
    mensajes <- append(mensajes, list(list(role = "assistant", content = respuesta)))
  }
}

# =====================================
# Iniciar la sesión de chat
# =====================================

chat_session()
