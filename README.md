# R Shiny App zum zählen von Sätzen
Diese Shiny-App ermöglicht das Hochladen einer XLSX-Datei mit einer Spalte "fulltext" und zählt die Sätze darin. Die Sätze werden nummeriert und ausgegeben. Dabei werden nur Sätze gezählt, die ein Verb enthalten. Das Ergebnis ist nicht komplett verlässlich und muss dementsprechend nochmal überprüft werden.
Die App kann gestartet werden, indem der R Code ausgeführt wird.

 
## Voraussetzungen
```r
install.packages(c("shiny", "readxl", "qdap", "shinycssloaders"))
```
