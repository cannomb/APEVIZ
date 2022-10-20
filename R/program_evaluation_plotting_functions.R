##############################################################################################
##############################################################################################
##############################################################################################
##############################################################################################
#####                                                                                    #####
#####    Program Evaluation Plot Building Functions                                      #####
#####                                                                                    #####
#####    Includes functions to create                                                    #####
#####      - love plots                                                                  #####
#####      - "tie-fighter" plots                                                         #####
#####      - data-wrangling sankey                                                       #####
#####                                                                                    #####
#####                                                                                    #####
#####                                                                                    #####
#####                                                                                    #####
#####                                                                                    #####
##############################################################################################
##############################################################################################
##############################################################################################
##############################################################################################






######################################################################################
######################################################################################
####                                                                              ####
####  Love Plots                                                                  ####
####                                                                              ####
######################################################################################
######################################################################################

#' Create a dataframe of pre and post matched standard mean difference between treatment and control groups
#'
#'  This function takes in a MatchIt object and returns a dataframe that can used to
#'  create love plots using the create_love_plot function
#'
#'  @param match_object MatchIt object that contains metadate about pre and post match dataframes
#'  @export
create_plot_metadata <- function(match_object){

  return(
    summary(match_object)$sum.all %>%
    tibble::as_tibble(rownames = "covariate") %>%
    janitor::clean_names() %>%
    tidyselect::select(covariate, unmatched_std_mean_diff = std_mean_diff) %>%
    left_join(summary(match_object)$sum.matched %>%
                tibble::as_tibble(rownames = "covariate") %>%
                janitor::clean_names() %>%
                tidyselect::select(covariate, cem_std_mean_diff = std_mean_diff))
  )

}



#' Creates a love plot
#'
#' This function takes in a dataframe created with the create_plot_metadata function
#' as an input and outputs a loveplot
#'
#' @param input Dataframe created from the create_plot_metadata function.
#' @param title A string to be used as the title of the plot.
#' @param subtitle A string to be used as the subtitle of the plot.
#' @param horizontal Defaults to FALSE. When TRUE, the plot will be horizontal instead of vertical,
#' @param segment_size Defaults to 0.3. The size of the segments connecting treatment and control dot geoms.
#' @param segment_color Defaults to "#b0aba5". A string indicating the color of the segments connecting treatment and control dot geoms.
#' @param matched_color Defaults to "#30694a". A string indicating the color of the dot geoms representing the matched set value.
#' @param prematched_color Defaults to "#9c513a". A string indicating the color of the dot geoms representing the prematched set value.
#' @param background_color Defaults to "#f1eee9". A string indicating the color of the plot background
#' @param axis_text_size Defaults to 8. An integer indicating the font size along both axis.
#' @param axis_text_angle Only applies when horizontal is TRUE, defaults to 45.
#' @param axis_text_hjusts Only applies when horizontal is TRUE, defaults to 1.
#' @param legend_position Defaults to "bottom". takes any string the legend.position argument excepts in ggplot::theme.
#' @export
create_love_plot <- function(input,
                             title,
                             subtitle,
                             horizontal = FALSE,
                             segment_size = 0.3,
                             segment_color = "#b0aba5",
                             matched_color = "#30694a",
                             prematched_color = "#9c513a",
                             background_color = "#F1EEE9",
                             axis_text_size = 8,
                             axis_text_angle = 45,
                             axis_text_hjusts = 1,
                             legend_position = "bottom"
                             ){
  if(class(input)[1] == "tbl_df"){
    return(input %>%
      ggplot2::ggplot(aes(y = reorder(covariate, abs(unmatched_std_mean_diff)))) +
      geom_segment(aes(x = abs(cem_std_mean_diff), xend = abs(unmatched_std_mean_diff),
                       yend = reorder(covariate, unmatched_std_mean_diff)),
                   size = segment_size,
                   color = segment_color) +
      geom_point(aes(x = abs(unmatched_std_mean_diff),
                     color = "Unmatched and Unpruned")) +
      geom_point(aes(x = abs(cem_std_mean_diff),
                     color = "Matched and Pruned")) +
      scale_color_manual(values = c(matched_color, prematched_color)) +
      guides(color = guide_legend(override.aes = list(size = 5))) +
      labs(y = "",
           x = "Absolute Standardized Mean Difference",
           color = "",
           title = title,
           subtitle = subtitle) +
      {if(horizontal) list(coord_flip(),
                           theme(panel.grid.major.x = element_blank(),
                                 panel.background = element_rect(fill = background_color),
                                 plot.background = element_rect(fill = background_color),
                                 legend.background = element_rect(fill = background_color),
                                 panel.grid = element_line(linetype = "dashed", color = "#73777B"),
                                 #axis.ticks = element_blank(),
                                 axis.text.x = element_text(size = axis_text_size,
                                                            angle = axis_text_angle,
                                                            hjust = axis_text_hjust),
                                 plot.title.position = "plot",
                                 legend.position = legend_position))} +
      {if(horizontal == FALSE) theme(panel.grid.major.y = element_blank(),
                                     panel.background = element_rect(fill = background_color),
                                     plot.background = element_rect(fill = background_color),
                                     legend.background = element_rect(fill = background_color),
                                     panel.grid = element_line(linetype = "dashed", color = "#73777B"),
                                     #axis.ticks = element_blank(),
                                     plot.title.position = "plot",
                                     legend.position = legend_position)})
  }

  if(class(input)[1] == "matchit"){

  }
}





########################################################################################
########################################################################################
####                                                                                ####
####    tie-fighter plots                                                           ####
####                                                                                ####
########################################################################################
########################################################################################

#' Creates "tie-fighter" plot
#'
#' Takes in one or more glm opjects and turnes creates a "tie-fighter" plot using
#' the estimates and standard errors
#'
#' @param estimate_objects One or more glm objects give as a list.
#' @param x_title String used as the title for the x-axis.
#' @param title String used as the title for the plot.
#' @param subtitle String used as the subtitle for the plot.
#' @param background_color Defaults to "#f5e8e4". A string indicating the plot background color.
#' @export
create_tiefighter_plot <- function(estimate_objects,
                                   x_title,
                                   title,
                                   subtitle,
                                   background_color = "#F5E8E4"){

  estimates <- lapply(estimate_objects, coeftest)

  estimates_table <- tibble(outcome = names(estimate_objects),
                            estimate = sapply(estimates, "[[", 2),
                            std.err = sapply(estimates, "[[", 4))

  cem_results %>%
    ggplot() +
    geom_point(aes(x = estimate, y = outcome)) +
    geom_segment(aes(x = estimate - (1.96 * std.err),
                     xend = estimate + (1.96 * std.err),
                     y = outcome,
                     yend = outcome)) +
    geom_vline(xintercept = 0, linetype = "dashed") +
    labs(x = x_title,
         y = "",
         title = title,
         subtitle = subtitle) +
    theme(plot.background = element_rect(fill = background_color),
          panel.background = element_rect(fill = background_color),
          panel.grid.major.y = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid = element_line(color = "#c7b8b3"),
          axis.text.y = element_text(face = "bold"),
          axis.ticks = element_blank()) %>% return()
}


# matched_data <- match.data(cem_match)
#
# table(matched_data$group, matched_data$previous_noncomplete)
#
#
# estimate_effects_removal2year <- glm(removal_2year ~ treated,
#                                      data = matched_data,
#                                      weights = weights,
#                                      family = quasibinomial(link = "identity"))
#
# effects_investigation2year <- glm(investigation_2year ~ treated,
#                                   data = matched_data,
#                                   weights = weights,
#                                   family = quasibinomial(link = "identity"))
#
# effects_founded2year <- glm(founded_2year ~ treated,
#                             data = matched_data,
#                             weights = weights,
#                             family = quasibinomial(link = "identity"))
#
# glm_obs <- list("removal_2year" = estimate_effects_removal2year,
#                 "investigation_2year" = effects_investigation2year,
#                 "founded_2year" = effects_founded2year)
#
# create_tiefighter_plot(glm_obs,
#                        x_title = "blachasdf;alj",
#                        title = "plot blahj",
#                        subtitle = "plotlaksjdf;l",
#                        background_color = "pink")








































































