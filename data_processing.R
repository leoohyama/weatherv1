#this script downloads data from openmeteo that is used for the daily dashboard
library(openmeteo)


weather_forecast("nyc",
  hourly = c("temperature_2m", "precipitation"),
  response_units = list(
    temperature_unit = c("fahrenheit"),
    precipitation_unit = "inch"
  )
)
gainesville_forecast<-weather_forecast(location = c(29.65163, -82.32483),
  hourly = c("temperature_2m", "precipitation"),
  response_units = list(
    temperature_unit = c("fahrenheit"),
    precipitation_unit = "inch"
  )
)


historical_gainesvillefl<-openmeteo::weather_history(location = c(29.65163, -82.32483),start = "2024-09-14",
end = "2024-09-15",
hourly =  c("temperature_2m", "precipitation"),
daily = c("temperature_2m_max", "precipitation_sum"),
response_units = list(
  temperature_unit = c("fahrenheit"),
  precipitation_unit = "inch"
  )
)

historical_dw<-openmeteo::weather_history(location = c(28.3772, -81.5707),start = "2024-09-14",
end = "2024-09-15",
hourly =  c("temperature_2m", "precipitation"),
daily = c("temperature_2m_max", "precipitation_sum"),
response_units = list(
  temperature_unit = c("fahrenheit"),
  precipitation_unit = "inch"
  )
)
