
export PATH=/root/anaconda3/bin/:/root/anaconda3/lib/python3.7/site-packages:$PATH
  python --version
  which python
  
export PERL5LIB=/opt/vep-102:${PERL5LIB}

export PATH=/opt/vep-102/htslib:$PATH
echo $PATH

job_id=$1
hlas=$2
email_=$3
exprs=$4
work_dir=$5
sample=$6 # fname2
ref=$7
thread=15
dir=/var/pipeline

mkdir -p $work_dir/vep_output
output=$work_dir/vep_output

input=/var/pipeline/$job_id/empt
vep_input=$input/${sample}.vcf

refpre=$dir/Ref/v27/vep/GRCh38.p10.genome.fa.gz
#https://data.broadinstitute.org/snowman/hg19/
#refPre1=/var/pipeline/Ref/GATK_bundle/hg38/Homo_sapiens_assembly38.fasta
#refPre2=/var/pipeline/Ref/GATK_bundle/hg19/ucsc.hg19.fasta
refPre3=/var/pipeline/Ref/b37/hg19_v0_Homo_sapiens_assembly19.fasta

#====================== Liftover ============
change_=0
picard=/opt/picard-2.17.4
gatk=/opt/gatk-4.1.8.0/gatk

if [ $ref == "hg19" ] 
then
	lift=hg19ToHg38
	change_=1
	
elif [ $ref == "b37" ] 
then
	lift=b37ToHg38
	change_=2
	#$gatk --java-options "-Xmx20g" SelectVariants 
	#--tmp-dir $work_dir/tmp
	$gatk SelectVariants \
	-R $refPre3 \
	-V $input/${sample}.vcf \
	--select-type-to-include SNP \
	-O $input/${sample}.SNP.vcf
	
else 
 echo "You select: $ref, No need to liftover!"
fi

if [ $change_ -eq 1 ] 
then
echo "===================================================== Liftover: $lift" 
java -jar $picard/picard.jar LiftoverVcf \
I=$input/${sample}.vcf \
O=$input/${sample}.hg38.vcf \
CHAIN=$dir/Ref/liftoverdoc/${lift}.over.chain \
REJECT=$input/${sample}_rejected_variants.vcf \
R=$refpre
vep_input=$input/${sample}.hg38.vcf

elif [ $change_ -eq 2 ]
then
echo "============================================================ Liftover: $lift" 
java -jar $picard/picard.jar LiftoverVcf \
I=$input/${sample}.SNP.vcf \
O=$input/${sample}.hg38.vcf \
CHAIN=$dir/Ref/liftoverdoc/${lift}.over.chain \
REJECT=$input/${sample}_rejected_variants.vcf \
R=$refpre
vep_input=$input/${sample}.hg38.vcf
fi
# ================================================


echo "------------------------------------ Start vep-annotator...... "

gtf=$dir/Ref/v27/vep/gencode.v27.annotation.gtf.gz

vep_path=/opt/vep-102

echo "Vep input: $vep_input"

$vep_path/./vep \
		--input_file $vep_input --output_file $output/${sample}.vcf \
		--format vcf --vcf --symbol --terms SO --tsl \
		--hgvs --fasta $refpre \
		--gtf $gtf \
		--plugin Downstream --plugin Wildtype --plugin Frameshift \
		-dir_plugins /opt/vep-102/VEP_plugins



#/root/anaconda3/bin/vcf-expression-annotator $output/${sample}.vcf $exprs --id-column Name --expression-column TPM -s ${sample} custom transcript -o $output/${sample}.tx.vcf







