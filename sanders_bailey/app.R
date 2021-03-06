#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


# Load all libraries ------------------------------------------------------------------------
library(shiny)
library(shinythemes)
library(tidyverse)
library(colourpicker)

source("covid_data_load.R") ## This line runs the Rscript "covid_data_load.R", which is expected to be in the same directory as this shiny app file!
# The variables defined in `covid_data_load.R` are how fully accessible in this shiny app script!!

# UI --------------------------------
ui <- shinyUI(
        navbarPage(theme = shinytheme("paper"), ### Uncomment the theme and choose your own favorite theme from these options: https://rstudio.github.io/shinythemes/
                   title = "Covid-19 Cumulative Case and Death Tracker", 
            
            ## All UI for NYT goes in here:
            tabPanel("NYT data visualization", ## do not change this name
            
                    # All user-provided input for NYT goes in here:
                    sidebarPanel(
                        
                        colourpicker::colourInput("nyt_color_cases", "Color for plotting COVID cases:", value = "gold3"),
                        colourpicker::colourInput("nyt_color_deaths", "Color for plotting COVID deaths:", value = "firebrick4"),            ## Change these colors to your own
                        selectInput("which_state",
                                    "Which state's data would you like to see?",
                                    choices = usa_states,
                                    selected = "New Jersey"), ## input$which_state
                        radioButtons("facet_county",
                                     "Show results across county?",
                                     choices = c("No", "Yes"),
                                     selected = "No"),
                        radioButtons("y_scale",
                                     "Scale for Y-axis?",
                                     choices = c("linear", "log")),
                        selectInput("which_theme",
                                    "Which visual theme would you like to use?",
                                    choices = c("Classic", "Minimal", "Dark", "Gray"),
                                    selected = "Classic")
                    ), # closes NYT sidebarPanel. Note: we DO need a comma here, since the next line opens a new function     
                    
                    # All output for NYT goes in here:
                    mainPanel(
                        plotOutput("nyt_plot", height = 600)
                    ) # closes NYT mainPanel. Note: we DO NOT use a comma here, since the next line closes a previous function  
            ), # closes tabPanel for NYT data
            
            
            ## All UI for JHU goes in here:
            tabPanel("JHU data visualization", ## do not change this name
                     
                     # All user-provided input for JHU goes in here:
                     sidebarPanel(

                         colourpicker::colourInput("jhu_color_cases", "Color for plotting COVID cases:", value = "blue2"),
                         colourpicker::colourInput("jhu_color_deaths", "Color for plotting COVID deaths:", value = "black"),
                         
                         selectInput("which_region",
                                     "What country or region would you like to see?",
                                     choices = world_countries_regions), ## input$which_region
                         radioButtons("loglin",
                                      "Scale for Y-axis?",
                                      choices = c("Linear", "Log"),
                                      selected = "Linear"),
                         selectInput("month_facet",
                                     "Would you like to display data by month?",
                                     choices = c("No", "Yes"),
                                     selected = "No"),
                         selectInput("which_themejhu",
                                     "Which visual theme would you like to use?",
                                     choices = c("Classic", "Minimal", "Dark", "Gray"),
                                     selected = "Classic")
                     ), # closes JHU sidebarPanel     
                     
                     # All output for JHU goes in here:
                     mainPanel(
                        plotOutput("jhu_plot")
                     ) # closes JHU mainPanel     
            ) # closes tabPanel for JHU data
    ) # closes navbarPage
) # closes shinyUI

# Server --------------------------------
server <- function(input, output, session) {

    ## PROTIP!! Don't forget, all reactives and outputs are enclosed in ({}). Not just parantheses or curly braces, but BOTH! Parentheses on the outside.
    
    

    
    ## All server logic for NYT goes here ------------------------------------------
    
    ## Define a reactive for subsetting the NYT data
    nyt_data_subset <- reactive({
        nyt_data %>%
            filter(state == input$which_state) -> nyt_state

            if(input$facet_county == "No"){
            nyt_state %>%
            group_by(date, covid_type) %>%
            summarize(y = sum(cumulative_number)) -> final_nyt_state
            }
        if(input$facet_county == "Yes"){
            nyt_state %>%
                rename(y = cumulative_number) -> final_nyt_state
            
            
        }
        final_nyt_state
          })
    
    ## Define your renderPlot({}) for NYT panel that plots the reactive variable. ALL PLOTTING logic goes here.
    output$nyt_plot <- renderPlot({
       nyt_data_subset() %>%
            ggplot(aes(x = date, y = y, color = covid_type, group = covid_type)) +
            geom_point() +
            geom_line() + 
            scale_color_manual(values = c(input$nyt_color_cases, input$nyt_color_deaths)) +
            labs(x = "Date", y = "Total Cumulative Count", title = paste(input$which_state, "Cases and Deaths")) -> myplot ## change size of axis text
        ## Deal with input$y_scale choice
       if (input$y_scale == "log") {
           myplot <- myplot +scale_y_log10()
       }
        ## Deal with input$facet_county
        if(input$facet_county == "Yes") myplot <- myplot +facet_wrap(~county)
         
        ## Deal with input$which_theme choice
        if(input$which_theme == "Classic") myplot <- myplot + theme_classic()
        if(input$which_theme == "Minimal") myplot <- myplot + theme_minimal()
        if(input$which_theme == "Gray") myplot <- myplot + theme_gray()
        if(input$which_theme == "Dark") myplot <- myplot + theme_dark()
        
    ## Return the plot to be plotted
        myplot
         }) 
    
    
    
    
    ## All server logic for JHU goes here ------------------------------------------

    
    ## Define a reactive for subsetting the JHU data
    jhu_data_subset <- reactive({
        jhu_data %>%
            filter(country_or_region == input$which_region) %>%
            mutate(month = lubridate::month((date), label = TRUE)) -> jhu_region
    
        
    })
    
    ## Define your renderPlot({}) for JHU panel that plots the reactive variable. ALL PLOTTING logic goes here.
    output$jhu_plot <- renderPlot({
        jhu_data_subset() %>%
            ggplot(aes(x = date, y = cumulative_number, color = covid_type, group = covid_type)) +
            geom_point() +
            geom_line() +
            scale_color_manual(values = c(input$jhu_color_cases, input$jhu_color_deaths)) +
            labs(x = "Date", y = "Total Cumulative Count") -> my_jhu_plot
        ## Deal with input$loglin choice
        if (input$loglin == "Log") {
            my_jhu_plot <- my_jhu_plot +scale_y_log10()
        }
        
        ## Deal with input$which_themejhu choice
        if(input$which_themejhu == "Classic") my_jhu_plot <- my_jhu_plot + theme_classic()
        if(input$which_themejhu == "Minimal") my_jhu_plot <- my_jhu_plot + theme_minimal()
        if(input$which_themejhu == "Gray") my_jhu_plot <- my_jhu_plot + theme_gray()
        if(input$which_themejhu == "Dark") my_jhu_plot <- my_jhu_plot + theme_dark()
        
        ## Deal with input$month_facet
        if(input$month_facet == "Yes") my_jhu_plot <- my_jhu_plot + facet_wrap(~month)
        
        my_jhu_plot
        
    })
 
}





# Do not touch below this line! ----------------------------------
shinyApp(ui = ui, server = server)
