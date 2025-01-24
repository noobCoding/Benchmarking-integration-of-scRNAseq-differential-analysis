library(readr)
library(magrittr)
library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(stringr)
base_dir='set base directory/'
setwd(base_dir)
analysis_script_dir=base_dir##Can set different directory. Directory contains scripts for real data analysis(visualization, clustering, correlation, gsea, ...).
standard_positive_dir=base_dir##Can set different directory. Directory contains standard positive data for real data analysis(Data for selecting known disease genes, survival analysis results for prognostic genes, GO biological pathway data, wikipathway geneset for gsea, scLUAD standard positive pathways ...).
source(paste0(analysis_script_dir,'EVAL_Functions for visualization.R'))
for(fdr_cut in c(0.05)){
  {
    `%ni%`<-Negate(`%in%`)
    analyze_with='TCGA'
    # methods_to_plot=list(Main_figure=c('Raw_Wilcox','MAST_Cov','DESeq2','ZW_DESeq2','DESeq2_FEM','edgeR_Cov','ZW_edgeR_Cov','limmatrend_Cov', 'LogN_FEM', 'RISC_QP','Pseudobulk_DESeq2','Pseudobulk_edgeR','Pseudobulk_limmavoom','Pseudobulk_limmatrend','TCGA_DESeq2','TCGA_edgeR','TCGA_limmavoom','TCGA_limmatrend'))
    methods_to_plot=list(Main_figure=c('Raw_Wilcox','MAST_Cov','DESeq2','ZW_DESeq2','DESeq2_FEM','edgeR_Cov','ZW_edgeR_Cov','limmatrend_Cov', 'LogN_FEM', 'RISC_QP','Pseudobulk_DESeq2','Pseudobulk_edgeR','Pseudobulk_limmavoom','Pseudobulk_limmatrend'))
  }
  for(ref in c('Known disease genes','Prognostic genes')){
    if(ref=='Known disease genes'){
      source(paste0(analysis_script_dir,'/EVAL_Known disease gene selection.R'))
      ref_genes<-Known_disease_genes
      ref_weight<-Known_disease_genes_weight
    }else if(ref=='Prognostic genes'){
      # Need to run 'Prognostic gene selection(survival_analysis).R' first
      meta.res<-read.table(paste0(standard_positive_dir,'survival_analysis_result.txt'))
      Prognostic_genes<-rownames(meta.res)[meta.res$FDR<0.05]
      Prognostic_genes_weight=rep(1,length(Prognostic_genes))
      ref_genes<-Prognostic_genes
      ref_weight<-Prognostic_genes_weight
    }else if(ref=='Standard Positive genes(GO:0051607)'){
      source(paste0(analysis_script_dir,'/EVAL_Standard positive gene selection(GO:0051607).R'))
      ref_genes<-Standard_Positive_gene_COVID19
      ref_weight<-Standard_Positive_gene_COVID19_weight
    }
    names(ref_weight)=ref_genes
    for(sort.meth in c('pvalue')){
      load(paste0('DE_result_analyzed_with_',analyze_with,'_',sort.meth,'_sorted_fdr_',fdr_cut,'_cut.rda'))
      draw_plot(result.list=result.list,methods_to_plot=methods_to_plot,ref=ref,ref_genes=ref_genes,ref_weight=ref_weight,
                sort.meth=sort.meth,fdr_cut=fdr_cut,plot_topn_genes=c(0.2))
    }
  }
}
