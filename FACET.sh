#!/bin/bash
#SBATCH -J FACET
#SBATCH -N 1
#SBATCH -n 8
#SBATCH -o %x.o%j
#SBATCH -e %x.e%j
#SBATCH -p mrcs
#SBATCH -w Zeta
#tool_path
DB=/data/MRC1_data4/kysbbubbu/genomicdb

##OUTPUT
BAM_DIR=./02_BAM
FACET_DIR=./06_FACET2
list1="1N 1N 1N 2N 2N 2N 3N 3N 3N 3N"
list2="1T1 1T2 1T3 2T1 2T2 2T3 3T1 3T2 3T3 3T4"
echo $list1 | sed 's/ /\n/g' > /tmp/c.$$
echo $list2 | sed 's/ /\n/g' > /tmp/d.$$
paste /tmp/c.$$ /tmp/d.$$ | while read item1 item2; do
cnv_facets.R -t $BAM_DIR/$item2\_b37.bam -n $BAM_DIR/$item1\_b37.bam -vcf $DB/00-common_all.vcf.gz -bq 20 -mq 30 -T $DB/SureselectV5.bed -g hg19 -a $DB/Sensus_v92.bed -o $FACET_DIR/$item2
done
rm /tmp/c.$$
rm /tmp/d.$$


