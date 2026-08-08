# Guía de inicio en español para rcol

`rcol` proporciona un acceso idiomático desde R a la API de
[ChecklistBank](https://www.checklistbank.org) y a las publicaciones
mensuales y anuales del [Catalogue of
Life](https://www.catalogueoflife.org) (COL).

``` r

library(rcol)
```

## Familias de funciones

El paquete organiza sus 46 funciones públicas en dos familias:

- **`col_*()`**: Funciones de alto nivel diseñadas para trabajar
  directamente con la versión extendida más reciente del Catalogue of
  Life (`"3LXR"`). La versión se fija automáticamente en la sesión
  ([`col_key()`](https://paulesantos.github.io/rcol/reference/col_key.md)).
- **`clb_*()`**: Funciones universales de bajo nivel que aceptan el
  argumento `dataset =` para consultar cualquier conjunto de datos
  publicado en ChecklistBank.

``` r

col_key()      # Clave numérica fijada para la sesión
col_refresh()  # Fuerza la actualización a una versión más reciente
```

## Verificación y coincidencia de nombres

Para verificar nombres científicos y obtener un resumen depurado de 9
columnas con el nombre aceptado válido y su estado taxonómico:

``` r

# Verificación depurada de 1 o más especies (9 columnas)
col_check_name(c("Werneria nubigena", "Panthera leo", "Schinus molle"))
#> # A tibble: 3 × 9
#>   queried_name      matched_name      status   accepted_name accepted_authorship
#>   <chr>             <chr>             <chr>    <chr>         <chr>              
#> 1 Werneria nubigena Werneria nubigena synonym  Rockhausenia… (Kunth) D.J.N.Hind 
#> 2 Panthera leo      Panthera leo      accepted Panthera leo  (Linnaeus, 1758)   
#> 3 Schinus molle     Schinus molle     accepted Schinus molle L.                 
#> # ℹ 4 more variables: accepted_rank <chr>, accepted_id <chr>, match <lgl>,
#> #   match_type <chr>

# Coincidencia directa completa (16 columnas)
col_match("Panthera leo")
#> # A tibble: 1 × 17
#>   match match_type usage_id name         authorship     rank  status accepted_id
#>   <lgl> <chr>      <chr>    <chr>        <chr>          <chr> <chr>  <chr>      
#> 1 TRUE  variant    4CGXP    Panthera leo (Linnaeus, 17… spec… accep… 4CGXP      
#> # ℹ 9 more variables: accepted_name <chr>, accepted_authorship <chr>,
#> #   accepted_rank <chr>, code <chr>, label <chr>, parent_id <chr>,
#> #   names_index_id <int>, names_index_match_type <chr>, classification <list>

# Inspeccionar candidatos homónimos
col_match_verbose("Oenanthe")
#> # A tibble: 2 × 16
#>   primary usage_id name     authorship    rank  status accepted_id accepted_name
#>   <lgl>   <chr>    <chr>    <chr>         <chr> <chr>  <chr>       <chr>        
#> 1 TRUE    679Q     Oenanthe L.            genus accep… 679Q        Oenanthe     
#> 2 FALSE   679P     Oenanthe Vieillot, 18… genus accep… 679P        Oenanthe     
#> # ℹ 8 more variables: accepted_authorship <chr>, accepted_rank <chr>,
#> #   code <chr>, label <chr>, parent_id <chr>, names_index_id <int>,
#> #   names_index_match_type <chr>, classification <list>

# Búsqueda masiva en paralelo
col_match_checklist(c("Panthera leo", "Bufo bufo", "Abies alba"))
#> # A tibble: 3 × 18
#>   verbatim_name match match_type usage_id name         authorship   rank  status
#>   <chr>         <lgl> <chr>      <chr>    <chr>        <chr>        <chr> <chr> 
#> 1 Panthera leo  TRUE  variant    4CGXP    Panthera leo (Linnaeus, … spec… accep…
#> 2 Bufo bufo     TRUE  variant    NP2D     Bufo bufo    (Linnaeus, … spec… accep…
#> 3 Abies alba    TRUE  variant    8K9Y     Abies alba   Mill.        spec… accep…
#> # ℹ 10 more variables: accepted_id <chr>, accepted_name <chr>,
#> #   accepted_authorship <chr>, accepted_rank <chr>, code <chr>, label <chr>,
#> #   parent_id <chr>, names_index_id <int>, names_index_match_type <chr>,
#> #   classification <list>
```

## Clasificación, sinónimos, vernáculos y distribución

Todas las funciones de relación aceptan indistintamente **nombres
científicos directos**, **vectores de especies**, **IDs alfanuméricos**
o **tablas de resultados**:

``` r

# Jerarquía taxonómica en formato Ancho o Largo
col_classification("Schinus molle", wide = TRUE)
#> # A tibble: 1 × 23
#>   match match_type usage_id name          authorship rank    status  accepted_id
#>   <lgl> <chr>      <chr>    <chr>         <chr>      <chr>   <chr>   <chr>      
#> 1 TRUE  variant    4V8GC    Schinus molle L.         species accept… 4V8GC      
#> # ℹ 15 more variables: accepted_name <chr>, accepted_authorship <chr>,
#> #   accepted_rank <chr>, code <chr>, label <chr>, parent_id <chr>,
#> #   names_index_id <int>, names_index_match_type <chr>, kingdom <chr>,
#> #   phylum <chr>, class <chr>, order <chr>, family <chr>, genus <chr>,
#> #   species <chr>

# Sinónimos taxonómicos para múltiples especies
col_synonyms(c("Werneria nubigena", "Panthera leo"))
#> # A tibble: 16 × 6
#>    accepted_name         scientific_name authorship synonym_type rank  full_name
#>    <chr>                 <chr>           <chr>      <chr>        <chr> <chr>    
#>  1 Rockhausenia nubigena Werneria nubig… Kunth      homotypic    spec… Werneria…
#>  2 Rockhausenia nubigena Oresigonia gra… Willd. ex… heterotypic  spec… Oresigon…
#>  3 Rockhausenia nubigena Oresigonia lat… Willd. ex… heterotypic  spec… Oresigon…
#>  4 Rockhausenia nubigena Oribasia acaul… DC.        heterotypic  spec… Oribasia…
#>  5 Rockhausenia nubigena Werneria disti… Kunth      heterotypic  spec… Werneria…
#>  6 Rockhausenia nubigena Werneria dombe… (Wedd.) H… heterotypic  spec… Werneria…
#>  7 Rockhausenia nubigena Werneria mocin… DC.        heterotypic  spec… Werneria…
#>  8 Rockhausenia nubigena Werneria nubig… Wedd.      heterotypic  subv… Werneria…
#>  9 Rockhausenia nubigena Werneria nubig… Wedd.      heterotypic  subv… Werneria…
#> 10 Rockhausenia nubigena Werneria nubig… Wedd.      heterotypic  vari… Werneria…
#> 11 Rockhausenia nubigena Werneria nubig… Wedd.      heterotypic  vari… Werneria…
#> 12 Rockhausenia nubigena Werneria nubig… NA         heterotypic  vari… Werneria…
#> 13 Rockhausenia nubigena Werneria steub… Hieron.    heterotypic  spec… Werneria…
#> 14 Rockhausenia nubigena Werneria stueb… Hieron.    heterotypic  spec… Werneria…
#> 15 Panthera leo          Felis leo       Linnaeus,… homotypic    spec… Felis le…
#> 16 Panthera leo          Panthera leo n… (de Blain… heterotypic  subs… Panthera…

# Nombres comunes con trazabilidad de especies (columna scientific_name)
col_vernacular(c("Werneria nubigena", "Panthera leo"))
#> # A tibble: 206 × 7
#>    scientific_name       name               language latin country area  remarks
#>    <chr>                 <chr>              <chr>    <chr> <chr>   <chr> <chr>  
#>  1 Rockhausenia nubigena Chicoria blanca    spa      Chic… NA      NA    NA     
#>  2 Rockhausenia nubigena Cóndor cebolla     spa      Cond… NA      NA    NA     
#>  3 Panthera leo          African Lion       eng      Afri… NA      NA    NA     
#>  4 Panthera leo          Afrikaanse Leeuw   nld      Afri… NA      NA    Contri…
#>  5 Panthera leo          Afrikanischer Löwe deu      Afri… DE      NA    NA     
#>  6 Panthera leo          Agrzam             shi      Agrz… NA      NA    Contri…
#>  7 Panthera leo          Ambessa            amh      Ambe… NA      NA    NA     
#>  8 Panthera leo          Arslon             uzb      Arsl… NA      NA    Contri…
#>  9 Panthera leo          Aslan              gag      Aslan NA      NA    Contri…
#> 10 Panthera leo          Dzata              ewe      Dzata NA      NA    Contri…
#> # ℹ 196 more rows

# Distribución geográfica oficial en formato tidy
col_distribution(c("Werneria nubigena", "Schinus molle"))
#> # A tibble: 54 × 1
#>    area                                
#>    <chr>                               
#>  1 Mexico (Chiapas)                    
#>  2 Guatemala                           
#>  3 Costa Rica                          
#>  4 Panama                              
#>  5 Ecuador                             
#>  6 Peru                                
#>  7 Bolivia (Cochabamba, La Paz, Tarija)
#>  8 Portugal [I]                        
#>  9 Spain [I]                           
#> 10 Gibraltar [I]                       
#> # ℹ 44 more rows
```

## Navegación del árbol y búsqueda

``` r

# Nodos raíz del árbol (Reinos / Dominios)
raices <- col_tree()

# Hijos taxonómicos directos
col_children("Panthera")
#> # A tibble: 18 × 10
#>    datasetKey id    parentId rank    status    count childCount name  authorship
#>         <int> <chr> <chr>    <chr>   <chr>     <int>      <int> <chr> <chr>     
#>  1     315834 TZBNY 6DBT     species provisio…     0          0 Leo … Brehm, 18…
#>  2     315834 TZ9SL 6DBT     species provisio…     0          0 Leo … Brehm, 18…
#>  3     315834 TZ8S4 6DBT     species provisio…     0          0 Leo … Gray, 1843
#>  4     315834 V32ZM 6DBT     species provisio…     0          0 Leo … Kretzoi, …
#>  5     315834 R9G88 6DBT     species provisio…     0          0 Pant… Fitzinger…
#>  6     315834 R9G8X 6DBT     species provisio…     0          0 Pant… Stinnesbe…
#>  7     315834 R9G95 6DBT     species provisio…     0          0 Pant… Tseng, Wa…
#>  8     315834 R9GBB 6DBT     species accepted      0          0 Pant… Kretzoï, …
#>  9     315834 4CGXP 6DBT     species accepted      0          3 Pant… (Linnaeus…
#> 10     315834 4CGXQ 6DBT     species accepted      0          1 Pant… (Linnaeus…
#> 11     315834 4CGXR 6DBT     species accepted      0         10 Pant… (Linnaeus…
#> 12     315834 V2VKY 6DBT     species provisio…     0          0 Pant… Hemmer, 2…
#> 13     315834 R9GXP 6DBT     species accepted      0          0 Pant… (Goldfuss…
#> 14     315834 4CGXS 6DBT     species accepted      0          2 Pant… (Linnaeus…
#> 15     315834 4CGXT 6DBT     species accepted      0          1 Pant… (Schreber…
#> 16     315834 R9H53 6DBT     species provisio…     0          1 Pant… Schreber,…
#> 17     315834 R9H5S 6DBT     species provisio…     0          0 Pant… Mazák, Ch…
#> 18     315834 T673T 6DBT     species provisio…     0          0 Tigr… Fitzinger…
#> # ℹ 1 more variable: full_name <chr>

# Búsqueda por texto libre
col_usage_search("Felidae", rank = "species")
#> <clb> result: 0 rows (total: 0)
#> # A tibble: 0 × 0
```

## Parsers

``` r

clb_parse_name("Abies alba Mill. var. alpina")
#> # A tibble: 1 × 9
#>   scientificName    rank  genus specificEpithet infraspecificEpithet type  label
#>   <chr>             <chr> <chr> <chr>           <chr>                <chr> <chr>
#> 1 Abies alba var. … vari… Abies alba            alpina               scie… Abie…
#> # ℹ 2 more variables: labelHtml <chr>, parsed <lgl>
```
