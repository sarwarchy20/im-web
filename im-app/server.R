
#shiny::runApp(host = "147.8.100.163", port = 5050)

#setwd("/root/im-app")

if(Sys.getenv('SHINY_PORT') == "") options(shiny.maxRequestSize=10*1024*1024^2)
#l <- list('class I' = c("",8:15),"class II" = c("",11:30))
allele <- read.table("mhc.txt",header = F)$V1
server <- function(input,output,session) {
  #output$secondSelection <- renderUI({
    #selectInput(inputId = 'length', 
               # label = 'Select peptide length (NOTE: range for HLA class I is 8-15 and for 
                                                #class II is 11-30, multiple lengths are possible', 
                #choices = l[input$type],multiple = TRUE)
  #})
  # upload data
    
  
  
  rv <- reactiveValues(data = NULL,len1i=NULL,hlao=NULL,len2i=NULL, emli=NULL, ck="",even=FALSE)
  

    iv <- InputValidator$new()
    iv$add_rule("VCF", sv_required())
    iv$add_rule("emaili", sv_required())
    iv$add_rule("emaili", sv_email())
    iv$enable()
  
  
  observe({
    
    rv$hlao=input$HLA
    rv$len1i=input$length1
    rv$len2i=input$length2
    eml2<- gsub(" ", "",input$emaili, fixed = TRUE)
    rv$emli <- eml2
    
    req(input$VCF)
    if(rv$ck!=""){
      if(rv$ck==input$VCF$datapath)
      {
        rv$data<-NULL 
      }
      else
        rv$data <- input$VCF
      }
    else
      rv$data <- input$VCF
   
  })

  half <- reactive({
    words <- unlist(strsplit(input$HLA, ","))
    rv$even <- 'FALSE' %in% (words %in% allele)
    shinyFeedback::feedbackWarning("HLA", rv$even, "Please type in valid allele name(s)")
    rv$hlao=input$HLA
    input$HLA    
    #print(even)
  })
  
  output$half <- renderText({
    paste0("Your input: ", half())})
  
  observeEvent(input$reset, {
    rv$data <- NULL
    rv$ck<-input$VCF$datapath
    reset('VCF')
  }) 
  
  observeEvent(input$reset1, {
    rv$hlao <- NULL
    reset('HLA')
  })
  
  observeEvent(input$reset2, {
    rv$len1i<- NULL
    reset('length1')
  })
  
  observeEvent(input$reset3, {
    rv$len2i<- NULL
    reset('length2')
  })
  
  observeEvent(input$reset4, {
    rv$emli <- NULL
    reset('emaili')
  })
  
  
  
  observe(
    {
      #print("yes........")
      #print(input$length1)
      #print(rv$len2i)
      #print(rv$len1i)
      #print(rv$hlao)
      #print(rv$data)
      #print(input$geno)
      #print(rv$emli)
      
      if(!is.null(rv$len1i) && !is.null(rv$len2i) && !(is.null(rv$data)||rv$data==1) && !is.null(input$geno) 
          && !(is.null(rv$hlao)||rv$hlao==""|| rv$even==TRUE) && !(is.null(rv$emli)||rv$emli==""))
      {
        enable("submit")
      }
      else
      {
        disable("submit")
      }
    })
  
  observeEvent(input$submit, {
    hlas<-input$HLA
    eml2<- gsub(" ", "",input$emaili, fixed = TRUE)
    inemail<-eml2
    #print(eml2) # print email address
    vcfdir<-input$VCF$datapath
    fname<-input$VCF$name
    #print(input$length1)
    
    peplen1<-combine_words(input$length1, and = "", sep = ",", before = "")
    length1 = nchar(peplen1)
    if(length1<5)
    {
      peplen1<-combine_words(input$length1, and = ",", sep = ",", before = "")
    }
    #pepln1<- gsub(" ", "",len1, fixed = TRUE)
    
    peplen2<-combine_words(input$length2,and = "", sep = ",", before = "")
    length2 = nchar(peplen2)
    if(length2<5)
    {
      peplen2<-combine_words(input$length2, and = ",", sep = ",", before = "")
    }
    #pepln2<- gsub(" ", "",len2, fixed = TRUE)
    
    ref <- input$geno
    
    #print("Submitted!!")
    #print(ref)
    #print(peplen1)
    #print(peplen2)
    #print(vcfdir)
    #print(inemail)
    
    job_id <- system(paste("/var/www/immunemirror.hku.hk/ImmuneMirror/docker_run.sh ",vcfdir,hlas,peplen1,inemail,fname,peplen2,ref, sep = " "), intern = TRUE)
    #showNotification(print(paste0("Your job has been submitted.","Job ID: ", job_id[1])))
    
    showNotification("Your job has been submitted.\n Results will be sent to your email when it is ready!");                
    
    reset('VCF')
    #system(paste("chmod 777",input$VCF$datapath, sep=" "), intern = T)
    #system(paste("rm",input$VCF$datapath, sep=" "), intern = T)
    rv$data <-NULL
    rv$ck<-input$VCF$datapath
    rv$len1i <-rv$len2i <- rv$hlao <-rv$emli<- NULL
    rv$even <- FALSE
   
    #disable("submit")
  })



}
