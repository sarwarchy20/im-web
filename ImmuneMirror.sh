#!/bin/bash

job_id=$1
hlas=$2
peplength=$3
email_=$4
fname2=$5
peplength2=$6
ref=$7

mkdir -p /var/pipeline/$job_id/tmp
mkdir -p /var/pipeline/$job_id/logs

processDay=`date +%Y%m%d`
bash /var/pipeline/pipeline/ImR_job.sh $job_id $hlas $peplength $email_ $fname2 $peplength2 $ref 1>/var/pipeline/$job_id/logs/job_${job_id}.log 2>&1

