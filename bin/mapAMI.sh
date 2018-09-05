#!/usr/bin/env bash
if [ "$#" -ne 2 ];then
  echo "[Error ] Missing parameter: $0 prefix ami_number"
  exit 1
fi
prefix_str=$1
ami_number=$2
echo "Searching for image where name begins with $1"
regions=$(aws ec2 describe-regions --output text --query 'Regions[*].RegionName')
for region in $regions; do
    (
    echo -e "$region:" \\n \"AMALINUX\" : $(aws ec2 describe-images --region $region --owners amazon --filters "Name=description,Values=$prefix_str*x86_64 ECS HVM GP2" "Name=virtualization-type,Values=hvm" "Name=root-device-type,Values=ebs" "Name=state,Values=available"|jq -c '.Images[] | {ImageId, Name, Description,VirtualizationType,State}'|jq .ImageId|head -n $ami_number)
     #echo -e "$region : \n$( aws ec2 describe-images --owners self amazon --region $region|grep -B 29 "\<${prefix_str}.*GP2\>"|grep 'ImageId'|head -n $ami_number)"|sed "s/,/  #$prefix_str/g"
    ) 
done
