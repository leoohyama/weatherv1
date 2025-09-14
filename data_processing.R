#this script downloads data from openmeteo that is used for the daily dashboard
require(openmeteo)
require(lubridate)

#get the current date
date<-Sys.Date( )

#get the same date but last year
lastdate <- date %m-% years(1)

#this downloads the forecase for Gainesville on the day this script is run
gainesville_forecast<-weather_forecast(location = c(29.65163, -82.32483), start = date, end = date,
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


historical_gainesvillefl<-openmeteo::weather_history(location = c(29.65163, -82.32483),
start = lastdate,
end = lastdate,
hourly =  c("temperature_2m", "precipitation"),
daily = c("temperature_2m_max", "precipitation_sum"),
response_units = list(
  temperature_unit = c("fahrenheit"),
  precipitation_unit = "inch"
  )
)

historical_dw<-openmeteo::weather_history(location = c(28.3772, -81.5707),
start = lastdate,
end = lastdate,
hourly =  c("temperature_2m", "precipitation"),
daily = c("temperature_2m_max", "precipitation_sum"),
response_units = list(
  temperature_unit = c("fahrenheit"),
  precipitation_unit = "inch"
  )
)
