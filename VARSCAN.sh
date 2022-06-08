#!/bin/bash
#SBATCH -J VARSCAN
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -o %x%j.o
#SBATCH -e %x%j.e
#SBATCH -p mrcs
#SBATCH -w Zeta
#tool_path
GATK=/data/MRC1_data4/kysbbubbu/tools/gatk-4.2.5.0
DB=/data/MRC1_data4/kysbbubbu/genomicdb
VARSCAN=/data/MRC1_data4/kysbbubbu/tools/Varscan2

##OUTPUT
BAM_DIR=./02_BAM
MT_DIR=./04_MT
FUNCTO=/data/MRC1_data4/kysbbubbu/genomicdb/funcotator/funcotator_dataSources.v1.7.20200521s
FUNCO_DIR=./05_FUNCTO
VARSCAN_DIR=./08_VARSCAN
N=3N
T=3T4
samtools mpileup -q 20 -Q 20 -f $DB/human_g1k_v37.fasta $BAM_DIR/$N\_b37.bam -l $DB/SureselectV5.bed -o $VARSCAN_DIR/$N\.pileup
samtools mpileup -q 20 -Q 20 -f $DB/human_g1k_v37.fasta $BAM_DIR/$T\_b37.bam -l $DB/SureselectV5.bed -o $VARSCAN_DIR/$T\.pileup
java -jar $VARSCAN/VarScan.v2.3.9.jar somatic $VARSCAN_DIR/$N\.pileup $VARSCAN_DIR/$T\.pileup $VARSCAN_DIR/$T --min-coverage-normal 20 --min-coverage-tumor 20 --min-coverage 20 --strand-filer 1 --output-vcf
java -jar $VARSCAN/VarScan.v2.3.9.jar processSomatic $VARSCAN_DIR/$T\.indel.vcf
$GATK/gatk Funcotator --data-sources-path $FUNCTO -V $VARSCAN_DIR/$T\.indel.Somatic.hc.vcf --output $FUNCO_DIR/$T\_indel.txt --output-file-format VCF --ref-version hg19 -R $DB/human_g1k_v37.fasta --force-b37-to-hg19-reference-contig-conversion --disable-sequence-dictionary-validation


