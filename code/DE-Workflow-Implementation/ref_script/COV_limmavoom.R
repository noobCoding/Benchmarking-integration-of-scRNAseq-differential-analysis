#raw count or pseudobulk data as input processed=rawcount
run_limmavoom<-function(processed,cellinfo,cov=T,former.meth=''){
  library(edgeR)
  library(limma)
  count_df<-processed
  rownames(cellinfo)=cellinfo$Cell
  cellinfo<-cellinfo[colnames(processed),]
  cellinfo$Group%<>%factor()
  cellinfo$Batch%<>%factor()
  
  cellinfo.cov<-cellinfo[,c('Group','Batch')]
  nf <- calcNormFactors(count_df)
  if(cov){
    design<-model.matrix(formula(paste(c("~ Group", setdiff(colnames(cellinfo.cov),c('Group'))), collapse = '+')), data=cellinfo.cov)
  }else{
    design <- model.matrix(~Group, data=cellinfo.cov)
  }
  voom.data <- limma::voom(count_df, design = design, lib.size = colSums(count_df) * nf)
  voom.data$genes <- rownames(count_df)
  voom.fitlimma <- limma::lmFit(voom.data, design = design)
  voom.fitbayes <- limma::eBayes(voom.fitlimma)
  pvalues <- voom.fitbayes$p.value[, 2]
  adjpvalues <- p.adjust(pvalues, method = 'BH')
  logFC <- voom.fitbayes$coefficients[, 2]
  res <- data.frame('pvalue' = pvalues, 'adjpvalue' = adjpvalues, 'logFC' = logFC)
  rownames(res) <- rownames(processed)
  
  res_name<-paste0(ifelse(former.meth=='','',paste0(former.meth,'+')),'limmavoom',ifelse(cov,'_Cov',''))
  save(res, cellinfo, file=paste0('./',res_name,'.rda'))
  return(res_name)
}
