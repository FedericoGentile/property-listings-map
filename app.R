library(shiny)
library(dplyr)
library(ggplot2)
library(leaflet)
library(shinythemes)

# Load your dataset here
house_data <- read.csv("houses.csv", sep = ";")

# Filter for available properties
available_properties <- house_data %>%
  filter(Status == "Available") %>%
  group_by(Item_Name) %>%
  arrange(desc(Date)) %>%
  slice(1) %>%
  ungroup()

ui <- fluidPage(
  theme = shinytheme("superhero"),
  titlePanel("Property Listings Map"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("region", "Region", choices = unique(available_properties$Region), multiple = TRUE),
      selectInput("object", "Object", choices = unique(available_properties$Object)),
      selectInput("action", "Action", choices = unique(available_properties$Action)),
      selectInput("mapTile", "Map Style", choices = c("OpenStreetMap" = providers$OpenStreetMap.Mapnik, "Positron" = providers$CartoDB.Positron, "Orthofoto" = providers$BasemapAT.orthofoto)),
      
      sliderInput("price", "Price (EUR)", 
                  min = min(available_properties$Price_EUR, na.rm = TRUE), 
                  max = max(available_properties$Price_EUR, na.rm = TRUE), 
                  value = c(min(available_properties$Price_EUR, na.rm = TRUE), max(available_properties$Price_EUR, na.rm = TRUE))),
      
      sliderInput("size", "Size (m2)", 
                  min = min(available_properties$Size_m2, na.rm = TRUE), 
                  max = max(available_properties$Size_m2, na.rm = TRUE), 
                  value = c(min(available_properties$Size_m2, na.rm = TRUE), max(available_properties$Size_m2, na.rm = TRUE))),
      
      checkboxGroupInput("rooms", "Rooms", choices = c("1", "2", "3", "4", "5", "6+"), selected = c("1", "2", "3", "4", "5", "6+"))
    ),
    
    mainPanel(
      fluidRow(
        column(8, 
               leafletOutput("map", height = "85vh")  # Map with adjusted height
        ),
        column(4,
               div(style = "overflow-y: scroll; max-height: 85vh;",  # Scrollable div with max height
                   uiOutput("houseDetails"),  # Output for displaying house details
                   br(),
                   plotOutput("pricePlot", height = "250px")  # Adjusted height for the plot
               )
        )
      )
    )
  )
)


server <- function(input, output, session) {
  
  # Reactive expression for filtered data
  filteredData <- reactive({
    house_data %>%
      filter(Status == "Available",
             Region %in% input$region,
             Object == input$object,
             Action == input$action)
  })
  
  # Observe changes and update price slider
  observe({
    data <- filteredData()
    updateSliderInput(session, "price",
                      min = min(data$Price_EUR, na.rm = TRUE),
                      max = max(data$Price_EUR, na.rm = TRUE),
                      value = c(min(data$Price_EUR, na.rm = TRUE), max(data$Price_EUR, na.rm = TRUE)))
  })
  
  # Observe changes and update size slider
  output$map <- renderLeaflet({
    data <- filteredData() %>%
      filter(Price_EUR >= input$price[1], Price_EUR <= input$price[2],
             Size_m2 >= input$size[1], Size_m2 <= input$size[2],
             Rooms %in% input$rooms)
    
    # Create a color palette
    pal <- colorNumeric(palette = "YlOrRd", domain = data$Price_EUR)
    
    # Create a map and add colored markers
    leaflet(data) %>%
      addProviderTiles(input$mapTile) %>%
      addCircleMarkers(~Longitude_n, ~Latitude_n, 
                       color = ~pal(Price_EUR), 
                       popup = ~as.character(Item_Name),
                       radius = 1, 
                       layerId = ~Item_Name) %>%
      addLegend("bottomright", pal = pal, values = ~Price_EUR,
                title = "Price (EUR)",
                labFormat = labelFormat(prefix = "€"))
  })
  
  # Reactive value to store the clicked house's details
  clickedHouse <- reactiveVal(NULL)
  
  # Reactive expression for data of the selected house
  selectedHouseData <- reactive({
    req(clickedHouse())  # Ensure that clickedHouse is not NULL
    house_link <- clickedHouse()$Page_Link
    data <- house_data %>%
      filter(Page_Link == house_link)
    
    # Convert Date to Date format if necessary
    data$Date <- as.Date(data$Date)
    
    # Ensure Price_EUR is numeric
    data$Price_EUR <- as.numeric(data$Price_EUR)
    
    data
  })
  
  output$pricePlot <- renderPlot({
    data <- selectedHouseData()
    ggplot(data, aes(x = Date, y = Price_EUR)) +
      geom_line(color = "green", size = 1.5) +  # Thicker line in white color
      theme_minimal() +
      theme(
        plot.background = element_rect(fill = "#4f5c6c"),  # Replace with the desired color
        text = element_text(color = "white"),  # White text
        panel.background = element_rect(fill = "#4f5c6c"),  # Same background color as plot.background
        axis.text = element_text(color = "white"),  # White axis text
        axis.title = element_text(color = "white")  # White axis titles
      ) +
      labs(x = "Date", y = "Price (EUR)")
  })
  
  
  observeEvent(input$map_marker_click, {
    click <- input$map_marker_click
    data <- available_properties
    clickedHouse(data[data$Item_Name == click$id, ])
  })
  
  output$houseDetails <- renderUI({
    house <- clickedHouse()[1, ]
    if (is.null(house)) {
      return()
    }
    
    # Generate a UI for displaying house details
    tagList(
      h3(strong(house$Item_Name)),
      tags$a(href = house$Page_Link, target = "_blank", tags$img(src = house$Image_URL, width = "100%", alt = "House Image")),
      br(),br(),
      p(strong("Price:"), house$Price),
      p(strong("Size:"), house$Size),
      p(strong("Rooms:"), house$Number_of_Rooms),
      p(strong("Address:"), house$Address),
      p(strong("Seller:"), house$Seller),
      p(strong("Tags:"), house$Tags),
    )
  })
  
}


shinyApp(ui = ui, server = server)
