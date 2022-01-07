#!/bin/bash

job_id=$1
hlas=$2
peplength=$3
email_=$4
fname2=$5
peplength2=$6
ref=$7

dir=/var/pipeline
work_dir=$dir/$job_id
#input=/var/pipeline/empt

#vep_input=$input/input_${job_id}.vcf

#pp=$(bcftools query -l $vep_input | tail -1)
#echo "$pp"

printf "ImmuneMirror (version 1.0),\n Developed by Dr. Wei's Research Team\n Department of Clinical Oncology,\n The University of Hong Kong.\n"
echo "=========================================="

mkdir -p $dir/${job_id}_outputs
tar -czvf $dir/${job_id}_outputs.tar.gz $dir/${job_id}_outputs
job_outputs=http://immunemirror.hku.hk/ImmuneMirror/${job_id}_outputs.tar.gz
R CMD BATCH '--args email_="'$email_'" file="'$job_outputs'" id="'$job_id'"' $dir/pipeline/submit_job.r $work_dir/submit_job.Rout
rm -r $dir/${job_id}_outputs.tar.gz $dir/${job_id}_outputs
## ===================================================================

if [ $ref == "b37" ]
then 
fname=$(bcftools query -l /var/pipeline/$job_id/empt/input_${fname2}.vcf)
mv /var/pipeline/$job_id/empt/input_${fname2}.vcf /var/pipeline/$job_id/empt/${fname2}.vcf
sample=$fname
else
{
fname=$(bcftools query -l /var/pipeline/$job_id/empt/input_${fname2}.vcf | tail -1)
if [ $fname == "TUMOR" ]
then
echo "TUMOR $fname2" >/var/pipeline/$job_id/empt/tmp.txt
bcftools reheader -s /var/pipeline/$job_id/empt/tmp.txt /var/pipeline/$job_id/empt/input_${fname2}.vcf -o /var/pipeline/$job_id/empt/${fname2}.vcf
sample=$fname2

else
tumor_sample=$(bcftools view --header-only /var/pipeline/$job_id/empt/input_${fname2}.vcf | grep '##tumor_sample=' | cut -c 16-)
cp /var/pipeline/$job_id/empt/input_${fname2}.vcf /var/pipeline/$job_id/empt/${fname2}.vcf
sample=$tumor_sample
fi
}
fi
###echo "$tumor_sample" | cut -c 16- # cut first 15 chars

###mv /var/pipeline/$job_id/empt/input_${job_id}.vcf /var/pipeline/$job_id/empt/input_${fname}.vcf

StartTime=`date`
printf "Job Start Time: $StartTime\n"
printf "Your job is running....... please wait for the results!\n"
echo "=================================================================================="
echo "Job ID: $job_id"
echo "File name: ${fname2}.vcf"
echo "Sample name: $sample"
echo "Alleles: $hlas"
echo "Peptide lengths (Class I): $peplength"
echo "Peptide lengths (Class II): $peplength2"
echo "Referece genome: $ref"
echo "Emial: $email_"
echo "==================================================================================="


echo "Your job has been Started............................"

StartTime=`date`

echo "Job Start Time: $StartTime"
echo "======================================================"
printf "\n"

thread=15

mkdir -p $work_dir/logs
logs=$work_dir/logs
mkdir -p $work_dir/tmp

processDay=`date +%Y%m%d`


  echo ${currentTime}"\tstart VEP......................................."
      type=ESCC
        pipeline=$dir/pipeline/HLA/vcf.vep2.RNA.sh
        RNA_id=$dir/Ref/RNA_data/${type}.quant.id.sf
        bash $pipeline $job_id $hlas $email_ $RNA_id $work_dir $fname2 $ref 1>$logs/${processDay}_${sample}.VEP 2>&1
 
  mkdir -p $work_dir/pvac_output
  output_pvac=$work_dir/pvac_output
  
  echo ${currentTime}"Start pvacseq tool for MHC-peptide binding prediction......................................."

  pipeline=$dir/pipeline/HLA/pvacseq.RNA.sh 
  bash $pipeline $hlas $output_pvac $thread $work_dir $fname2 $sample $peplength $peplength2 1>$logs/${processDay}_${sample}.pvacseq 2>&1
  
  echo ${currentTime}"Start antigen.garnish......................................."
  pipeline=$dir/pipeline/HLA/antigen.garnish.net.sh
  bash $pipeline $sample $output_pvac/MHC_Class_I/${sample}.filtered.tsv $output_pvac/MHC_Class_I 1>$logs/${processDay}_${sample}.pvacseq_ClassI.ag 2>&1
  
  pipeline=$dir/pipeline/HLA/antigen.garnish.sh
  bash $pipeline $sample $output_pvac/MHC_Class_II/${sample}.filtered.tsv $output_pvac/MHC_Class_II 1>$logs/${processDay}_${sample}.pvacseq_ClassII.ag 2>&1
  
  echo ${currentTime}"Start Prediction by our ML method......................................."
  pipeline=$dir/pipeline/HLA/predict.sh
  
  bash $pipeline $sample $output_pvac/MHC_Class_I $output_pvac/MHC_Class_I 1>$logs/${processDay}_${sample}.predict_ClassI.ag 2>&1  
 

printf "\n"

echo "================================================================================="
echo "Your job has been completed!"

EndTime=`date`

printf "Your job has been finished!\n"
printf "Browse the results located in $job_id \n"

printf "Job Completion Time: $EndTime\n"

#tar -czvf $dir/${job_id}.tar.gz $dir/${job_id}
#job_dir=http://immunemirror.hku.hk/ImmuneMirror/${job_id}.tar.gz

mkdir -p $dir/${job_id}_outputs
mkdir -p $dir/${job_id}_outputs/Original_input_vcf_file
mkdir -p $dir/${job_id}_outputs/MHC_Class_I_Prediction_Output


cp /var/pipeline/$job_id/empt/input_${fname2}.vcf $dir/${job_id}_outputs/Original_input_vcf_file
mv $dir/${job_id}_outputs/Original_input_vcf_file/input_${fname2}.vcf $dir/${job_id}_outputs/Original_input_vcf_file/${fname2}.vcf

lift_file=/var/pipeline/$job_id/empt/${fname2}.hg38.vcf
if test -f $lift_file; then
  mkdir -p $dir/${job_id}_outputs/LiftOverFile
  cp $lift_file $dir/${job_id}_outputs/LiftOverFile
fi

predict_file=/var/pipeline/$job_id/empt/pvac_output/MHC_Class_I/${sample}.features.netctlpan.predict.tsv
if test -f $predict_file; then
  cp $predict_file $dir/${job_id}_outputs/MHC_Class_I_Prediction_Output
else 
 echo "No neoantigen was identified for your sample."> $dir/${job_id}_outputs/MHC_Class_I_Prediction_Output/${sample}.features.netctlpan.predict.tsv
fi

tar -czvf $dir/${job_id}_outputs.tar.gz $dir/${job_id}_outputs

job_outputs=http://immunemirror.hku.hk/ImmuneMirror/${job_id}_outputs.tar.gz

R CMD BATCH '--args email_="'$email_'" file="'$job_outputs'" id="'$job_id'"' $dir/pipeline/send.r $work_dir/send.Rout




