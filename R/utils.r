library(httr)
library(rvest)

get_number_of_rounds <- function(league, season){
    tables <-
    read_html(sprintf(
        'https://www.worldfootball.net/schedule/%s-%s-spieltag/', league, season)
        )

    select <- tables |> rvest::html_nodes('select')

    rounds <- select[3] |> rvest::html_elements('option') |> rvest::html_text2()

    clean_rounds <- unlist(lapply(stringr::str_split(rounds, '\\.'), \(x){x[1]}))
    return(clean_rounds)
}


result_table <- function(league, season, round){
    tables <-
    read_html(sprintf(
        'https://www.worldfootball.net/schedule/%s-%s-spieltag/%s', league, season, round)
        ) |> html_table()

    table <- tables[[2]] |>
        dplyr::select(home_team = X3, away_team = X5, result = X6) |>
        dplyr::mutate(round = round)

    return(table)
}


classification_table <- function(league, season, round){
    tables <-
    read_html(sprintf(
        'https://www.worldfootball.net/schedule/%s-%s-spieltag/%s', league, season, round)
        ) |> html_table()

    table <- tables[[4]] |>
                dplyr::select(1,3,10)

    colnames(table) <- c('position', 'team', 'points')

    return(table)
}


get_results_of_season <- function(league, season){
    rounds <- get_number_of_rounds(league, season)

    all_results <- list()
    for(round in rounds){
        all_results[[round]] <- result_table(league, season, round)

        message(sprintf(
            'Getting results from round %s of the %s season %s',
            round, league, season
        ))
    }

    return(all_results)
}

get_round_classification_of_season <- function(league, season){

    rounds <- get_number_of_rounds(league, season)
    all_classification <- list()
    for(round in rounds){
        all_classification[[round]] <- classification_table(league, season, round)

        message(sprintf(
            'Getting Classification from round %s of the %s season %s',
            round, league, season
        ))
    }

    return(all_classification)
}
