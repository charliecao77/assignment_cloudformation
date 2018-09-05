# assignment_cloudformation
Configuring an AWS instance with logging and core OS patches
Objective: Install td‐agent (from fluentd) onto an EC2 instance using a CloudFormation StackSet  
1. Launch an EC2 instance (t2.micro) that uses Amazon Linux 2017.3 within a VPC  
2. Associate a Security Group to the instance to allow ssh access  
3. Apply the appropriate OS patches (may use yum for the purposes of this exercise)  
4. Install fluentd (and pre‐requesites) form the source
5. Configure fluentd to parse the Linux syslog and write to a KMS key encrypted S3 bucket
(directory path should be the instance ID)
You may have a separate StackSet to create the S3 bucket and to configure the KMS key for its usage,
appropriate resource IAM roles and the proposed SecurityGroup  
The Stackset for the instance configuration should include references to bash scripts that may be
needed to complete the above tasks. You can use a directory path in the S3 bucket to stage the binaries
and the bash scripts for use with CloudFormation
CloudFormation should be written in YAML (though for aspects such as policies, JSON usage is
acceptable)
Please note any assumptions that have been made (VPC configuration / setup, role / permissions
needed by the AWS console user for execution of the CloudFormation scripts, etc.)
Approach will be reviewed for completeness and ability to replicate the execution to create the desired
outcomes
Please package all the components into a zip file. A readme (can be a word document or a markdown
file) outlining the assumptions and steps should be included in the root folder)

