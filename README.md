# LepMap3_Scripts
Various scripts associated with using LepMap3 to create genetic maps from SNP data. Each script contains a description of what it does and how it works.

LM_ScaffInformed_StartingOrder.pl : LepMap3's OrderMarkers2 can take a starting order of markers within a linkage group. This script generates a starting order
                                    based on the order of markers on the scaffolds in your genome assembly. Each run of the script will produce a starting order
                                    that keeps within-scaffold marker order intact, but randomly i) reverses the orientation of the scaffolds and ii) randomly
                                    orders the scaffolds within the linkage groups. 


LM_FindBestOrder.sh:                Using 10 replicates of the output of each LM_ScaffInformed_StartingOrder.pl, runs OrderMarkers2 and summarises the likelihood of each 
                                    run into an output folder. Repeats this in parallel for each chromosome. Is a slurm submission script.
