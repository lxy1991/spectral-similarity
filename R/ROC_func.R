
#' ROC function for looking at FPR vs. TPR and graphing possibilites
#'
#' @param realdata 
#' @param randdata 
#' @param metricList 
#' @param steps 
#' @param specScenario 
#' @param PandRplot 
#' @param legend.lab 
#' @param save.data 
#' @param aucs 
#' @param fPvfN 
#'
#' @return
#' @export
#'
#' @examples
ROC <- function(realdata, randdata, metricList = metricList, steps = 0.001,
                specScenario = "AllFragments", PandRplot = TRUE, legend.lab = metricList, save.data = TRUE, aucs = TRUE, fPvfN = TRUE){
  
  # library(pROC)
  
  #   if(metricList %in% colnames(realdata) == FALSE){
  #     print("Metrics not in realdata!")
  #     stop
  #       }
  # 
  #   if(metricList %in% colnames(randdata) == FALSE){
  #     print("Metrics not in realdata!")
  #     stop
  #   }
  
  
  # pandr <- data.frame(matrix(data = NA, nrow = 1/steps, ncol = 3))
  #  colnames(pandr) <- c("Threshold", "False pos", "True pos")
  
  #  if(save.data == TRUE){
  PandRList <- list()
  ROCList <- list()
  # }
  
  if(aucs == TRUE){
    aucs.dat <- data.frame(matrix(data = NA, ncol = 4, nrow = length(metricList)))
  }
  
  if(fPvfN == TRUE){
    miscal <- data.frame(matrix(NA, nrow = length(metricList), ncol = 3))
  }
  
  for(k in 1:length(metricList)){
    
    pandr <- data.frame(matrix(data = NA, nrow = 1/steps, ncol = 3))
    colnames(pandr) <- c("Threshold", "False pos", "True pos")
    
    metric <- metricList[k]
    real.npair <- length(na.omit(realdata[,paste(metric)]))
    rand.npair <- length(na.omit(randdata[,paste(metric)]))
    
    
    for(i in 1:(1/steps+1)){
      
      thres <- (i-1)*steps
      pandr[i,1] <- thres
      pandr[i,2] <- length(which(randdata[,paste(metric)] > thres)) / real.npair
      pandr[i,3] <- length(which(realdata[,paste(metric)] > thres)) / rand.npair
      
    }
    
    pandr[,4] <- 1 - pandr[,"True pos"]
    colnames(pandr) <- c("Threshold", "False pos", "True pos", "False neg")
    
    colnames(miscal) <- c("Metric", "minimum misclassification", "sim threshold")
    miscal[k,1] <- paste(metric)
    miscal[k,2] <- min(pandr[,2]+pandr[,4])
    miscal[k,3] <- pandr[which.min(pandr[,2]+pandr[,4]), 1]
    
    
    #if(save.data == TRUE){
    pandr$metric <- c(rep(metric, 1/steps+1))
    PandRList[[k]] <- pandr
    #   name(PandRList[k]) <- metric
    #   return(PandRList)
    #  }
    
    rocdat <- data.frame(matrix(ncol = 2, nrow = nrow(randdata) + nrow(realdata))) 
    rocdat[,1] <- c(realdata[,paste(metric)], randdata[,paste(metric)])
    rocdat[,2] <- c(rep("True", nrow(realdata)), rep("Random", nrow(randdata)))
    ROCList[[k]] <- rocdat
    
    if(aucs == TRUE){
      rocauc <- roc(rocdat[,2], rocdat[,1], levels = c("True", "Random"), plot=FALSE, auc = TRUE, ci = TRUE)
      aucs.dat[k,1] <- metric
      aucs.dat[k,2] <- as.numeric(rocauc$ci[1])
      aucs.dat[k,3] <- as.numeric(rocauc$ci[2])
      aucs.dat[k,4] <- as.numeric(rocauc$ci[3])
      
    }
    
  }
  
  if(fPvfN == TRUE){
    
    metcol <- rainbow(length(metricList))
    
    for(k in 1:length(metricList)){
      
      pandr <- PandRList[[k]]
      
      if(k == 1){
        png(filename = paste("fPvfN ", specScenario, ".png", sep = "")#, height = 1060, width = 1060
        )
        plot.new()
        box()
        title(main = paste(specScenario, "False Positives vs. False Negatives Plot", sep = " "))
        axis(side = 1)
        axis(side = 2)
        mtext(side = 1, "Similarity Score Threshold", line = 2.5)
        mtext(side = 2, "Misclassification Rate", line = 2.5)
        
        #    points(pandr[,1], pandr[,2], col = metcol[k], pch = 4)
        #    points(pandr[,1], pandr[,4], col = metcol[k], pch = 16)
        points(pandr[,1], pandr[,2]+pandr[,4], col = metcol[k], pch = 19)
        
        
      }else{
        #  points(pandr[,1], pandr[,2], col = metcol[k], pch = 4)
        #  points(pandr[,1], pandr[,4], col = metcol[k], pch = 16)
        points(pandr[,1], pandr[,2]+pandr[,4], col = metcol[k], pch = 19)
        
      }
      
      if(k == length(metricList)){
        #abline(v = 0.05, lty = 2)
        #abline(h = 0.95, lty = 2)
        grid(col = "darkgray")
        legend("bottomright", legend = legend.lab, col = metcol, pch = 19, cex = 1.2, #title = "Combinations",
               ncol = ifelse(length(metricList)>8,2,1))
        
        dev.off()
      }
      
    }
  }
  
  
  if(PandRplot == TRUE){
    
    metcol <- rainbow(length(metricList))
    
    for(k in 1:length(metricList)){
      
      rocdat <- ROCList[[k]]
      
      if(k == 1){
        png(filename = paste(specScenario, "_ROC.png", sep = ""))
        #  plot.new()
        #  box()
        #  title(main = paste(specScenario, "ROC Plot", sep = " "))
        #  axis(side = 1)
        #  axis(side = 2)
        #  mtext(side = 1, "False positive rate (FPR)", line = 2.5)
        #  mtext(side = 2, "True positive rate (TPR)", line = 2.5)
        
        roc(rocdat[,2], rocdat[,1], levels = c("True", "Random"), plot=TRUE, auc = FALSE, col = metcol[k], main = paste(specScenario, " ROC Plot"),
            cex = 1.4)
        
        
      }else{
        roc(rocdat[,2], rocdat[,1], levels = c("True", "Random"), plot=TRUE, auc = FALSE, add = TRUE, col = metcol[k], cex = 1.4)
        
      }
      
      if(k == length(metricList)){
        #abline(v = 0.05, lty = 2)
        #abline(h = 0.95, lty = 2)
        grid(col = "darkgray")
        legend("bottomright", legend = legend.lab, col = metcol, pch = 19, cex = 1.2, #title = "Combinations",
               ncol = ifelse(length(metricList)>8,2,1))
        
        dev.off()
      }
      
    }
    
  }
  
  if(save.data == TRUE){
    output <- do.call(rbind, PandRList)
    write.csv(output, file = paste("PandRList_", specScenario, ".csv", sep = ""))
    print(paste("Saved PandRList to ", getwd(), sep = ""))
  }
  
  if(aucs == TRUE){
    colnames(aucs.dat) <- c("Scenario", "95% CI lower", "AUC", "95% CI upper")
    write.csv(aucs.dat, file = paste("AUCs_", specScenario, ".csv", sep = ""))
    print(paste("Saved AUC table to ", getwd(), sep = ""))
  }
  
  if(fPvfN == TRUE){
    write.csv(miscal, file = paste("Miscal_", specScenario, ".csv", sep = ""))
    print(paste("Saved Misclassification table to ", getwd(), sep = ""))
  }
  # return(PandRList)
}
