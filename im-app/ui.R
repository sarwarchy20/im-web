library(shiny)
library(shinythemes)
library(mailtoR)
library(shinyjs)
library(knitr)
shinyUI(fluidPage(theme = shinytheme("cerulean"),useShinyjs(),
                  titlePanel("ImmuneMirror"),
                  sidebarLayout(position = "right",
                                sidebarPanel = (""),
                                mainPanel("Cooperated with ImmuneMirror, 
                                     this application helps to identify the key genomic and transcriptomic 
                                     features associated with response of cancer immunotherapy on the basis of a user-friendly interface.")),
                  br(),
                  navbarPage("Menu",
                             tabPanel("Instructions",
                                      fluidRow(column(
                                        
                                        strong("Upload files"),
                                        p("Users can upload the VCF file containing the somatic mutations identified by Mutect2 following the GATK best practice pipeline (https://gatk.broadinstitute.org/). Please indicate the human genome version. Our pipeline is mainly designed for hg38 and the liftover step is necessary for other genome versions.",style="text-align:justify;color:black;background-color:papayawhip;padding:15px;border-radius:10px"),
                                        br(),
                                        strong("Enter HLA alleles or upload HLA allele reference set"),
                                        p("Users can manually type in HLA alleles or upload a file including all the HLA alleles. Our method is working for both MHC class I and II prediction.",style="text-align:justify;color:black;background-color:papayawhip;padding:15px;border-radius:10px"),
                                        br(),
                                        strong("Select peptide lengths"),
                                        p("Specify length of peptide to predict. The typical peptides very between 8-15 for MHC class I and 11-30 for MHC class II.",style="text-align:justify;color:black;background-color:papayawhip;padding:15px;border-radius:10px"),
                                        br(),
                                        strong("Submit the job"),
                                        p("Click the 'Submit' button then the job will be sent to the server. You will be notified by e-mail with the ULR to download the results when the job is accomplished.",style="text-align:justify;color:black;background-color:papayawhip;padding:15px;border-radius:10px"),
                                        br(),
                                        p(em("Developed by"),br(), tags$a(tags$i("Dr. Wei Dai’s group"),href="http://weidai-lab.hku.hk/", 
                                                                         target="_blank" ),
                                        br("Department of Clinical Oncology, The University of Hong Kong."),
"We acknowledge the", tags$a(tags$i("Health and Medical Research Fund (HMRF)"),href="https://rfs1.fhb.gov.hk/english/funds/funds_hmrf/funds_hmrf_abt/funds_hmrf_abt.html", target="_blank" ), "for support.",
br(),"The work is jointly done with",tags$a(tags$i("Dr. Zhonghua Liu’s group"), href="https://sites.google.com/view/drliu/home", target="_blank" ),
br("Department of Statistics and Actuarial Science, The University of Hong Kong"),style="text-align:center; font-family: times"),
                                        width=8)
                                      )),
                             
                             tabPanel("Neoantigen Prediction and Prioritization",
                                      useShinyjs(),
                                      fileInput("VCF",span("Upload your VCF File", 
                                                           tags$a(tags$i("(Example VCF file)"),href="example.vcf", 
                                                                  target="_blank" )), multiple=FALSE),
                                      actionButton("reset", "Reset"),
                                      tags$hr(),
                                      
                                      selectInput("geno","Genome version:",
                                                  choices=c("hg38",'hg19'),multiple = F),
                                      tags$hr(),
                                    
                                      shinyFeedback::useShinyFeedback(),
                                      textInput("HLA", "Enter HLA allele names separated by commas without space (e.g., HLA-A*01:01,DRB1*11:01):"),
                                      textOutput("half"),
                                      
                                      #fileInput("HLA_set","Or choose your HLA allele reference set", multiple=FALSE),
                                      actionButton("reset1", "Reset"),
                                      tags$hr(),
                                      #selectInput("type","please indicate HLA class",choices = c("","class I","class II"),multiple=FALSE),
                                      #uiOutput('secondSelection'),
                          
                                      selectInput("length1","Please select peptide length for HLA class I (NOTE: range for class I is 8-15, multiple lengths are possible):",
                                                  choices = c(8:15), multiple=TRUE),
                                      actionButton("reset2", "Reset"),
                                      
                                      tags$hr(),
                                      selectInput("length2","Please select peptide length for HLA class II (NOTE: range for 
                                                class II is 11-30, multiple lengths are possible):",choices = c(11:30),
                                                  multiple=TRUE),
                                      actionButton("reset3", "Reset"),
                                      
                                      tags$hr(),
                                      textInput("emaili","Please enter your email address for receiving the outputs Download Link."),
                                      actionButton("reset4", "Reset"),
                                      
                                      tags$hr(),
                                      tags$head(
                                        tags$style(HTML('#submit{background-color:red;color:black;}'))
                                      ),
                                      actionButton("submit","Submit",class = "btn btn-success"),
                                      br(),
                                      br(),
                                      br()

                             ),

                             tabPanel("Documentation",
                                      fluidRow(
                                        strong("Restrictions:"),
                                        p("Max 6 MHC alleles per submission"),
                                        p("Max 50 mutations per submission"),
                                        br(),
                                        strong("Confidentiality:"),
                                        p("The files are kept confidential and will be deleted after processing"),
                                        br(),
                                        strong("Citation:"),
                                        p("ImmuneMirror: manuscript in preparation"),
                                        p("ImmuneMirror is adapted based on the binding prediction from pVACtools; for publication of results please cite pVACtools in addition to ImmuneMirror"),
                                        p("Jasreet Hundal+, Susanna Kiwala+, Joshua McMichael, Christopher A Miller, 
                                          Alexander T Wollam, Huiming Xia, Connor J Liu, Sidi Zhao, Yang-Yang Feng, 
                                          Aaron P Graubert, Amber Z Wollam, Jonas Neichin, Megan Neveau, Jason Walker, 
                                          William E Gillanders, Elaine R Mardis, Obi L Griffith, Malachi Griffith. 
                                          pVACtools: a computational toolkit to select and visualize cancer neoantigens. 
                                          Cancer Immunology Research. 2020 Mar;8(3):409-420. DOI: 10.1158/2326-6066.CIR-19-0401. PMID: 31907209."),
                                        p("Jasreet Hundal, Susanna Kiwala, Yang-Yang Feng, Connor J. Liu, Ramaswamy Govindan, William C. Chapman, Ravindra Uppaluri, S. Joshua Swamidass, Obi L. Griffith, Elaine R. Mardis, and Malachi Griffith. Accounting for proximal variants improves neoantigen prediction. Nature Genetics. 2018, DOI: 10.1038/s41588-018-0283-9. PMID: 30510237."),
                                        p("Jasreet Hundal, Beatriz M. Carreno, Allegra A. Petti, Gerald P. Linette, Obi L. Griffith, Elaine R. Mardis, and Malachi Griffith. pVACseq: A genome-guided in silico approach to identifying tumor neoantigens. Genome Medicine. 2016, 8:11, DOI: 10.1186/s13073-016-0264-5. PMID: 26825632."),
                                        br(),
                                        strong("Portable version"),
                                        p("The whole pipeline for ImmuneMirror is available on GitHub. The pipeline starts from the fastq data for both whole-exome sequencing and RNA sequencing datasets."),
                                        br(),
                                        strong("Getting help"),
                                        p("Please contact Gulam Sarwar Chuwdhury for help.")
                                        
                                      )
                                      
                             ),
                             tabPanel("Contact us",
                                      
                                      fluidRow(column(width=2),
                                               column(
                                                 h4(p("Bug reports or relevant enquiries can be submitted below.")),
                                                 width=8,style="background-color:#BFF7BB;border-radius: 10px")),
                                      hr(),
                                      sidebarPanel(
                                        mailtoR(email = "immunemirror2021@gmail.com",
                                                text = "Click here to send an email."),
                                        use_mailtoR()
                                        
                                      )
                                      
                             )
                             
                             
                  )))
