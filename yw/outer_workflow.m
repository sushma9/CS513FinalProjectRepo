''' 
# @begin CS513-Team-150-NYPL_Menus  @desc Team 150 NYPL Overall Data Workflow
# @in Menu.csv  @uri file://data/Menu.csv
# @in Dish.csv  @uri file://data/Dish.csv
# @in MenuItem.csv  @uri file://data/MenuItem.csv
# @in MenuPage.csv  @uri file://data/MenuPage.csv

#     @begin MenuClean  @desc Use OpenRefine to clean Menu
#     @in Menu.csv  @uri file://data/Menu.csv
#     @out menu.csv  @uri file://data/menu_post_or.csv
#     @end MenuClean

#     @begin MenuItemClean  @desc Use OpenRefine to clean Menu Item
#     @in MenuItem.csv  @uri file://data/MenuItem.cv
#     @out menuitem.csv  @uri file://data/menu_item_post_or.csv
#     @end MenuItemClean

#     @begin DishClean  @desc Use OpenRefine to clean Dish
#     @in Dish.csv  @uri file://data/Dish.cv
#     @out dish.csv  @uri file://data/dish_post_or.csv
#     @end OpenRefine_CleanDish

#     @begin R_Processing  @desc Use R to perform detailed data cleaning & transformation
#     @in menu.csv  
#     @in menuitem.csv
#     @in dish.csv
#     @in MenuPage.csv
#     @out menu_post_process.csv @uri file://data/menu_post_process.csv
#     @out menu_item_post_process.csv @uri file://data/menu_item_post_process.csv
#     @out menu_page_post_process.csv @uri file://data/menu_page_post_process.csv
#     @out dish_post_process.csv @uri file://data/dish_post_process.csv
#     @end R_Processing

#     @begin SQLite_IC_Check  @desc Load data into relational DB store
#     @in menu_post_process.csv
#     @in menu_item_post_process.csv
#     @in menu_page_post_process.csv
#     @in dish_post_process.csv
#     @param SQL_Load_IC_Script
#     @out menu  @uri sqlite://database.db/MenuDB
#     @out menuitem  @uri sqlite://database.db/MenuItemDB
#     @out menupage  @uri sqlite://database.db/MenuPageDB
#     @out dish  @uri sqlite://database.db/DishDB
#     @end LoadToSQLite

# @out menu  @uri sqlite://database.db/MENU_FINAL
# @out menuitem  @uri sqlite://database.db/MENU_ITEM_FINAL
# @out menupage  @uri sqlite://database.db/MENU_PAGE_FINAL
# @out dish  @uri sqlite://database.db/DISH_FINAL
# @end CS513-Team-150-NYPL_Menus 
'''
