# banGeocodeR

## Description
banGeocodeR is an experimental R Shiny App allowing the geocoding of addresses in France. The app uses the Base Adresse Nationale (BAN), the offical french addresses database. banGeocodeR was developped as part of a research project by the Centre Hospitalier Universitaire de La Réunion and is limited to Réunion for the moment.

banGeocodeR est une application R Shiny expérimentale, permettant de géocoder des adresses en France. L'application utilise la Base Adresse Nationale (BAN), la base de données officielle des adresses françaises. banGeocodeR a été développé dans le cadre d'un projet de recherche mené par le Centre Hospitalier Universitaire de La Réunion et est pour l'instant limité à La Réunion.

## Dependencies
```r
install.packages(c("shiny", "shinythemes", "shinyjs", "shinycssloaders", "DT", "leaflet", "httr", "RCurl", "plyr", "RColorBrewer"))
```

## Data sources
* Postcodes : La Poste (ODbL licence, https://www.data.gouv.fr/fr/datasets/base-officielle-des-codes-postaux/)
* Geocoding : Base Adresse Nationale API (https://adresse.data.gouv.fr/, ODbL licence)

## Authors
Jérémy Commins, Institut de Recherche pour le Développement (IRD)