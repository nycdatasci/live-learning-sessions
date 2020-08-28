library(ggplot2)
library(scales)
library(RColorBrewer)
library(dplyr)
library(lubridate)
library(grid)
library(plotly)

tweets=read.csv('Tweets.csv',stringsAsFactors = F)

bar_data=tweets %>%
  filter(airline_sentiment=='negative') %>% 
  group_by(airline) %>% 
  summarise(n=n()) %>% 
  mutate(perc=n/sum(n)) %>% 
  filter(airline%in%c('American','United')) 

bar_data %>% 
  ggplot(aes(x=airline,fill=airline,y=perc))+
  geom_col()+
  theme(legend.position = 'none',
        axis.title = element_blank(),
        axis.text = element_text(size=13),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "transparent",colour = NA),
        plot.background = element_rect(fill = "transparent",colour = NA))+
  ggtitle('Negative Sentiment of Airlines')+
  geom_text(aes(airline,perc, label = comma(perc)), vjust = 1.5, size = 4.5)+
  scale_fill_brewer(palette = 'Blues')

bar_data %>% 
  ggplot(aes(x=airline,fill=airline,y=perc))+
  geom_col()+
  theme(legend.position = 'none',
        axis.title = element_blank(),
        axis.text = element_text(size=13),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "transparent",colour = NA),
        plot.background = element_rect(fill = "transparent",colour = NA))+
  ggtitle('Negative Sentiment of Airlines')+
  coord_cartesian(ylim = c(.2,.3))+
  geom_text(aes(airline,perc, label = comma(perc)), vjust=-0.5,size = 4.5)+
  scale_fill_brewer(palette = 'Blues')

# waterfall
balance <- data.frame(desc = c("Starting Cash",
                               "Sales", "Refunds", "Payouts", "Court Losses",
                               "Court Wins", "Contracts", "End Cash"), 
                      amount = c(2000,3400, -1100, -100, -6600, 3800, 1400, 2800))
balance$desc <- factor(balance$desc, levels = balance$desc)
balance$id <- seq_along(balance$amount)
balance$type <- ifelse(balance$amount > 0, "in", "out")
balance[balance$desc %in% c("Starting Cash", "End Cash"),"type"] <- "net"
balance$end <- cumsum(balance$amount)
balance$end <- c(head(balance$end, -1), 0)
balance$start <- c(0, head(balance$end, -1))
balance <- balance[, c(3, 1, 4, 6, 5, 2)]
balance$type <- factor(balance$type, levels = c("out","in", "net"))
strwr <- function(str) gsub(" ", "\n", str)

ggplot(balance, aes(x=desc, y=amount,fill = type))+geom_col()+
  scale_y_continuous("") +
  scale_x_discrete("", breaks = levels(balance$desc),
                   labels = strwr(levels(balance$desc))) +
  theme(legend.position = "none",
        axis.ticks = element_blank(),
        axis.text = element_text(size=13),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "transparent",colour = NA),
        plot.background = element_rect(fill = "transparent",colour = NA))+
  geom_text(data = balance, 
            aes(id,amount, label = comma(amount)), 
            vjust = 1, size = 4)+
  ggtitle('Company Cash Position')+
  scale_fill_brewer(palette = 'Blues')

ggplot(balance, aes(fill = type)) + geom_rect(aes(x = desc,
                                                  xmin = id - 0.45, xmax = id + 0.45, ymin = end,ymax = start)) + 
  scale_y_continuous("") +
  scale_x_discrete("", breaks = levels(balance$desc),labels = strwr(levels(balance$desc))) +
  theme(legend.position = "none",
        axis.text = element_text(size=13),
        axis.ticks = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "transparent",colour = NA),
        plot.background = element_rect(fill = "transparent",colour = NA)
  )+
  geom_text(data = subset(balance,type == "in"), 
            aes(id,end, label = comma(amount)), vjust = 1.5, size = 4) +
  geom_text(data = subset(balance,type == "out"), 
            aes(id,end, label = comma(amount)), vjust = -0.5,size = 4) + 
  geom_text(data = subset(balance,type == "net" & id == min(id)), 
            aes(id, end, label = comma(end), 
                vjust = ifelse(end < start, 1.5, -0.3)),vjust=1.5, size = 4) + 
  geom_text(data = subset(balance,type == "net" & id == max(id)), 
            aes(id, start, label = comma(start), 
                vjust = ifelse(end < start, -0.3, 1)), vjust = 1.5,size = 4)+
  ggtitle('Company Cash Position')+
  scale_fill_brewer(palette = 'Blues')

# diamonds
# First simple fix is to zoom in a smaller region
ggplot(diamonds, aes(carat, price, color=cut)) + 
  geom_point() +
  geom_smooth(method="lm") + 
  ylim(0, 20000) + xlim(0, 3.5)

# To highlight the "Fair" class,
# we can combine all the other classes
diamonds %>%
  mutate(is_fair=(cut=="Fair")) %>%
  ggplot(aes(carat, price, color=is_fair)) + 
  geom_point() +
  geom_smooth(method="lm", se=F) +
  ylim(0, 20000) + xlim(0, 3.5)

# Too much overlap of different classes, we can 
# change alpha to make it more clear
diamonds %>%
  mutate(is_fair=(cut=="Fair")) %>%
  ggplot(aes(carat, price, color=is_fair)) + 
  geom_point(alpha=0.1) +
  geom_smooth(method="lm", se=F) +
  ylim(0, 20000) + xlim(0, 3.5)

# Because "Fair" is minority, we might not want to fade 
# its color as much as other kinds of cut.
# Below we see that the fair class is now highlighted,
# but it's too ugly!
diamonds %>%
  mutate(is_fair=(cut=="Fair")) %>%
  ggplot(aes(carat, price, color=is_fair)) + 
  geom_point(
    aes(alpha=is_fair, size=is_fair), 
  ) +
  geom_smooth(method="lm", se=F) +
  ylim(0, 20000) + xlim(0, 3.5)

# Adjust the range of alpha and size to make it better
diamonds %>%
  mutate(is_fair=(cut=="Fair")) %>%
  ggplot(aes(carat, price, color=is_fair)) + 
  geom_point(
    aes(alpha=is_fair, size=is_fair), 
  ) +
  geom_smooth(method="lm", se=F) +
  scale_size_discrete(range = c(0.5, 1.5)) +
  scale_alpha_discrete(range = c(0.05, 0.5)) +
  ylim(0, 20000) + xlim(0, 3.5)

# Supplier Market Share

ms=data.frame(Supplier=c('Supplier A','Supplier B','Supplier C','Supplier D'),
              prop=c(34,31,9,26)) 

mycols=c("#0073C2FF", "#EFC000FF", "#868686FF", "#CD534CFF")

ggplot(ms, aes(x = "", y = prop, fill = Supplier)) +
  geom_bar(width = 1, stat = "identity", color = "white") +
  coord_polar("y", start = 0)+
  # geom_text(aes(label = paste0(prop,'%')), color = "white",
  #           position = position_stack(vjust = 0.5),
  #           size=6)+
  scale_fill_manual(values = mycols) +
  theme_void()+
  ggtitle('Supplier Market Share')

ggplot(ms, aes(x = 2, y = prop, fill = Supplier)) +
  geom_bar(stat = "identity", color = "white") +
  coord_polar(theta = "y", start = 0)+
  geom_text(aes(label = paste0(prop,'%')), color = "white",
            position = position_stack(vjust = 0.5),
            size=6)+
  scale_fill_manual(values = mycols) +
  theme_void()+
  xlim(0.5, 2.5)+
  ggtitle('Supplier Market Share')

v= ms %>% 
  ggplot(aes(x=prop,y=reorder(Supplier,prop),
             fill=Supplier, text=paste0(prop,'%')))+
  geom_col()+
  theme(axis.ticks = element_blank(),
        axis.text.x = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "transparent",colour = NA),
        plot.background = element_rect(fill = "transparent",colour = NA),
        legend.position = 'none'
  )+
  ggtitle('Supplier Market Share')+
  scale_fill_brewer('Diamond\nclarity',direction=-1)+
  geom_text(aes(label = paste0(prop,'%')), 
            position = position_stack(vjust = 0.9),size=6)+
  xlab('')+ylab('')
ggplotly(v,tooltip=c('text'))

economics %>% 
  filter(year(date)%in%c(2005:2010),month(economics$date)==12) %>% 
  mutate(year=year(date)) %>% 
  ggplot()+
  geom_bar(aes(x=year,y=unemploy,fill='PCE'),stat='identity')+
  geom_point(aes(x=year,y=pce*2),color='blue4',size=3)+
  geom_line(aes(x=year,y=pce*2,linetype='# of Unemployees'),color='blue4',size=1)+
  scale_y_continuous(name='Personal Consumption Expenditures',
                     sec.axis = sec_axis(~.*.5, name='# of Unemployees'))+
  scale_fill_manual(name='PCE',values = 'steelblue2')+
  theme(axis.title.x = element_blank(),
        axis.title.y = element_text(color='grey50',size=13),
        axis.ticks.x  = element_blank(),
        axis.ticks.y  = element_line(color='grey50'),
        axis.text = element_text(color = 'grey50',size=13),
        axis.line.y  = element_line(color = 'grey50'),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "transparent",colour = NA),
        plot.background = element_rect(fill = "transparent",colour = NA),
        legend.title = element_blank(),
        legend.text = element_text(size=13,color='grey50'),
        legend.position = 'top')

economics %>% 
  filter(year(date)%in%c(2005:2010),month(economics$date)==12) %>% 
  mutate(year=year(date)) %>% 
  ggplot()+
  geom_bar(aes(x=year,y=unemploy),stat='identity',fill='steelblue2')+
  geom_text(aes(x=year,y=unemploy,label = unemploy), color = "white",
            vjust=1.5,size=4)+
  geom_point(aes(x=year,y=pce*2),color='blue4',size=3)+
  geom_line(aes(x=year,y=pce*2),color='blue4',size=1)+
  geom_text(aes(x=year,y=pce*2,label = pce), color = "blue4",
            vjust=-.5,size=4)+
  scale_y_continuous(name='Personal Consumption Expenditures',
                     sec.axis = sec_axis(~.*.5, name='# of Unemployees'))+
  theme(axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(color = 'grey50',size=13),
        axis.text.y = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "transparent",colour = NA),
        plot.background = element_rect(fill = "transparent",colour = NA)
  )+
  annotation_custom(grobTree(textGrob("# of Unemployees\n(thousand)", x=0.1,  y=0.95, hjust=0.1,
                                      gp=gpar(col="blue4", fontsize=13,fontface='bold'))))+
  annotation_custom(grobTree(textGrob("Personal Consumption\nExpenditures\n(Billions)", 
                                      x=0.1,  y=0.5, hjust=0.1,
                                      gp=gpar(col="steelblue2", fontsize=13,fontface='bold'))))

# bnames
bnames_sub=read.csv('bnames_sub.csv')

bnames_sub %>% 
  ggplot(aes(x=year,y=total,color=sex))+
  geom_point(aes(shape=sex),size=3)+
  geom_line(size=1)+
  ggtitle('# of the Name--Robin from 1930 to 1943')+
  scale_x_continuous(breaks=c(1930:1943))+
  scale_y_continuous(breaks=c(100,150,200,250,300))+
  scale_color_manual(values=c('steelblue1','steelblue4'))+
  theme(
    axis.title = element_blank(),
    axis.text.x = element_text(angle = 45,hjust = 1,size=13),
    axis.text.y = element_text(size=13),
    axis.ticks = element_line(color='grey80'),
    legend.position = 'bottom',
    legend.title = element_blank(),
    legend.text = element_text(size=13),
    panel.background = element_rect(fill='white'),
    panel.border = element_rect(fill = NA,color='grey80'),
    panel.grid.major.y = element_line(color='grey80'),
    panel.grid.major.x = element_blank(),
    plot.title = element_text(color='gray30',size=16),
    plot.background = element_rect(color = 'grey30')
  )

bnames_sub %>% 
  ggplot(aes(x=year,y=total,color=sex))+
  geom_line(size=1)+
  geom_text(aes(x=1943,y=220,label='Number of \nboys',color='boy'),size=4)+
  geom_text(aes(x=1943,y=350,label='Number of \ngirls',color='girl'),size=4)+
  ggtitle('Number of Robin from 1930 to 1943')+
  scale_y_continuous(breaks=c(100,150,200,250,300))+
  scale_color_manual(values=c('steelblue1','steelblue4'))+
  theme(
    axis.line = element_line(color='grey80'),
    axis.title = element_blank(),
    axis.text.x = element_text(angle = 45,hjust = 1,size=13),
    axis.text.y = element_text(size=13),
    axis.ticks = element_line(color='grey80'),
    legend.position = 'none',
    panel.background = element_rect(fill='white'),
    plot.title = element_text(color='gray30',size=16)
  )

# employee feedback
employ_fb=data.frame(year=c(rep(2014,7),rep(2015,7)),
                     category=rep(c('Peers','Culture','Work environment','Leadership',
                                    'Career development','Rewards & recognition','Perf management'),2),
                     percent=c(.85,.8,.76,.59,.49,.41,.33,.91,.96,.75,.62,.33,.45,.42))

ggplot(employ_fb,aes(x=category,y=percent,fill=as.factor(year)))+
  geom_bar(stat='identity',position = 'dodge')+
  scale_fill_manual(name='Year',values = c('gray60','skyblue'))+
  xlab('Survey category')+
  ylab('Percent favorable')+
  ggtitle('Employee feedback over time')+
  theme(
    axis.text.x = element_text(angle = 45,hjust=1,size=15),
    axis.title = element_text(size=16),
    plot.title = element_text(size = 16),
    legend.title = element_text(size=15),
    legend.text = element_text(size=12))


ggplot(employ_fb) + 
  geom_line(aes(x = as.factor(year), y = percent, group = category, color = category), size = 2,color='gray45') + 
  geom_point(aes(x = as.factor(year), y = percent, color = category), size = 5,color='gray45') + 
  geom_point(aes(x = as.factor(2014), y = .49), size = 5,color='orange') + 
  geom_point(aes(x = as.factor(2015), y = .33), size = 5,color='orange') + 
  geom_line(data=subset(employ_fb,category=='Career development'),
            aes(x = as.factor(year), y = percent, group = category), size = 2,color='orange') + 
  theme_minimal(base_size = 18) + 
  geom_text(data = subset(employ_fb, year == 2014&category%in%c('Peers','Culture')), 
            aes(x = as.factor(year), y = percent, 
                label = paste(category,paste0(percent*100,'%'))), color='gray45',size = 5, hjust = 1.2)+
  geom_text(data = subset(employ_fb, year == 2014& !category%in%c('Peers','Culture') ), 
            aes(x = as.factor(year), y = percent, 
                label = paste(category,paste0(percent*100,'%'))), color='gray45',size = 5, hjust = 1.1)+
  geom_text(data = subset(employ_fb, year == 2015 ),
            aes(x = as.factor(year), y = percent,
                label = paste0(percent*100,'%')),
            size = 5, hjust = -.5, vjust = 0.8,color='gray45')+
  xlab('')+
  theme(legend.position = "none", 
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.x = element_blank(), 
        axis.ticks.y = element_blank(),
        axis.ticks.x = element_blank(), 
        axis.title.y = element_blank(), 
        axis.text.y = element_blank(), 
        axis.text.x = element_text(color='gray45',size=15),
        plot.title = element_text(size = 15))+
  annotation_custom(grobTree(textGrob("Survey category | Percent favorable", x=0.1,  y=0.85, hjust=-.1,
                                      gp=gpar(col="gray45", fontsize=15))))+
  ggtitle('Employee feedback over time')



