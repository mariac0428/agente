# Instalar librerías necesarias (solo la primera vez)
if (!require(httr)) install.packages("httr", dependencies = TRUE)
if (!require(jsonlite)) install.packages("jsonlite", dependencies = TRUE)

library(httr)
library(jsonlite)

# --- Pedir la API key cada sesión ---
api_key <- readline("Ingresa tu API key de Gemini: ")

# --- Función que consulta la API de Gemini ---
consultar_gemini <- function(prompt, api_key) {
  url <- paste0(
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=",
    api_key
  )
  
  body <- list(
    contents = list(
      list(parts = list(list(text = prompt)))
    )
  )
  
  response <- POST(
    url,
    body = toJSON(body, auto_unbox = TRUE),
    encode = "json",
    content_type_json()
  )
  
  if (status_code(response) != 200) {
    cat("Error en la llamada a la API:\n")
    print(content(response, "text"))
    return(NULL)
  }
  
  result <- content(response, "parsed")
  text <- result$candidates[[1]]$content$parts[[1]]$text
  cat("\nGemini:\n", text, "\n")
}

# --- Chat interactivo ---
cat("=== Chat con Gemini (escribe 'salir' para terminar) ===\n")
repeat {
  prompt <- readline("\nTú: ")
  if (tolower(prompt) %in% c("salir", "exit", "quit")) {
    cat("\nChat finalizado.\n")
    break
  }
  consultar_gemini(prompt, api_key)
}
