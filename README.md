# Football_Transfer_Market_Analysis_2022
Analysis of the effect of Barclays Premiere League on club football.

# Introduction
The football summer transfer market promised to be as exciting as ever. With leading clubs like Manchester United and Paris Saint Germain having newly appointed managers, 
Barcelona having been given a huge financial lift, Chelsea having undergone a change in ownership, and other top clubs also looking to strengthen their squads, it became 
evident that the upcoming transfer window would be a very busy one. The estimated spend for the transfer window exceeded £6 billion for all of the clubs in Europe's top 
five leagues. However, a huge proportion of the spending was done by the Premier League clubs alone. This is not a surprise as each of the clubs earns a hefty 100-150 
million pounds from TV rights alone. Therefore, the following study analyses the effect of the previously mentioned TV rights deal on the money spent by English clubs 
compared to other European clubs. We will also discuss other elements that factor into determining a player's transfer value.

# Objectives
The question to be answered is how the money spent by Premier League clubs compares to the money spent by Europe’s other top leagues. This begs the question have the 
lucrative sponsorships and various broadcasting deals made the Premier League a Super League? There is also a need to realize that the spending of prestigious clubs 
in Europe is not just random. Instead, it is done after analysing various parameters such as age and position played by scouted players. The first task is to create 
a clean and operable dataset using various data preparation and cleaning techniques. The next task is to create multiple imputations for the missing data, by means of 
a linear model function. The penultimate task is to visualize graphically the relation between money spent by the Premier League clubs and the rest of Europe’s top five 
league clubs. Graphs and tables are used in addition to illustrate how the money spent is influenced by various factors. Lastly, the shortcomings of the study must be 
acknowledged.

# Data
The data that is used for this analysis is the Kaggle dataset of the football summer transfer market in 2022. This dataset has various columns like date of transfer, 
name of the player, market and transfer value of the player, and several other columns necessary for the analysis. The market value column is really interesting as it
is predicted by various analysts based on the player’s age, position played, and a number of other factors. In an ideal scenario, the market value of a player would be 
similar to their transfer value. However, there are a few factors the analysts can't predict, such as human emotion, which make a player's transfer value slightly 
different from their market value.
It was necessary to perform a few operations on the existing dataset to convert it into a tidy dataset. Firstly, the market value and transfer value of the provided 
dataset were in the “character” class, with the value being in either thousands or millions format. This was changed into numeric form for all sets of players. 
The next step was to add a column called "relative_position" that will be relative to the current column "positions" of our dataset. This will be useful when we 
analyze the data. Similar to the previous step, we are preparing to add an "age-group" column which will help us better analyse and represent data in tabular form. 
Below is a table depicting the number of players transferred based on newly formed columns “relative_positions” and “age-group”.

# Conclusion
Through the results of the survey, we are able to show how Premier League clubs outspend clubs from other leagues. It is no secret that even the so-called mid-sized 
English clubs spend more than other top European clubs. We have also shown that the money spent isn't random and there are rationales for the spending. Generally, clubs 
tend to overspend on players with a predicted future yield or players who can make a significant difference on their own.
Due to these facts the Premier League is referred to as the Super League, nearly every team can spend a small fortune on players they would like. As the overall 
quality of football keeps improving, the league will become more and more prominent than other European leagues.
As the quality keeps rising, there will be more and more people deciding to watch the Premier League. Therefore, Premier League clubs will have more money to spend. 
We cannot assure that the English clubs will dominate the European Competition, but a regular football fan would only want to watch one League Competition at a time. 
And even more significantly, an average footballer would want to play in the Premier League only.

# Dataset Link
https://www.kaggle.com/datasets/mohamedsiika/football-transfer-window-from-july-to-september












