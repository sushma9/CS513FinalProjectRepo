library(dplyr)
library(ggplot2)

#######################################################################################
########################     Read the raw data files    ###############################
#######################################################################################

dish = read.csv("C:\\Users\\14088\\Documents\\Books\\CS513 - TDC\\Data\\Dish.csv")
menu = read.csv("C:\\Users\\14088\\Documents\\Books\\CS513 - TDC\\Data\\Menu.csv")
menu_item = read.csv("C:\\Users\\14088\\Documents\\Books\\CS513 - TDC\\Data\\MenuItem.csv")
menu_page = read.csv("C:\\Users\\14088\\Documents\\Books\\CS513 - TDC\\Data\\MenuPage.csv")

######################################################################################################################
########################  1. check_empty function finds empty/NA values in each col    ###############################
########################  2. Cleaned Data files from OpenRefine are loaded             ###############################
########################  3. Few Data cleaning operations on menu, dish and menu_item  ###############################
########################     were missed in OpenRefine, so performing them here        ###############################
######################################################################################################################


check_empty = function(col){
  emp_miss_count =length(col[col == ""]) 
  na_count = sum(is.na(col))
  emp_miss_proportion = 100*emp_miss_count/length(col)
  res = data.frame(cbind(emp_miss_count, na_count, emp_miss_proportion))
  return(res)
}

m1 = sapply(menu, check_empty)
m2 = sapply(dish, check_empty)
m3 = sapply(menu_item, check_empty)
m4 = sapply(menu_page, check_empty)


menu_cleaned = read.csv("C:\\Users\\14088\\Documents\\Books\\CS513 - TDC\\CS513FinalProjectRepo\\Data_Cleaned\\Menu_cleaned.csv")
dish_cleaned = read.csv("C:\\Users\\14088\\Documents\\Books\\CS513 - TDC\\CS513FinalProjectRepo\\Data_Cleaned\\Dish_cleaned.csv")

### Remove the rows with no event 
menu_cleaned = menu_cleaned[!(menu_cleaned$event == ""),]  

### Remove the rows with no venue
menu_cleaned = menu_cleaned[!(menu_cleaned$venue == ""),]                 

### Remove the rows with no dish name
dish_cleaned = dish_cleaned[!(dish_cleaned$name == ""),]     

### Few records have neg values for times_appeared, setting it to 1
dish_cleaned[(dish_cleaned$times_appeared <= 0),"times_appeared"] = 1

### Few records have 0,1,2928 in first_appeared, setting them to 1840 and 2023
dish_cleaned[dish_cleaned$first_appeared < 1840,"first_appeared"] = 1840
dish_cleaned[dish_cleaned$first_appeared > 2023,"first_appeared"] = 2023

### Few records have 0,1,2928 in last_appeared, setting them to 2023
dish_cleaned[dish_cleaned$last_appeared < 1840,"last_appeared"] = 2023
dish_cleaned[dish_cleaned$last_appeared > 2023,"last_appeared"] = 2023

### high_price_new is the highest price if high_price is not NA else it takes the value from the 'price' col. It is set to NA otherwise
menu_item$high_price_new = ifelse(!is.na(menu_item$high_price), menu_item$high_price, ifelse(!is.na(menu_item$price), menu_item$price, NA))

### Keeping only the required columns
menu_item = menu_item[!is.na(menu_item$high_price_new),c(1,2,5,7,10)]

### saving the files to Data_Cleaned folder 
write.csv(menu_cleaned, "C:\\Users\\14088\\Documents\\Books\\CS513 - TDC\\CS513FinalProjectRepo\\Data_Cleaned\\Menu_cleaned.csv", row.names = F)
write.csv(dish_cleaned, "C:\\Users\\14088\\Documents\\Books\\CS513 - TDC\\CS513FinalProjectRepo\\Data_Cleaned\\Dish_cleaned.csv", row.names = F)
write.csv(menu_item, "C:\\Users\\14088\\Documents\\Books\\CS513 - TDC\\CS513FinalProjectRepo\\Data_Cleaned\\Menu_item_cleaned.csv", row.names = F)


###################################################################################################################
########################  1. Building the query for the Use case U1            ####################################
########################  2. Finding the Most Popular Dish and then finding    ####################################
########################     the most expensive venues which serve this dish   ####################################
###################################################################################################################


###  Perform Inner Join between menu_page and menu_cleaned
df_merge1 = merge(menu_page[,c("id","menu_id")], menu_cleaned, by.x = "menu_id", by.y = "id", all=F)
names(df_merge1)[2] = "menu_page_id"

###  Perform Inner Join between menu_item and Dish_cleaned
df_merge2 = merge(menu_item[, c("menu_page_id", "dish_id", "high_price_new")], dish_cleaned,  by.x = "dish_id", by.y="id",  all = F)

###  Perform another innerjoin between the above 2 tables
df_merge3 = merge(df_merge1, df_merge2, by = "menu_page_id", all=F)
names(df_merge3)[21] = "dish_name"

### Keep only the below required columns & eliminate any duplicate records
keepCols = c("menu_id","event","venue","menu_page_id","dish_id","dish_name","location","currency","page_count","dish_count",
             "menus_appeared","times_appeared","first_appeared","last_appeared","high_price_new","lowest_price","highest_price")

df_new = df_merge3[,keepCols]           ## 1327109 records
df_new = df_new[!duplicated(df_new),]   ## 1313928 records ; eliminated some duplicates

###  We do not have convertion rate data so keeping it to USD and filtering by currency = Dollars 
df_usd = df_new[df_new$currency == "DOLLARS",]  # 858660 records

###  filtering by the event = DINNER
df_dinner_usd = df_usd[df_usd$event == "DINNER",] # 66306 records


### removing all records where both lowest and highest price is NA  # 65719 records
df_curr = df_dinner_usd[!(is.na(df_dinner_usd$high_price_new) & is.na(df_dinner_usd$lowest_price) & is.na(df_dinner_usd$highest_price)),]


### keep the highest price for the dish
df_curr$price = pmax(df_curr$high_price_new, df_curr$lowest_price, df_curr$highest_price, na.rm=T)


### 125 records have dishes priced at 2500, treating them as anamolies and elimating them.
### Keeping records which have dish prices below 500 USD
df_curr = df_curr[df_curr$price < 500,]
df_curr = df_curr[order(-df_curr$menus_appeared, -df_curr$price),]


####  For the most_popular dishes
most_popular_dish = df_curr[,c("dish_name", "menus_appeared")]
most_popular_dish = most_popular_dish[!duplicated(most_popular_dish),]
most_popular_dish_20 = most_popular_dish[1:20,]

### Plotting the top 20 most popular dishes
ggplot(most_popular_dish_20, aes(x = reorder(dish_name, -menus_appeared), y= menus_appeared)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(x = "Dish_name", y = "menus_appeared", title = "Top 20 Most Popular Dishes")+
  theme(axis.text.x = element_text(angle = 90, hjust = 0.5))

#write.csv(most_popular_dish_20, "most_popular_dish_20.csv", row.names=F)

###  which venues serve the most expensive coffee
df_curr_coffee = df_curr[df_curr$dish_name == "COFFEE", c("dish_name", "venue")]
df_curr_coffee <- df_curr_coffee %>% group_by(venue) %>%   mutate(counts = n())

ggplot(data=df_curr_coffee, aes(x=reorder(venue,-counts))) +
  geom_bar(stat="count", fill="steelblue")+
  labs(x = "Venue", y = "count", title = "Venues where the most expensive Coffee is served")+
  theme(axis.text.x = element_text(angle = 90, hjust = 0.5))

#write.csv(df_curr_coffee, "df_curr_cofee.csv", row.names=F)