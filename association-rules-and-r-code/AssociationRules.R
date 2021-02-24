###########################################################
###########################################################
#####[13] Association Rules & Naïve Bayes Lecture Code#####
###########################################################
###########################################################



#####################################
#####Tools for Association Rules#####
#####################################
#Attempting to read the groceries data in the original way.
not.useful = read.csv("Groceries.csv", header = FALSE)
head(not.useful)
View(not.useful)

#Two different problems arise:
#- Splitting our data into chunks of 4 because of the first row of our dataset;
#  what about when we have transactions with more than 4 items?
#- Creating features that not only include the items that were purchased,
#  but also the artificial order in which they were purchased. Technically,
#  there is no order to a basket of items, just whether or not the items were
#  included in the transaction.

#Instead, let's create a sparse matrix. The different items will represent the
#columns and the rows will represent the transactions; essentially we are
#creating an indicator variable for each available item. The resulting matrices
#will be quite large; under the hood, the sparse matrix that we are creating
#using the read.transactions() function is only actually storing the 1's among
#the millions of cells.

#Load the Association Rules library and store the groceries data in a sparse
#matrix.
library(arules)
groceries = read.transactions("Groceries.csv", sep = ",")

#Inspecting the groceries object we just created.
groceries
class(groceries)
dim(groceries)
colnames(groceries)
rownames(groceries)

#Gathering summary information for the groceries object we just created.
summary(groceries)

#Inspecting the distribution of transaction size.
size(groceries)
hist(size(groceries))

#Using the inspect() function to look at the actual contents of the sparse
#matrix. In particular, looking at each tranasction.
inspect(groceries[1:10])

#Using the itemFrequency() function to look at the actual contents of the sparse
#matrix. In particular, looking at each item.
itemFrequency(groceries[, 1:5], type = "relative") #Default
itemFrequency(groceries[, 1:5], type = "absolute")

#Using the itemFrequencyPlot() function to visualize item frequencies.
itemFrequencyPlot(groceries)
itemFrequencyPlot(groceries, support = 0.1)
itemFrequencyPlot(groceries, topN = 20)

#Visualizing the binary relationship among transactions and items.
set.seed(0)
image(sample(groceries, 100))

#Using the apriori() function to look for association rules using the Apriori
#algorithm.
apriori(groceries,
        parameter = list(support = .1,     #Default minimum support.
                         confidence = .8,  #Default minimum confidence.
                         minlen = 1,       #Default minimum set size.
                         maxlen = 10))     #Default maximum set size.

#Creating some rules by lowering the support and confidence.
groceryrules = apriori(groceries,
                       parameter = list(support = 0.006,
                                        confidence = 0.25,
                                        minlen = 2))

#Investigating summary information about the rule object.
groceryrules
class(groceryrules)
summary(groceryrules)

#Inspecting specific information about rules.
inspect(groceryrules[1:5])

#Sorting the rules by various metrics.
inspect(sort(groceryrules, by = "support")[1:5])
inspect(sort(groceryrules, by = "confidence")[1:5])
inspect(sort(groceryrules, by = "lift")[1:5])

#Finding subsets of rules based on a particular item.
berryrules = subset(groceryrules, items %in% "berries")
inspect(berryrules)

herbrules = subset(groceryrules, items %in% "herbs")
inspect(herbrules)
