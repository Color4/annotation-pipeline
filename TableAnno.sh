#!/bin/sh
#PBS -N ANNOVAR
cd $DIR
file="$FILE.anno"
DATADIR="/data/Clinomics/Ref/annovar/"
TOOL="/usr/local/apps/ANNOVAR/2015-03-22/"
CUSTOM="$CODE/addAnnotation.pl"
BUILD=hg19
###############################
# Add gene, cytoband,dbsnp, 1000g, ESP, CG69, NCI60 annotations
#
###############################
$TOOL/table_annovar.pl\
	$file\
	$DATADIR\
	-buildver ${BUILD}\
	-out $file\
	-remove\
	-protocol refGene,cytoBand,snp138,1000g2014oct_all,1000g2014oct_eur,1000g2014oct_afr,1000g2014oct_amr,1000g2014oct_eas,1000g2014oct_sas,esp6500_all,esp6500_ea,esp6500_aa,cg69,nci60\
	-operation g,r,f,f,f,f,f,f,f,f,f,f,f,f\
	-nastring "-1"
mv $file.hg19_multianno.txt $file.gene

###############################
# Add ExAC annotation
#
###############################
$TOOL/annotate_variation.pl\
	$file\
	$DATADIR\
	-buildver ${BUILD}\
	-otherinfo\
	-filter\
	-dbtype exac03

awk '{OFS="\t"};{print $3,$4,$5,$6,$7,$2}' $file.${BUILD}_exac03_dropped |sed -e 's/,/\t/g' >$file.exac.3
head -1 $DATADIR/${BUILD}_exac03.txt >>$file.exac.3
rm -rf $file.${BUILD}_exac03_dropped $file.${BUILD}_exac03_filtered
################################
# Add clinseq annotation
#
################################
$TOOL/annotate_variation.pl\
	$file\
	$DATADIR\
	-buildver ${BUILD}\
	-otherinfo\
	-filter\
	-dbtype generic\
	-genericdbfile ${BUILD}_clinseq_951.txt

awk '{OFS="\t"};{print $3,$4,$5,$6,$7,$2}' $file.${BUILD}_generic_dropped |sed -e 's/,/\t/g' >$file.clinseq
head -1 $DATADIR/${BUILD}_clinseq_951.txt >>$file.clinseq
rm -rf $file.${BUILD}_generic_dropped $file.${BUILD}_generic_filtered
################################
# Add CADD annotation
#
################################
$TOOL/annotate_variation.pl\
	$file\
	$DATADIR\
	-buildver ${BUILD}\
	-otherinfo\
	-filter\
	-dbtype cadd


$TOOL/annotate_variation.pl\
	$file\
	$DATADIR\
	-buildver ${BUILD}\
	-otherinfo\
	-filter\
	-dbtype caddindel

cut -f 2-7 $file.${BUILD}_cadd_dropped $file.${BUILD}_caddindel_dropped |sed -e 's/,/\t/g' |awk '{OFS="\t"};{print $3,$4,$5,$6,$7,$1,$2}' >$file.cadd
head -1 $DATADIR/${BUILD}_caddindel.txt >>$file.cadd
rm -rf $file.${BUILD}_cadd_dropped $file.${BUILD}_cadd_filtered $file.${BUILD}_caddindel_dropped $file.${BUILD}_caddindel_filtered
################################
# Add Clinvar and COSMIC
#
################################
$TOOL/table_annovar.pl\
	$file\
	$DATADIR\
	-buildver ${BUILD}\
	-out $file\
	-remove\
	-protocol clinvar_20150330,cosmic70\
	-operation f,f\
	-nastring "NA"
mv $file.hg19_multianno.txt $file.clinvar
################################
# Add PCG 
#
################################
$TOOL/annotate_variation.pl\
	$file\
	$DATADIR\
	-buildver ${BUILD}\
	-otherinfo\
	-filter\
	-dbtype generic\
	-genericdbfile ${BUILD}_PediatricGenome.11.24.14.txt
awk -F "\t" '{OFS="\t"};{print $3,$4,$5,$6,$7,$2}' $file.${BUILD}_generic_dropped |sed -e 's/,/\t/g' >$file.pcg
head -1 $DATADIR/${BUILD}_PediatricGenome.11.24.14.txt >>$file.pcg
rm -rf $file.${BUILD}_generic_dropped $file.${BUILD}_generic_filtered
################################
# Add HGMD
#
################################
OUT=`echo $file |sed -e 's/.anno//g'`
$CUSTOM $DATADIR/${BUILD}_hgmd.2014.3.txt $file >$OUT.hgmd
################################
# Add MATCH Trial
#
################################
$CUSTOM $DATADIR/${BUILD}_MATCHTrial_v3_02_2015.txt $file >$OUT.match
################################
# Add MyCG
#
################################
$CUSTOM $DATADIR/${BUILD}_MCG.02.27.15.txt $file >$OUT.mcg
################################
# Add DoCM
#
################################
$CUSTOM $DATADIR/${BUILD}_DoCM.txt $file >$OUT.docm
################################
# Add GermlineActionable
#
################################
$CUSTOM $DATADIR/${BUILD}_GermlineActionable.txt $file >$OUT.germline
################################
# Add Uveal Melanoma
#
################################
$CUSTOM $DATADIR/${BUILD}_uveal_melanoma.txt $file >$OUT.uvm
################################
#
#
################################
rm -rf $file.invalid_input
rm -rf $file.refGene.invalid_input
rm -rf $file.log
rm -rf $file.anno.log 
