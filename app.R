###############################################################################
# App Shiny — Consulta a Flora e Funga do Brasil (pacote florabr)
#
# COMO USAR:
#   1) Salve este arquivo como "app.R".
#   2) Abra no RStudio e clique em "Run App"  (ou rode: shiny::runApp("app.R")).
#   3) Em "1) Configuracao": escolha a pasta dos dados e a pasta de saida
#      (use os botoes "Escolher pasta..." OU digite/cole o caminho no campo).
#   4) Clique em "Baixar / atualizar base"  (so na 1a vez, ou para atualizar).
#   5) Clique em "Carregar base".
#   6) Pronto: busque por familia/genero/especie/nome popular e exporte.
#
# Fonte dos dados: Flora e Funga do Brasil - Jardim Botanico do Rio de Janeiro.
# Pacote: Trindade, W. C. (2024). florabr. Applications in Plant Sciences, e11616.
###############################################################################

## ---- Instala os pacotes necessarios (apenas se faltarem) -------------------
pacotes <- c("shiny", "DT", "shinyFiles", "florabr")
for (p in pacotes) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org")
  }
}

library(shiny)
library(DT)
library(shinyFiles)
library(florabr)

## ---- Pastas padrao (a pessoa pode trocar pela interface) -------------------
pasta_dados_padrao <- file.path(path.expand("~"), "florabr", "dados")
pasta_saida_padrao <- file.path(path.expand("~"), "florabr", "saida")

## ---- Auxiliar: pega o valor de uma coluna com seguranca --------------------
val <- function(linha, coluna) {
  if (coluna %in% names(linha)) {
    v <- as.character(linha[[coluna]][1])
    if (is.na(v) || v == "") "-" else v
  } else "-"
}

## ============================== UI =========================================
ui <- fluidPage(
  titlePanel("Consulta a Flora e Funga do Brasil"),
  sidebarLayout(
    sidebarPanel(
      width = 4,

      tags$h4("1) Configuracao"),
      textInput("data_dir", "Pasta dos dados (onde a base sera salva/lida):",
                value = pasta_dados_padrao),
      shinyDirButton("data_dir_btn", "Escolher pasta dos dados...",
                     title = "Selecione a pasta dos dados"),
      tags$br(), tags$br(),
      textInput("output_dir", "Pasta de saida (onde salvar resultados):",
                value = pasta_saida_padrao),
      shinyDirButton("output_dir_btn", "Escolher pasta de saida...",
                     title = "Selecione a pasta de saida"),

      tags$hr(),
      radioButtons("tipo", "Versao da base:",
                   c("Curta - 20 colunas (recomendada)" = "short",
                     "Completa - 39 colunas"            = "complete"),
                   selected = "short"),
      div(style = "display:flex; gap:8px; flex-wrap:wrap;",
        actionButton("baixar_dados",   "Baixar / atualizar base",
                     class = "btn-warning"),
        actionButton("carregar_dados", "Carregar base",
                     class = "btn-success")
      ),
      tags$br(),
      verbatimTextOutput("status"),

      tags$hr(),
      tags$h4("2) Busca"),
      selectInput("nivel", "Buscar por:",
                  c("Familia"            = "family",
                    "Genero"             = "genus",
                    "Especie (binomio)"  = "species",
                    "Nome popular"       = "vernacular")),
      textInput("termo", "Termo:",
                placeholder = "ex.: Fabaceae / Mimosa / Mimosa pudica / ipe"),
      div(style = "display:flex; gap:16px;",
        checkboxInput("sub", "Incluir subespecies", FALSE),
        checkboxInput("var", "Incluir variedades",  FALSE)
      ),
      actionButton("buscar", "Buscar", class = "btn-primary"),

      tags$hr(),
      tags$small(
        "Fonte: Flora e Funga do Brasil - Jardim Botanico do Rio de Janeiro. ",
        "Pacote florabr (Trindade, 2024)."
      )
    ),

    mainPanel(
      width = 8,
      h4("Resultados"),
      textOutput("resumo"),
      tags$br(),
      DTOutput("tabela"),

      tags$hr(),
      h4("Exportar"),
      div(style = "display:flex; gap:8px; flex-wrap:wrap;",
        downloadButton("baixar_csv",  "Baixar CSV (navegador)"),
        actionButton("salvar_saida",  "Salvar na pasta de saida",
                     class = "btn-info")
      ),
      verbatimTextOutput("status_export"),

      tags$hr(),
      h4("Detalhe da especie e sinonimos"),
      uiOutput("seletor_especie"),
      verbatimTextOutput("detalhe"),
      DTOutput("sinonimos")
    )
  )
)

## ============================ SERVER =======================================
server <- function(input, output, session) {

  ## Seletores de pasta (shinyFiles): preenchem os campos de texto.
  ## Mesmo sem usar o botao, o usuario pode simplesmente digitar o caminho.
  roots <- c(Inicio = path.expand("~"), shinyFiles::getVolumes()())
  shinyDirChoose(input, "data_dir_btn",   roots = roots, session = session)
  shinyDirChoose(input, "output_dir_btn", roots = roots, session = session)

  observeEvent(input$data_dir_btn, {
    p <- parseDirPath(roots, input$data_dir_btn)
    if (length(p) > 0) updateTextInput(session, "data_dir", value = p)
  })
  observeEvent(input$output_dir_btn, {
    p <- parseDirPath(roots, input$output_dir_btn)
    if (length(p) > 0) updateTextInput(session, "output_dir", value = p)
  })

  ## Estado da aplicacao
  bf         <- reactiveVal(NULL)
  status_msg <- reactiveVal("Configure as pastas, baixe e carregue a base para comecar.")
  busca      <- reactiveValues(df = NULL, msg = "")
  export_msg <- reactiveVal("")

  output$status        <- renderText(status_msg())
  output$status_export <- renderText(export_msg())

  ## Baixar / atualizar base
  observeEvent(input$baixar_dados, {
    dir <- trimws(input$data_dir)
    if (!nzchar(dir)) { status_msg("Informe a pasta dos dados."); return() }
    if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)
    status_msg("Baixando a base... isso pode levar alguns minutos. Aguarde.")
    res <- tryCatch({
      get_florabr(output_dir = dir, data_version = "latest", overwrite = TRUE)
      "Base baixada com sucesso. Agora clique em 'Carregar base'."
    }, error = function(e) paste("Erro ao baixar:", conditionMessage(e)))
    status_msg(res)
  })

  ## Carregar base na memoria
  observeEvent(input$carregar_dados, {
    dir <- trimws(input$data_dir)
    if (!dir.exists(dir)) {
      status_msg("A pasta dos dados nao existe. Baixe a base primeiro.")
      return()
    }
    status_msg("Carregando base na memoria...")
    res <- tryCatch({
      d <- load_florabr(data_dir     = dir,
                        data_version = "Latest_available",
                        type         = input$tipo)
      bf(d)
      sprintf("Base carregada: %s registros, %s colunas (versao '%s').",
              format(nrow(d), big.mark = "."), ncol(d), input$tipo)
    }, error = function(e) paste("Erro ao carregar:", conditionMessage(e)))
    status_msg(res)
  })

  ## Busca
  observeEvent(input$buscar, {
    d <- bf()
    if (is.null(d)) {
      busca$df  <- NULL
      busca$msg <- "Carregue a base antes de buscar."
      return()
    }
    termo <- trimws(input$termo)
    if (!nzchar(termo)) {
      busca$df  <- NULL
      busca$msg <- "Digite um termo de busca."
      return()
    }

    out <- tryCatch(
      switch(input$nivel,
        family = select_species(d, family = termo,
                                include_subspecies = input$sub,
                                include_variety    = input$var),
        genus  = select_species(d, genus = termo,
                                include_subspecies = input$sub,
                                include_variety    = input$var),
        species = {
          sel <- d[tolower(d$species) == tolower(termo), , drop = FALSE]
          if (nrow(sel) == 0)
            sel <- d[grepl(termo, d$species, ignore.case = TRUE), , drop = FALSE]
          sel
        },
        vernacular = tryCatch(
          select_by_vernacular(d, names = termo, exact = FALSE),
          error = function(e)
            d[grepl(termo, d$vernacularName, ignore.case = TRUE), , drop = FALSE]
        )
      ),
      error = function(e) {
        showNotification(paste("Erro na busca:", conditionMessage(e)),
                         type = "error", duration = 8)
        d[0, , drop = FALSE]
      }
    )

    busca$df  <- out
    busca$msg <- if (is.null(out) || nrow(out) == 0)
      "Nenhum registro encontrado." else
      sprintf("%s registro(s) encontrado(s).", format(nrow(out), big.mark = "."))
  })

  output$resumo <- renderText(busca$msg)

  output$tabela <- renderDT({
    req(busca$df)
    datatable(busca$df,
              selection = "single",
              filter    = "top",
              rownames  = FALSE,
              options   = list(pageLength = 15, scrollX = TRUE))
  })

  ## Exportar - download direto pelo navegador
  output$baixar_csv <- downloadHandler(
    filename = function() paste0("florabr_resultado_", Sys.Date(), ".csv"),
    content  = function(file) {
      req(busca$df)
      write.csv(busca$df, file, row.names = FALSE, fileEncoding = "UTF-8")
    }
  )

  ## Exportar - salvar na pasta de saida escolhida pelo usuario
  observeEvent(input$salvar_saida, {
    if (is.null(busca$df) || nrow(busca$df) == 0) {
      export_msg("Nao ha resultados para salvar."); return()
    }
    out_dir <- trimws(input$output_dir)
    if (!nzchar(out_dir)) { export_msg("Informe a pasta de saida."); return() }
    if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
    arquivo <- file.path(
      out_dir,
      sprintf("florabr_%s_%s_%s.csv",
              input$nivel,
              gsub("[^A-Za-z0-9]+", "_", trimws(input$termo)),
              format(Sys.time(), "%Y%m%d_%H%M%S"))
    )
    res <- tryCatch({
      write.csv(busca$df, arquivo, row.names = FALSE, fileEncoding = "UTF-8")
      paste("Arquivo salvo em:", arquivo)
    }, error = function(e) paste("Erro ao salvar:", conditionMessage(e)))
    export_msg(res)
  })

  ## Seletor de especie a partir dos resultados
  output$seletor_especie <- renderUI({
    req(busca$df)
    if (nrow(busca$df) == 0 || !("species" %in% names(busca$df))) return(NULL)
    especies <- sort(unique(busca$df$species))
    selectInput("especie_sel", "Escolha uma especie:", choices = especies)
  })

  ## Detalhe textual da especie
  output$detalhe <- renderText({
    req(input$especie_sel)
    d <- bf()
    linha <- d[d$species == input$especie_sel, , drop = FALSE]
    if (nrow(linha) == 0) return("")
    linha <- linha[1, , drop = FALSE]
    paste0(
      "Especie: ",            val(linha, "species"), "\n",
      "Nome cientifico: ",    val(linha, "scientificName"), "\n",
      "Familia: ",            val(linha, "family"),
      "  |  Genero: ",        val(linha, "genus"), "\n",
      "Forma de vida: ",      val(linha, "lifeForm"),
      "  |  Habitat: ",       val(linha, "habitat"), "\n",
      "Origem: ",             val(linha, "Origin"),
      "  |  Endemismo: ",     val(linha, "Endemism"), "\n",
      "Status taxonomico: ",  val(linha, "taxonomicStatus"), "\n",
      "Biomas: ",             val(linha, "Biome"), "\n",
      "Estados: ",            val(linha, "States"), "\n",
      "Tipo de vegetacao: ",  val(linha, "vegetationType"), "\n",
      "Nome(s) popular(es): ",val(linha, "vernacularName")
    )
  })

  ## Sinonimos da especie selecionada
  output$sinonimos <- renderDT({
    req(input$especie_sel)
    d <- bf()
    s <- tryCatch(
      get_synonym(d, species = input$especie_sel,
                  include_subspecies = input$sub,
                  include_variety    = input$var),
      error = function(e) NULL
    )
    if (is.null(s) || !is.data.frame(s) || nrow(s) == 0) {
      return(datatable(data.frame(Sinonimos = "Nenhum sinonimo encontrado."),
                       rownames = FALSE, options = list(dom = "t")))
    }
    datatable(s, caption = "Sinonimos", rownames = FALSE,
              options = list(pageLength = 10, scrollX = TRUE))
  })
}

shinyApp(ui, server)
