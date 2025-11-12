if (!require(httr)) install.packages("httr", dependencies = TRUE)
if (!require(jsonlite)) install.packages("jsonlite", dependencies = TRUE)
if (!require(openssl)) install.packages("openssl", dependencies = TRUE)

library(httr)
library(jsonlite)
library(openssl)

# --- Archivo donde se guardará la clave encriptada ---
key_file <- "gemini_key.enc"

# --- Pedir o leer la API key ---
if (file.exists(key_file)) {
  encrypted_key <- readBin(key_file, what = "raw", n = file.info(key_file)$size)
  api_key <- rawToChar(aes_cbc_decrypt(encrypted_key, charToRaw(Sys.info()[["user"]])))
} else {
  api_key <- readline("Ingresa tu API key de Gemini: ")
  encrypted_key <- aes_cbc_encrypt(charToRaw(api_key), charToRaw(Sys.info()[["user"]]))
  writeBin(encrypted_key, key_file)
  cat("Clave guardada de forma segura.\n")
}

# --- Función para consultar a Gemini ---
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
  cat("\nRespuesta de Gemini:\n", text, "\n")
}

# --- Ejemplo de uso ---
prompt <- readline("Escribe tu pregunta o prompt: ")
consultar_gemini(prompt, api_key)
