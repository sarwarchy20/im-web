args=(commandArgs(TRUE))
for(i in 1:length(args)){
    eval(parse(text=args[[i]]))
    }
cat(email_,'\n')
cat(file,'\n')
cat(id,'\n')

print(paste("Click the link to download the outputs:",file, sep = " "))

library(magrittr)
#install.packages("emayili")
library(emayili)


email <- envelope(
  to = email_,
  from = "immunemirror2021@gmail.com",
  subject = paste("Your job has been completed! (job id:",id,")", sep=""),
  text = paste("Please go to the link to download the outputs:",file, sep = " ")
)

smtp <- emayili :: server(host = "smtp.gmail.com",
               port = 587,
               username = "immunemirror2021@gmail.com",
               password = "5*Mu2021")

smtp(email, verbose = TRUE)
