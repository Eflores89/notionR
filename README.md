# notionR


<!-- markdownlint-disable -->
<div align="center">
    <h1>Notion package for R</h1>
    <p>
        <b>Wrapper functions to access <a href="https://developers.notion.com">Notion API</a> using R</b>
    </p>
    <br/>
</div>

<h2>⚠️ This package is still work in progress </h2>

<h2> Quick Start </h2>
You will need a Notion API Token (see API documentation for how-to) and the id's of the databases you might want to access. 

For now, we can `GET` database metadata and the results of a database query, with some helpful filter functions. 
```{r}
# my_secret_token <- 1231412341
# my_db_id <- "lask1-231lñ3k2-p010202"
# to get the metadata (columns and column id's), 
get_database_metadata(my_secret_token, my_db_id)
```

```{r}
# to get the actual database items, we need to query the database.
# first we create a filter using the helpers: 
query <- notion_or(add_checkbox_filter("column2", TRUE), 
                   add_checkbox_filter("column3", FALSE)) %>% notion_filter()
                   
results <- get_database(my_secret_token, my_db_id, query)
```
❗ Not all data types (such as **relations**) are supported via `get_database()` yet. Only number formula, number, title, checkbox and date (with start date only) for now. 

