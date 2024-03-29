Fuzzy2Hab <-
function(
  mrt.x,                  # Column name for the distance to the nucleus.
  mrt.y,                  # Column name for the elemental concentration.
  data,                   # Name of the dataframe to analyse (must be charged).
  Dens1,                  # Results of Density function for habitat 1.
  Dens2,                  # Results of Density function for habitat 2.
  loess=FALSE,            # Loess of the probability function (instead of raw data).
  span=0.05,              # The parameter 'alpha' which controls the degree of smoothing of the loess.
  Graph=FALSE,            # To (additionally) plot the distributions of the two habitats.
  W=TRUE                  # To open new windows. Must be turned off for the fonction 'Proba1', so that graphs will be printed in a PDF file.
)
{
  # Preliminary (package & arguments) 
  if (is.function(Dens1$NFun)==FALSE){
    stop("Invalid density estimation - Dens1 must be generated by the Dens function")
  }
  if (is.function(Dens2$NFun)==FALSE){
    stop("Invalid density estimation - Dens2 must be generated by the Dens function")
  }
  if(missing(data)|missing(mrt.x)|missing(mrt.y)){
    stop("Data is missing")
  }
  
  # Data acquisition & Modelling  
  y.data<-na.omit(data[,mrt.y])
  x.data<-data[which(data[,mrt.y]!="NA"),mrt.x]
  if(Dens1$Mode>Dens2$Mode) {
    Dens1->a;Dens1<-Dens2;Dens2<-a    
  }
  
  D1<-Dens1$NFun(y.data)
  D2<-Dens2$NFun(y.data)
    
  Equivocal<-rep(0,length=length(x.data))
    for(i in 1:length(x.data)){
      if (y.data[i]>Dens1$Min & y.data[i]<Dens1$Max & y.data[i]>Dens2$Min & y.data[i]<Dens2$Max) {
        Equivocal[i]<-"Equivocal"
      } else {
        if (xor(y.data[i]>Dens1$Min & y.data[i]<Dens1$Max,y.data[i]>Dens2$Min & y.data[i]<Dens2$Max)) {
          Equivocal[i]<-"Assigned"
        } else {Equivocal[i]<-"Unassigned"}
      }
    }
  Equivocal<-as.factor(Equivocal)
  if(any(levels(Equivocal)=="Equivocal")){
    Equ<-100/length(x.data)*length(which(Equivocal=="Equivocal"))
  } else {
    Equ<-0
  }
  if(any(levels(Equivocal)=="Unassigned")){
    Una<-100/length(x.data)*length(which(Equivocal=="Unassigned"))
  } else {
    Una<-0
  }
  if(any(levels(Equivocal)=="Assigned")){
    Ass<-100/length(x.data)*length(which(Equivocal=="Assigned"))
  } else {
    Ass<-0
  }
  if (loess=="TRUE"){
    p.loess<- loess(D1 ~ x.data, span=span, method="loess")
    q.loess<- loess(D2 ~ x.data, span=span, method="loess")
  }
  #   dev.off()
  #   par(oma=c(1,1,1,1)mar=c(1,1,1,1))
  plot(c(min(x.data),max(x.data)),c(0,1.2),ylab="Relative probability",yaxt="n",xlab="Distance from primordium (??m)",main="Habitat assignement probability");x<-par("usr")  #A vector of the form c(x1, x2, y1, y2)   #segments(x0, y0, x1, y1,
  axis(side=2, at=seq(from=0,to=1,by=0.2))
  rect(x[1],x[3],x[2],x[4],col="grey")
  rect(x[1],1,x[2],x[4],col="grey60")
  if (loess=="TRUE"){
    polygon(c(min(x.data),x.data,max(x.data)),c(0,p.loess$fitted,0),col="white",border = NA )
    polygon(c(min(x.data),x.data,max(x.data)),c(0,q.loess$fitted,0),col="white",border = NA )
    polygon(c(min(x.data),x.data,max(x.data)),c(0,p.loess$fitted,0),col="#FF404075",border = NA )
    polygon(c(min(x.data),x.data,max(x.data)),c(0,q.loess$fitted,0),col="#483D8B99",border = NA )
    lines(x.data,p.loess$fitted,type="l",lwd=1,col="black");lines(x.data,q.loess$fitted,type="l",lwd=1,col="black")
    rect(x[1],x[3],x[2],0,col="grey")
  } else {
    polygon(c(min(x.data),x.data,max(x.data)),c(0,D1,0),col="white",border = NA )
    polygon(c(min(x.data),x.data,max(x.data)),c(0,D2,0),col="white",border = NA )
    polygon(c(min(x.data),x.data,max(x.data)),c(0,D1,0),col="#FF404075",border = NA )
    polygon(c(min(x.data),x.data,max(x.data)),c(0,D2,0),col="#483D8B99",border = NA )
    lines(x.data,D1,type="l",lwd=1,col="black");lines(x.data,D2,type="l",lwd=1,col="black")
  }
  abline(h=c(Dens1$LP,Dens1$RP,Dens2$LP,Dens2$RP),lty=c(2,2,2,2),lwd=c(1,1,1,1),col=c("red","red","blue","blue"))
  points(c(x[1],x[1]),c(Dens1$LP,Dens1$RP),col="red",pch=18,cex=2)
  points(c(x[2],x[2]),c(Dens2$LP,Dens2$RP),col="blue",pch=18,cex=2)
  legend("top",inset=0.02,c("Habitat 1: ","Habitat 2: "),horiz=T,fill=c("#FF404075","#483D8B75"))
  
  if(Graph=="TRUE"){
    if(W==TRUE) dev.new()
    maxyplot<-max(D1,D2)*1.05
    minxplot<-min(y.data)
    maxxplot<-max(y.data)
    x<-seq(minxplot,maxxplot,0.1)
    plot(x,ylim=c(0, maxyplot),xlim=c(minxplot,maxxplot),type="n",ylab="Density probability",xlab="Elemental concentration")
    title(main=paste("Density probability for habitats at ",Dens1$IC*100,"%")) 
    dim<-par("usr")
    polygon(c(min(x), x, max(x)), c(0, Dens1$NFun(x), 0), col="#FF404075", border=NA)
    polygon(c(min(x), x, max(x)), c(0, Dens2$NFun(x), 0), col="#483D8B75", border=NA)
#     rug(y.data)
    abline(v=c(Dens1$Min,Dens1$Max,Dens2$Min,Dens2$Max),col=c("red","red","blue","blue"))
    xx1<-seq(Dens1$Min,Dens1$Max,0.1)
    polygon(c(Dens1$Min, xx1, Dens1$Max), c(0,Dens1$NFun(xx1), 0), col="#FF404050", border=NA)
    xx2<-seq(Dens2$Min,Dens2$Max,0.1)
    polygon(c(Dens2$Min, xx2, Dens2$Max), c(0,Dens2$NFun(xx2), 0), col="#483D8B50", border=NA)
    text(Dens1$Min,Dens1$NFun(Dens1$Min),pos=3, paste(round(Dens1$Min),2), col="black")
    text(Dens1$Max,Dens1$NFun(Dens1$Max),pos=3, paste(round(Dens1$Max),2), col="black")
    text(Dens2$Min,Dens2$NFun(Dens2$Min),pos=3, paste(round(Dens2$Min),2), col="black")
    text(Dens2$Max,Dens2$NFun(Dens2$Max),pos=3, paste(round(Dens2$Max),2), col="black")
    rug(y.data[which(y.data>Dens1$Min & y.data<Dens1$Max)],col="red")
    rug(y.data[which(y.data>Dens2$Min & y.data<Dens2$Max)],col="blue")
#     rug(y.data[which(y.data>Dens1$Max & y.data>Dens2$Max)],col="black")
#     rug(y.data[which(y.data<Dens1$Min & y.data<Dens1$Min)],col="black")
    rug(y.data[which(Equivocal=="Unassigned")],col="black")
    rug(y.data[which(Equivocal=="Equivocal")],col="grey")
  }
    #   main informations
  cat("For sample '");cat(mrt.y);cat("':");cat("\n")
  if(any(levels(Equivocal)=="Equivocal")){
    cat("   - ");cat(round(Equ,2));cat(" % of equivocal assignation given the ");cat(Dens1$IC);cat(" confidence interval");cat("\n")
  } else {
    cat("   - ");cat("No equivocal assignation given the ");cat(Dens1$IC);cat(" confidence interval");cat("\n")
  }
  if(any(levels(Equivocal)=="Unassigned")){
    cat("   - ");cat(round(Una,2));cat(" % of unassigned data given the ");cat(Dens1$IC);cat(" confidence interval");cat("\n")
  } else {
    cat("   - ");cat("No unassigned data given the ");cat(Dens1$IC);cat(" confidence interval");cat("\n")
  }
 
  
  #   return
  ans<-list(Equivocal=Equ,Unassigned=Una,Assigned=Ass)
}
