#this will be a script I use to get historical data from disney to use
#yearly

require(openmeteo)
require(lubridate)
require(here)
require(ggplot2)

historical_dw_daily<-openmeteo::weather_history(location = c(28.3772, -81.5707),
                                                start = "2024-01-01",
                                                end = "2024-12-31",
                                                daily = c("temperature_2m_max", "precipitation_sum"),
                                                response_units = list(
                                                  temperature_unit = c("fahrenheit"),
                                                  precipitation_unit = "inch"
                                                )
)

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
