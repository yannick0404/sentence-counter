library(shiny)
library(readxl)
library(qdap)
library(shinycssloaders)

# UI
ui <- fluidPage(
  titlePanel("Sätze zählen"),
  
  uiOutput("sidebar_or_text")  # Dynamisches UI-Element
)

# Server
server <- function(input, output, session) {
  
  data <- reactive({
    # Datensatz einlesen
    df <- read_xlsx(input$file$datapath)
    if (!"fulltext" %in% names(df)) {
      stop("Column 'fulltext' not found in the uploaded file!")
    }
    
    return(as.data.frame(df)$fulltext)
  })
  
  output$sidebar_or_text <- renderUI({
    if (is.null(input$file)) {
      # Zeige die Upload-UI, solange keine Datei hochgeladen wurde
      sidebarLayout(
        sidebarPanel(
          fileInput("file", "Lade eine XLSX-Datei hoch",
                    accept = c(".xlsx")),
          helpText("Die Datei sollte eine Spalte mit 'fulltext' enthalten.")
        ),
        mainPanel(
          h4("Bitte eine Datei hochladen.")
        )
      )
    } else {
      # Zeige nur die Tabelle nach dem Upload
      fluidRow(
        column(12,
               withSpinner(uiOutput("outputText"))
        )
      )
    }
  })
  
  vis <- function(dat) {
    # Funktion zum Saetze zaehlen
    detc <- lapply(lapply(dat, function(x) sent_detect(x, endmarks = c("?", ".", "!", "|", "::"),
                                                rm.bracket = F)), rm_non_ascii)
    
    # checking and saving file with pos tags
    if(file.exists(paste0(input$file$name,"pos.rds"))) {
      pos <- readRDS(paste0(input$file$name,"pos.rds"))
    }
    else {
      # Part-of-Speech Tagging fuer Wortarten
      pos <- pos(detc, parallel = T)
      saveRDS(pos, file = paste0(input$file$name,"pos.rds"))
    }
    
    res <- vector("character", length(detc))
    po_co <- 0
    
    for (j in 1:length(detc)) {
      co <- 0
      res[j] <- paste("NR. ", j)
      for (i in 1:length(detc[[j]])) {
        po_co <- po_co + 1
        # Pruefen ob Verb im Satz
        if (!identical(grep("V", pos$POStagged$POStags[[po_co]]), integer(0))) {
          co <- co + 1
          res[j] <- paste(c(res[j], detc[[j]][i]), collapse = paste0("\n", "[", co, "]"))
        } else {
          res[j] <- paste(c(res[j], detc[[j]][i]), collapse = paste0("\n", "[", "NA", "]"))
        }
      }
    }
    
    return(res)
  }
  
  output$outputText <- renderUI({
    df <- data()
    processed_text <- vis(df)
    ## HTML output
    html_output <- paste0("<div style='width:100%; 
                   font-size:18px; 
                   line-height:1.8; 
                   white-space: pre-wrap; 
                   word-wrap: break-word; 
                   overflow-wrap: break-word;'>", 
                          paste(processed_text, collapse = "<br>
                          <hr style='height: 5px; background-color: black; border: none;'>
                                <br>"), 
                          "</div>"
    )
    
    HTML(html_output)
  })
}

# Run the app
shinyApp(ui, server)
