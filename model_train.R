#model training for predictive

#load libraries
require(tidyverse)
require(tidymodels)
require(vip)

#load data
disneydata<-readRDS("data/trainingdata/disneyworld_historical.rds")
disneydata<-disneydata %>% select(-datetime)
# 2. Split data
set.seed(123)
data_split <- initial_split(disneydata, prop = 0.75)

train <- training(data_split)
test  <- testing(data_split)

rf_recipe <- recipe(hourly_temperature_2m ~ ., data = train) %>%
  step_zv(all_predictors()) 

#set up parallel processing for tuning the model
library(future)

plan(multisession, workers = 4)

tune_spec <- rand_forest(
  mode = "regression",
  mtry = tune(),
  min_n = tune(),
  trees = 500
) %>%
  set_engine("ranger")

# 6. Cross-validation folds for tuning
set.seed(234)
tune_fold <- vfold_cv(train, v = 8)

# 5. Create workflow
tune_wf <- workflow() %>%
  add_recipe(rf_recipe) %>%
  add_model(tune_spec) 

tune_res<-tune_grid(
  tune_wf,
  resamples = tune_fold,
  grid = 10,
  control = control_grid(verbose = TRUE)
)

#close out parallel procesisng
future::plan(future::sequential)

#collect metrics from tuning
metrics <- collect_metrics(tune_res)

best_params <- select_best(tune_res, metric = "rmse")

# Update the model with the best parameters and set importance and trees
final_rf <- rand_forest(
  mode = "regression",
  mtry = best_params$mtry,
  min_n = best_params$min_n,
  trees = 500
) %>%
  set_engine("ranger", importance = "permutation") 

# Update the final workflow with the updated model
final_wf <- tune_wf %>%
  update_model(final_rf)

final_fit <- fit(final_wf, data = train)

library(vip)  # for plotting
final_fit %>%
  extract_fit_parsnip() %>%
  vip::vip()


predictions <- predict(final_fit, test) %>%
  bind_cols(test)

# Evaluate RMSE etc.
yardstick::rmse(predictions, truth = hourly_temperature_2m, estimate = .pred)
yardstick::rsq(predictions, truth = hourly_temperature_2m, estimate = .pred)

predictionsr %>%
  summarise(
    within_1C = mean(abs(residual) <= 1),
    within_2C = mean(abs(residual) <= 2),
    within_3C = mean(abs(residual) <= 3),
    within_5C = mean(abs(residual) <= 5)
  )

predictionsr <- predictions %>%
  mutate(residual = hourly_temperature_2m - .pred)

summary(predictionsr$residual)
sd(predictionsr$residual)
mean(abs(predictionsr$residual))

# Plot
ggplot(predictions, aes(.pred, hourly_temperature_2m)) +
  geom_point(alpha = 0.3) +
  geom_abline(color = "red")


yesterdays_data<-openmeteo::weather_history(location = c(28.3772,-81.5707),
                           start = "2015-09-17",
                           end = "2015-09-17",
                           hourly = c("temperature_2m",
                                      "relative_humidity_2m",
                                      "precipitation",
                                      "wind_direction_100m",
                                      "wind_speed_100m",
                                      "shortwave_radiation"),
                           response_units = list(
                             temperature_unit = c("celsius"),
                             precipitation_unit = "mm"
                           ))

newdata2<-newdata |>
  filter(format(datetime, "%H:%M") == "14:00") %>%
  arrange(datetime)  %>%       # Make sure data is sorted by date
  mutate(    day_of_year =  as.numeric(format(datetime, "%j")),
             time_of_day =  as.numeric(format(datetime, "%H"))) %>%
  rename(hourly_temperature_2mlag = hourly_temperature_2m)

actual = 29.2

openmeteo::weather_now(location = c(28.3772,-81.5707))
predictions <- predict(final_fit, newdata2) 
