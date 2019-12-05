## Introduction to R - Part II

## This file contains all of the same code that is contained in the Markdown
## version of the guide. This document serves to demonstrate how a regular R
## script looks and how to run code in this format.


# Loading the packages and data as shown on the previous guide 
# "Introduction to R". 

packages.to.load <- c("plyr", "dplyr" ,"DT", "ggplot2", "plotly", "RODBC")

invisible(lapply(packages.to.load, library, character.only=TRUE))


load("C:/Users/shregmi/Documents/Current Projects/R Training/Example Datasets/Auto.rda")

write.csv(Auto, file="Autodata.csv")

auto.data <- read.csv(file ="C:/Users/shregmi/Documents/Current Projects/R Training/Autodata.csv"
                      , header = TRUE)


#Manipulating Data

# This section will cover a couple ways to shape data into something that is 
# easy to work with.

##Using the $ operator

#For very simple filters and selection of certain columns from a data frame, you
# can use the $ operator. Here, we take one column from our auto.data data frame
# and assign it to a new object. You can use the class() function to see what 
# kind of object it is.

JustMPG <- matrix(auto.data$mpg)

class(JustMPG)

# We can also pull multiple columns pretty easily.
MPGandWeight <- data.frame(auto.data$mpg, auto.data$weight)
head(MPGandWeight)


##dplyr

# The package dplyr is a heavily used library for data cleaning and preparation 
# (one of R's main strong suits). Here is a little cheat sheet covering some 
# dplyr and tidyr features: 
# https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf

# The official dplyr documentation can also be found here:
# https://cran.r-project.org/web/packages/dplyr/dplyr.pdf


#There are 5 main functions or "verbs" used in dplyr: Select, Filter, Mutate, 
# Arrange, and Summarize. Many of these align with the main SQL commands: 
# Select, Where, Group By, etc...


###Select

# Let's take a subset of columns from the auto.data dataset.
auto.subset <- select(auto.data, name, mpg, cylinders, weight)

head(auto.subset)

# We can also specify which columns to exclude using the "-" operator.

auto.subset2 <- select(auto.data, -horsepower, -year)
head(auto.subset2)


###Filter
# After selecting your data of interest, you can pass filters in the same way as
# you would a "where" clause in SQL.

only.4cyl <- filter(auto.subset, cylinders==4)
head(only.4cyl)

# You can add multiple arguments to the filter function.

multi.filter <- filter(auto.subset, cylinders %in% c(4,6), weight<3000)
head(multi.filter)

# We can filter strings as well.

filter.name <- filter(auto.subset, cylinders==4, weight<2000, 
                      grepl("toyota|volkswagen", name))
head(filter.name)


###Mutate
# Using mutate, we can create new columns. Additionally, we can chain the 
# previous "verbs" together using the "%>%" operator (called pipe operator).
# Note that the dplyr package must be loaded in order to use this operator.

add.col <- auto.data %>%
  select(name, mpg, cylinders, weight) %>%
  filter(weight>1800) %>%
  mutate(weightpercyl <- weight/cylinders)

head(add.col)


###Arrange
# This is equivalent to an "order by" statement in SQL. Here, we sort the 
# previous output by "weightpercyl" in descending order using the "-" operator. 

add.col.sorted <- auto.data %>%
  select(name, mpg, cylinders, weight) %>%
  filter(weight>1800) %>%
  mutate(weightpercyl = weight/cylinders) %>%
  arrange(-weightpercyl)

head(add.col.sorted)


###Summarize


summarized.auto <- auto.data %>%
  select(name, mpg, cylinders, weight) %>%
  filter(weight>1800) %>%
  mutate(weightpercyl = weight/cylinders) %>%
  summarise(avg_mpg = mean(mpg),
            min_weight = min(weight),
            median_weightpercyl = median(weightpercyl))

summarized.auto

# We can pass a group_by() clause as well.

summarized.auto2 <- auto.data %>%
  select(name, mpg, cylinders, weight) %>%
  filter(weight>1800) %>%
  mutate(weightpercyl = weight/cylinders) %>%
  group_by(cylinders) %>%
  summarise(avg_mpg = mean(mpg),
            avg_weight = mean(weight),
            avg_weightpercyl = mean(weightpercyl))

summarized.auto2


#Visualization

# This section will cover a few useful packages and methods for visualization in 
# an R Markdown document. 


  ##Displaying Tables in R Markdown
  
# When using print() or head() functions to show the contents of a data frame, 
# the output looks very ugly. There are a huge number of packages that are 
# specifically for displaying tables in an aesthetically pleasing way. The "DT" 
# or Data Tables package is one of them.

datatable(auto.data)

# This is the default way to display a data frame with this package with no 
# arguments provided except for the object that is to be shown.

# There are a huge number of arguments you can add to make your reports look 
# nicer and to add functionality. BONUS: You'll also write the smallest piece of
# JavaScript code in this as well. 

datatable(auto.data, extensions = 'Buttons', options = list(
dom = 'Bfrtip', 
buttons= c('copy', 'excel'),
pageLength = 5,
initComplete = JS("
function(settings, json) {
$(this.api().table().header()).css({
'background-color': '#232D69',
'color': '#fff'
});
}")
), rownames = FALSE)





##Charts with Plotly

# Cheat sheet for plotly: 
# https://images.plot.ly/plotly-documentation/images/r_cheat_sheet.pdf. 

# Another great resource: https://plot.ly/r/ 

plot <- plot_ly(x = auto.data$weight, type="histogram")
plot

# In plotly, you can add multiple sets of traces or bars to the same plot with 
# the use of pipe operators. You can also name each of the traces/bars so that 
# the result is clear. 

plot2 <- plot_ly(data =auto.data, alpha = 0.5) %>% #adjusting color transparency 
add_histogram(x = auto.data$weight[auto.data$origin == 1], name="American") %>%
add_histogram(x = auto.data$weight[auto.data$origin == 2], name="European") %>%
add_histogram(x = auto.data$weight[auto.data$origin == 3], name="Japanese") %>%
layout(barmode = "overlay")

plot2

# Here is an example of a scatterplot generated by plotly. This has many more 
# features and much more functionality than the plot we first generated with the
# R Base plot() function. 

auto.data$OriginName[which(auto.data$origin == 1)]  = "American"
auto.data$OriginName[which(auto.data$origin == 2)]  = "European"
auto.data$OriginName[which(auto.data$origin == 3)]  = "Japanese"


plot3 <- plot_ly(data = auto.data
                 ,x = ~weight
                 ,y = ~mpg
                 ,color = ~OriginName
                 ,type ="scatter"
                 ,mode="markers"
                 ,text= ~paste("Car name: ", name 
                               ,"</br> Year: ", year
                               ,"</br> Cylinders: ", cylinders))

plot3

##Charts with ggplot2

#Cheat sheet for ggplot2: https://www.rstudio.com/wp-content/uploads/2015/03/ggplot2-cheatsheet.pdf 



