
<!-- README.md is generated from README.Rmd. Please edit that file -->

# notionR

<!-- badges: start -->
<!-- badges: end -->

The goal of notionR is to connect to Notion API from R. Create, Modify,
Download databases or pages from Notion.

This is a wrapper functions to access [Notion
API](https://developers.notion.com%22) using R

**This package is work in progress! Use at your own risk!**

## Installation

You can install the development version of notionR like so:

``` r
pak::pak("Eflores89/notionR")
```

## Access to Notion API

You need to be the **owner** of the Notion Workspace to create an
integration.

- Read the “Getting Started” from Notion API :
  <https://developers.notion.com/docs/getting-started>
- Build your first integration :
  <https://developers.notion.com/docs/create-a-notion-integration>
- Remember the name of the integration
- Store its API Secret

The only way for other users of your workspace to be able to use the API
integration is to share the API Secret with them: choose the
authorization wisely. See this page for more information about
authorization : <https://developers.notion.com/docs/authorization>

We recommend to store your API Secret in a environment variable in your
prefered .Renviron file.

``` r
usethis::edit_r_environ()
```

Add a variable like:

    NOTION_API_SECRET="secret_xxx111"

## Example

### Get a specific database table content

- Open the database you want to retrieve on Notion
- Open it as a full page
- Click on the “…” on the top right of the page
- Go to “Connexions”
- “Add connexion” and choose your own integration in the list
  - The database is now accessible with your API Secret
- Get database ID
  - Get the full URL of the page, and retrieve characters between last
    `/` and `?`
  - e.g. If the URL is
    `https://www.notion.so/00001111bbbbcccc?v=ddddeeee33334444`, the
    database ID is `00001111bbbbcccc`

You have now all information to download the database as follows:

``` r
library(notionR)

DATABASE_ID <- "00001111bbbbcccc"

data_project <- getNotionDatabase(
  secret = Sys.getenv("NOTION_API_SECRET"), 
  database = DATABASE_ID
)

data_project
```

    # A tibble: 26 × 70
       archived created_by.id      created_by.object created_time
       <chr>    <chr>              <chr>             <chr>       
     1 FALSE    xxxxx-7e0a-480… user              2023-11-22T…
     2 FALSE    xxxxx-7e0a-480… user              2023-10-28T…
     3 FALSE    xxxxx-7e0a-480… user              2023-10-02T…
     4 FALSE    xxxxx-7e0a-480… user              2023-09-30T…
     5 FALSE    xxxxx-7e0a-480… user              2023-09-23T…
     6 FALSE    xxxxx-7e0a-480… user              2023-09-23T…
     7 FALSE    xxxxx-7e0a-480… user              2023-09-23T…
     8 FALSE    xxxxx-7e0a-480… user              2023-09-23T…
     9 FALSE    xxxxx-7e0a-480… user              2023-09-08T…
    10 FALSE    xxxxx-7e0a-480… user              2023-08-26T…
    # ℹ 16 more rows
    # ℹ 66 more variables: icon.emoji <chr>, icon.type <chr>,
    #   id <chr>, last_edited_by.id <chr>,
    #   last_edited_by.object <chr>, last_edited_time <chr>,
    #   object <chr>, parent.database_id <chr>,
    #   parent.type <chr>, properties.Achievement.id <chr>,
    #   properties.Achievement.rollup.function <chr>, …
    # ℹ Use `print(n = ...)` to see more rows

To filter on some specific parameters see `?filters`.  
You can use code as follows:

``` r
DATABASE_ID <- "00001111bbbbcccc"

# using {notionR} built-in functions

data_project <- getNotionDatabase(
  secret = Sys.getenv("NOTION_API_SECRET"), 
  database = DATABASE_ID,
  filters = add_checkbox_filter("my property with checkbox", equals = FALSE)
)

# Or using list directly

data_project <- getNotionDatabase(
  secret = Sys.getenv("NOTION_API_SECRET"), 
  database = DATABASE_ID,
  filters = list(property = "my property with checkbox", checkbox = list(equals = FALSE))
)
data_project
```

See the documentation to get all available filters :
<https://developers.notion.com/reference/post-database-query-filter>
