#!/bin/bash
#SBATCH -J germline
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -o %x%j.o
#SBATCH -e %x%j.e
#SBATCH -p mrcs
#SBATCH -w Theta

#tool_path
GATK=/data/MRC1_data4/kysbbubbu/tools/gatk-4.2.1.0
DB=/data/MRC1_data4/kysbbubbu/genomicdb
FUNCTO=/data/MRC1_data4/kysbbubbu/genomicdb/funcotator/funcotator_dataSources.v1.7.20200521s

##OUTPUT
BAM_DIR=./02_BAM
MT_DIR=./04_MT
ANNO_DIR=./05_Annovar
FUNCO_DIR=./05_FUNCTO

$GATK/gatk --java-options "-Xmx4g -Xms4g" GenomicsDBImport --genomicsdb-workspace-path ./workspace --tmp-dir /home/kysbbubbu/temp --sample-name-map cohort_map.txt -L $DB/germline.list 
$GATK/gatk --java-options "-Xmx4g" GenotypeGVCFs -R $DB/human_g1k_v37.fasta -V gendb://workspace -O $MT_DIR/germline.vcf.gz
$GATK/gatk --java-options "-Xmx4g" VariantRecalibrator -R $DB/human_g1k_v37.fasta -V $MT_DIR/germline.vcf.gz --resource:hapmap,known=false,training=true,truth=true,prior=15.0 $DB/hapmap_3.3.b37.vcf  --resource:omni,known=false,training=true,truth=false,prior=12.0 $DB/1000G_omni2.5.b37.vcf  --resource:1000G,known=false,training=true,truth=false,prior=10.0 $DB/1000G_phase1.snps.high_confidence.b37.vcf --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $DB/dbsnp_138.b37.vcf -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR -mode SNP --max-gaussians 4 -O output.AS.recal --tranches-file output.AS.tranches
$GATK/gatk --java-options "-Xmx4g" VariantRecalibrator -R $DB/human_g1k_v37.fasta -V $MT_DIR/germline.vcf.gz --resource:hapmap,known=false,training=true,truth=true,prior=15.0 $DB/hapmap_3.3.b37.vcf  --resource:omni,known=false,training=true,truth=false,prior=12.0 $DB/1000G_omni2.5.b37.vcf  --resource:1000G,known=false,training=true,truth=false,prior=10.0 $DB/1000G_phase1.snps.high_confidence.b37.vcf --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $DB/dbsnp_138.b37.vcf -an QD -an ReadPosRankSum -an FS -an SOR -mode SNP --max-gaussians 4 -O output.AS.recal --tranches-file output.AS.tranches
$GATK/gatk --java-options "-Xmx4g" ApplyVQSR -R $DB/human_g1k_v37.fasta -V $MT_DIR/germline.vcf.gz -O $MT_DIR/germline_filt.vcf --tranches-file output.AS.tranches --recal-file output.AS.recal -mode SNP
rm output.AS.recal output.AS.tranches output.AS.recal.idx
find . -type f -name "*.config" -exec rm {} \;
find . -type f -name "*.so" -exec rm {} \;
awk -F '\t' '{if($7== NULL) print; else if($7 == "FILTER") print ; else if($7 == "PASS") print}' $MT_DIR/germline_filt.vcf > $MT_DIR/germline_filt2.vcf
$GATK/gatk SelectVariants -R $DB/human_g1k_v37.fasta -V $MT_DIR/germline_filt2.vcf --select-type-to-include SNP -O $MT_DIR/germline_filt3.vcf
$GATK/gatk Funcotator --data-sources-path $FUNCTO -V $MT_DIR/germline_filt3.vcf -L $DB/Sensus_v95.list -LE true --output $FUNCO_DIR/germline.txt --output-file-format MAF --ref-version hg19 -R $DB/human_g1k_v37.fasta --force-b37-to-hg19-reference-contig-conversion --sites-only-vcf-output

