# assignment_cloudformation
# Configuring an AWS instance with logging and core OS patches
# Objective: Install td‐agent (from fluentd) onto an EC2 instance using a CloudFormation StackSet  

# Deployment Guide
## Steps
- Download and unzip file jianyuancao_assignment.zip
- Login and Open the AWS CloudFormation Service with a Console (Register one if don't have :))
- Create a IAM user cfnadmin(with AdministratorAccess policie,Skip this step if you already login it) which will be used to run the CloudFormation Template
  - Access type - AWS Management Console access
  - Console password - Custom password
  - Require password reset - check out
  - Set permissions for IAM user cfnadmin
    - Attach existing policies directly
    - Check in Policy name - AdministratorAccess
- Login AWS console with the user cfnadmin
- Open the EC2 service
  - navigate to Key Pairs(show in the left side )
  - Click the button [Create Key Pair] and fill out the name 'LoginAssignmentEC2' in the pop up window, and Create
  - Change the Key file LoginAssignmentEC2.pem read only by root
    - $ chmod 400 LoginAssignmentEC2.pem
- Create a S3 Bucket 'jianyuancao-assignment-code'(or the one you prefer) and upload CloudFormantion Template files, and Make them public can read access to them
  - GenerateRole.yml
  - GenerateKMS.yml
  - GenerateBucket.yml
  - GenerateSecurityGroup.yml
  - GenerateEC2.yml
- replace the bucket name in 'TemplateURL' in the file main.yml, if the above bucket name is not 'jianyuancao-assignment-code'
- Run Stack, and [choose file] main.yml, click button next then go on 
  - Stack name - could be the one you prefer, like 'test-jyc-assignment'
  - CFNTemplateS3 - A Bucket name which contains CloudFormation Template files in S3
  - VPCId - Choose the default one (which was attached the InternetGateway)
  - EnvironmentSize - default is t1.micro
  - SSHKeyname - choose 'LoginAssignmentEC2' (the one created before) for ssh login the EC2 Server
  - InstallSourceTdAgent - skip
  - SyslogCollectInterval - choose %Y%m%d%H%M (for testing only, that's why didn't set it as default value)
  - SyslogUploadS3Interval - change to 5 (for testing only)
  - Click button next 
  - No thing need to do on page Option, just click button next
  - On the Review Page, check in 'I acknowledge that AWS CloudFormation might create IAM resources with custom names.'
  - then, click button Create. and waiting for CloudFormation Complete the deployment on AWS.
 
 # Verify Guide
 the syslog files will be automatically upload to the S3 bucket under the prefix EC2 instance ID
 ## Steps
 - Login the AWS console
 - open the bucket which was created in above deployment in S3
   - the bucket name show in the Bucket stack Output
 - Monitor the bucket content
   - show the prefix as EC2 instance id
   - show the log files under the prefix,ex: *.gz
   - the log file number is increasing with time estimate
   
  

 
