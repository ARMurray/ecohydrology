library(googlesheets4)
library(tidyverse)
library(sf)
library(here)
library(leaflet)
library(leaflet.extras)
library(htmltools)
library(htmlwidgets)

# Set Mapbox token
Sys.setenv('MAPBOX_TOKEN' = 'pk.eyJ1IjoiYXJtdXJyYXkxODkiLCJhIjoiY2trcjFhNG4yMG1sdjJ3bnhsY3p0dnlpaiJ9.1z2hrGSZT0vA9P4gXAcezg')

# Read in Data from google sheets

df <- read_sheet("https://docs.google.com/spreadsheets/d/1qiFlx8GLiMoJjtfWzlzVu7km1XCnWXjWCVAhmCtI-j0/edit#gid=0")%>%
  mutate(Date = as.character(Date))

write.csv(df, here("Leaf_Map/Leaf_Data.csv")) # Save updated table locally

# Read in local table and exclude rows with no coordinates
locs <- read.csv(here("Leaf_Map/Leaf_Data.csv"))%>%
  select(Date,Lon,Lat)%>%
  drop_na()%>%
  left_join(df)


# Create spatial dataset

sf <- st_as_sf(locs, coords = c("Lon", "Lat"), 
               crs = 4326, agr = "constant")

# Create Leaf Icon
greenLeafIcon <- makeIcon(
  iconUrl = "http://leafletjs.com/examples/custom-icons/leaf-green.png",
  iconWidth = 10, iconHeight = 20,
  iconAnchorX = 0, iconAnchorY = 180
)

map <- leaflet(data = sf) %>% addTiles() %>%
  addMarkers(icon = greenLeafIcon, popup = ~paste(
    First,Last, "<br>",
    Institution, "<br>",
    City," (",Country,")","<br>",
    "<b><a href=",Leaf_URL,">Leaf Page</a></b>","<br>",
    "<b><a href=",Website,">Website</a></b>"
    ))
map
#search <- addSearchFeatures(map,~c(sf$Institution,sf$Last), options = searchFeaturesOptions())

saveWidget(map, file=here("Leaf_Map/Leaf_Map.html"))

#carto-positron