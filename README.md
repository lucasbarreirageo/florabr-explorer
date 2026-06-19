<div align="center">
  <img src="www/flora_chan.png" alt="Flora-chan Logo REFLORA" width="250">
  
  # florabr-explorer
</div>

# florabr-explorer
Ferramenta computacional para acesso rápido e exportação de registros da Flora e Funga do Brasil (JBRJ), desenvolvida para otimizar fluxos de trabalho em pesquisa botânica e conservação.

# Consulta à Flora e Funga do Brasil 🌿🍄

Um aplicativo interativo construído em R (Shiny) para consultar e exportar dados da base da Flora e Funga do Brasil, utilizando o pacote [`florabr`](https://brunomc-oliveira.github.io/florabr/).

## Sobre os Dados e a Tecnologia

**A Flora e Funga do Brasil**
A plataforma [`Flora e Funga do Brasil`](https://reflora.jbrj.gov.br/reflora/listaBrasil/ConsultaPublicaUC/ResultadoDaConsultaNovaConsulta.do#CondicaoTaxonCP) é um marco na botânica mundial e o pilar fundamental para qualquer estratégia de conservação da biodiversidade brasileira. Coordenada pelo Jardim Botânico do Rio de Janeiro (JBRJ), a base consolida décadas de esforço colaborativo de centenas de taxonomistas e especialistas. Ela fornece o alicerce de dados mais robusto e atualizado sobre a diversidade vegetal e fúngica do país, sendo uma fonte primária inestimável para a pesquisa científica e para o desenvolvimento de políticas públicas de proteção ambiental.

**O Pacote florabr**
Este aplicativo atua como uma interface gráfica construída sobre o pacote R [`florabr`](https://brunomc-oliveira.github.io/florabr/), desenvolvido por W. C. Trindade (2024). O pacote otimizou de forma significativa a maneira como pesquisadores interagem com as bases de dados do JBRJ no ambiente R, permitindo o download ágil, a filtragem e a manipulação de milhares de registros taxonômicos com extrema eficiência computacional.

## 📌 Funcionalidades
* **Download e Gerenciamento da base:** Baixe a versão mais recente dos dados diretamente do Jardim Botânico do Rio de Janeiro.
* **Busca flexível:** Consulte espécies, gêneros, famílias ou nomes populares.
* **Filtros avançados:** Opção de incluir subespécies e variedades.
* **Exportação:** Salve os resultados em CSV diretamente no seu computador.
* **Detalhes taxonômicos:** Visualize sinônimos, biomas, formas de vida, endemismo e status de conservação.

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
## Passo a passo de utilização

O aplicativo foi desenhado para processar a base de dados localmente no seu computador, garantindo estabilidade e rapidez nas consultas após a configuração inicial.

### 1. Configuração e Download da Base (Primeiro Acesso)
Antes de realizar qualquer busca, é necessário baixar a base de dados oficial.
* Na barra lateral esquerda, localize a seção **1) Configuração**.
* **Pasta dos dados:** O aplicativo sugere um diretório padrão no seu computador (ex: `~/florabr/dados`) para armazenar a base. Você pode manter este caminho ou clicar em "Escolher pasta dos dados..." para definir um diretório customizado.
* **Versão da base:** Selecione entre a versão Curta (recomendada para a maioria das análises de ocorrência) ou a Completa.
* Clique no botão amarelo **"Baixar / atualizar base"**. *Nota: Este processo pode levar alguns minutos, pois o aplicativo fará o download dos registros diretamente do servidor do JBRJ. O painel de status informará quando o download for concluído.*

### 2. Carregando os dados (Uso contínuo)
Uma vez que a base já foi baixada no seu computador, você **não precisa** baixá-la novamente nos acessos futuros (a menos que deseje atualizar os dados taxonômicos).
* Ao abrir o aplicativo novamente, basta verificar se a "Pasta dos dados" está apontando para o local correto.
* Clique no botão verde **"Carregar base"**. O painel de status confirmará o número de registros e colunas carregados na memória ativa.

### 3. Busca, Filtragem e Visualização
Com a base carregada, utilize a seção **2) Busca** para explorar os táxons.
* **Buscar por:** Defina o nível taxonômico da sua consulta (Família, Gênero, Espécie) ou busque por Nome Popular.
* **Termo:** Insira o nome desejado (ex: *Fabaceae*, *Mimosa*, *Prepusa connata*).
* **Filtros avançados:** Utilize as caixas de seleção para refinar sua matriz de dados antes da exportação:
  * *Incluir subespécies / variedades*
  * *Apenas endêmicas* (retém apenas espécies com endemismo confirmado no Brasil)
  * *Apenas nativas* (exclui ocorrências naturalizadas ou cultivadas)
  * *Apenas nomes aceitos* (remove sinonímias da tabela principal)
* Clique em **"Buscar"**. Os resultados aparecerão na tabela interativa à direita.
* **Detalhes e Sinônimos:** Abaixo da tabela principal, você pode selecionar uma espécie específica nos resultados para visualizar uma ficha técnica completa (Forma de vida, Habitat, Biomas, Estados, etc.) e sua respectiva lista de sinônimos.

### 4. Exportação dos dados
Após filtrar os dados de interesse, você possui duas opções para exportar a matriz em formato CSV:
* **Baixar CSV (navegador):** Faz o download imediato do arquivo através da interface do navegador ou visualizador do RStudio, salvando na sua pasta de Downloads padrão.
* **Salvar na pasta de saída:** Salva o arquivo CSV automaticamente no diretório especificado no campo "Pasta de saída" (na seção de Configuração). O arquivo é gerado com uma nomenclatura padronizada, incluindo o nível de busca, o termo e um carimbo de data/hora (ex: `florabr_family_Fabaceae_20260615_143000.csv`), facilitando a organização de múltiplas extrações.


## Como citar

Se por acaso achar que esta ferramenta foi útil para o seu fluxo de trabalho de alguma forma, por favor, utilize uma das seguintes formatações para citação:

### Padrão ABNT
BARREIRA, A.L. florabr-explorer: Ferramenta computacional para acesso rápido e exportação de registros da Flora e Funga do Brasil. Versão 1.0. Rio de Janeiro: GitHub, 2026. Disponível em: <https://github.com/lucasbarreirageo/florabr-explorer>. Acesso em: [Inserir data de acesso].

### Padrão APA
Barreira, A.L. (2026). florabr-explorer: Ferramenta computacional para acesso rápido e exportação de registros da Flora e Funga do Brasil (Version 1.0) [Computer software]. GitHub. https://github.com/lucasbarreirageo/florabr-explorer
