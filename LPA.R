#!/usr/bin/env Rscript
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("plotutils.R")



bed = fread('../sd_regions_in_hifi_wga/lpa/all.gene.models.bed', col.names = c("contig", "starto","endo", "target", "qual", "strand","sample","hap"));bed$len = bed$endo - bed$starto; bed
bed = merge(bed, fread("../assemblies_for_anlysis/sample_info/Master.tbl"), all.x=T); bed
bed$lab = paste(bed$sample, bed$hap, bed$Population, sep="_")


bed = data.table(bed %>% group_by(lab) %>% mutate( clength = max(endo)))
bed$starto2 = bed$clength - bed$endo
bed$endo2 = bed$clength - bed$starto

bed[bed$sample == "HG002",]$SuperPop = "EUR"
bed = data.table(bed %>% group_by(lab) %>% mutate( clength = max(endo2), start = starto2 - min(starto2), end = endo2-min(starto2)))




bed$SuperPop = factor(bed$SuperPop, levels = sort(unique(bed$SuperPop)))
bed$lab = factor(bed$lab, levels = rev(unique(bed$lab[order(bed$SuperPop)])) )

bed = bed[order(bed$SuperPop), ]

p=ggplot(data=bed, aes(color=SuperPop) )+
  geom_segment(aes(x=start, xend=end, y=lab, yend=lab), size=6)+
  #scale_x_continuous( expand = c(0, 0), limits = c(1,max(df$end)),breaks = c(1,max(df$end)) ) +
  geom_segment(data = bed %>% group_by(lab,SuperPop) %>% summarise(start=min(start), end=max(end)), aes(x=start, xend=end, y=lab, yend=lab))+
  ylab('')+xlab('')+
  theme_classic()+
  scale_x_continuous(label = comma)   +
  scale_color_brewer(palette = "Set1")+
  #facet_grid(lab~.)+
  theme_cowplot(font_size = 22)+
  theme(plot.margin=margin(1,1,1,1, 'cm'), axis.line.y =  element_blank(), axis.ticks.y = element_blank(), legend.position = "top");p

#ggsave( "gene_models.pdf", plot=p, height = 9/1.5, width = 16/1.5)



#g=plot_grid(p2, NULL, p, labels = c('a','c', 'b'));g
#ggsave("fig.pdf", plot = g, height = 12, width = 16)

#ggdraw() + draw_image("aln.png", scale = 0.7)



paf = fread("../minigraph/lpa/out.paf", fill=T, header=F)[,1:12]; colnames(paf) = c("q", "qle", "qst", "qen", "strand", "t", "tle", "tst", "ten", "x","y","z"); paf; unique(paf$t)
ggplot(data=paf) +geom_segment(aes(x=tst, xend=ten, y=q, yend=q, color=q)) + facet_wrap(vars(t), ncol=length(unique(paf$t)), scales="free_x") +theme_cowplot() + theme(legend.position = "none")


