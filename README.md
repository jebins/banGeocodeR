# GeocodeR

## Description
GeocodeR is an experimental R Shiny App allowing the geocoding of addresses in France. The app uses the Base Adresse Nationale, the offical french addresses database. GeocodeR was developped as part of a research project by the Centre Hospitalier Universitaire de La Réunion and is limited to Réunion for the moment.


GeocodeR est une application R Shiny expérimentale, permettant de géocoder des adresses en France. L'application utilise la Base Adresse Nationale, la base de données officielle des adresses françaises. GeocodeR a été développé dans le cadre d'un projet de recherche mené par le Centre Hospitalier Universitaire de La Réunion et est pour l'instant limité à La Réunion.

## installing the packages
install.packages("shiny", "shinythemes", "shinyjs", "shinycssloaders", "DT", "leaflet", "httr", "RCurl", "plyr", "RColorBrewer")

## Data sources
Postcodes : La Poste (ODbL licence, https://www.data.gouv.fr/fr/datasets/base-officielle-des-codes-postaux/)
Geocoding : Base Adresse Nationale API (https://adresse.data.gouv.fr/, ODbL licence)