source('global.R')

shinyUI(
navbarPage(

title = "Consumer Complanits of Financial Products in U.S.",
theme = shinytheme("cerulean"),
id = "tab_being_displayed",


tabPanel("Welcome",
mainPanel(
div(style = "margin-left:15%;",
br(),
br(),
h3(strong("Welcome to the Consumer Complaints Analysis Shiny App"),
style = "margin-top:0"),
br(),
h4(strong("Reaserch Question")),
br(),
p("This app provides the visualization of Consumer Complaint Database collected by CFPB, which contains complaints on a range of financial products and servicer. We aim to provide public with a clear view of the complaints situation in the U.S. and provide some references for related organization to strengthen the supervision of products and companies that are most complainted. To reach this goal, we explore the number of complaints, timely respsonse rate according to different dimensions and try to find further information behind the products and companies with problems."),
br(),
h4(strong("About CFPB")),
p("The Consumer Financial Protection Bureau (CFPB) regulates the offering and provision of consumer financial products or services under the federal consumer financial laws and educates and empowers consumers to make better informed financial decisions."),
br(),
h4(strong("About Consumer Complaint Database")),
p("Each week thousands of consumers’ complaints about financial products and services were sent to companies for response. Those complaints are published here after the company responds or after 15 days, whichever comes first. In this analysis, we look into data from 2016 January to 2019 March."),
br(),
h4(strong("Data Source and code")),
p("The data was obtained from",
a("Consumer Financial Protection Bureau.",
href="http://www.consumerfinance.gov/data-research/consumer-complaints/"), ". All of our code for cleaning the data and developing this app can be found from",
a("here", href = "https://github.com/qmss-gr5063-2019/Group_E_US-Consumer-Finance-Complaints") ),
br(),
h4(strong("Authors")),
p("Wanying Wang (ww2502@columbia.edu), Yue Ma (ym2704@columbia.edu), Xiaohan Zhou (xz2762@columbia.edu), and Yuye Mao (ym2703@columbia.edu)."),
br()

))),


# First Tab
tabPanel("Geographic Insight",
sidebarLayout(
sidebarPanel(h3("Graph Note:"), style = "width:400px",
helpText("This graph helps user to have a general view of the consumer
complaints of different financial products across each state in the US. It
displays three key indicators by product. Hover over each state to get
detailed information and a more detailed graph with sub product information by
clicking on the state."),
br(),
selectInput('product', h4('Select Product:'),
c("Debt collection", "Checking or savings account",
"Credit card or prepaid card", "Credit reporting",
"Money transfer, virtual currency, or money service",
"Mortgage", "Student loan",
"Payday loan, title loan, or personal loan" ),
selected = 'Credit reporting'),
dateRangeInput("date_range", h4('Select Date Range:'),
start = "2016-01-01", end = "2019-04-01",
min = "2016-01-01", max = "2019-04-30",
format = "yyyy-mm-dd", separator = " to "),
radioButtons("indicator", h4('Indicator:'),
c("Number of Complaints", "Timely Response Rate",
"Rate of Resolution in Favor of Consumer"),
selected = "Number of Complaints")),
mainPanel(style="position:relative",
tags$head(
tags$style(HTML(".leaflet-container { background: #fff; }"))
),
h3(textOutput("MapTitle"), style="margin:20px; margin-left:150px"),
leafletOutput("map"),
plotOutput("barplot", width="800px", height="600px"),
p("From the January 2016 to March 2019, CFPB has received 307,744 consumer complaints in total across the country. During these 3 years, the average population is 300 million across the country. That is to say, nearly 1 out of every 135 people in the united states have complaints."),
br(),
p("Generally, from the choropleth map we can find that more densely populated states tend to have more number of volumes, for instance, New York, Pennsylvania, California, etc. However, the map also tells that though most of the states have pretty high timely response rate, there are some states having low rate of resolution in favor of consumer, including New Mexico, Missouri, Mississippi, etc. In other words, many companies in those states does not accept the complaints. There are three ways for companies to reply to the complaints: close with monetary or non-monetary relief, close with explanation. If closed with relief, that means companies accept the complaints but if close only with explanation, that means companies think the complaints are not reasonable. According to an analysis of Deloitte, this trend indicates that many complaints in these states may be the result of customer misunderstanding instead of actual mistakes from financial companies. As a result, it is a good idea for companies to provide better communication with customers to help them better understand the products or services, manage consumer expectations as well as improve consumer satisfacton."),
br(),
p("From the barplot of sub-product, which appears after clicking on states, we can find that the complaints are mostly from credit reporting, however, high rates of resolution in favor of customers are mostly from sub-products related to card issues. So, we should put more focus on the credit reporting to see why there are so many complaints about it."),
br()
)
)

),

# Second Tab
tabPanel("Product Insight",
sidebarLayout(
sidebarPanel(h3("Graph Note:"), style = "width:300px",
helpText("This page displays the volume comparison and time trend of complaints
of each product. User can add the company and choose the year to get more
informaion."),
br(),
selectizeInput("product1", h4("Select Product:"),
choices = c("Checking or savings account",
"Credit card or prepaid card",
"Credit reporting",
"Money transfer, virtual currency, or money service",
"Mortgage",
"Payday loan, title loan, or personal loan",
"Student loan"),
selected = c("Checking or savings account",
"Credit card or prepaid card",
"Credit reporting",
"Money transfer, virtual currency, or money service",
"Mortgage",
"Payday loan, title loan, or personal loan",
"Student loan"),
multiple=TRUE),
selectizeInput("year1", h4("Select Year:"),
choices = c("2016", "2017", "2018", "2019"),
selected =  c("2016", "2017", "2018", "2019"),
multiple=TRUE)
),
mainPanel(
h3("Financial Product Complaint Counts by Product",
style="text-align:center;font-size:200%"),
plotOutput("threemap_count_product",height="400px"),
br(),
h3("Time Trend of Number of Complaints by Product",
style="text-align:center;font-size:200%"),
br(),
plotlyOutput("lineplot", width="800px", height="600px"),
p("This treemap displays the share of complaints of each product. We can find that credit reporting has the biggest propotion in terms of number of complaints across the four years. Seeing from line graph, we can find that credit reporting has a drastic increase in October 2017 while student loan has a rapid increase in January 2017."),
br()
)
)
),


# Third Tab
tabPanel("Company Insight",
sidebarLayout(
sidebarPanel(h3("Graph Note:"), style = "width:300px",
helpText("This graph displays the volume comparison of complaints of each
company."),
br(),
selectizeInput("company", h4("Select Company:"),
choices = list('top 5' =
list("EQUIFAX, INC.",
"Experian Information Solutions Inc.",
"TRANSUNION INTERMEDIATE HOLDINGS, INC.",
"Navient Solutions, LLC.",
"CITIBANK, N.A."),
'top 6-10' =
list("WELLS FARGO & COMPANY",
"JPMORGAN CHASE & CO.",
"BANK OF AMERICA, NATIONAL ASSOCIATION",
"CAPITAL ONE FINANCIAL CORPORATION",
"SYNCHRONY FINANCIAL"),
'top 11-15' = list("SYNCHRONY FINANCIAL",
"AMERICAN EXPRESS COMPANY",
"AES/PHEAA",
"PORTFOLIO RECOVERY ASSOCIATES INC",
"OCWEN LOAN SERVICING LLC",
"NATIONSTAR MORTGAGE")),
selected = c("EQUIFAX, INC.",
"Experian Information Solutions Inc.",
"TRANSUNION INTERMEDIATE HOLDINGS, INC.",
"WELLS FARGO & COMPANY",
"JPMORGAN CHASE & CO.",
"BANK OF AMERICA, NATIONAL ASSOCIATION",
"CAPITAL ONE FINANCIAL CORPORATION",
"Navient Solutions, LLC."),
multiple=TRUE),
selectizeInput("year2", h4("Select Year:"),
choices = c("2016", "2017", "2018", "2019"),
selected =  c("2016", "2017", "2018", "2019"),
multiple=TRUE)
),
mainPanel(
h3("Financial Product Complaint Counts by Company",
style="text-align:center;font-size:200%"),
plotOutput("threemap_count_company",height="400px"),
br(),
p("Seeing from this graph, we can find that EQUIFAX, Experian Information Solutions and
Transunion Intermediate Holdings are the top three companies who have most complaints.
EQUIFAX took a leading position since 2016, but Transunion Intermediate Holdings surpassed it
in 2019. Having done some research about these three companies, we found that they are the big
three credit reporting agencies across the country."),
br(),
p("As for the fourth company, we found that it is a company whose main product is student loan.
Therefore, combining the previous analysis, we decided to focus on credit reporting and student
loan, because they show distinguish patterns of number of complaint, time trend and related
companies complaint sources.")
)
)
),



# Fourth Tab
tabPanel("Complaint narrative analysis",
sidebarLayout(
sidebarPanel(h3("Graph note:"), style = "width:300px",
helpText("This page displays the wordcloud of th most frequent bigram words used in the
complaints the companies received. Select the specific product and get the
most frequent words in narratives."),
br(),
selectInput("product_selector", h4("Select Product:"),
choices = productlist,
selected = "Credit reporting")
),
mainPanel(h3(textOutput("txtWordcloud"), align = "center"),
imageOutput('wordcloud'),
br(),
p("According to our previous analysis, we want to explore the detailed complaints content
of credit reporting and student loan these two products. The wordcloud of credit
reporting tells that customers mainly complain about credit organization, report
agency, file and score, theft and late payment."),
br(),
p("The wordcloud of student loan tells that the main complaints are about month payment,
repay plan and something related to their credit reporting. Therefore, these
information should draw more attention of departments concerned, improve the service
and strenthen the supervision.")
)
)),


# Fifth Tab
tabPanel("Case Study I: Credit Reporting",
sidebarLayout(
sidebarPanel(h3("Graph note:"), style = "width:300px",
helpText("This page displays the time trend of the issues of Credit reporting
product and several main company sources of complaints.
Select the specific issue to compare the trend in the numer of
complaints and timely response rate over time."),
radioButtons("Indicator2",
h4("Indicator:"),
choices = c("Number of Complaints", "Timely Response Rate"),
selected = "Number of Complaints"),
checkboxGroupInput("Issue",
h4("Issue of Credit reporting product:"),
choices = issue_name, selected = c("Improper use of your report", "Credit monitoring or identity theft protection services", "Problem with fraud alerts or security freezes"))
),
mainPanel(h3(textOutput("txt"), align = "center"),
htmlOutput("dchart", height = "450", width = "500", align = "center"),
br(),
p("From the previous analysis of all products, we can conclude that the product - Credit reporting received the most complaints through 2016 to 2019. Meantime, there is a dramatical increase for the volume of complaints received from August, 2017 to October, 2017. This section explores the time trend in issues of Credit reporting product, and figures out the insights behind the rocket increasing. There are 9 issues of Credit reporting in total. The plot above indicates clearly that the 3 issues, including “Improper use of the report”, “Credit monitoring or identity theft protection services”, “Problem with fraud alerts or security freezes”, have a increase during August , 2017 and October, 2017. The most significant finding is that the issue - “Improper use of the report” contributed most to the rocket increasing of Credit reporting product, with an increase of more than 300%. The volume of complaints of other 6 issues remained stable during the analytical period."),
br(),
p("As for the timely response rate for different issues, most are more than 60%, however, there is a response problem with issue - “Fraud or scam”. From the end of 2017 to the beginning of 2018, consumers with “Fraud or scam” issues often received delayed responses from companies, with timely response rate only of 45%. The timely response rate for issue - “Improper use of the report” also had a decreasing from the end of 2017 to the beginning of 2018, but remained above 90%. Maybe this decreasing of timely response is due to the rocket increasing volume of complaints."),
br(),
h3("Sankey Network: Company with Credit reporting",
style="text-align:center;font-size:200%"),
sankeyNetworkOutput("sankey_diagram", height = "450", width = "500"),
p("In this network, the wider the edge is, the more complaints for this companies. We
can easily find that the top three companies have much more complaints than other
companies who provide this kind of product and service."))
)
),


# Sixth Tab
tabPanel("Case Study II: Student Loan",
sidebarLayout(
sidebarPanel(h3("Graph note:"), style = "width:300px",
helpText("This page displays the time trend of the issues of Student loan product and several main
company sources of complaints.Select the specific issue to compare the trend in the numer of
complaints and timely response rate over time."),
radioButtons("Indicator_loan",
h4("Indicator:"),
choices = c("Number of Complaints", "Timely Response Rate"),
selected = "Number of Complaints"),
checkboxGroupInput("Issue_loan",
h4("Issue of Student loan product:"),
choices = issue_name_loan, selected = c("Dealing with your lender or servicer",
"Getting a loan",
"Struggling to repay your loan"))),
mainPanel(h3(textOutput("txt_loan"), align = "center"),
htmlOutput("dchart_loan", height = "450", width = "500", align = "center"),
p("This plot explores the time trend in issues of Student loan product, and figures out the insights behind the increasing in early 2017. There are 5 issues of Student loan in total. The plot above indicates clearly that the issue - Dealing with your lender or servicer, has a increase from late 2016 to early 2017, with more than 200% increasing. This trend clearly showed that the most severe problem of Student loan is the problem with lender or sevicer. Other issues did not receive too much complaints during the past 3 years."),
br(),
h3("Sankey Network: Company with Student Loan",
style="text-align:center;font-size:200%"),
sankeyNetworkOutput("sankey_diagram_2", height = "450", width = "500"),
p("From this network, we can easily find that Navient Solutions has way more complaints
than other companies in this field. This may indicate monopoly to some extent and should
be supervised more closely.")))
),


# Conclusion Tab
tabPanel("Conclusion",
mainPanel(
div(style = "margin-left:15%;",
br(),
br(),
br(),
h4(strong("Geographic insights")),
p("From the January 2016 to March 2019, we have seen consumer complaints increasing year by year across the country. The complaints were not evenly distributed across the country. Generally, more densely populated states tend to have more number of volumes, for instance, New York, Pennsylvania, California, etc. Some states had great timely response rate but low rate of resolution in favor of consumer, including New Mexico, Missouri, Mississippi, etc. The trend indicates that many complaints in these states may be the result of customer misunderstanding instead of actual mistakes from financial companies. Better communication between the financial institutions and consumers may help."),
br(),
h4(strong("Product insights")),
p("For 2016, Mortgage and Credit reporting were the top two financial product complaints sources. Since 2017, the proportion of mortgage dropped and Credit Reporting took the largest proportion among all. We could also find a drastic increase of student loan in Jan 2017. So it is urgent to regulate the market of credit reproting and student loan, meantime, related departments should focus more on improvement of education on financial products for students in order to protect their rights better."),
br(),
h4(strong("Company insights")),
p("The big three credit reporting agencies, EQUIFAX, Experian Information Solutions and Transunion Intermediate Holdings, were the top three complaint sources through the 3 years from 2016 to 2019. Especially, we could see a drastic increase for Navient Solutions on exactly the same time student loan increases. More strict supervison on these companies may help."),
br(),
h4(strong("Case study I: Credit reporting")),
p("There are 9 issues of Credit reporting in total. The 3 issues, including “Improper use of the report”, “Credit monitoring or identity theft protection services”, “Problem with fraud alerts or security freezes”, had an increase during August and October, 2017. The most significant finding was that the issue - “Improper use of the report” contributed most to the rocket increasing of Credit reporting product, with an increase of more than 300%. The volume of complaints of other 6 issues remained stable during the analytical period. So financial institutions should focus more on resolution of improper use of the report to reduce the consumer complaints."),
br(),
h4(strong("Case study II: Student Loan")),
p("Student loan product had a dramatic increase from late 2016 to early 2017. There are 5 issues of Student loan in total. The issue - Dealing with your lender or servicer, has a dramatic increase from late 2016 to early 2017, with more than 200% increasing, which contributed most to the increasing of Student loan product. Other issues did not receive too much complaints during the past 3 years. So financial institutions should focus more on resolutions to problems with lender or servicer"),
br(),
h4(strong("Moving forward")),
p("We hope our dashboard can identify trends and problems in the financial marketplace to help public have a better understanding of the situation of financial products complaint and help the bureau or other departments concerned do a better job supervising companies, enforcing federal consumer financial laws and writing rules and regulations. While the Consumer Complaint Database may identify some problems or risk for financial institutions, it also presents opportunities. We hope that our results can help the companies look more closely at CFPB consumer complaint data, and the processes that impact their customer experience so that they can better address their regulatory compliance responsibilities and simultaneously elevate their customer experience and operational effectiveness.")

)))
))
