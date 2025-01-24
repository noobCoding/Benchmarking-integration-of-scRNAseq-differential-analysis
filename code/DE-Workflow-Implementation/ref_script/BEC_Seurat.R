#raw count as input count=rawcount
run_Seurat<-function(count, cellinfo,former.meth=''){
  library(Seurat)
  rownames(cellinfo)=cellinfo$Cell
  cellinfo<-cellinfo[colnames(count),]
  cellinfo$Group%<>%factor()
  cellinfo$Batch%<>%factor()
  seurat_normalized <- CreateSeuratObject(counts = count, project = '', min.cells = 0, min.features = 0, meta.data = cellinfo)
  seurat_normalized<-SCTransform(seurat_normalized,variable.features.n=nrow(seurat_normalized),ncells = ncol(seurat_normalized),return.only.var.genes = F,conserve.memory = F, batch_var='Batch', n_genes=NULL,min_cells=0,method='glmGamPoi')

  res<-seurat_normalized
  processed<-seurat_normalized@assays$SCT@data
  
  res_name<-paste0(ifelse(former.meth=='','',paste0(former.meth,'+')),'Seurat')
  save(res,processed,cellinfo, file=paste0('./',res_name,'.rda'))
  return(res_name)
}