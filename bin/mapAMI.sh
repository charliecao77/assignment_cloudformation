#!/usr/bin/env bash
if [ "$#" -ne 2 ];then
  echo "[Error ] Missing parameter: $0 prefix ami_number"
  echo "[Error ] Missing parameter: $0 'Amazon Linux AMI 2017.03' 1"
  exit 1
fi
prefix_str=$1
ami_number=$2
echo "Searching for image where name begins with $1"
regions=$(aws ec2 describe-regions --output text --query 'Regions[*].RegionName')
for region in $regions; do
    (
    echo -e "$region:"\\n " "\"AMALINUX\" : $(aws ec2 describe-images --region $region --filters "Name=owner-id,Values=137112412989" "Name=description,Values=$prefix_str*x86_64 HVM GP2" "Name=virtualization-type,Values=hvm" "Name=root-device-type,Values=ebs" "Name=state,Values=available"|jq -c '.Images[] | {ImageId, Name, Description,VirtualizationType,State}'|jq .ImageId|head -n $ami_number) "#$prefix_str"
    ) 
done
