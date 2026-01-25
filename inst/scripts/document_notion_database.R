#' Document Notion Database Structure
#'
#' This script pulls a Notion database and generates a markdown file
#' describing its structure, columns, data types, and sample values.
#' The output is designed to help Claude Code understand the database
#' structure for further development.
#'
#' Usage:
#'   Rscript document_notion_database.R <database_id> [output_file]
#'
#' Or source and call the function directly:
#'   source("document_notion_database.R")
#'   document_notion_database("your_database_id", "output.md")
#'
#' Requirements:
#'   - NOTION_API_SECRET environment variable must be set
#'   - Database must be shared with your Notion integration

library(notionR)
library(dplyr)
library(tidyr)

#' Document a Notion Database Structure
#'
#' @param database_id The Notion database ID (from the URL)
#' @param output_file Path to the output markdown file (default: "notion_database_structure.md")
#' @param secret The Notion API secret (default: from NOTION_API_SECRET env var)
#' @param sample_rows Number of sample rows to include (default: 5)
#' @param include_raw_columns Whether to include all raw column names (default: TRUE
#'
#' @return Invisibly returns the path to the generated markdown file
#' @export
document_notion_database <- function(
    database_id,
    output_file = "notion_database_structure.md",
    secret = Sys.getenv("NOTION_API_SECRET"),
    sample_rows = 5,
    include_raw_columns = TRUE
) {

  # Validate inputs
  if (is.null(secret) || secret == "") {
    stop("NOTION_API_SECRET environment variable is not set.\n",
         "Set it with: Sys.setenv(NOTION_API_SECRET = 'your_secret')\n",
         "Or add to .Renviron: usethis::edit_r_environ()")
  }

  if (is.null(database_id) || database_id == "") {
    stop("database_id is required")
  }

  message("Fetching database metadata...")

  # Get database metadata (schema)
  metadata <- tryCatch(
    getNotionDatabaseMetadata(secret = secret, database = database_id, raw = FALSE),
    error = function(e) {
      stop("Failed to fetch database metadata: ", e$message)
    }
  )

  # Get raw metadata for additional info
  metadata_raw <- tryCatch(
    getNotionDatabaseMetadata(secret = secret, database = database_id, raw = TRUE),
    error = function(e) NULL
  )

  message("Fetching database contents...")

  # Get database contents
  data <- tryCatch(
    getNotionDatabase(secret = secret, database = database_id, all_pages = TRUE),
    error = function(e) {
      warning("Failed to fetch database contents: ", e$message)
      NULL
    }
  )

  # Check if data is empty
  is_empty <- is.null(data) || isEmptyNotionDatabaseExport(data)

  message("Generating documentation...")

  # Build the markdown content
  md_lines <- character()

  # Header
  db_title <- if (!is.null(metadata_raw$title) && length(metadata_raw$title) > 0) {
    paste(sapply(metadata_raw$title, function(x) x$plain_text), collapse = "")
  } else {
    "Notion Database"
  }

  md_lines <- c(md_lines,
    paste0("# ", db_title, " - Database Structure"),
    "",
    paste0("**Generated:** ", Sys.time()),
    paste0("**Database ID:** `", database_id, "`"),
    ""
  )

  # Description if available
  if (!is.null(metadata_raw$description) && length(metadata_raw$description) > 0) {
    desc <- paste(sapply(metadata_raw$description, function(x) x$plain_text), collapse = "")
    if (desc != "") {
      md_lines <- c(md_lines,
        "## Description",
        "",
        desc,
        ""
      )
    }
  }

  # Summary statistics
  md_lines <- c(md_lines,
    "## Summary",
    "",
    paste0("- **Total Properties (Columns):** ", nrow(metadata)),
    paste0("- **Total Rows:** ", if (is_empty) "0" else nrow(data)),
    ""
  )

  # Property types summary
  type_counts <- metadata %>%
    count(type, sort = TRUE)

  md_lines <- c(md_lines,
    "### Property Types Distribution",
    "",
    "| Type | Count |",
    "|------|-------|"
  )

  for (i in seq_len(nrow(type_counts))) {
    md_lines <- c(md_lines,
      paste0("| ", type_counts$type[i], " | ", type_counts$n[i], " |")
    )
  }
  md_lines <- c(md_lines, "")

  # Detailed column definitions
  md_lines <- c(md_lines,
    "## Column Definitions",
    "",
    "| Property Name | Type | ID |",
    "|---------------|------|-----|"
  )

  for (i in seq_len(nrow(metadata))) {
    md_lines <- c(md_lines,
      paste0("| ", metadata$name[i], " | `", metadata$type[i], "` | `", metadata$id[i], "` |")
    )
  }
  md_lines <- c(md_lines, "")

  # Detailed property information
  md_lines <- c(md_lines,
    "## Property Details",
    ""
  )

  for (i in seq_len(nrow(metadata))) {
    prop_name <- metadata$name[i]
    prop_type <- metadata$type[i]
    prop_id <- metadata$id[i]

    md_lines <- c(md_lines,
      paste0("### ", prop_name),
      "",
      paste0("- **Type:** `", prop_type, "`"),
      paste0("- **ID:** `", prop_id, "`")
    )

    # Get additional type-specific info from raw metadata
    if (!is.null(metadata_raw$properties[[prop_name]])) {
      prop_details <- metadata_raw$properties[[prop_name]]

      # For select/multi_select, show available options
      if (prop_type %in% c("select", "multi_select")) {
        options <- prop_details[[prop_type]]$options
        if (!is.null(options) && length(options) > 0) {
          option_names <- sapply(options, function(x) x$name)
          md_lines <- c(md_lines,
            paste0("- **Available Options:** ", paste(paste0("`", option_names, "`"), collapse = ", "))
          )
        }
      }

      # For relation, show related database
      if (prop_type == "relation" && !is.null(prop_details$relation$database_id)) {
        md_lines <- c(md_lines,
          paste0("- **Related Database ID:** `", prop_details$relation$database_id, "`")
        )
      }

      # For rollup, show configuration
      if (prop_type == "rollup") {
        rollup_cfg <- prop_details$rollup
        if (!is.null(rollup_cfg)) {
          md_lines <- c(md_lines,
            paste0("- **Rollup Function:** `", rollup_cfg$function %||% "unknown", "`"),
            paste0("- **Rollup Property:** `", rollup_cfg$rollup_property_name %||% "unknown", "`")
          )
        }
      }

      # For formula, show expression
      if (prop_type == "formula" && !is.null(prop_details$formula$expression)) {
        md_lines <- c(md_lines,
          paste0("- **Formula:** `", prop_details$formula$expression, "`")
        )
      }

      # For number, show format
      if (prop_type == "number" && !is.null(prop_details$number$format)) {
        md_lines <- c(md_lines,
          paste0("- **Number Format:** `", prop_details$number$format, "`")
        )
      }
    }

    # Show sample values from actual data
    if (!is_empty) {
      # Find columns that match this property
      prop_cols <- grep(paste0("^properties\\.", gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", prop_name), "\\."),
                        names(data), value = TRUE)

      if (length(prop_cols) > 0) {
        # Get the most useful column for samples
        # Prefer .name, .plain_text, .content, etc.
        priority_suffixes <- c(".name", ".plain_text", ".content", ".start", ".number",
                               ".checkbox", ".url", ".email", ".phone_number")
        sample_col <- NULL

        for (suffix in priority_suffixes) {
          matching <- grep(paste0(suffix, "$"), prop_cols, value = TRUE)
          if (length(matching) > 0) {
            sample_col <- matching[1]
            break
          }
        }

        if (is.null(sample_col)) {
          sample_col <- prop_cols[1]
        }

        # Get sample values
        sample_vals <- data[[sample_col]]
        if (!is.null(sample_vals)) {
          unique_vals <- unique(sample_vals[!is.na(sample_vals) & sample_vals != ""])
          if (length(unique_vals) > 0) {
            display_vals <- head(unique_vals, 5)
            md_lines <- c(md_lines,
              paste0("- **Sample Values:** ",
                     paste(paste0("`", substr(as.character(display_vals), 1, 50),
                                  ifelse(nchar(as.character(display_vals)) > 50, "...", ""), "`"),
                           collapse = ", "))
            )
          }
        }
      }
    }

    md_lines <- c(md_lines, "")
  }

  # Raw column names from the data frame
  if (include_raw_columns && !is_empty) {
    md_lines <- c(md_lines,
      "## Raw Data Frame Columns",
      "",
      "These are the actual column names in the data frame returned by `getNotionDatabase()`:",
      "",
      "```"
    )

    # Group columns by category
    meta_cols <- grep("^(id|object|archived|created_|last_edited_|parent\\.|url|public_url|icon\\.|cover)",
                      names(data), value = TRUE)
    prop_cols <- grep("^properties\\.", names(data), value = TRUE)
    other_cols <- setdiff(names(data), c(meta_cols, prop_cols))

    if (length(meta_cols) > 0) {
      md_lines <- c(md_lines, "# Metadata columns:", meta_cols)
    }
    if (length(other_cols) > 0) {
      md_lines <- c(md_lines, "", "# Other columns:", other_cols)
    }
    if (length(prop_cols) > 0) {
      md_lines <- c(md_lines, "", "# Property columns:", prop_cols)
    }

    md_lines <- c(md_lines, "```", "")
  }

  # Sample data
  if (!is_empty && sample_rows > 0) {
    md_lines <- c(md_lines,
      "## Sample Data",
      "",
      paste0("First ", min(sample_rows, nrow(data)), " rows (selected columns):"),
      ""
    )

    # Select interesting columns for display
    display_cols <- c()

    # Add id
    if ("id" %in% names(data)) display_cols <- c(display_cols, "id")

    # Add property columns (one per property, prefer .name or .plain_text)
    for (prop in metadata$name) {
      prop_cols <- grep(paste0("^properties\\.", gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", prop), "\\."),
                        names(data), value = TRUE)

      if (length(prop_cols) > 0) {
        # Pick best column
        for (suffix in c(".name", ".plain_text", ".content", ".start", ".number",
                         ".checkbox", ".url", ".email", ".phone_number")) {
          matching <- grep(paste0(suffix, "$"), prop_cols, value = TRUE)
          if (length(matching) > 0) {
            display_cols <- c(display_cols, matching[1])
            break
          }
        }
        if (!(prop_cols[1] %in% display_cols)) {
          display_cols <- c(display_cols, prop_cols[1])
        }
      }
    }

    display_cols <- unique(display_cols)
    sample_data <- head(data[, display_cols, drop = FALSE], sample_rows)

    # Create markdown table
    # Simplify column names for readability
    simple_names <- gsub("^properties\\.", "", names(sample_data))
    simple_names <- gsub("\\.(name|plain_text|content|start|number|checkbox|url)$", "", simple_names)

    header <- paste0("| ", paste(simple_names, collapse = " | "), " |")
    separator <- paste0("|", paste(rep("---", length(simple_names)), collapse = "|"), "|")

    md_lines <- c(md_lines, header, separator)

    for (r in seq_len(nrow(sample_data))) {
      row_vals <- sapply(sample_data[r, ], function(x) {
        if (is.na(x)) return("-")
        x <- as.character(x)
        if (nchar(x) > 30) x <- paste0(substr(x, 1, 27), "...")
        # Escape pipes in values
        gsub("\\|", "\\\\|", x)
      })
      md_lines <- c(md_lines, paste0("| ", paste(row_vals, collapse = " | "), " |"))
    }

    md_lines <- c(md_lines, "")
  }

  # Usage notes for Claude Code
  md_lines <- c(md_lines,
    "## Usage Notes for Development",
    "",
    "### Accessing this database with notionR",
    "",
    "```r",
    "library(notionR)",
    "",
    "# Set your API secret",
    "secret <- Sys.getenv(\"NOTION_API_SECRET\")",
    paste0("database_id <- \"", database_id, "\""),
    "",
    "# Get metadata (schema)",
    "metadata <- getNotionDatabaseMetadata(secret, database_id)",
    "",
    "# Query all data",
    "data <- getNotionDatabase(secret = secret, database = database_id)",
    "",
    "# Query with filter example",
    "# filtered_data <- getNotionDatabase(",
    "#   secret = secret,",
    "#   database = database_id,",
    "#   filters = add_checkbox_filter(\"PropertyName\", equals = TRUE)",
    "# )",
    "```",
    "",
    "### Available notionR Functions",
    "",
    "- `getNotionDatabase()` - Query database contents",
    "- `getNotionDatabaseMetadata()` - Get database schema",
    "- `createNotionPage()` - Create new page in database",
    "- `updateText()`, `updateSelect()`, `updateCheckbox()`, etc. - Update page properties",
    "- `getMultiSelectValues()` - Extract unique values from multi-select columns",
    "",
    "### Column Name Pattern",
    "",
    "Data frame columns follow the pattern: `properties.{PropertyName}.{subfield}`",
    "",
    "Common subfields by type:",
    "- **title/text:** `.plain_text`, `.content`",
    "- **select/multi_select:** `.name`",
    "- **date:** `.start`, `.end`",
    "- **number:** `.number`",
    "- **checkbox:** `.checkbox`",
    "- **url:** `.url`",
    "- **relation:** `.id`",
    ""
  )

  # Write to file
  writeLines(md_lines, output_file)

  message("Documentation written to: ", output_file)
  invisible(output_file)
}


# Command-line interface
if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)

  if (length(args) < 1) {
    cat("Usage: Rscript document_notion_database.R <database_id> [output_file]\n")
    cat("\nArguments:\n")
    cat("  database_id   The Notion database ID (from the URL)\n")
    cat("  output_file   Path to output markdown file (default: notion_database_structure.md)\n")
    cat("\nEnvironment:\n")
    cat("  NOTION_API_SECRET  Your Notion API integration secret (required)\n")
    quit(status = 1)
  }

  database_id <- args[1]
  output_file <- if (length(args) >= 2) args[2] else "notion_database_structure.md"

  document_notion_database(database_id, output_file)
}
