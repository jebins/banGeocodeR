---
output:
  html_document: default
  pdf_document: default
---
# banGeocodeR

## Description
banGeocodeR is an experimental R Shiny App allowing the geocoding of addresses in France. The app uses the [Base Adresse Nationale (BAN)](https://adresse.data.gouv.fr/), the offical french addresses database. It aims to provide two main features :

### CSV file geocoding
* geocode a CSV formatted file containing addresses (< 8 Mo)
* highlight possible errors and correct them
* display the results on an interactive map
* save the final table

### Live geocoding
* geocode typed addresses
* add them to a table
* save the whole table

The geocoding is **limited to Réunion** for the moment.

## Authors
banGeocodeR is carried out by UMR Espace-Dev (IRD, Univ. Guyane, Univ. Montpellier, Univ. Réunion) in ESoR axis (Environment, Societies and Health Risks). It was initially developed for the needs of the FOSFORE research project coordinated by the Réunion Cancers Registry (Emmanuel Chirpaz) of the Hospital University Centre of Réunion (CHU Réunion).

* Design and developement : Jérémy Commins, French National Research Institute for Sustainable Development (IRD) - UMR Espace-Dev.
* Design : Vincent Herbreteau, French National Research Institute for Sustainable Developmen (IRD) - UMR Espace-Dev.

## Data sources
* Postcodes : La Poste (ODbL licence, https://www.data.gouv.fr/fr/datasets/base-officielle-des-codes-postaux/)
* Geocoding : Base Adresse Nationale API (ODbL licence, https://adresse.data.gouv.fr/)

## Dependencies
```r
install.packages(c("shiny", "shinythemes", "shinyjs", "shinycssloaders", "DT", "leaflet", "httr", "RCurl", "plyr", "RColorBrewer"))
```
