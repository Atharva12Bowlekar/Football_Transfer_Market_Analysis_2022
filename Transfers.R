#importing libraries
library(dplyr)
library(stringr)
library(ggplot2)
library(lme4)
library(tidyverse)
library(RColorBrewer)

#importing dataset
df = read.csv('Summer_transfer_window_2022.csv')
col_names = colnames(df)

#Getting the transfers that took place in the top 5 leagues
top_5_df=select(filter(df,
                       (from_league=='premier-league' & from_country=='England')| 
                       (to_league=='premier-league' & to_country=="England")|
                       (from_league=='serie-a' & from_country=='Italy')| 
                       (to_league=='serie-a' & to_country=="Italy")|
                       (from_league=='bundesliga' & from_country=='Germany')| 
                       (to_league=='bundesliga' & to_country=="Germany")|
                       (from_league=='ligue-1' & from_country=='France')| 
                       (to_league=='ligue-1' & to_country=="France")|
                       (from_league=='laliga' & from_country=='Spain')| 
                       (to_league=='laliga' & to_country=="Spain")),
                       col_names)


#Removing not needed columns
top_5_df <- top_5_df %>% 
  select(-c(1, 2))

#Functions to make changes in columns
rep_value <- function(x){
  if(substr(x,1,1)=="€")
  {
    n = nchar(x)
    if(substr(x,n,n)=="m")
    {
      return(as.numeric(substr(x,2,n-1))*1000)
    }
    else{
      return(as.numeric(substr(x,2,n-3)))
    }
  }
}

pos_change <- function(x){
  if(x == "Left-Back" | x == "Centre-Back" | 
     x == "Right-Back")
  {
    return("Defender")
  }
  else if(x == "Central Midfield" | x == "Defensive Midfield" | 
          x == "Attacking Midfield" | x == "Left Midfield" |
          x == "Right Midfield")
  {
    return("Midfielder")
  }
  else if(x == "Left Winger" | x == "Centre-Forward" | 
          x == "Right Winger" | x == "Second Striker")
  {
    return("Attacker")
  }
  else
  {
    return("Goalkeeper")
  }
}

age_group <- function(x) {
  if(x <= 21){
    return("17-21")
  }
  else if(x<=26){
    return("22-26")
  }
  else if(x<=31){
    return("27-31")
  }
  else if(x<=36){
    return("32-36")
  }
  else{
    return("Above 36")
  }
}

#Applying the functions
top_5_df$market_value = sapply(top_5_df$market_value, rep_value)
top_5_df$transfer_value = sapply(top_5_df$transfer_value, rep_value)
top_5_df$relative_positions = sapply(top_5_df$positions, pos_change)
top_5_df$age_group = sapply(top_5_df$age, age_group)

#table
xtabs(~relative_positions+age_group, top_5_df)

#Separating NA Values from Non-Na Values
na_df = top_5_df[top_5_df$transfer_value=="NULL",]


na_df <- na_df %>% 
  select(-c(13))

top_5_df = top_5_df[!(top_5_df$transfer_value=="NULL"),]

#list to numeric for dataset column
top_5_df = transform(top_5_df, transfer_value = as.numeric(transfer_value))

#correlation between market and transfer
cor(top_5_df$market_value,top_5_df$transfer_value)


####Multiple Imputation for Missing Values
#1st Imputation
Imp1 = lm(transfer_value~market_value, top_5_df)

ggplot(aes(x=market_value, y=transfer_value), 
       data = top_5_df) + 
  geom_point() +
  stat_smooth(method = "lm") +
  labs(x="Market Value", 
       y="Transfer Value",
       title = "Transfer Value vs Market Value")

#2nd Imputation
Imp2 = lm(log(transfer_value)~log(market_value), top_5_df)

ggplot(aes(x=log(market_value), y=log(transfer_value)),
       data = top_5_df) + 
  geom_point()+
  stat_smooth(method = "lm") +
  labs(x="Market Value In Logarithmic Form", 
       y="Transfer Value In Logarithmic Form",
       title = "Transfer Value vs Market Value")


#3rd Imputation

Imp3 = lm(log(transfer_value)~age +log(market_value), top_5_df)

ggplot(aes(x=log(market_value), y=log(transfer_value),color=age), 
       data = top_5_df) + 
  geom_point() +
  stat_smooth(method = "lm") + 
  labs(x="Market Value In Logarithmic Form", 
       y="Transfer Value In Logarithmic Form",
       col="Age",
       title = "Transfer Value vs Market Value by Age.")

#4th Imputation
Imp4 = lm(log(transfer_value)~positions +log(market_value), top_5_df)

ggplot(aes(x=log(market_value), y=log(transfer_value),color=positions), 
       data = top_5_df) + 
  geom_point() +
  stat_smooth(method = "lm",se=F) +
  labs(x="Market Value In Logarithmic Form", 
       y="Transfer Value In Logarithmic Form",
       col="Positions",
       title = "Transfer Value vs Market Value by every position.")


#5th Imputations  
Imp5 = lm(log(transfer_value)~relative_positions +log(market_value), top_5_df)

ggplot(aes(x=log(market_value), y=log(transfer_value),color=relative_positions), 
       data = top_5_df) + 
  geom_point() +
  stat_smooth(method = "lm",se=F) +
  labs(x="Market Value In Logarithmic Form", 
       y="Transfer Value In Logarithmic Form",
       col="Relative Positions",
       title = "Transfer Value vs Market Value by type of player.")

  
#predicting na_values based on model 3
na_df$transfer_value <- exp(predict(Imp3, newdata = na_df))

#merging na and non-na dfs
top_5_df = rbind(top_5_df,na_df)

#converting values in millions
top_5_df$market_value = top_5_df$market_value/1000
top_5_df$transfer_value = top_5_df$transfer_value/1000


# For Showing PL vs Rest of the leagues
sum_Top_5 = top_5_df %>%
  filter(to_league=='premier-league'|to_league=='bundesliga'|
         to_league=='serie-a'|to_league=='ligue-1'|
         to_league=='laliga') %>%
  group_by(to_league) %>%
  summarise(total = sum(transfer_value))

#pie - chart showing share of pl clubs total spent
pie(x=sum_Top_5$total,labels = c("Bundesliga","LaLiga","Ligue-1",
                              "Premier League","Serie-A"), 
                              col = c("red","blue","orange","green","yellow"), 
    main = "Share of Transfer Market for Top 5 Leagues")

######Premier League
#Filtering on players that joined the Premier League
prem_df = select(filter(top_5_df, 
                        (to_league=="premier-league") & 
                        (to_country=="England")),
                        colnames(top_5_df))

#counting the number of signings done by each club
count_prem_df = prem_df %>%
                    count(to_club)

#Plotting the above df
ggplot(aes(x=reorder(to_club,n),y=n,fill=to_club), data = count_prem_df) +
  geom_bar(stat="identity")+
  coord_flip() +
  xlab("Club") +
  ylab("Number of Signings") + 
  title("Number of Signings by a Club") +
  labs(x="Club", 
       y="Number of Signings",
       title = "Number of Signings by a Club")+ 
  theme(legend.position = "none") 

#Filtering out clubs which spent more than 100 million
prem_df_clubs = prem_df %>%
  group_by(to_club)  %>%
  summarise(total_spend = sum(transfer_value), league = 'PL') %>%
  data.frame() %>%
  arrange(desc(total_spend))  %>%
  filter(total_spend>100)

prem_df_clubs$total_spend = sapply(prem_df_clubs$total_spend,round)


######LaLiga
##Filtering on players that joined the LaLiga


la_liga_df = select(filter(top_5_df, 
                        (to_league=="laliga") & 
                          (to_country=="Spain")),
                 colnames(top_5_df))

#counting the number of signings done by each club
count_la_liga_df = la_liga_df %>%
  count(to_club)

#Plotting the above df
ggplot(aes(x=reorder(to_club,n),y=n,fill=to_club), data = count_la_liga_df) +
  geom_bar(stat="identity")+
  coord_flip() + 
  theme(legend.position = "none") 

#Filtering out clubs which spent more than 100 million
la_liga_df_clubs = la_liga_df %>%
  group_by(to_club)  %>%
  summarise(total_spend = sum(transfer_value), league = 'LaLiga') %>%
  data.frame() %>%
  arrange(desc(total_spend))  %>%
  filter(total_spend>100)

la_liga_df_clubs$total_spend = sapply(la_liga_df_clubs$total_spend,round)

####Bundesliga
#Filtering on players that joined the BundesLiga


bd_liga_df = select(filter(top_5_df, 
                           (to_league=="bundesliga") & 
                             (to_country=="Germany")),
                    colnames(top_5_df))

#counting the number of signings done by each club
count_bd_liga_df = bd_liga_df %>%
  count(to_club)

#Plotting the above df
ggplot(aes(x=reorder(to_club,n),y=n,fill=to_club), data = count_bd_liga_df) +
  geom_bar(stat="identity")+
  coord_flip() + 
  theme(legend.position = "none") 

#Filtering out clubs which spent more than 100 million
bd_liga_df_clubs = bd_liga_df %>%
  group_by(to_club)  %>%
  summarise(total_spend = sum(transfer_value), league = 'BdLiga') %>%
  data.frame() %>%
  arrange(desc(total_spend))  %>%
  filter(total_spend>100)

bd_liga_df_clubs$total_spend = sapply(bd_liga_df_clubs$total_spend,round)


#######Serie-a
#Filtering on players that joined the Serie-A

serie_a_df = select(filter(top_5_df, 
                           (to_league=="serie-a") & 
                             (to_country=="Italy")),
                    colnames(top_5_df))

#counting the number of signings done by each club
count_serie_a_df = serie_a_df %>%
  count(to_club)

#Plotting the above df
ggplot(aes(x=reorder(to_club,n),y=n,fill=to_club), data = count_serie_a_df) +
  geom_bar(stat="identity")+
  coord_flip() + 
  theme(legend.position = "none") 

#Filtering out clubs which spent more than 100 million
serie_a_df_clubs = serie_a_df %>%
  group_by(to_club)  %>%
  summarise(total_spend = sum(transfer_value), league = 'Serie-A') %>%
  data.frame() %>%
  arrange(desc(total_spend))  %>%
  filter(total_spend>100)

serie_a_df_clubs$total_spend = sapply(serie_a_df_clubs$total_spend,round)

#####Ligue-1
# Filtering on players that joined the Ligue-1

ligue_1_df = select(filter(top_5_df, 
                           (to_league=="ligue-1") & 
                             (to_country=="France")),
                    colnames(top_5_df))

#counting the number of signings done by each club
count_ligue_1_df = ligue_1_df %>%
  count(to_club)

#Plotting the above df
ggplot(aes(x=reorder(to_club,n),y=n,fill=to_club), data = count_ligue_1_df) +
  geom_bar(stat="identity")+
  coord_flip() + 
  theme(legend.position = "none") 

#Filtering out clubs which spent more than 100 million
ligue_1_df_clubs = ligue_1_df %>%
  group_by(to_club)  %>%
  summarise(total_spend = sum(transfer_value), league = 'Ligue-1') %>%
  data.frame() %>%
  arrange(desc(total_spend))  %>%
  filter(total_spend>100)

ligue_1_df_clubs$total_spend = sapply(ligue_1_df_clubs$total_spend,round)


#clubs with 100m+ spend
final_df = rbind(prem_df_clubs,
                 la_liga_df_clubs,
                 bd_liga_df_clubs,
                 serie_a_df_clubs,
                 ligue_1_df_clubs)

#plotting above df
ggplot(aes(x=reorder(to_club,total_spend),y=total_spend,fill=league), data = final_df) +
  geom_bar(stat="identity")+
  coord_flip() +
  xlab("Club") +
  ylab("Number of Signings") + 
  guides(fill=guide_legend(title="League")) +
  title("Number of Signings by a Club") +
  labs(x="Club", 
       y="Amount Spent in Millions(Pounds)",
       title = "Clubs that spent more than 100 Million") +
  scale_color_brewer(palette="Dark2")



# Filtering by transfer value and then comparing with age
high_t_v_df=select(filter(top_5_df, transfer_value>20.00),colnames(top_5_df))

ggplot(aes(x=log(transfer_value), y=log(market_value), col = age), data = top_5_df) + 
  geom_point() +
  stat_smooth(method = "lm")+
  guides(fill=guide_legend(title="Age")) +
  labs(x="Transfer Value in Log Form", 
       y="Market Value in Log Form",
       title = "Plot between Transfer and Market Value with Age", col="Age")

#table for players within age_group
high_t_v_df %>% group_by(age_group) %>% tally()

# Spread of Transfer value per position
boxplot(transfer_value~relative_positions, data=high_t_v_df, notch=T,
        col=(c("gold")),
        ylab="Transfer Value", xlab="Position Played", 
        main = "Box Plot between Position and Transfer Value") 

#Table number of players per position 
high_t_v_df %>% group_by(relative_positions) %>% tally()


#Hypothesis Testing
mid_df = select(filter(high_t_v_df,
                       relative_positions=="Midfielder"),
                colnames(high_t_v_df))

def_df = select(filter(high_t_v_df, 
                       relative_positions=="Defender"), 
                colnames(high_t_v_df))

#Analysing the spread of midfielders and defenders
ggplot(data = high_t_v_df, aes(x=relative_positions,y=transfer_value)) +
  geom_point(colour = 'blue', size = 5) +
  xlab("Position") +
  ylab("Transfer Value") +
  ggtitle("Transfer Value based on Positions")

res = t.test(def_df$transfer_value,mid_df$transfer_value,
             alternative = "greater",p.value=0.05,conf.int=0.95)

#p-value, estimate and confidence interval for t-test
p_value = res$p.value
estimate = res$estimate
conf_int = res$conf.int


  





















