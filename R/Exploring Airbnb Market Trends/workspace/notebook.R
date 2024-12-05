# Load necessary libraries
library(readr)
library(readxl)
library(stringr)
library(tidyr)
library(lubridate)
library(tibble)

airbnb_price <- read.csv("../data/airbnb_price.csv")

# Count occurrences of "Private" and "private" (case insensitive)
nb_private_rooms <- sum(str_count(tolower(airbnb_room_type_df$room_type), pattern = "private")) # nolint

# Output the result
print(nb_private_rooms)

last_reviewed <- airbnb_last_review %>% 
  mutate(last_review = parse_date_time(last_review, orders = "mdy")) %>%  # Corrected 'order' to 'orders' # nolint
  slice_max(last_review, n = 1, with_ties = FALSE) %>% 
  select(last_review)

print(last_reviewed)


first_reviewed <- airbnb_last_review %>% 
  mutate(last_review = parse_date_time(last_review, orders = "mdy")) %>%  # Corrected 'order' to 'orders' # nolint
  slice_min(last_review, n = 1, with_ties = FALSE) %>%
  select(last_review)

print(first_reviewed)

# Read the Airbnb price data airbnb_
price <- read.csv("data/airbnb_price.csv")

# Separate the 'price' column into 'number' and 'currency'
airbnb_price <- airbnb_price %>%
  separate(price, into = c("number", "currency"), sep = " ")
# Convert 'number' to a numeric vector
numeric_vector <- as.numeric(airbnb_price$number)
# Calculate the average price and round to 1 decimal place
avg_price <- round(mean(numeric_vector, na.rm = TRUE), 1)
# Print the average price
print(avg_price)


combined_results <- tibble(
  nb_private_rooms = nb_private_rooms,
  last_reviewed = last_reviewed$last_review,
  first_reviewed = first_reviewed$last_review,
  avg_price = avg_price
)


print(combined_results)