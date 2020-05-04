#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(tidyverse)
library(lubridate)
library(shiny)
library(DT)
load("parametric_wind_res_comp_2019_data_20200207.RData")
# load("~/Documents/RES_calculations_data/parametric_wind_res_comp_2019_data_20200207.RData")

res_list_default <- calculate_parametric_costs(res_df_2019)
default_coefs <- list(kupst_tol_level = 0.1,kupst_penalty_level = 0.03,ptf_tol_level = 0.03, imb_extra_penalty = 0.03, dsg_absorb = 0)

# Define UI for application that draws a histogram
ui <- fluidPage(

   # Application title
   titlePanel("Rüzgar Santralleri Destekler ve Bedeller Net Maliyet Analizi"),

   # Sidebar with a slider input for number of bins
   sidebarLayout(
      sidebarPanel(
         selectInput(inputId = "pp_name",label="Santral",choices = c("Hepsi",sort(res_df_2019_map$pp_name))),
         numericInput(inputId = "in_kupst_tol_level",label = "KÜPST Tolerans",value=default_coefs$kupst_tol_level,min=0,max=1,step = 0.05),
         numericInput(inputId = "in_kupst_penalty_level",label = "KÜPST Bedel Katsayısı",value=default_coefs$kupst_penalty_level,min=0,max=0.25,step = 0.01),
         numericInput(inputId = "in_ptf_tol_level",label = "Dengesizlik PTF Tolerans (1-j katsayısı)",value=default_coefs$ptf_tol_level,min=0,max=0.25,step = 0.01),
         numericInput(inputId = "in_imb_extra_penalty",label = "Dengesizlik Maliyet Katsayısı",value=default_coefs$imb_extra_penalty,min=0,max=0.25,step = 0.01),
         numericInput(inputId = "in_dsg_absorb",label = "DSG Dengesizlik Sönümleme Oranı",value=default_coefs$dsg_absorb,min=0,max=1,step = 0.05),
         actionButton(inputId = "action_calculate",label = "Hesapla",icon = icon("bolt"),width="100%",class="btn btn-primary")
      ),

      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("result_plot"),
         DTOutput("result_dt")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  observeEvent(input$action_calculate,{

    res_list <- calculate_parametric_costs(
      res_df_2019,
      kupst_tol_level = input$in_kupst_tol_level,
      kupst_penalty_level = input$in_kupst_penalty_level,
      ptf_tol_level = input$in_ptf_tol_level,
      imb_extra_penalty = input$in_imb_extra_penalty)

    summary_df <- res_list$level_summary_df

    def_summary_df <- res_list_default$level_summary_df

    if(input$pp_name != "Hepsi"){
      selected_pp_id <- res_df_2019_map %>% filter(pp_name == input$pp_name) %>% select(pp_id) %>% unlist()

      summary_df <- summary_df %>% filter(pp_id == selected_pp_id)
      def_summary_df <- def_summary_df %>% filter(pp_id == selected_pp_id)
    }

    summary_df <- summary_df %>%
      summarise(kupst = sum(sum_kupst),imb= sum(sum_imb),tol=sum(sum_tol),prod=sum(sum_prod)) %>%
      mutate_at(vars(kupst:tol),list(unit=~(./prod)))

    def_summary_df <- def_summary_df %>%
      summarise(kupst = sum(sum_kupst),imb= sum(sum_imb),tol=sum(sum_tol),prod=sum(sum_prod)) %>%
      mutate_at(vars(kupst:tol),list(unit=~(./prod)))

    comp_df <-
      bind_rows(
        def_summary_df %>%
          mutate(tol=-tol) %>%
          select(kupst:tol) %>%
          mutate(net = kupst + imb + tol) %>%
          rename(`KÜPST` = kupst,`Dengesizlik Maliyeti`=imb,`PTF Tolerans`=tol,`Net Maliyet`=net) %>%
          gather(key,value) %>% mutate(Durum = "Gerçekleşen"),
      summary_df %>% mutate(tol=-tol, imb = (1-input$in_dsg_absorb)*imb) %>% select(kupst:tol) %>% mutate(net = kupst + imb + tol) %>% rename(`KÜPST` = kupst,`Dengesizlik Maliyeti`=imb,`PTF Tolerans`=tol,`Net Maliyet`=net) %>% gather(key,value) %>% mutate(Durum = "Senaryo"))

    output$result_plot <- renderPlot({

      comp_df %>%
        ggplot(.,aes(x=factor(key,levels=c("KÜPST","Dengesizlik Maliyeti","PTF Tolerans","Net Maliyet")),y=value/1000,fill=Durum,group=Durum)) + geom_bar(stat = "identity",position = "dodge") + theme_minimal() +
        theme(legend.position = "top") + labs(x=NULL,y="x1000 TL",title=paste0(input$pp_name),subtitle=paste0(" Toplam Üretim: ",summary_df$prod, "MWh"))

    })

    output$result_dt <- renderDT({
      datatable(comp_df %>% spread(key,value) %>% select(Durum,`Net Maliyet`,everything()),options = list(dom = 't')) %>% formatCurrency(c("KÜPST","Dengesizlik Maliyeti","PTF Tolerans","Net Maliyet"),currency = "TL",digits=0)
    })

  },ignoreNULL = FALSE)


}

# Run the application
shinyApp(ui = ui, server = server)
