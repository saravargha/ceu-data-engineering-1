## Data Engineering 1 - Term project 2 report (Bogota)

Team members:

- Péter Kaiser
- Rauhan Nazir
- Sára Vargha
- Xibei Chen

### Introduction

------

The aim of the term project was to collect data on a selected topic, formulate a couple of analytics questions and build a Knime workflow to answer those questions (including analytical methods and visualization). As all team members shared interest in movies, we decided to look for a suitable dataset on films and conduct an analysis on the relationship between the success of different movies - measured by the number of awards won and the box office revenue - and various economic factors, such as the government expenditure on education or the population of cultural employment. 

Although we have discussed several analytical questions, in the end we narrowed down our analysis to the following four questions:

1. Which genres are the top 5 in terms of average number of awards won and IMDb ratings?
2. What is the relationship between number of awards won and IMDb ratings?
3. What is the relationship between the box office revenue of a movie and the GDP per capita, expenditure on education and population of cultural employment of its country of origin?
4. What is the relationship between the number of awards won by a movie and the GDP per capita, expenditure on education and population of cultural employment of its country of origin?

### Data sources

------

For the sake of the term project, data have been collected from the following sources:

1. [**Movies on Netflix, Prime Videos, Hulu and Disney+ dataset from Kaggle**](https://www.kaggle.com/ruchi798/movies-on-netflix-prime-video-hulu-and-disney)

   To get comprehensive information on movies, we downloaded a dataset from Kaggle including scraped data on movies available on the major streaming platforms (Netflix, Prime Videos, Hulu, Disney+).  The dataset provides information on title, genre, year of production, origin, language, runtime, ratings and availability on streaming platforms of 9,515 films and was last updated in August 2021.

   The four tables involved (rating, movie, platforms and country) have been loaded and joined in MySQL using dampling for better reproducibility. 

   <img src="C:\Users\vargh\OneDrive\Dokumentumok\CEU Business Analytics\Courses\Fall\Data Engineering 1\TP2\Screen Shot 2021-11-11 at 5.10.07 PM.png" alt="Screen Shot 2021-11-11 at 5.10.07 PM" style="zoom: 33%;" />

2. **Country codes and coordinates data table from GitHub**
   Since countries are identified by country codes in some of the following APIs and our existing data sources included only country names, we needed an intermediary to match country names in the country table of our Kaggle dataset to the country codes in the World Bank API. For this reason, we used the[ countries_codes_and_coordinates.csv](https://gist.github.com/tadast/8827699#file-countries_codes_and_coordinates-csv) from GitHub to get the Alpha-2 country codes.

3. **OMDb API**

   To get information about (1) box office statistics and (2) the awards won by the films in our Kaggle dataset, we used the Open Movie Database (OMDb API), which is a crowdsourced RESTful web service obtaining detailed information on movies.

   <img src="https://lh5.googleusercontent.com/eUqkXEApNA3M5ogwNpcCzyBgXDy4CQBczM3nQgF610oqGChzQEovQ29T17DXmlF7DLHZ8BxF6vSbxzF4PKVSx4CcUGH9TsyyrcxcN86Ub-M7mzm7Wj0QdfvhmaHwlnlWRquYdDvS" alt="img" style="zoom:25%;" />

4. **World Bank API**

   As we also needed data on GDP per capita and government spending on education to answer our analytical questions, we included two relevant indicators from the World Bank API in our project:

   - GDP per capita (current USD): NY.GDP.PCAP.CD

   - Government expenditure on education, total (% of GDP): SE.XPD.TOTL.GD.ZS

     <img src="https://lh4.googleusercontent.com/DoZu4Fv_seSY4iDFgch9UL5xqvlHN1DaPMgldAZeFy-n-x-dDgRtgHUqIxuj1wIMSufQc7EUwNDkZ-0bkODABsmzoU0vYnvTEasY37_zu6aBKdo5yywdpA5C0Xndjl1okOYsJXmF" alt="img" style="zoom:33%;" />

5. **Eurostat API**

   To get information about the employment statistics of the cultural/creative industry of the countries, we connected to Eurostat's API and used the "Persons working as creative and performing artists, authors, journalists and linguists" data table.

   <img src="https://lh4.googleusercontent.com/BburyjU_wRquKnuDbx0gBbcv1QKs_1pvja-xqct6M6O_AynGJIXTIxhmd5dktQ2iWAi7eg63x1egR_-cF_R_lqMjQIshEZ9Chrbo66EVmQlnRlci0VJ1cVEk1sOwJjmJZGWP5LaH" alt="img" style="zoom:33%;" />

### Workflow in Knime

------

1. ##### Preparation

   **MySQL connector and DB Query Reader:** to make the connection with the 'movies_on_streaming_platforms' database created in mySQL, the first step to be executed is setting up the MySQL connector to establish the connection between MySQL and Knime. To do so, users must input their credentials into this node to access their MySQL user interface, as well as select the 'movies on streaming_platforms' database.  To create the analytical layer, we joined the tables from the 'movies_on_streaming platforms' dataset with DB Query Reader.

   <img src="https://lh4.googleusercontent.com/Mfo_lBRVzNtiWhjgeZIYsLlI8lt_LZ-7junm66q8M8kXFo1ZmohHS-6K4iFk-dD6_1-arU2j1xLIzVZu4yo1XdS-RuaEbBY7O_AKAStgojtvEDQ9gnbh20fg123Ur8aRM1PvNtHq" alt="img" style="zoom:33%;" />

   **File reader to read 'country_codes_and_coordinates.csv' from GitHub and filter selected columns:** we used a file reader to read 'country_codes_and_coordinates.csv' downloaded from GitHub to our local computers and applied a column filter to get the two relevant columns for our project: "Country" and "Alpha-2 code". (Please note that in order to run the Knime script properly, the above mentioned csv file needs to be downloaded from GitHub and loaded using the file reader.)

   **Joining movies and country codes:** as the next step, we merged the two data tables with a Joiner node. As a result, the 'movies_on_streaming_platforms' data table has been complemented with country codes and become ready for loading and joining our API sources.

2. ##### Load APIs and clean data sources

   **OMDb API:** First we added the OMDb API and after some basic cleaning steps (removing one unfound movie and creating a new column "new" with the titles extracted from the API url) extracted the "Awards" and "BoxOffice" data into separate columns. 

   As the "Awards" column was originally a string including both the number of wins and the number of nominations,the following data cleaning steps were taken to get the number of wins as a separate numeric variable:

   - Created a new column for the number of wins and extracted the number using Sting Manipulation nodes. As the first step, we created the "indexofwin" variable where we extracted the number of digits before the phrase " win".  This variable had three values: -1 for zero wins, 1 for one digit number of wins and 2 for two-digit number of wins. 
   - Next, we created the actual "num_of_wins" variable where we displayed the two characters before the phrase " win", which equals to the number of wins.  Where the index was -1 (movies with zero wins), we dropped both the "indexofwin" and "num_of_wins" columns and concatenated the resulting table with a table where we kept the "num_of_wins" column for the movies which won at least one award. 
   - As the last step, we converted the "num_of_wins" to numeric variable.

   In case of "BoxOffice", first we removed the dollar signs and commas from the string and replaced "N/A"s with " ".  Second, we converted the variable from string to numeric and then changed the unit to million USD and set the variable as integer.

   **World Bank API**

   After connecting to the selected indicators of the World Bank API, we noticed that the "exp_on_edu" variable was a string and changed it a numeric rounded to two decimals.

   <img src="https://lh3.googleusercontent.com/K9auUdv-Yxdem6SsFrvzWzSnNO31PqcsbyP1Yss1LIaqg4MFUmjEKkOwbucuFCESRboBGZdgINtZANoi_syIngfkzHdPXoPwhKfg2elaVTWY3wFYzyp9rn5c4bmKHnQsZWouG-v8" alt="img" style="zoom: 33%;" />

   **Eurostat API**

   As Eurostat API contains data only for European countries, movies from non-European countries did not have matching data in the API. To exclude the resulting errors, we added a rule-based row filter to keep employment statistics of the cultural/creative industry for movies originated from European countries.

3. ##### Joining data sources

   As the first step, we joined World Bank API and Eurostat API with a full outer join based on the titles of the movies, keeping all data from both data sources. To create our denormalized analytical layer, we took the movies data table expanded with the cleaned OMDb APIs inputs as the left table and joined it to the result of our World Bank & Eurostat join as our right table using left join based on the title of movies.

   <img src="https://lh6.googleusercontent.com/sdhDHdN3McnV_KZztbDb_SwGuBa1cHJTLVBbKLbaYO8m3IfWkXoCTZkwWReoM5oFbN7hV2TygOqBJovp0ygwH1yEM1mtCPIn5qgTUdR_LDXT9pOfmcTqVn4Dl7V-JWwsPEllbBnU" alt="img" style="zoom:50%;" />

### Data analytics and visualization

------

**Which genres are the top 5 in terms of average number of awards won and IMDb ratings?**

Based on our data, we can tell that there are differences in terms of what kinds of movies that win more awards compared to those that receive higher IMDb ratings. Animation wins significantly more awards on average than the 4 other genres, whereas Documentary is the top1 in terms of average IMDb ratings, but the difference between the top 5 genres are only slight.

<img src="https://lh6.googleusercontent.com/0RPsCHMRAPPbEJKad8SwKnA8F9jlVYWFYByDoiQco7kMXIyvjB7GsppkKT4gfA97XBREtGF2R-wykvJ0Qc3oi0rU3LAXkIOzmvz5gfHAUebFIRVHqAenx8znf9XLTeTFMudfIKgb" alt="img" style="zoom: 25%;" /><img src="https://lh3.googleusercontent.com/riOYDwc4eTLkm2TbqCghCoOx6fdslIR7S5katAp4lj_zYsc9dwe1Tross1Y-GaaYqmzCU0hWIvbtovwszzuT6vzH3_RW64DxEsnjL5XSVlmdTfqFRm_TE1hjrY3VcQ8-z-UNDSRY" alt="img" style="zoom: 25%;" />



**What is the relationship between number of awards won and IMDb ratings?**

The histogram shows an increase in the number of awards won for the movies that are rated higher on IMDB. For movies rated between 3 and 6 there is not much variance in the number of awards won, however beyond 6.2 we witness a significant improvement, most notably, the difference between the movies that lie in the 7 and 8 rated category (the increase is over 90%). So we can say on average, as the rating of the movie increases so does the performance of the movie in terms of awards won.<img src="https://lh4.googleusercontent.com/t_mr8t0m0V3NKqXbWfoZ0omc7lFxs1PHa2b5RjnE47z82yC9MCn4soGSaa2N5M-glPKOsFWRKmCUcrOusrDEu4amgVfdwbMSAPsLvwfnViQrbd-mhVoyqqP4yv25sIO3jNUN2WSZ" alt="img" style="zoom:33%;" /><img src="https://lh6.googleusercontent.com/pU2CzA2YMdyQTG-MrhzdmI1F2OHinSI1zk8mN6VvU1sFHatfyvUXFU1aZFnJx1X2LzSW-K4yAiNZSslOtPHnKRW8lGQsXMihdoMKgalPo55RIWY6csmn0ej8Eh5q-lTyTLOWmfXz" alt="img" style="zoom:33%;" />

This scatter plot further emphasizes the same point, as we can see that a positive slope trend line can be fitted between the two variables. Low rated movies are only able to win a fraction of the number of awards compared to the high rated movies.

**What is the relationship between the box office revenue of a movie and the GDP per capita, expenditure on education and population of cultural employment of its country of origin?**

From the below statistics on linear regression, we can see that a country’s government expenditure on education (% of total GDP) is positively related to the average box office revenue of movies produced by this country. However, the p-value is too high, so we cannot reject that there is no correlation between the two. Therefore, from our dataset, we can conclude there is no statistically significant correlation between average box office revenue of movies and the country’s GDP per capita, expenditure on education and cultural employment population.

<img src="https://lh3.googleusercontent.com/40kuzsTNWIZ2I0L09ic0INL1h8AK24yHs-dAEE3BPIoTbVaXOdZ8-VNsub6nbVPg11ScTc9ISxmxoqhLZd1ZIo_8uIKmGjdxRKDGAehkPbT9RMExtFEyL2WrhtRlCdOf1YDDp8ps" alt="img" style="zoom: 50%;" />

**What is the relationship between the number of awards won by a movie and the GDP per capita, expenditure on education and population of cultural employment of its country of origin?**

We run a multiple regression and from the statistics we can be 95% confident that a country’s government expenditure on education (% of total GDP) is positively related to the average number of awards won by movies originating from that particular country. However, based on our data, there is no statistically significant correlation either (1) between the number of movies’ awards won, and (2) the country’s GDP per capita and cultural employment population.

<img src="https://lh6.googleusercontent.com/hM5jSQO18wb3itNzJRHwcTDAwYn4ayzfJR4OgZMMbEt-_Is-aLTO_FDtQoJ7aUNtnXAuCctrNvT7-FYHwP0cuph8dcS7Rdy1se6r8NiADVC2c7DGe7ZP0goGbdwCRe5hFsSUB9yQ" alt="img" style="zoom: 50%;" />

### Who did what?

------

Péter Kaiser: Data Cleaning, Reproducibility, Knime Workflow

Rauhan Nazir: Data Cleaning, Part of Data Analysis and Visualization, Part of Extracting Values through APIs

Sára Vargha: Markdown report and project documentation, PPT

Xibei Chen: Create DB on MySQL, Extract Values from JSON by Calling APIs, part of Data Analysis and Visualization, Knime Workflow Annotation

