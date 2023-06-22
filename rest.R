roads <- read_sf("background_data/swisstlm3d_2023-03_2056_5728.shp/TLM_STRASSEN/swissTLM3D_TLM_STRASSE.shp") |> #loading roads
  select(OBJEKTART, geometry) |> #choosing attributes needed
  filter(OBJEKTART != "Verbindung" & OBJEKTART != "Raststaette" & OBJEKTART != "Dienstzufahrt" & OBJEKTART != "Verbindung" & OBJEKTART != "Zufahrt " & OBJEKTART != "Klettersteig") |> #deleting factorlevels which are not of interest
  st_transform(2056)#set crs to 2056 (get rid of LN02)

rails <- read_sf("background_data/swisstlm3d_2023-03_2056_5728.shp/TLM_OEV/swissTLM3D_TLM_EISENBAHN.shp") |> #loading rails
  select(VERKEHRSMI, geometry) |> #choosing attributes needed
  rename(OBJEKTART = VERKEHRSMI) |> #rename for merging
  st_transform(2056)#set crs to 2056 (get rid of LN02)

boats <- read_sf("background_data/swisstlm3d_2023-03_2056_5728.shp/TLM_OEV/swissTLM3D_TLM_SCHIFFFAHRT.shp") |> #loading boats
  select(OBJEKTART, geometry) |> #choosing attributes needed
  st_transform(2056)#set crs to 2056 (get rid of LN02)

stops <- read_sf("background_data/swisstlm3d_2023-03_2056_5728.shp/TLM_OEV/swissTLM3D_TLM_HALTESTELLE.shp")|> #loading stops
  select(OBJEKTART, geometry) |> #choosing attributes needed
  st_transform(2056) #set crs to 2056 (get rid of LN02)
```{r, fig.cap = "Spatial join of the POSMO data to the nearest feature of roads, rails and boat lines for the examplary day 18.04.2023"}

#| echo: false
#| warning: false
#| message: false

##visualize part of it:
data_01 <- data |> 
  filter(as.Date(datetime) == "2023-04-18") #select example day

bbox <- st_bbox(data_01) #produce a bounding box with that day
clipped_background <- st_crop(background_data, bbox)

ggplot()+ #visualize
  geom_sf(data=clipped_background, aes(color=OBJEKTART))+
  geom_sf(data=data_01, alpha=0.4, size=2.5, aes(color=OBJEKTART))+
  theme_classic()+
  theme(legend.position = "bottom")

```
```{r, fig.cap = "Spatial join of the POSMO data to the nearest feature of roads, rails and boat lines for the examplary day 18.04.2023"}

#| echo: false
#| warning: false
#| message: false

##visualize part of it:

tmap_mode("view") 
tm_shape(data)+
  tm_dots(col="OBJEKTART")+
  tm_shape(background_data)+
  tm_lines("OBJEKTART")+
  
  
  ```


```{r}
data_smry <- read_delim("output_files/data_smry.csv", delim = ",")

#First allocation = Walk
data_smry$travel_mode_det <- ifelse(data_smry$max_speed < 2, "Walk", NA)

#Bike
data_smry$travel_mode_det <- ifelse(is.na(data_smry$travel_mode_det) & data_smry$max_speed < 20 & data_smry$mean_speed < 7, "Bike", data_smry$travel_mode_det)

#Rail
data_smry$travel_mode_det <- ifelse(data_smry$nearest_route == "rail", "rail", data_smry$travel_mode_det)
```


```{r}
#validation with second dataset




## SEVI: TLM

Load datas, preparing and cropping them to canton of zuerich

```{r}

#layers <- st_layers("background_data/SWISSTLM3D_2023_LV95_LN02.gpkg")

#roads <- read_sf("background_data/SWISSTLM3D_2023_LV95_LN02.gpkg", layer = "tlm_strassen_strasse")
#stops <- read_sf("background_data/SWISSTLM3D_2023_LV95_LN02.gpkg", layer = "tlm_oev_haltestelle")
#rail <- read_sf("background_data/SWISSTLM3D_2023_LV95_LN02.gpkg", layer = "tlm_oev_eisenbahn")
swiss <- read_sf("background_data/swissBOUNDARIES3D_1_4_TLM_LANDESGEBIET.shp")
canton <- read_sf("background_data/swissBOUNDARIES3D_1_4_TLM_KANTONSGEBIET.shp")
district <- read_sf("background_data/swissBOUNDARIES3D_1_4_TLM_BEZIRKSGEBIET.shp")
plot(canton)
plot(swiss)

zurich <- canton |> 
  filter(NAME=="Zürich")
zurich <- zurich |> 
  select(c(NAME, geometry))
plot(zurich)

horgen <- district |> 
  filter(NAME=="Horgen" & BEZIRK_TEI==1)
horgen <- horgen |> 
  select(NAME, geometry)
plot(horgen)

roads <- st_transform(roads, st_crs(zurich))
stops <- st_transform(stops, st_crs(zurich))
rail <- st_transform(rail, st_crs(zurich))

intersect_roads <- st_intersection(roads, zurich)
intersect_stops <- st_intersection(stops, zurich)
intersect_rail <- st_intersection(rail, zurich)

plot(intersect_rail$geom)
plot(intersect_roads$geom)
plot(intersect_stops$geom)

intersect_roads <- intersect_roads |> 
  select(c(objektart, verkehrsbedeutung, geom))
st_write(intersect_roads,"output_files/intersect_roads.gpkg")

intersect_rail <- intersect_rail |> 
  select(c(objektart, auf_strasse, verkehrsmittel, geom))
st_write(intersect_rail,"output_files/intersect_rail.gpkg")

intersect_stops <- intersect_stops |> 
  select(c(objektart, name, geom))
st_write(intersect_stops,"output_files/intersect_stops.gpkg")

intersect_roads <- read_sf("output_files/intersect_roads.gpkg")
intersect_rail <- read_sf("output_files/intersect_rail.gpkg")
intersect_stops <- read_sf("output_files/intersect_stops.gpkg")

```

## Intersect data before filtering data

nrow(data_swiss) ist etwas klein....vielleicht nachprüfen oder mit Sämi besprechen

```{r}
data_sevi <- read_delim("posmo_data/posmo_v1.csv")
head(data_sevi)

data_sevi <- select(data_sevi, datetime, transport_mode, lon_x, lat_y) # Keep only the necessary columns

data_sevi <- st_as_sf(data_sevi, coords = c("lon_x","lat_y"), crs = 4326) |>  #cs is transformed to 2056
  st_transform(2056)

data_coord_sevi <- st_coordinates(data_sevi) #coordinates are extracted
data_sevi <- cbind(data_sevi, data_coord_sevi) #coordinates are binded in separate columns

swiss <- read_sf("background_data_small/swissBOUNDARIES3D_1_4_TLM_LANDESGEBIET.shp")
canton <- read_sf("background_data_Small/swissBOUNDARIES3D_1_4_TLM_KANTONSGEBIET.shp")
district <- read_sf("background_data_small/swissBOUNDARIES3D_1_4_TLM_BEZIRKSGEBIET.shp")

zurich <- canton |> 
  filter(NAME=="Zürich")
zurich <- zurich |> 
  select(c(NAME, geometry))

horgen <- district |> 
  filter(NAME=="Horgen" & BEZIRK_TEI==1)
horgen <- horgen |> 
  select(NAME, geometry)

data <- st_transform(data_sevi, "+init=EPSG:2056")
st_crs(swiss) <-  "+init=EPSG:2056"

zurich <- st_transform(zurich, "+init=EPSG:2056")
horgen <- st_transform(horgen, "+init=EPSG:2056")


data_swiss <- read_delim("output_files/data_swiss.csv")
#data_swiss <- st_intersection(data, swiss)
#write_delim(data_swiss, "output_files/data_swiss.csv")


data_zurich <- st_intersection(data_sevi, zurich)

data_horgen <- st_intersection(data_sevi, horgen)


#Timelag
data_swiss <- data_swiss |>
  mutate(timelag = as.numeric(difftime(lead(datetime), datetime, units = "secs")))

data_zurich <- data_zurich |>
  mutate(timelag = as.numeric(difftime(lead(datetime), datetime, units = "secs")))

data_horgen <- data_horgen |>
  mutate(timelag = as.numeric(difftime(lead(datetime), datetime, units = "secs")))

#Gap
data_swiss <- data_swiss %>%
  mutate(gap = timelag > 10)

data_zurich <- data_zurich %>%
  mutate(gap = timelag > 10)

data_horgen <- data_horgen %>%
  mutate(gap = timelag > 10)


#Segment ID
data_swiss <- data_swiss %>%
  mutate(segment_id = cumsum(gap))

data_zurich <- data_zurich %>%
  mutate(segment_id = cumsum(gap))

data_horgen <- data_horgen %>%
  mutate(segment_id = cumsum(gap))


#Steplength
data_swiss <- data_swiss %>%
  group_by(segment_id) %>%
  mutate(
    step_length = sqrt((lead(X, 1) - X) ^ 2 + (lead(Y, 1) - Y) ^ 2),
    sum_step_length = rollsum(step_length, k = 12, fill = NA, align = "right", na.rm = TRUE)
  ) %>%
  ungroup()

data_zurich <- data_zurich %>%
  group_by(segment_id) %>%
  mutate(
    step_length = sqrt((lead(X, 1) - X) ^ 2 + (lead(Y, 1) - Y) ^ 2),
    sum_step_length = rollsum(step_length, k = 12, fill = NA, align = "right", na.rm = TRUE)
  ) %>%
  ungroup()

data_horgen <- data_horgen %>%
  group_by(segment_id) %>%
  mutate(
    step_length = sqrt((lead(X, 1) - X) ^ 2 + (lead(Y, 1) - Y) ^ 2),
    sum_step_length = rollsum(step_length, k = 12, fill = NA, align = "right", na.rm = TRUE)
  ) %>%
  ungroup()

#Static
data_swiss <- data_swiss %>%
  mutate(static = if_else(is.na(sum_step_length) | sum_step_length < 25, T, F))
ggplot(data_swiss, aes(X, Y)) +
  geom_path() +
  geom_point() +
  coord_fixed() +
  theme_bw()+
  theme(legend.position = "none")

data_zurich <- data_zurich %>%
  mutate(static = if_else(is.na(sum_step_length) | sum_step_length < 25, T, F))
ggplot(data_zurich, aes(X, Y)) +
  geom_path() +
  geom_point() +
  coord_fixed() +
  theme_bw()+
  theme(legend.position = "none")

data_horgen <- data_horgen %>%
  mutate(static = if_else(is.na(sum_step_length) | sum_step_length < 25, T, F))
ggplot(data_horgen, aes(X, Y)) +
  geom_path() +
  geom_point() +
  coord_fixed() +
  theme_bw()+
  theme(legend.position = "none")

#RLE ID Function
rle_id <- function(vec) {
  x <- rle(vec)$lengths
  as.factor(rep(seq_along(x), times = x))
} 

#Segment ID
data_swiss <- data_swiss |>
  mutate(segment_id = rle_id(static))

data_zurich <- data_zurich |>
  mutate(segment_id = rle_id(static))

data_horgen <- data_horgen |>
  mutate(segment_id = rle_id(static))

#Filter Movement
data_swiss <- data_swiss |> 
  filter(!static)

data_zurich <- data_zurich |> 
  filter(!static)

data_horgen <- data_horgen |> 
  filter(!static)

#Filter short segment IDs
data_swiss <- data_swiss |> 
  group_by(segment_id) |> 
  filter(sum(timelag, na.rm = T) > 120) |> 
  filter(sum(step_length, na.rm = T) > 200)

data_zurich <- data_zurich |> 
  group_by(segment_id) |> 
  filter(sum(timelag, na.rm = T) > 120) |> 
  filter(sum(step_length, na.rm = T) > 200)

data_horgen <- data_horgen |> 
  group_by(segment_id) |> 
  filter(sum(timelag, na.rm = T) > 120) |> 
  filter(sum(step_length, na.rm = T) > 200)

#Plot

ggplot(data_swiss, aes(X, Y, color = segment_id)) +
  geom_path() +
  geom_point() +
  coord_fixed() +
  theme(legend.position = "none")

ggplot(data_zurich, aes(X, Y, color = segment_id)) +
  geom_path() +
  geom_point() +
  coord_fixed() +
  theme(legend.position = "none")

ggplot(data_horgen, aes(X, Y, color = segment_id)) +
  geom_path() +
  geom_point() +
  coord_fixed() +
  theme(legend.position = "none")

ggplot(data_swiss, aes(X, Y, color = segment_id)) +
  geom_path() +
  geom_point() +
  coord_fixed() +
  theme_bw()+
  theme(legend.position = "none")

ggplot(data_zurich, aes(X, Y, color = segment_id)) +
  geom_path() +
  geom_point() +
  coord_fixed() +
  theme_bw()+
  theme(legend.position = "none")

ggplot(data_horgen, aes(X, Y, color = segment_id)) +
  geom_path() +
  geom_point() +
  coord_fixed() +
  theme_bw()+
  theme(legend.position = "none")

#Speed
data_swiss <- data_swiss|> 
  mutate(speed = step_length/timelag) 

data_zurich <- data_zurich|> 
  mutate(speed = step_length/timelag) 

data_horgen<- data_horgen|> 
  mutate(speed = step_length/timelag) 

#Mean, max und min speed
data_swiss_smry <- data_swiss |> 
  filter(timelag != 0) |> 
  group_by(segment_id, transport_mode) |> 
  summarise(mean_speed = mean(speed, na.rm=T),
            max_speed = max(speed,na.rm=T),
            min_speed = min(speed,na.rm=T))

data_zurich_smry <- data_zurich |> 
  filter(timelag != 0) |> 
  group_by(segment_id, transport_mode) |> 
  summarise(mean_speed = mean(speed, na.rm=T),
            max_speed = max(speed,na.rm=T),
            min_speed = min(speed,na.rm=T))

data_horgen_smry <- data_horgen |> 
  filter(timelag != 0) |> 
  group_by(segment_id, transport_mode) |> 
  summarise(mean_speed = mean(speed, na.rm=T),
            max_speed = max(speed,na.rm=T),
            min_speed = min(speed,na.rm=T))


?sf


```

## Results

<!-- the following is just a placeholder text, remove it!-->
  
  Philosophy oneself passion play fearful self noble zarathustra deceptions sexuality. Endless ocean of oneself dead ocean. Selfish decrepit.

## Discussion

<!-- the following is just a placeholder text, remove it!-->
  
  Justice convictions spirit sexuality insofar free marvelous joy. Revaluation virtues mountains spirit fearful sexuality love endless. Society intentions will noble burying aversion moral. Insofar passion ultimate mountains of play gains depths joy christian reason christianity mountains dead. Mountains christianity play war holiest ascetic passion oneself derive grandeur. Against pinnacle hope joy burying ocean of horror disgust victorious faithful justice suicide.
