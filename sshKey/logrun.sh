if [ $# -ne 1 ];then
  echo "example: $0 52.206.148.202"
  exit 1
fi
ipaddress=$1
ssh -i assignmentCFN.pem ec2-user@$ipaddress

