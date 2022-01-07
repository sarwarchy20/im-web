#!/bin/bash

 job_id=`date +%s`
 
 mkdir -p /var/www/immunemirror.hku.hk/ImmuneMirror/$job_id
 
 vcf_file=$1
 hlas=$2
 peplength=$3
 email_=$4
 fname=$5
 peplength2=$6
 ref=$7
 
 echo $job_id
 
 fname2=`echo $fname | rev | cut -c 5- | rev` # remove '.vcf', keep only the file name part
 
 cp $vcf_file /var/www/immunemirror.hku.hk/ImmuneMirror/$job_id
 rm $vcf_file
 
 mv /var/www/immunemirror.hku.hk/ImmuneMirror/$job_id/0.vcf /var/www/immunemirror.hku.hk/ImmuneMirror/$job_id/input_${fname2}.vcf
 
 

#hlas=HLA-A*01:01,HLA-A*02:03,HLA-B*39:09,HLA-B*57:01,HLA-C*06:02,HLA-C*07:02
#peplength=8,9,10,11
#email_=sarwar20@hku.hk

sudo docker run -it -d --rm=TRUE \
-v /var/www/immunemirror.hku.hk/ImmuneMirror/:/var/pipeline/ \
-v /var/www/immunemirror.hku.hk/ImmuneMirror/$job_id/:/var/pipeline/$job_id/empt \
-v /root/HMRF/Ref/:/var/pipeline/Ref/ \
im3_server4:1.0 ./ImmuneMirror.sh $job_id $hlas $peplength $email_ $fname2 $peplength2 $ref
