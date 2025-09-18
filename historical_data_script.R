#this will be a script I use to get historical data from disney to use
#yearly

require(openmeteo)
require(lubridate)
require(here)
require(ggplot2)
require(purrr)
require(dplyr)
require(tidyr)


#get a table of the locations and what they are called:

locations<-c("Disney World, FL", "Apopka", "Sanford","Downtown Orlando", "Kissimmee", "Winter Park")
latitude<-c(28.3772,28.8029, 28.6934,28.5475,28.2956, 28.5950)
longitude<-c(-81.5707,-81.2695, -81.5322, -81.3791, -81.4039, -81.3509)

table_locations = data.frame(locations = locations,
                             latitude = latitude,
                             longitude = longitude)

historical_daily<-purrr::map2(table_locations$latitude, table_locations$longitude, .f = ~ 
              openmeteo::weather_history(location = c(.x,.y),
                                         start = "2015-01-01",
                                         end = "2025-09-01",
                                         hourly = c("temperature_2m",
                                                    "relative_humidity_2m",
                                                    "precipitation",
                                                    
                                                    "wind_direction_100m",
                                                    "wind_speed_100m",
                                                    "shortwave_radiation"),
                                         response_units = list(
                                           temperature_unit = c("celsius"),
                                           precipitation_unit = "mm"
                                         )))


names(historical_daily)<-table_locations$locations


#create lag variables for the previous day

features_ml_max<-lapply(historical_daily, function(x){
  new_df<-x |>
    arrange(datetime) %>%       # Make sure data is sorted by date
    mutate(
      hourly_temperature_2mlag = lag(hourly_temperature_2m, 24),  # min temp from previous day
      hourly_precipitation = lag(hourly_precipitation, 24),
      hourly_wind_direction_100m = lag(hourly_wind_direction_100m,24),
      hourly_wind_speed_100m = lag(hourly_wind_speed_100m,24),
      hourly_shortwave_radiation = lag(hourly_shortwave_radiation,24),
      day_of_year =  as.numeric(format(datetime, "%j")),
      time_of_day =  as.numeric(format(datetime, "%H"))
    ) %>%
    drop_na() 
  return(new_df)
})

saveRDS(features_ml_max[[1]], "data/trainingdata/disneyworld_historical.rds")

features_ml_min<-lapply(historical_daily, function(x){
  new_df<-x |>
    arrange(date) %>%       # Make sure data is sorted by date
    mutate(
      daily_temperature_2m_min1 = lag(daily_temperature_2m_min, 1),  # min temp from previous day
      temperature_2m_max1 = lag(temperature_2m_max, 1),# max temp from 1 days ago
      precipitation_hours1 = lag(precipitation_hours, 1),
      precipitation_sum = lag(precipitation_sum, 1),
      wind_direction_10m_dominant1 = lag(wind_direction_10m_dominant,1),
      wind_speed_10m_max1 = lag(wind_speed_10m_max,1),
      shortwave_radiation_sum1 = lag(shortwave_radiation_sum,1),
      day_of_year =  as.numeric(format(date, "%j"))
    ) %>%
    drop_na(c(daily_temperature_2m_min1,daily_temperature_2m_min2)) %>%
    select(-daily_sunrise,-daily_sunset)
  return(new_df)
})
#creating weather strips

theme_strip <- function(){ 
  
  theme_minimal() %+replace%
    theme(
      axis.text.y = element_blank(),
      axis.line.y = element_blank(),
      axis.title = element_blank(),
      panel.grid.major = element_blank(),
      legend.title = element_blank(),
      axis.text.x = element_text(vjust = 3),
      panel.grid.minor = element_blank(),
      plot.title = element_text(size = 14, face = "bold"),
      legend.key.width = unit(.5, "lines")
    )
}

col_strip<- RColorBrewer::brewer.pal(11, "RdBu")

maxmin <- range(historical_dw_daily$daily_temperature_2m_max, na.rm = T)
md <- mean(historical_dw_daily$daily_temperature_2m_max, na.rm = T)

climate_stripe_disney_2024<-ggplot(data = historical_dw_daily) +
  geom_tile(aes(x = (date), y = 0.1, 
                fill =daily_temperature_2m_max)) +
  scale_x_date(
    date_breaks = "6 years",
    date_labels = "%m",
    expand = c(0, 0)
  ) +
  scale_fill_gradientn(colors = rev(col_strip), values = scales::rescale(c(maxmin[1], md, maxmin[2])),
                       na.value = "gray80") +
  theme_strip()

saveRDS(climate_stripe_disney_2024, file =here("weather_app","data","weatherstripes",paste0("disney_2024.rds")))
ggsave(filename = here("weather_app","data","weatherstripes",paste0("disney_2024.png")),
  climate_stripe_disney_2024,
  width = 12,
  height = 1.5  # very thin
)
