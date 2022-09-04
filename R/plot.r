path <- 'data/leagues/bra-serie-a/'
data <- list.files(path)
logos <- 
  read.csv('logos.csv') %>% 
    dplyr::select(names, links_path) %>% 
    dplyr::mutate(names = stringr::str_trim(names))
        

library(dplyr)

# Function for read files
get_year_as_df <- function(file){
  list_df <- jsonlite::fromJSON(paste0(path, file))
  df <- 
    dplyr::bind_rows(list_df) %>% 
      dplyr::mutate(year = file)
  return(df)
}

# Function to extract results
extract_result <- function(x){
  brk_str <- 
    x %>% 
      stringr::str_split(' ')
  
  result <- brk_str[[1]][1]
  home_team <- stringr::str_split(result, ':')[[1]][1]
  away_team <- stringr::str_split(result, ':')[[1]][2]
  
  return(list(home_team, away_team))
}

dat <-
## Reading all files and transforming into data_frame
dplyr::bind_rows(lapply(data, get_year_as_df)) %>% 
  dplyr::mutate(result_list = lapply(result,extract_result)) %>% # Extract result to list
  tidyr::unnest_wider(result_list, names_sep = c('home_goals', 'away_goals')) %>% # Transfrom into columns
  dplyr::rename(home_goals = result_listhome_goals1, away_goals = result_listaway_goals2) %>% 
  dplyr::filter(home_goals != '-' | away_goals != '-') %>% # Filtering Null results
  # Creating score cases
  dplyr::mutate(home_result = case_when(
    home_goals > away_goals ~ 'Win',
    home_goals < away_goals ~ 'Lose',
    home_goals == away_goals ~ 'Draw',
  )) %>% 
  dplyr::mutate(away_result = case_when(
    home_goals < away_goals ~ 'Win',
    home_goals > away_goals ~ 'Lose',
    home_goals == away_goals ~ 'Draw',
  )) %>% 
  # Getting year from file
  dplyr::mutate(year = substring(year, 9,12)) %>% 
  dplyr::select(-result)


##Pivoting Longer
longer_df <-
dat %>% 
  tidyr::pivot_longer(c(home_team, away_team), names_to = 'place', values_to = 'team') %>% 
  mutate(result = case_when(
    place == 'home_team' ~ home_result,
    place == 'away_team' ~ away_result
  )) %>% 
  mutate(goals = case_when(
    place == 'home_team' ~ home_goals,
    place == 'away_team' ~ away_goals
  )) %>% 
  select(-c(home_goals, away_goals, home_result, away_result)) %>% 
  mutate(points = case_when(
    result == 'Win' ~ 3,
    result == 'Lose' ~ 0,
    result == 'Draw' ~ 1
  )) %>% 
  filter(!is.na(points))



## cummulative sums for graph
df_graph <-
longer_df %>% 
  mutate(year_round = as.numeric(ifelse(
                                  nchar(round) == 1, paste0(year,0,round),
                                  paste0(year,round)))
         )%>% 
  select(-c(round, place, year, result, goals)) %>% 
  tidyr::complete(year_round, team) %>% ##Complete teams that there arent in the season
  mutate(year_round_legend = paste(
    'Year:', substring(year_round,1,4), 'Round:', substring(year_round, 5,6)
  )) %>% 
  mutate(points = case_when(
    is.na(points) ~ 0,
    TRUE ~ points
  )) %>% 
  group_by(team) %>% 
  arrange(year_round) %>% 
  mutate(points_cumulative = cumsum(points)) %>% #Cummulative sum
  group_by(year_round) %>% 
  mutate(rank = row_number(desc(points_cumulative))) %>% # RAnking
  filter(rank <= 10) %>% 
  mutate(team = stringr::str_trim(team)) %>% 
  left_join(logos, by = c('team' = 'names'))
  

## PLOT
library(ggplot2)
library(gganimate)
library(ggimage)

samples <-
df_graph %>% 
  mutate(year = substring(year_round,1,4)) %>% 
  group_by(year) %>% 
  summarise(samples = seq(min(year_round), max(year_round), length = 20)) %>% 
  pull(samples) %>% 
  as.integer()



p <- 
  df_graph  %>%
  # keep top 10
  filter(rank <= 10 & year_round %in% samples) %>%
  # plot
  ggplot(aes(-rank,points_cumulative, image = links_path)) +
  geom_col(width = 0.8, position="identity") +
  coord_flip() + 
  geom_image(aes(-rank,y=0), hjust = 1, by='width') +
  geom_text(aes(label=as.character(round(points_cumulative))), hjust = 0)+
  theme_minimal() +
  theme(legend.position = "none",
        axis.title = element_blank(),
        axis.ticks.y = element_blank(),
        axis.text.y = element_blank()) +
  labs(title = '{closest_state}', x = 'Points')+
  # animate along Year and round
  transition_states(year_round_legend,4,1)+
  enter_grow()+
  exit_shrink()+
  ease_aes('linear')

animate(p, 
        400, 
        fps = 25, 
        duration = 80, 
        width = 800, 
        height = 600, 
        renderer = ffmpeg_renderer())
