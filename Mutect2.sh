#!/bin/bash
#SBATCH -J Bowen
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -o %x%j.o
#SBATCH -e %x%j.e
#SBATCH -p mrcs
#SBATCH -w Zeta
#tool_path
GATK=/data/MRC1_data4/kysbbubbu/tools/gatk-4.2.5.0
DB=/data/MRC1_data4/kysbbubbu/genomicdb
FUNCTO=/data/MRC1_data4/kysbbubbu/genomicdb/funcotator/funcotator_dataSources.v1.7.20200521s

##OUTPUT
BAM_DIR=./02_BAM
MT_DIR=./04_MT
FUNCO_DIR=./05_FUNCTO

list1="1N 1N 1N 2N 2N 2N 3N 3N 3N 3N"
list2="1T1 1T2 1T3 2T1 2T2 2T3 3T1 3T2 3T3 3T4"
echo $list1 | sed 's/ /\n/g' > /tmp/e.$$
echo $list2 | sed 's/ /\n/g' > /tmp/f.$$
paste /tmp/e.$$ /tmp/f.$$ | while read N T; do
$GATK/gatk --java-options "-Xmx4g" Mutect2 -R $DB/human_g1k_v37.fasta -I $BAM_DIR/$N\_b37.bam -I $BAM_DIR/$T\_b37.bam -normal $N --intervals $DB/SureselectV5.list --f1r2-tar-gz $MT_DIR/$T\.tar.gz --germline-resource $DB/af-only-gnomad.raw.sites.b37.vcf.gz -O $MT_DIR/$T\.vcf 
$GATK/gatk --java-options "-Xmx4g" CalculateContamination -I $MT_DIR/$T\_pileups.table -matched $MT_DIR/$N\_pileups.table -O $MT_DIR/$T\_contamination.table
$GATK/gatk --java-options "-Xmx4g" LearnReadOrientationModel -I $MT_DIR/$T\.tar.gz -O $MT_DIR/$T\_cal.tar.gz
$GATK/gatk --java-options "-Xmx4g" FilterMutectCalls -V $MT_DIR/$T\.vcf --ob-priors $MT_DIR/$T\_cal.tar.gz -R $DB/human_g1k_v37.fasta --intervals $DB/SureselectV6.list -O $MT_DIR/$T\_filt.vcf
awk -F '\t' '{if($7== NULL) print; else if($7 == "FILTER") print ; else if($7 == "PASS") print}' $MT_DIR/$T\_filt.vcf > $MT_DIR/$T\_filt2.vcf
$GATK/gatk SelectVariants -R $DB/human_g1k_v37.fasta -V $MT_DIR/$T\_filt2.vcf --select-type-to-include SNP -O $MT_DIR/$T\_filt3.vcf
$GATK/gatk Funcotator --data-sources-path $FUNCTO -V $MT_DIR/$T\_filt3.vcf -L $DB/SureselectV5.list -LE true --output $FUNCO_DIR/$T\.txt --output-file-format MAF --ref-version hg19 -R $DB/human_g1k_v37.fasta --force-b37-to-hg19-reference-contig-conversion --sites-only-vcf-output
done
rm /tmp/e.$$
rm /tmp/f.$$

