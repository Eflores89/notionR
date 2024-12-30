### experimental - used to structure page content from getNotionPageContent...

makePage <- function(pagecontent){

  p <- NULL
  for(i in 1:length(pagecontent$results) ){
    type <- pagecontent$results[[i]]$type
    line <- extractBlockContentType(type = type,
                                    block = pagecontent$results[[i]])
    print(line)
    md <- createMDfromBlockExtract(type = type, input = line)

    p <- paste(p, md, sep = "/n ")
  }

  p
}


extractBlockContentType <- function(type, block){
  print(type)
  print(block)

  if(type == "heading_2"){
    e <- block$heading_2$text[[1]]$plain_text
  }

  if(type == "heading_1"){
    e <- block$heading_2$text[[1]]$plain_text
  }

  e
}













createMDfromBlockExtract <- function(type, input, bold = FALSE, italic = FALSE, underline = FALSE){
  if(type == "heading_2"){
    e <- paste0("##", ifelse(bold, "**", ""), input)
  }


  e
}
