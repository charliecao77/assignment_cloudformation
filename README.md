# assignment_cloudformation
Configuring an AWS instance with logging and core OS patches
Objective: Install td‐agent (from fluentd) onto an EC2 instance using a CloudFormation StackSet  
- [x] 1. Launch an EC2 instance (t2.micro) that uses Amazon Linux 2017.3 within a VPC  
- [x] 2. Associate a Security Group to the instance to allow ssh access  
- [x] 3. Apply the appropriate OS patches (may use yum for the purposes of this exercise)  
- [x] 4. Install fluentd (and pre‐requesites) form the source
- [ ] 5. Configure fluentd to parse the Linux syslog and write to a KMS key encrypted S3 bucket
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


# How to parse syslog and write into S3 with td-agent
###### [Ref link](https://docs.fluentd.org/v0.12/articles/recipe-syslog-to-s3)
- Install td-agent (which is a stable community distribution of Fluentd)
```
## td-agent 2.5 or later. Only CentOS/RHEL 6 and 7 for now.
$ curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.5.sh | sh
## td-agent 2.3 or earlier (Adapte for Amazon Linux) 
$ curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.sh | sh
```

- fluentd.conf should look like this (just copy and paste this into fluentd.conf):
```
<source>
  @type syslog
  port 5140
  bind 0.0.0.0
  tag system.local
</source>

<match **>
  @type s3
  path <s3 path> #(optional; default="")
  time_format <format string> #(optional; default is ISO-8601)
  aws_key_id <Your AWS key id> #(required)
  aws_sec_key <Your AWS secret key> #(required)
  s3_bucket <s3 bucket name> #(required)
  s3_endpoint <s3 endpoint name> #(required; ex: s3-us-west-1.amazonaws.com)
  s3_object_key_format <format string> #(optional; default="%{path}%{time_slice}_%{index}.%{file_extension}")
  auto_create_bucket <true/false> #(optional; default=true)
  check_apikey_on_start <true/false> #(optional; default=true)
  proxy_uri <proxy uri string> #(optional)
</match>
```

 - After that, you can start fluentd and everything should work:
```
$ fluentd -c fluentd.conf
```

  Of course, this is just a quick example. If you are thinking of running fluentd in production, consider using td-agent, the enterprise version of Fluentd packaged and maintained by Treasure Data, Inc..
  
  
  
