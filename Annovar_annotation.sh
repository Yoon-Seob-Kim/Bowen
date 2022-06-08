#!/bin/bash
ANNO_DIR=./05_Annovar
for T in Annovar3
do
/data/MRC1_data4/kysbbubbu/tools/annovar/table_annovar.pl $ANNO_DIR/$T\.txt /data/MRC1_data4/kysbbubbu/genomicdb/humandb -buildver hg19 -out $ANNO_DIR/$T -remove -protocol refGene,cytoBand,cosmic95_coding,cosmic95_noncoding,icgc28,exac03,gnomad211_exome,clinvar_20220320,dbnsfp42a,avsnp150 -operation g,r,f,f,f,f,f,f,f,f -nastring . -otherinfo
done
