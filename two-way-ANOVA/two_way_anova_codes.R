library(ggpubr)

# class codes
plantgrowth=data.frame(block=factor(c('block1','block2','block3',
                                      'block1','block2','block3',
                                      'block1','block2','block3')),
                       treatment=factor(c('A','A','A','B','B','B','C','C','C')),
                       growth=c(430,542,287,367,463,253,320,421,207))

summary(aov(growth~treatment,data=plantgrowth))

aov2=aov(growth ~ treatment + block, data = plantgrowth)
summary(aov2)

TukeyHSD(aov(growth ~ treatment + block, data = plantgrowth),which='treatment')


#?ToothGrowth
my_data=ToothGrowth
head(my_data)
str(my_data)

my_data$dose <- factor(my_data$dose, 
                       levels = c(0.5, 1, 2),
                       labels = c("D0.5", "D1", "D2"))
head(my_data)

# generating a frequency table
# this is a balenced design
table(my_data$supp, my_data$dose)

# Visualizing the data
#boxplot
ggboxplot(my_data, x = "dose", y = "len", color = "supp",
          palette = c("#00AFBB", "#E7B800"))

# interaction plot
ggline(my_data, x = "dose", y = "len", color = "supp",
       add = c("mean_se", "dotplot"),
       palette = c("#00AFBB", "#E7B800"))

# Compute two_way ANOVA test balanced design
res.aov2 <- aov(len ~ supp + dose, data = my_data)
summary(res.aov2)

# Two-way ANOVA with interaction effect
# These two calls are equivalent
#res.aov3 <- aov(len ~ supp * dose, data = my_data)
res.aov3 <- aov(len ~ supp + dose + supp*dose, data = my_data)
summary(res.aov3)

# Multiple pairwise-comparison between the means of groups
# We use Tukey's HSD here for equal size in each group
# Other methods include: Bonferroni, Scheffe, LSD and so forth may be used
TukeyHSD(res.aov3, which = "dose")

#install.packages('multcomp')
#library(multcomp)
#summary(glht(res.aov2, linfct = mcp(dose = "Tukey")))

# Check assumptions
# Check the homogeneity of variance assumption
plot(res.aov3,1)
library(car)
leveneTest(len ~ supp*dose, data = my_data)

#Check the normality assumption
plot(res.aov3, 2)

# Compute two-way ANOVA test in R for unbalanced designs
my_anova <- aov(len ~ supp * dose, data = my_data)
Anova(my_anova, type = "III")








