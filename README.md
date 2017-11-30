# banGeocodeR

## Description
banGeocodeR is an experimental R Shiny App allowing the geocoding of addresses in France. The app uses the [Base Adresse Nationale (BAN)](https://adresse.data.gouv.fr/), the offical French address database. It provides two main features :

### CSV file geocoding
* geocode a CSV formatted file containing addresses (< 8 Mo)
* highlight possible errors and correct them
* display the results on an interactive map
* export the geocoded table

### Live geocoding
* geocode addresses one by one
* add them to a table
* export the geocoded table

The geocoding is **limited to Réunion** for the moment.

## Authors
banGeocodeR is carried out by [UMR Espace-Dev](http://www.espace-dev.fr/) (IRD, Univ. Guyane, Univ. Montpellier, Univ. Réunion) in ESoR research group (Environment, Societies and Health Risks). It was initially developed for the needs of the FOSFORE research project coordinated by the Cancer Registry of Réunion (Emmanuel Chirpaz) at the Réunion hospital (CHU Réunion).

* Design and developement : Jérémy Commins, French National Research Institute for Sustainable Development (IRD) - UMR Espace-Dev.
* Design : Vincent Herbreteau, French National Research Institute for Sustainable Developmen (IRD) - UMR Espace-Dev.

## Data sources
* Postcodes : La Poste (ODbL licence, https://www.data.gouv.fr/fr/datasets/base-officielle-des-codes-postaux/)
* Geocoding : Base Adresse Nationale API (ODbL licence, https://adresse.data.gouv.fr/)

## Dependencies
```r
install.packages(c("shiny", "shinythemes", "shinyjs", "shinycssloaders", "DT", "leaflet", "httr", "RCurl", "plyr", "RColorBrewer"))
```
