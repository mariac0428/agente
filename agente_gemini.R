# Instalar librerías necesarias
if (!require(httr)) install.packages("httr", dependencies = TRUE)
if (!require(jsonlite)) install.packages("jsonlite", dependencies = TRUE)
if (!require(openssl)) install.packages("openssl", dependencies = TRUE)

library(httr)
library(jsonlite)
library(openssl)

# --- Ruta donde se guardará la clave encriptada ---
key_file <- "gemini_key.enc"

# --- Función auxiliar: genera clave AES válida (32 bytes) ---
get_encryption_key <- function() {
  user <- Sys.info()[["user"]]
  user_raw <- charToRaw(user)
  length(user_raw) <- 32
  user_raw[is.na(user_raw)] <- as.raw(0)
  return(user_raw)
}

# --- Cargar o pedir la API key ---
if (file.exists(key_file)) {
  encrypted_key <- readBin(key_file, what = "raw", n = file.info(key_file)$size)
  api_key <- rawToChar(aes_cbc_decrypt(encrypted_key, get_encryption_key()))
} else {
  api_key <- readline("Ingresa tu API key de Gemini: ")
  encrypted_key <- aes_cbc_encrypt(charToRaw(api_key), get_encryption_key())
  writeBin(encrypted_key, key_file)
  cat("Clave guardada de forma segura.\n")
}

# --- Función que consulta Gemini ---
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

# --- CHAT INTERACTIVO ---
cat("=== Chat con Gemini (escribe 'salir' para terminar) ===\n")
repeat {
  prompt <- readline("\nTú: ")
  if (tolower(prompt) %in% c("salir", "exit", "quit")) {
    cat("\nChat finalizado.\n")
    break
  }
  consultar_gemini(prompt, api_key)
}
