source('global.R')


shinyServer(function(input, output) {
    
    # First Tab
    output$MapTitle <- renderText({
        if (input$indicator == "Number of Complaints") {
            title = paste("Number of Complaints of ", input$product)
        }
        
        if (input$indicator == "Timely Response Rate") {
            title = paste("Timely Response Rate ", input$product)
        }
        
        if (input$indicator == "Rate of Resolution in Favor of Consumer") {
            title = paste("Rate of Resolution in Favor of Consumer ", input$product)
        }
        
        print(title)
    })
    
    graphdata <- reactive({
        if (input$indicator == "Number of Complaints") {
            ind_data <- mapdata %>%
            filter(date >= input$date_range[1] & date <= input$date_range[2]) %>%
            filter(product == input$product) %>%
            group_by(state) %>%
            summarise(indicator = n())
        }
        
        if (input$indicator == "Timely Response Rate") {
            ind_data <- mapdata %>%
            filter(date >= input$date_range[1] & date <= input$date_range[2]) %>%
            filter(product == input$product) %>%
            group_by(state, timely_response) %>%
            summarise(response = n()) %>%
            spread(timely_response, response) %>%
            mutate(indicator = round((Yes/(No + Yes) * 100),1))
        }
        
        if (input$indicator == "Rate of Resolution in Favor of Consumer") {
            ind_data <- mapdata %>%
            filter(date >= input$date_range[1] & date <= input$date_range[2]) %>%
            filter(product == input$product) %>%
            group_by(state, company_response_to_consumer) %>%
            summarise(resolution = n()) %>%
            spread(company_response_to_consumer, resolution) %>%
            mutate(indicator = round(((`Closed with monetary relief` + `Closed with non-monetary relief`)/
            (`Closed with monetary relief` + `Closed with non-monetary relief` +
            `Closed with explanation`) * 100),1))
        }
        
        
        us_map@data <- left_join(us_map@data, ind_data, by = c("STUSPS" = "state"))
        
        us_map
    })
    
    output$map <- renderLeaflet({
        map <- leaflet() %>%
        setView(-101.04509, 39.08910, zoom = 4)
        map
    })
    
    
    observe({
        req(input$tab_being_displayed == "Geographic Insight")
        classes <- 6
        pal <- colorQuantile("GnBu", NULL, n = classes)
        labs <- quantile_labels(graphdata()[["indicator"]], classes)
        
        popup <- paste0("<strong>StateAbb: </strong>",graphdata()$STUSPS,
        "<br><strong>", input$indicator, ": </strong>",
        graphdata()[["indicator"]])
        
        map <- leafletProxy("map") %>%
        clearShapes() %>%
        clearControls() %>%
        addPolygons(data = graphdata(),
        fillColor = ~pal(graphdata()[["indicator"]]),
        fillOpacity = 0.8,
        color = "white",
        weight = 1,
        popup = popup,
        highlightOptions = highlightOptions(
        color='grey', weight = 3,
        bringToFront = TRUE, sendToBack = TRUE),
        layerId = ~STUSPS,
        label= paste0("State: ",graphdata()$STUSPS, "\n",
        input$indicator, ": ",graphdata()[["indicator"]])) %>%
        leaflet::addLegend(colors = c(RColorBrewer::brewer.pal(classes, "GnBu"), "grey"),
        position = "bottomright",
        bins = classes,
        labels = labs,
        title = paste0(input$indicator))
    })
    
    state <- eventReactive(input$map_shape_click,  {
        x <- input$map_shape_click
        y <- x$id
        y
    })
    
    plotdata <- reactive({
        if (input$indicator == "Number of Complaints") {
            plotdat <- mapdata %>%
            filter(date >= input$date_range[1] & date <= input$date_range[2]) %>%
            filter(state == state()) %>%
            group_by(sub_product) %>%
            summarise(metric = n())
        }
        
        if (input$indicator == "Timely Response Rate") {
            plotdat <- mapdata %>%
            filter(date >= input$date_range[1] & date <= input$date_range[2]) %>%
            filter(state == state()) %>%
            group_by(sub_product, timely_response) %>%
            summarise(response = n()) %>%
            spread(timely_response, response) %>%
            mutate(metric = round((Yes/(No + Yes) * 100),1))
        }
        
        if (input$indicator == "Rate of Resolution in Favor of Consumer") {
            plotdat <- mapdata %>%
            filter(date >= input$date_range[1] & date <= input$date_range[2]) %>%
            filter(state == state()) %>%
            group_by(sub_product, company_response_to_consumer) %>%
            summarise(resolution = n()) %>%
            spread(company_response_to_consumer, resolution) %>%
            mutate(metric = round(((`Closed with monetary relief` + `Closed with non-monetary relief`)/
            (`Closed with monetary relief` + `Closed with non-monetary relief` +
            `Closed with explanation`) * 100),1))
        }
        
        plotdat
    })
    
    output$barplot <- renderPlot({
        ggplot(plotdata(), aes(x = sub_product, y= metric, fill = sub_product)) +
        geom_bar(width = 1, stat = "identity") +
        geom_text(aes(label = plotdata()$metric), size=2,
        vjust = -0.5) +
        theme(axis.text.x=element_text(angle = 90, hjust = 1)) +
        labs(x = "Sub_Product Category", y = input$indicator, title = paste0(input$indicator, " in ",
        state(), " by Sub Product")) +
        theme(plot.title = element_text(hjust = 0.5, size = 20)) +
        guides(fill=FALSE)+
        theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))
    })
    
    
    # Second Tab
    data_selected_product<-reactive({
        treemap1 %>% filter(product%in%input$product1) %>% filter(year%in%input$year1)
    })
    
    output$threemap_count_product <- renderPlot({
        
        par(mar=c(0,0,0,0), xaxs='i', yaxs='i')
        plot(c(0,1), c(0,1),axes=F, col="white")
        vps1 <- baseViewports()
        
        temp1 = data_selected_product()
        .tm <<- treemap(temp1,
        index="product",
        vSize="count",
        vColor="count",
        type="value",
        title = "",
        palette="GnBu",
        border.col ="white",
        position.legend="right",
        fontsize.labels = 16,
        title.legend="")
    })
    
    
    
    
    output$lineplot<- renderPlotly({
        time_line <- ggplot(data = data_selected_product(), aes(x=Month_Yr, y=count, color=product)) +
        geom_point(size=1) +
        geom_line(aes(group = product)) +
        scale_color_brewer(palette = "GnBu") +
        theme(axis.text.x=element_text(angle = 90, hjust = 1)) +
        labs(x = "Month_Year", y = "Number of Complaints") +
        theme(plot.title = element_text(hjust = 0.5, size = 20)) +
        theme(legend.position="none") +
        guides(fill=FALSE)+
        theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))
        
        ggplotly(time_line)
    })
    
    
    
    # Third Tab
    data_selected_company<-reactive({
        treemap2 %>% filter(year%in%input$year2) %>% filter(company%in%input$company)
    })
    
    output$threemap_count_company <- renderPlot({
        
        par(mar=c(0,0,0,0), xaxs='i', yaxs='i')
        plot(c(0,1), c(0,1),axes=F, col="white")
        vps2 <- baseViewports()
        
        temp2 = data_selected_company()
        .tm <<- treemap(temp2,
        index="company",
        vSize="count",
        vColor="count",
        type="value",
        title = "",
        palette="GnBu",
        border.col ="white",
        position.legend="right",
        fontsize.labels = 16,
        title.legend="")
    })
    
    
    
    # Fourth Tab
    output$txtWordcloud <- renderText({
        "Bigram Word Cloud"
    })
    
    output$wordcloud <- renderImage({
        if (input$product_selector == "Student loan") {
            return(list(
            src = "student_loan.png",
            width = 600,
            height = 400
            ))
        }
        else if (input$product_selector == "Credit reporting") {
            return(list(
            src = "credit_reporting.png",
            width = 600,
            height = 400
            ))
        }
    }, deleteFile = FALSE)
    
    
    
    
    # Fifth Tab
    output$txt <- renderText({
        if  (input$Indicator2 == "Number of Complaints")   { title = input$Indicator2  }
        if  (input$Indicator2 == "Timely Response Rate")   { title = input$Indicator2  }
        print (title)
    })
    
    graphissue <- reactive({
        if (input$Indicator2 == "Number of Complaints") { graphdata <- reshaped_number_complaint }
        if (input$Indicator2 == "Timely Response Rate") { graphdata <- reshaped_timely_response }
        i = c()
        if ("Confusing or misleading advertising or marketing" %in% input$Issue) {
            i[length(i)+1] = 2
        }
        if ("Credit monitoring or identity theft protection services" %in% input$Issue) {
            i[length(i)+1] = 3
        }
        if ("Fraud or scam" %in% input$Issue) {
            i[length(i)+1] = 4
        }
        if ("Identity theft protection or other monitoring services" %in% input$Issue) {
            i[length(i)+1] = 5
        }
        if ("Improper use of your report" %in% input$Issue) {
            i[length(i)+1] = 6
        }
        if ("Incorrect information on your report" %in% input$Issue) {
            i[length(i)+1] = 7
        }
        if ("Problem with a company's investigation into an existing issue" %in% input$Issue) {
            i[length(i)+1] = 8
        }
        if ("Problem with a credit reporting company's investigation into an existing problem" %in% input$Issue) {
            i[length(i)+1] = 9
        }
        if ("Problem with customer service" %in% input$Issue) {
            i[length(i)+1] = 10
        }
        if ("Problem with fraud alerts or security freezes" %in% input$Issue) {
            i[length(i)+1] = 11
        }
        if ("Unable to get your credit report or credit score" %in% input$Issue) {
            i[length(i)+1] = 12
        }
        #    firstcol = 1
        #    print(i)
        i = c(1, i)
        #    print(i)
        graphdata = graphdata[, c(i)]
        #    return(data.frame(graphdata))
        
    })
    
    # Graphing data of interest
    output$dchart <- renderGvis({
        gvisLineChart(
        graphissue(), options=list(
        lineWidth=3, pointSize=5,
        vAxis="{title:'Response Metric'}",
        hAxis="{title:'Time'}",
        width=750, height=500))
    })
    
    
    output$sankey_diagram = renderSankeyNetwork({
        links = credit_edglist
        nodes = nodes
        s = sankeyNetwork(Links = links,
        Nodes = nodes,
        Source = "source",
        Target = "target",
        Value = "value",
        NodeID = "name",
        NodeGroup = "name",
        fontSize = 12,
        nodeWidth = 30,
        iterations = 0,
        colourScale = network_color)
        return(s)
    })
    
    
    
    # Sixth Tab
    
    output$txt_loan <- renderText({
        if  (input$Indicator_loan == "Number of Complaints")   { title = input$Indicator_loan  }
        if  (input$Indicator_loan == "Timely Response Rate")   { title = input$Indicator_loan  }
        print(title)
    })
    
    graphissue_loan <- reactive({
        
        
        if (input$Indicator_loan == "Number of Complaints") { graphdata_loan <- reshaped_number_complaint_loan }
        if (input$Indicator_loan == "Timely Response Rate") { graphdata_loan <- reshaped_timely_response_loan }
        t = c()
        if ("Can’t repay my loan" %in% input$Issue_loan) {
            t[length(t)+1] = 2
        }
        if ("Credit monitoring or identity theft protection services" %in% input$Issue_loan) {
            t[length(t)+1] = 3
        }
        if ("Dealing with your lender or servicer" %in% input$Issue_loan) {
            t[length(t)+1] = 4
        }
        if ("Getting a loan" %in% input$Issue_loan) {
            t[length(t)+1] = 5
        }
        if ("Incorrect information on your report" %in% input$Issue_loan) {
            t[length(t)+1] = 6
        }
        if ("Problem with a credit reporting company’s investigation into an existing problem" %in% input$Issue_loan) {
            t[length(t)+1] = 7
        }
        if ("Struggling to repay your loan" %in% input$Issue_loan) {
            t[length(t)+1] = 8
        }
        #    firstcol = 1
        #    print(i)
        t = c(1, t)
        #    print(i)
        graphdata_loan = graphdata_loan[, c(t)]
        #    return(data.frame(graphdata_loan))
        
    })
    
    # Graphing data of interest
    output$dchart_loan <- renderGvis({
        gvisLineChart(
        graphissue_loan(), options=list(
        lineWidth=3, pointSize=5,
        vAxis="{title:'Response Metric'}",
        hAxis="{title:'Time'}",
        width=750, height=500))
    })
    
    
    output$sankey_diagram_2 = renderSankeyNetwork({
        links = student_edglist
        nodes = nodes_1
        s = sankeyNetwork(Links = links,
        Nodes = nodes,
        Source = "source",
        Target = "target",
        Value = "value",
        NodeID = "name",
        NodeGroup = "name",
        fontSize = 12,
        nodeWidth = 30,
        iterations = 0,
        colourScale = network_color_1)
        return(s)
        
    })
    
})
