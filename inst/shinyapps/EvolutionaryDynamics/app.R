############################################################
#This is the Shiny file for the Evolutionary Dynamics App
#written by Andreas Handel, with contributions from others 
#maintained by Andreas Handel (ahandel@uga.edu)
#last updated 7/13/2017
############################################################


#the main function with all the functionality for the server
#this function is wrapped inside the shiny server function below to allow return to main menu when window is closed
refresh <- function(input, output){

    res <- reactive({
    input$submitBtn
    
    # Read all the input values from the UI
    S0 = isolate(input$S0);
    Iu0 = isolate(input$Iu0);
    It0 = isolate(input$It0);
    Ir0 = isolate(input$Ir0);
    tmax = isolate(input$tmax);

    bu = isolate(input$bu);
    bt = isolate(input$bt);
    br = isolate(input$br);

    cu = isolate(input$cu);
    ct = isolate(input$ct);

    f = isolate(input$f);
    
    gu = isolate(input$gu);
    gt = isolate(input$gt);
    gr = isolate(input$gr);
    
    nreps = isolate(input$nreps)

    # Call the adaptivetau simulator with the given parameters
    # simulation will be run multiple times based on value of nreps
    #result is returned as list
    result <- list()
    for (nn in 1:nreps)
    {
     result[[nn]] <- simulate_evolution(S0 = S0, Iu0 = Iu0, It0 = It0, Ir0 = Ir0, tmax = tmax, bu = bu, bt = bt, br = br, cu = cu, ct = ct, f = f, gu = gu, gt = gt, gr = gr)
    }
    
    return(result)
    })
    
    #function that takes result saved in res and produces output
    #output (plots, text, warnings) is stored in and modifies the global variable output
    generate_simoutput(input,output,res)
    
} #ends inner shiny server function that runs the simulation and returns output


server <- function(input, output, session) {

  # Waits for the Exit Button to be pressed to stop the app server
  observeEvent(input$exitBtn, {
    input$exitBtn
    stopApp(returnValue = 0)
  })

  # This function is called to refresh the content of the UI
  refresh(input, output)

  # Event handler to listen for the webpage and see when it closes.
  # Right after the window is closed, it will stop the app server and the main menu will
  # continue asking for inputs.
  session$onSessionEnded(function(){
    stopApp(returnValue = 0)
  })

} #ends main/outer shiny server function


#This is the UI for the Stochastic Dynamics App
ui <- fluidPage(
  includeCSS("../styles/dsaide.css"),
  
  #add header and title
   
  div( includeHTML("www/header.html"), align = "center"),
  h1('Evolutionary Dynamics App', align = "center", style = "background-color:#123c66; color:#fff"),
  
  #start section to add buttons
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
  
  ################################
  #Split screen with input on left, output on right
  fluidRow(
    #all the inputs in here
    column(6,
           #################################
           # Inputs section
           h2('Simulation Settings'),
           fluidRow(
             column(4,
                    numericInput("S0", "initial number of susceptible hosts (S0)", min = 100, max = 3000, value = 1000, step = 50)
             ),
             column(4,
                    numericInput("Iu0", "initial number of untreated wild-type infected hosts (Iu0)", min = 0, max = 100, value = 1, step = 1)
             ),
             column(4,
                    numericInput("tmax", "Maximum simulation time (tmax)", min = 1, max = 1200, value = 100, step = 1)
             )
           ), #close fluidRow structure for input
           fluidRow(
             column(4,
                    numericInput("It0", "initial number of treated wild-type infected hosts (It0)", min = 0, max = 100, value = 0, step = 1)
             ),
             column(4,
                    numericInput("Ir0", "initial number of resistant infected hosts (Ir0)", min = 0, max = 100, value = 0, step = 1)
             ),
             column(4,
                    numericInput("bu", "Rate of transmission of untreated wild-type hosts (bu)", min = 0, max = 0.02, value = 0.001, step = 0.0001  )
             )
           ), #close fluidRow structure for input
           fluidRow(
             column(4,
                    numericInput("bt", "Rate of transmission of treated wild-type hosts (bt)", min = 0, max = 0.02, value = 0, step = 0.0001  )
             ),
             column(4,
                    numericInput("br", "Rate of transmission of resistant hosts (br)", min = 0, max = 0.02, value = 0, step = 0.0001  )
             ),
             column(4,
                    numericInput("cu", "Fraction of resistant generation by untreated hosts (cu)", min = 0, max = 0.5, value = 0.0, step = 0.005 )
             )
           ), #close fluidRow structure for input
           
           fluidRow(
             column(4,
                    numericInput("ct", "Fraction of resistant generation by treated hosts (ct)", min = 0, max = 0.5, value = 0.0, step = 0.005 )
             ),
             column(4,
                    numericInput("gu", "Rate at which untreated hosts leave compartment (gu)", min = 0, max = 5, value = 0.5, step = 0.05)
             ),
             column(4,
                    numericInput("gt", "Rate at which treated hosts leave compartment (gt)", min = 0, max = 5, value = 0.5, step = 0.05)
             )
           ), #close fluidRow structure for input
           fluidRow(
             column(4,
                    numericInput("gr", "Rate at which resistant hosts leave compartment (gr)", min = 0, max = 5, value = 0.5, step = 0.1)
             ),
             column(4,
                    numericInput("f", "Fraction of infected receiving treatment (f)", min = 0, max = 1, value = 0.0, step = 0.05)
             ),
             column(4,
                         numericInput("nreps", "Number of simulations", min = 1, max = 50, value = 1, step = 1)
              )
            ) #close fluidRow structure for input
           
    ), #end sidebar column for inputs
    
    #all the outcomes here
    column(6,
           
           #################################
           #Start with results on top
           h2('Simulation Results'),
           plotOutput(outputId = "plot", height = "500px"),
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
  #Instructions section at bottom as tabs
  h2('Instructions'),
  #use external function to generate all tabs with instruction content
  do.call(tabsetPanel,generate_instruction_tabs()),
  div(includeHTML("www/footer.html"), align="center", style="font-size:small") #footer
) #end fluidpage

shinyApp(ui = ui, server = server)

