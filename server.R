################################################################################
# 
# Package: Cirrus-OCT-Signal-Adjustment
# Copyright (C) 2020  Marco Chak-Yan YU
# 
# This program is under the terms of the GNU General Public License
# as published by the Free Software Foundation, version 2 of the License.
# 
# Redistribution, add, delete or modify are NOT ALLOWED
# WITHOUT AUTHOR'S NOTIFICATION AND PERMISSION.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
################################################################################

library(shiny)
ds.template <- readRDS('data_template.rds')
ds.template[1,] <- NA
cns <- c("ONH_RNFL_AVERAGE","ONH_RNFL_TEMP","ONH_RNFL_SUP","ONH_RNFL_NAS","ONH_RNFL_INF",
         "GC_AVERAGE","GC_MINIMUM",
         "GC_TEMPSUP","GC_SUP","GC_NASSUP","GC_NASINF","GC_INF","GC_TEMPINF",
         "MAC_RNFL_AVERAGE","MAC_RNFL_MINIMUM","OR_AVERAGE","OR_MINIMUM")
cns.must <- c('ADJUSTED_SIGNAL_STRENGTH','SIGNAL_STRENGTH')
ds.in <- ds.template
ds.out <- ds.in
ds.out <- cbind(ds.out[,c(1,3:13)],ds.out[,2:13])
colnames(ds.out)[2:12] <- paste('ADJUSTED',colnames(ds.out)[14:24],sep='_')
coef <- readRDS('calibration_coefficients.rds')
coef[,grep('^(ONH_RNFL_|GC_|MAC_RNFL_|OR_)',colnames(coef))] <- round(coef[,grep('^(ONH_RNFL_|GC_|MAC_RNFL_|OR_)',colnames(coef))]*100)/100
coef[,grep('^(RIM|DISC|CUP|AVERAGE_CD|VERTICAL_CD|THREEMM|FIVEMM)',colnames(coef))] <- round(coef[,grep('^(RIM|DISC|CUP|AVERAGE_CD|VERTICAL_CD|THREEMM|FIVEMM)',colnames(coef))]*10000)/10000
coef <- coef[,c('SS',cns)]

shinyServer(function(input, output) {
  addResourcePath("www", tempdir())
  
  values <- reactiveValues()
  values$ds.template <- ds.template
  values$ds.in <- ds.in
  values$ds <- ds.in[,c('ADJUSTED_SIGNAL_STRENGTH','SIGNAL_STRENGTH',
                        "ONH_RNFL_AVERAGE",
                        "GC_AVERAGE",
                        "MAC_RNFL_AVERAGE",
                        "OR_AVERAGE")]
  values$ds.out <- ds.out
  output$input_table <- DT::renderDataTable({DT::datatable(values$ds,editable=TRUE,class='cell-border stripe',options=list(pageLength=20,lengthMenu=list(c(20,100,-1), c("20",'100',"All")),ordering=FALSE))})
  output$output_table <- DT::renderDataTable({DT::datatable(values$ds.out,editable=FALSE,class='cell-border stripe',options=list(pageLength=20,lengthMenu=list(c(20,100,-1), c("20",'100',"All")),ordering=FALSE))})
  
  ####################
  # sidebarPanel
  
  output$download_template <- downloadHandler(
    filename = function() {
      paste('data_template', '.csv', sep='')
    },
    content=function(file) {
      # write.csv(values$ds.template,file=file,append=FALSE,row.names=FALSE,na='')
      write.table(values$ds.template,file=file,append=FALSE,row.names=FALSE,na='',sep=',')
    }
  )
  
  observe({
    values$ds.template <- ds.template[,c(cns.must,input$vars)]
  })
  observeEvent(input$infile,{
    try({
      ds.in <- read.csv(input$infile$datapath,colClasses='numeric')
      for (c in 1:ncol(ds.in)) {
        if (is.factor(ds.in[,c])) ds.in[,c] <- as.numeric(as.character(ds.in[,c]))
      }
      for (cn in c(cns.must,input$vars)) {
        if (!(cn %in% colnames(ds.in))) eval(parse(text=paste('ds.in$',cn,' <- NA',sep='')))
      }
      values$ds.in <- ds.in[,colnames(ds.template)[colnames(ds.template) %in% colnames(ds.in)]]
      values$ds <- values$ds.in[,c(cns.must,input$vars)]
    },silent=TRUE)
  })
  observeEvent(input$run_calibration, {
    ds <- values$ds
    ys <- cns[cns %in% colnames(ds)]
    ds.out <- ds
    for (y in ys) {
      y1to2 <- paste('ADJUSTED',y,sep='_')
      eval(parse(text=paste('ds.out$',y1to2,' <- ds.out$',y,'-coef$',y,'[match(ds.out$SIGNAL_STRENGTH,coef$SS)]+coef$',y,'[match(ds.out$ADJUSTED_SIGNAL_STRENGTH,coef$SS)]', sep='')))
    }
    ds.out <- cbind(ds.out[,grep('ADJUSTED',colnames(ds.out))],ds[,!grepl('ADJUSTED',colnames(ds.out))])
    values$ds.out <- ds.out
  })
  
  output$download_calibration <- downloadHandler(
    filename = function() {
      paste('adjusted_results_', Sys.Date(), '.csv', sep='')
    },
    content=function(file) {
      # write.csv(values$ds.out,file=file,append=FALSE,row.names=FALSE,na='')
      write.table(values$ds.out,file=file,append=FALSE,row.names=FALSE,na='',sep=',')
    }
  )
  
  ####################
  # mainPanel
  observeEvent(input$input_table_cell_edit, {
    info = input$input_table_cell_edit
    i = info$row
    j = info$col
    v = info$val
    values$ds[i,j] = DT::coerceValue(as.numeric(v), values$ds[i,j])
    values$ds.in[i,colnames(values$ds)[j]] = DT::coerceValue(as.numeric(v), values$ds.in[i,colnames(values$ds)[j]])
  })
  observeEvent(input$add_row, {
    values$ds.in[nrow(values$ds.in)+1,] <- NA
    values$ds <- values$ds.in[,c('ADJUSTED_SIGNAL_STRENGTH','SIGNAL_STRENGTH',input$vars)]
  })
  observeEvent(input$delete_row, {
    values$ds.in <- values$ds.in[-nrow(values$ds.in),]
    values$ds <- values$ds.in[,c('ADJUSTED_SIGNAL_STRENGTH','SIGNAL_STRENGTH',input$vars)]
  })
  observeEvent(input$vars, {
    values$ds.template <- ds.template[,c(cns.must,input$vars)]
    for (cn in c(cns.must,input$vars)) {
      if (!(cn %in% colnames(values$ds.in))) eval(parse(text=paste('values$ds.in$',cn,' <- NA',sep='')))
    }
    values$ds.in <- values$ds.in[,colnames(ds.template)[colnames(ds.template) %in% colnames(values$ds.in)]]
    values$ds <- values$ds.in[,c(cns.must,input$vars)]
    ys <- cns[cns %in% colnames(values$ds)]
    values$ds.out <- values$ds.out[,grep(paste(c(cns.must,ys),collapse='|'),colnames(values$ds.out))]
  })
  
  
})
