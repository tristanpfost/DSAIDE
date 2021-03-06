############################################################
#This is the Shiny file for the Environmental Transmission App
#written by Andreas Handel, with contributions from others 
#maintained by Andreas Handel (ahandel@uga.edu)
#last updated 7/13/2017
############################################################

#the server-side function with the main functionality
#this function is wrapped inside the shiny server function below to allow return to main menu when window is closed
refresh <- function(input, output){
  
  # This reactive takes the input data and sends it over to the simulator
  # Then it will get the results back and return it as the "res" variable
  res <- reactive({
    input$submitBtn
    
    # Read all the input values from the UI
    S0 = isolate(input$S0);
    I0 = isolate(input$I0);
    E0 = isolate(input$E0);
    tmax = isolate(input$tmax);
    g  = isolate(input$g);
    bd = isolate(input$bd);
    be = isolate(input$be);
    m  = isolate(input$m);
    n  = isolate(input$n);
    c  = isolate(input$c);
    p  = isolate(input$p);
    
    
    # Call the ODE solver with the given parameters
    result <- simulate_environmentaltransmission(S = S0, I = I0, E = E0, tmax = tmax, bd = bd, be = be, m = m, n = n, g = g, p = p, c = c)
    
    return(list(result)) #this is returned as the res variable
  })
  
  #if we want certain variables plotted and reported separately, we can specify them manually as a list
  #if nothing is specified, all variables are plotted and reported at once
  varlist = list(c("S","I","R"), c("E"))
  #function that takes result saved in res and produces output
  #output (plots, text, warnings) is stored in and modifies the global variable 'output'
  generate_simoutput(input,output,res,varlist=varlist)
} #ends the 'refresh' shiny server function that runs the simulation and returns output

#main shiny server function
server <- function(input, output, session) {
  
  # Waits for the Exit Button to be pressed to stop the app and return to main menu
  observeEvent(input$exitBtn, {
    input$exitBtn
    stopApp(returnValue = 0)
  })
  
  # This function is called to refresh the content of the Shiny App
  refresh(input, output)
  
  # Event handler to listen for the webpage and see when it closes.
  # Right after the window is closed, it will stop the app server and the main menu will
  # continue asking for inputs.
  session$onSessionEnded(function(){
    stopApp(returnValue = 0)
  })
} #ends the main shiny server function


#This is the UI part of the shiny App
ui <- fluidPage(
  includeCSS("../styles/dsaide.css"),
  
   
  
  div( includeHTML("www/header.html"), align = "center"),
  h1('Environmental Transmission App', align = "center", style = "background-color:#123c66; color:#fff"),
  
  #section to add buttons
  fluidRow(
    column(6,
           actionButton("submitBtn", "Run Simulation", class="submitbutton")  
    ),
    column(6,
           actionButton("exitBtn", "Exit App", class="exitbutton")
    ),
    align = "center"
  ), #end section to add buttons
  
  tags$hr(),
  
  
  #################################
  #Split screen with input on left, output on right
  fluidRow(
    #all the inputs in here
    column(6,
           #################################
           # Inputs section
           h2('Simulation Settings'),
           fluidRow(
             column(6,
                    numericInput("S0", "initial number of susceptible hosts (S0)", min = 1000, max = 5000, value = 1000, step = 500)
             ),
             column(6,
                    numericInput("I0", "initial number of infected hosts (I0)", min = 0, max = 50, value = 0, step = 1)
             )
           ), #close fluidRow structure for input
           fluidRow(
             column(6,
                    numericInput("E0", "initial amount of environmental pathogen (E0)", min = 0, max = 100, value = 0, step = 1)
             ),
             column(6,
                    numericInput("tmax", "Maximum simulation time (tmax)", min = 1, max = 500, value = 100, step = 1)
             )
           ), #close fluidRow structure for input
           fluidRow(
             column(6,
                    numericInput("bd", "direct transmission rate (bD)", min = 0, max = 0.01, value = 0, step = 0.0001  )
             ),
             column(6,
                    numericInput("be", "environmental transmission rate (bE)", min = 0, max = 0.01, value = 0, step = 0.0001  )
             )
           ), #close fluidRow structure for input
           fluidRow(
             column(6,
                    numericInput("p", "Rate of pathogen shedding by infected hosts (p)", min = 0, max = 50, value = 1, step = 0.1)
             ),
             column(6,
                    numericInput("c", "Rate of environmental pathogen decay (c) ", min = 0, max = 10, value = 0, step = 0.01  )
             )
           ), #close fluidRow structure for input
           fluidRow(
             column(4,
                    numericInput("g", "Rate of recovery of infected hosts (g)", min = 0, max = 2, value = 0.5, step = 0.1)
             ),
             column(4,
                    numericInput("m", "Rate of new births (m)", min = 0, max = 100, value = 0, step = 1)
             ),
             column(4,
                    numericInput("n", "Natural death rate (n)", min = 0, max = 0.02, value = 0, step = 0.0005 )
             )
           ) #close fluidRow structure for input
    ), #end sidebar column for inputs
    
    #all the outcomes here
    column(6,
           
           #################################
           #Start with results on top
           h2('Simulation Results'),
           plotOutput(outputId = "plot"),
           # PLaceholder for results of type text
           htmlOutput(outputId = "text"),
           #Placeholder for any possible warning or error messages (this will be shown in red)
           htmlOutput(outputId = "warn"),
           
           tags$head(tags$style("#warn{color: red;
                                font-style: italic;
                                }")),
           tags$hr()
           
           ) #end main panel column with outcomes
  ), #end layout with side and main panel
  #################################
  #Ends the 2 column structure with inputs on left and outputs on right
  
  
  
  #################################
  #Instructions section at bottom as tabs
  h2('Instructions'),
  
  #use external function to generate all tabs with instruction content
  do.call(tabsetPanel,generate_instruction_tabs()),
  
  div(includeHTML("www/footer.html"), align="center", style="font-size:small") #footer
) #end fluidpage



shinyApp(ui = ui, server = server)