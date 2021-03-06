library(tidyverse)
library(lubridate) ## a tidyverse (but not core tidyverse) package for working with dates more easily


## Define global variables ----------------------------------------------

# array of USA states (for use with NYT data)
usa_states <- c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia", "Guam", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Northern Mariana Islands", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Puerto Rico", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virgin Islands", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming")

# array of world countries/regions (for use with JHU data)
world_countries_regions <- c("Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burma", "Burundi", "Cabo Verde", "Cambodia", "Cameroon", "Canada", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Congo (Brazzaville)", "Congo (Kinshasa)", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba", "Cyprus", "Czechia", "Denmark", "Diamond Princess", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Eswatini", "Ethiopia", "Fiji", "Finland", "France", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Holy See", "Honduras", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Korea, South", "Kosovo", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Mauritania", "Mauritius", "Mexico", "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "MS Zaandam", "Namibia", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "North Macedonia", "Norway", "Oman", "Pakistan", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Romania", "Russia", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "San Marino", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Somalia", "South Africa", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Sweden", "Switzerland", "Syria", "Taiwan*", "Tanzania", "Thailand", "Timor-Leste", "Togo", "Trinidad and Tobago", "Tunisia", "Turkey", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "Uruguay", "US", "Uzbekistan", "Venezuela", "Vietnam", "West Bank and Gaza", "Western Sahara", "Zambia", "Zimbabwe")

## URL where New York Times data is stored and regularly updated
nyt_usa_data_url <- "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv"

## URL where Johns Hopkins University data is stored and regularly updated
jhu_top_url <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/"
jhu_confirmed_global_url <- paste0(jhu_top_url, "time_series_covid19_confirmed_global.csv")
jhu_deaths_global_url    <- paste0(jhu_top_url, "time_series_covid19_deaths_global.csv")


## Read in all THREE datasets and tidy/wrangle them into one JHU and one NYT dataset according to the instructions --------------------------

## Tidying NYT Data
nyt_raw <- read_csv(nyt_usa_data_url)

nyt_raw %>%
  pivot_longer(cases:deaths, names_to = "covid_type", values_to = "cumulative_number") -> nyt_data

## Reading in JHU Data

jhu_cases_raw <- read_csv(jhu_confirmed_global_url)
jhu_deaths_raw <- read_csv(jhu_deaths_global_url)

## Tidying JHU Data
jhu_cases_raw %>%
  pivot_longer('1/22/20':last_col(), names_to = "date", values_to = "cumulative_number") %>%
  mutate("covid_type" = "cases") %>%
  rename("province_or_state" = `Province/State`, 
         "country_or_region" = `Country/Region`,
         "latitude" = Lat,
         "longitude" = Long) %>%
  select(1:5, covid_type, cumulative_number) -> jhu_cases_tidy
## I coded it from the first date to whatever the last column is, to avoid hardcoding in a date, as the data is constantly being updated and you want the most recent date. 

jhu_deaths_raw %>%
  pivot_longer('1/22/20':last_col(), names_to = "date", values_to = "cumulative_number") %>%
  mutate("covid_type" = "deaths") %>%
  rename("province_or_state" = `Province/State`, 
         "country_or_region" = `Country/Region`,
         "latitude" = Lat,
         "longitude" = Long) %>%
  select(1:5, covid_type, cumulative_number) -> jhu_deaths_tidy

bind_rows(jhu_cases_tidy, jhu_deaths_tidy) -> jhu_data
  
jhu_data$date <- lubridate::mdy(jhu_data$date)
 
