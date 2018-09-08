# assignment_cloudformation
# Configuring an AWS instance with logging and core OS patches
# Objective: Install td‐agent (from fluentd) onto an EC2 instance using a CloudFormation StackSet

# Deployment Guide for running on AWS console
## Steps
- Download and unzip file jianyuancao_assignment.zip
- Login and Open the AWS CloudFormation Service with a Console (Register one if don't have one :-) )
- Create an IAM user cfnadmin(with AdministratorAccess policy, Skip this step if you already login with one) which will be used to run the under CloudFormation Template deployment
  - Access type - AWS Management Console access
  - Console password - Custom password
  - Require password reset - check out
  - Set permissions for IAM user cfnadmin
  - Attach existing policies directly
  - Check-in Policy name - AdministratorAccess
- Login AWS console with the user cfnadmin(or, the existing one with AdministratorAccess policy)
  - Open the EC2 service
  - navigate to Key Pairs(show on the left side of the window )
  - Click the button [Create Key Pair] and fill out the name 'LoginAssignmentEC2' in the popup window, and Create
  - Change the Key file LoginAssignmentEC2.pem read only by root
    - $ chmod 400 LoginAssignmentEC2.pem
  - Create an S3 Bucket 'jianyuancao-assignment-code'(or the one you prefer) and upload CloudFormantion Template files, and Make them public (read access only)
    - GenerateRole.yml
    - GenerateKMS.yml
    - GenerateBucket.yml
    - GenerateSecurityGroup.yml
    - GenerateEC2.yml
  - Run Stack, and [choose file] main.yml, click the button next then go on 
  - Stack name - could be the one you prefer, like 'test-jyc-assignment'
  - CFNTemplateS3 - fill out the Bucket name,which was created above and contained those CloudFormation Template files in S3
  - VPCId - Choose the default one (which was attached the InternetGateway)
  - EnvironmentSize - default is t1.micro
  - SSHKeyname - choose 'LoginAssignmentEC2' (the one created before) for ssh login the EC2 Server
  - InstallSourceTdAgent - skip
  - SyslogCollectInterval - choose %Y%m%d%H%M (for testing only, that's why didn't set it as a default value)
  - SyslogUploadS3Interval - change to 5 (for testing only)
  - Click button next 
  - Nothing need to do on page Option, just click the button next
  - On the Review Page, check in 'I acknowledge that AWS CloudFormation might create IAM resources with custom names.'
  - then, click button Create. and waiting for CloudFormation Complete the deployment on AWS.

# Verify Guide
the syslog files will be automatically upload to the S3 bucket under the prefix EC2 instance ID
## Steps
- Login the AWS console
  - open the bucket which was automatically created by above deployment in S3
    - check the Bucket Stack Output, the Stack name as prefix
- Monitor the bucket content
  - waitting around 10 minutes will see the Instance Id in the Bucket
  - click the Instance Id, will see the log files with suffix ".gz"
  


 

 
