# florabr-explorer
Ferramenta computacional para acesso rápido e exportação de registros da Flora e Funga do Brasil (JBRJ), desenvolvida para otimizar fluxos de trabalho em pesquisa botânica e conservação.


# Consulta à Flora e Funga do Brasil 🌿🍄

Um aplicativo interativo construído em R (Shiny) para consultar e exportar dados da base da Flora e Funga do Brasil, utilizando o pacote [`florabr`](https://brunomc-oliveira.github.io/florabr/).

## 📌 Funcionalidades
* **Download e Gerenciamento da Base:** Baixe a versão mais recente dos dados diretamente do Jardim Botânico do Rio de Janeiro.
* **Busca Flexível:** Consulte espécies, gêneros, famílias ou nomes populares.
* **Filtros Avançados:** Opção de incluir subespécies e variedades.
* **Exportação:** Salve os resultados em CSV diretamente no seu computador.
* **Detalhes Taxonômicos:** Visualize sinônimos, biomas, formas de vida, endemismo e status de conservação.

## 🚀 Como usar (Direto do RStudio)
Qualquer pessoa com o R e o RStudio instalados pode executar esta aplicação diretamente do GitHub, sem precisar de descarregar os ficheiros manualmente. Basta correr o seguinte código no R:

```R
# Instalar o pacote shiny caso não esteja instalado
if (!requireNamespace("shiny", quietly = TRUE)) {
  install.packages("shiny")
}

# Executar a aplicação diretamente do repositório
shiny::runGitHub(repo = "florabr-explorer", username = "lucasbarreirageo")

```
## Como Citar

Se por acaso achar que esta ferramenta foi útil para o seu fluxo de trabalho de alguma forma, por favor, utilize uma das seguintes formatações para citação:

### Padrão ABNT
BARREIRA, A.L. florabr-explorer: Ferramenta computacional para acesso rápido e exportação de registros da Flora e Funga do Brasil. Versão 1.0. Rio de Janeiro: GitHub, 2026. Disponível em: <https://github.com/lucasbarreirageo/florabr-explorer>. Acesso em: [Inserir data de acesso].

### Padrão APA
Barreira, A.L. (2026). florabr-explorer: Ferramenta computacional para acesso rápido e exportação de registros da Flora e Funga do Brasil (Version 1.0) [Computer software]. GitHub. https://github.com/lucasbarreirageo/florabr-explorer
