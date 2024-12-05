# Load necessary libraries
library(readr)
library(readxl)
library(stringr)
library(tidyr)
library(lubridate)
library(tibble)

airbnb_price <- read.csv("data/airbnb_price.csv")
airbnb_room_type <- lapply(excel_sheets("data/airbnb_room_type.xlsx"), read_excel, path = "data/airbnb_room_type.xlsx") # nolint
airbnb_last_review <- read_tsv("data/airbnb_last_review.tsv", show_col_types = FALSE) # nolint


# Separate the 'price' column into 'number' and 'currency'
airbnb_price <- airbnb_price %>%
  separate(price, into = c("number", "currency"), sep = " ")
# Convert 'number' to a numeric vector
numeric_vector <- as.numeric(airbnb_price$number)
# Calculate the average price and round to 1 decimal place
avg_price <- round(mean(numeric_vector, na.rm = TRUE), 2)
# Print the average price
print(avg_price)

airbnb_room_type <- as.data.frame(airbnb_room_type)
# Count occurrences of "Private" and "private" (case insensitive)
#nb_private_rooms <- sum(str_count(tolower(airbnb_room_type$room_type), pattern = "private ")) # nolint
airbnb_room_type <- airbnb_room_type %>% 
	 mutate(room_type = tolower(room_type)) # nolint

nb_private_rooms <- sum(str_detect(airbnb_room_type$room_type, "private"))


last_reviewed <- airbnb_last_review %>% 
  mutate(last_review = parse_date_time(last_review, orders = "mdy")) %>%  # Corrected 'order' to 'orders' # nolint
  slice_max(last_review, n = 1, with_ties = FALSE) %>% 
  select(last_review)


first_reviewed <- airbnb_last_review %>% 
  mutate(first_review = parse_date_time(last_review, orders = "mdy")) %>%
  slice_min(first_review, n = 1, with_ties = FALSE) %>%
  select(first_review)

review_dates <- tibble(
  nb_private_rooms = nb_private_rooms,
  last_reviewed = last_reviewed$last_review,
  first_reviewed = first_reviewed$first_review,
  avg_price = avg_price
)

print(review_dates)