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
- A running instance of rsyslogd
- Install td-agent (which is a stable community distribution of Fluentd)
```
## td-agent 2.5 or later. Only CentOS/RHEL 6 and 7 for now.
$ curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.5.sh | sh
## td-agent 2.3 or earlier (Adapte for Amazon Linux) 
$ curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.sh | sh
```
# Start a small testing first
####### [Ref_link](https://www.fluentd.org/guides/recipes/parse-syslog)

## Setting up rsyslogd
Go to /etc/rsyslogd.conf and add the following line:
```
*.* @127.0.0.1:42185
```
Restart the rsyslog, to active this setting
```
service rsyslog restart
```
This line tells rsyslogd to forward local system logs to port 42185 to which Fluentd will listen.

## Setting up Fluentd
In this section, we will evolve our Fluentd configuration step-by-step.
#### Step 1: Listening to syslog messages
First, let's configure to listen to syslog messages.
Edit /etc/td-agent/td-agent.conf to look like this:
```
<source>
  @type syslog
  port 42185
  tag system
</source>

<match system.**>
  @type stdout
</match>
```
This is the most basic setup: it listens to all syslog messages and logs them to stdout.
Now, let's restart td-agent:
```
$ sudo service td-agent restart
```
Let's confirm data is coming in. Here is what my log looks like:
```
$ sudo tail /var/log/td-agent/td-agent.log
```
(One can always "force" a syslog event with the logger command like logger -t foo.bar "hello world")
```
2014-06-01 19:41:28 +0000 system.kern.info: {"host":"precise64","ident":"kernel","message":"[49851.032200] docker0: port 2(veth6091) entering disabled state"}
2014-06-01 19:41:29 +0000 system.daemon.info: {"host":"precise64","ident":"ntpd","pid":"3289","message":"Deleting interface #11 veth6091, fe80::540b:1aff:fe1f:810c#123, interface stats: received=0, sent=0, dropped=0, active_time=4 secs"}
2014-06-01 19:41:29 +0000 system.daemon.info: {"host":"precise64","ident":"ntpd","pid":"3289","message":"peers refreshed"}
2014-06-01 19:41:44 +0000 system.authpriv.notice: {"host":"precise64","ident":"sudo","message":"vagrant : TTY=pts/3 ; PWD=/home/vagrant ; USER=root ; COMMAND=/usr/bin/vim /var/log/td-agent/td-agent.log"}
```
#### Step 2: Parsing the details of sudo calls.
Now, let's look at a sudo message like this one.
> 2014-06-01 19:41:44 +0000 system.authpriv.notice: {"host":"precise64","ident":"sudo","message":"vagrant : TTY=pts/3 ; PWD=/home/vagrant ; USER=root ; COMMAND=/usr/bin/vim /var/log/td-agent/td-agent.log"}



- /etc/td-agent/td-agent.conf should look like this (just copy and paste this into td-agent.conf):
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

 - After that, you can start td-agent and everything should work:
```
$ td-agent -c /etc/td-agent/td-agent.conf
```

  Of course, this is just a quick example. If you are thinking of running fluentd in production, consider using td-agent, the enterprise version of Fluentd packaged and maintained by Treasure Data, Inc..
  
  
  
