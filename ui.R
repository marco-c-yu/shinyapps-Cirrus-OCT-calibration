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

copyright <- c(
  "Copyright (C) 2020  Marco Chak-Yan YU",
  "",
  "This program is under the terms of the GNU General Public License",
  "as published by the Free Software Foundation, version 2 of the License.",
  "",
  "Redistribution, add, delete or modify are NOT ALLOWED",
  "WITHOUT AUTHOR'S NOTIFICATION AND PERMISSION.",
  "",
  "This program is distributed in the hope that it will be useful,",
  "but WITHOUT ANY WARRANTY; without even the implied warranty of",
  "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.",
  "See the GNU General Public License for more details."
)

shinyUI(pageWithSidebar(
  
  headerPanel('Adjustment of Cirrus OCT parameters by Signal Strength'),
  
  sidebarPanel(
    downloadButton('download_template', 'download template .csv'),
    br(),br(),br(),br(),
    fileInput('infile','upload data (.csv):', multiple = FALSE),
    br(),br(),
    actionButton('run_calibration','run adjustment'),
    br(),br(),
    downloadButton('download_calibration', 'download adjusted results .csv'),
    br(),br(),br(),
    HTML("<b><i>Reference:</i></b>"),br(),
    HTML("Thakur S, Yu M, Tham YC, et al. 
        Utilisation of poor-quality optical coherence tomography scans: 
        adjustment algorithm from the Singapore Epidemiology of Eye Diseases (SEED) study. 
        Br J Ophthalmol. 2022;106(7):962-969. doi:<a href='https://doi.org/10.1136/bjophthalmol-2020-317756'>10.1136/bjophthalmol-2020-317756</a>")
  ),
  
  mainPanel(
    tabsetPanel(
      tabPanel('data tab',
               HTML("</br>Input data (editable):</br></br>"),
               DT::dataTableOutput("input_table"),
               br(),
               actionButton('add_row','add row'),
               actionButton('delete_row','delete row')),
      tabPanel('variable tab',
               checkboxGroupInput(
                 'vars','Please tick the required variables:',
                 choiceNames = c("ONH Average RNFL (ONH_RNFL_AVERAGE)",
                                 "ONH Temporal RNFL (ONH_RNFL_TEMP)",
                                 "ONH Superior RNFL (ONH_RNFL_SUP)",
                                 "ONH Nasal RNFL (ONH_RNFL_NAS)",
                                 "ONH Inferior RNFL (ONH_RNFL_INF)",
                                 "Macular Average GCIPL (GC_AVERAGE)",
                                 "Macular Temporal-Superior GCIPL (GC_TEMPSUP)",
                                 "Macular Superior GCIPL (GC_SUP)",
                                 "Macular Nasal-Superior GCIPL (GC_NASSUP)",
                                 "Macular Nasal_Inferior GCIPL (GC_NASINF)",
                                 "Macular Inferior GCIPL (GC_INF)",
                                 "Macular Temporal GCIPL (GC_TEMPINF)"),
                 choiceValues = c("ONH_RNFL_AVERAGE","ONH_RNFL_TEMP","ONH_RNFL_SUP","ONH_RNFL_NAS","ONH_RNFL_INF",
                                 "GC_AVERAGE",
                                 "GC_TEMPSUP","GC_SUP","GC_NASSUP","GC_NASINF","GC_INF","GC_TEMPINF"),
                 selected = c("ONH_RNFL_AVERAGE",
                              "GC_AVERAGE"),
                 width='100%')),
      tabPanel('results tab',
               HTML("</br>Adjusted results:</br></br>"),
               DT::dataTableOutput("output_table")),
      tabPanel('help',
               HTML("<script src='/pdf.js'></script>
                    </br>User Guide (<a href='user_guide.pdf'>pdf</a>):</br>"),
               tags$iframe(style='height:600px; width:100%', src='user_guide.pdf'))
      # tabPanel("Copyright", HTML(paste(copyright,collapse='</br>')))
    )
  )
  
))
