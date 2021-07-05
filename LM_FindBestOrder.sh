#!/bin/bash --login
#SBATCH -o batch_LM_4.5_.%A.out.txt
#SBATCH -e batch_LM_4.5_.%A.err.txt
#SBATCH --ntasks=12
#SBATCH --time=12:00:00
#SBATCH --partition=htc

module load parallel;

#Function:
#Generates 10 random starting orders based on LM_ScaffInformed_StartingOrder.pl for each chromosome, and runs OrderMarkers2 based on this. 
#Records the likelihood of these for each run in $dir/OrderSummary.$dat.txt
#Does this in parallel for each chromosome.


#Inputs
export dir="/scratch/b.bssc1d/Linkage_Mapping";
export sepchrom="SepChrom.txt"; #Output of java -cp ~/LepMap3/bin SeparateChromosomes2 > SepChrom.txt
export filtered="Filtered.txt"; #Output of java -cp ~/LepMap3/bin Filtering2.txt > Filtered.txt
export dat=$(date +Y%_%m_%d);
chrom_num=12; #Maximum chromosome number you're interested in (default starts at 1).
#Note - values to be used inside the bash function need to be exported.

#Outputs:
#For each chromosome 1-N; 
#$sepchrom.LG.N.1, $sepchrom.LG.N.2... $sepchrom.LG.N.10: 10 random starting orientations for each chromosome.
#$dir/$sepchrom.LG.N.1.order... #The resulting 10 orders for each of these starting orientations (output of OrderMarkers2).
#$dir/OrderSummary.dat.txt: tab separated file with i) chromosome number ii) order file iii) likelihood of that order.

#####

#Gets an array with one element per chromosome..
array=($(seq 1 1 $chrom_num));

#Set up a summary file...
truncate -s 0 $dir/OrderSummary.$dat.txt; 

#You could probably further parallelise this but it doesn't really take that long. 

estchrom () {
	echo $1; 
	#Repeats each OrderMarkers2 step (with a starting order defined by LM_ScaffInformed_StartingOrder.pl) 10 times by default
	for i in {1..10}; 
		do echo $i;  echo $1;
		#Generates the starting order
		echo $1; perl ~/LepMap3_Scripts/LM_ScaffInformed_StartingOrder.pl $dir/$sepchrom $dir/$filtered $1 $i; 
		#Estimates the starting order based on this
		java -cp ~/LepMap3/bin OrderMarkers2 data=$dir/$filtered map=$dir/$sepchrom grandparentPhase=1 chromosome=$1 numThreads=1 evaluateOrder=$dir/$sepchrom.LG.$1.$i> $dir/$sepchrom.LG.$1.$i.order; 
		
		#Recording the likelihood of the resulting order.
		likeline=$(grep likelihood $dir/$sepchrom.LG.$1.$i.order); 
		likeline=${likeline/*= /}; #Rempves everything up to the equals...
		printf "$1\t$dir/$sepchrom.LG.$1.$i.order\t$likeline" >> $dir/OrderSummary.$dat.txt;
	done;
} 
export -f estchrom;
#Runs these 10 replicates for each chromosome in parallel
#Change -j 12 if you have more/less chromosomes..
parallel -j 12 --delay 0.2 "estchrom {1}" ::: ${array[@]};

