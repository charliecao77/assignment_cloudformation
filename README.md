# assignment_cloudformation
# Configuring an AWS instance with logging and core OS patches
# Objective: Install td‐agent (from fluentd) onto an EC2 instance using a CloudFormation StackSet  
- [x] 1. Launch an EC2 instance (t2.micro) that uses Amazon Linux 2017.3 within a VPC  
- [x] 2. Associate a Security Group to the instance to allow ssh access  
- [x] 3. Apply the appropriate OS patches (may use yum for the purposes of this exercise)  
- [x] 4. Install fluentd (and pre‐requesites) form the source
- [x] 5. Configure fluentd to parse the Linux syslog and write to a KMS key encrypted S3 bucket
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
- Create a S3 Bucket 'us-east-1-jianyuancao-assignment-code'(or the one you prefer) and upload CloudFormantion Template files, and Make them public can read access to them
  - GenerateRole.yml
  - GenerateKMS.yml
  - GenerateBucket.yml
  - GenerateEC2.yml
- Run Stack, and [choose file] main.yml, click button next then go on 
  - Stack name - could be the one you prefer, like 'test-jyc-assignment'  
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
 ## Steps
 - Login the AWS console
 - open the bucket which was created in above deployment in S3
   - the bucket name show in the Bucket stack Output
 - Monitor the bucket content
   - show the prefix as EC2 instance id
   - show the log files under the prefix,ex: *.gz
   - the log file number is increasing with time
 - Login the EC2 instance with the key file LoginAssignmentEC2.pem
 - 
  



# How to parse syslog and write into S3 with td-agent
[Ref:Amazon S3 Output Plugin](https://docs.fluentd.org/v0.12/articles/out_s3)
- A running instance of rsyslogd
- Install td-agent (which is a stable community distribution of Fluentd)
```
## td-agent 2.5 or later. Only CentOS/RHEL 6 and 7 for now.
$ curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.5.sh | sh
## td-agent 2.3 or earlier (Adapte for Amazon Linux) 
$ curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.sh | sh
```
1. Let rsyslogd forward syslog to td-agent
```
$ echo -e '#Add\n *.* @127.0.0.1:42185 \n' >> /etc/rsyslogd.conf
$ service rsyslog restart
```
2. Edit /etc/td-agent/td-agent.conf to look like this:
```
<source>
  @type syslog
  port 42185
  tag system
</source>

<match system.**>
  @type s3
  s3_bucket <your S3 bucket Name>
  s3_region <bucket in which aws region>
  path syslogs/        # prefix of the file on S3  
  buffer_path /var/log/td-agent/buffer
  time_slice_format %Y%m%d%H
  time_slice_wait 10m
  utc
  buffer_chunk_limit 256m
</match>
```

3. After that, you can start td-agent and everything should work:
```
$ service td-agent restart
```


# What to learn more, keep looking
# Parse Syslog Messages Robustly 
## Start a small testing first
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
> 2014-06-01 19:41:44 +0000 system.authpriv.notice: {"host":"precise64",**"ident":"sudo"**,"message":"vagrant : TTY=pts/3 ; PWD=/home/vagrant ; USER=root ; COMMAND=/usr/bin/vim /var/log/td-agent/td-agent.log"}

For security, it is worth knowing which user performed which action as a sudo-er. In order to do so, we need to parse the message field.
In other words, we need to parse sudo syslog messages differently from other messages.

To do this, we will use the [rewrite tag filter output plugin](https://github.com/fluent/fluent-plugin-rewrite-tag-filter). This plugin examines an event's record fields, match them against regexps and routes them. In the following example, Fluentd filters out all events except for "sudo" events. Sudo events are assigned the new tag "sudo".

The rewrite tag filter output plugin ships with td-agent. If you are using vanilla Fluentd, run gem install fluent-plugin-rewrite-tag-filter.
```
<source>
  @type syslog
  port 42185
  tag system
</source>

<match system.**>
  @type rewrite_tag_filter
  rewriterule1 ident ^sudo$  sudo # sudo events
  rewriterule2 .*                   clear # everyone else
</match>

<match clear>
  @type null
</match>
```
The last "clear" match block is to filter out all non-sudo events. Think of it as Fluentd's **/dev/null**.

We still need to match sudo events. More specifically, let's just match lines that look like this:
> 2014-06-01 19:41:44 +0000 system.authpriv.notice: {"host":"precise64","ident":"sudo","message":"vagrant : TTY=pts/3 ; PWD=/home/vagrant ; USER=root ; COMMAND=/usr/bin/vim /var/log/td-agent/td-agent.log"}

For this, we use the rewrite tag filter plugin again and use another plugin called fluent-plugin-parser. fluent-plugin-parser lets Fluentd re-parse a particular field with arbitrary regular expressions.

To install fluent-plugin-parser, run
```
$ sudo /usr/sbin/td-agent-gem install fluent-plugin-parser
Fetching: fluent-plugin-parser-0.3.4.gem (100%)
Successfully installed fluent-plugin-parser-0.3.4
1 gem installed
```
Now, here is the final configuration:
```
<source>
  type syslog
  port 42185
  tag system
</source>

<match system.**>
  type rewrite_tag_filter
  rewriterule1 ident ^sudo$  sudo  # sudo events
  rewriterule2 ident .*      clear # everyone else
</match>

# This one matches for the exact sudo syslog messages that we want to parse
# and re-tags it with "sudo_parse_it"
<match sudo>
  type rewrite_tag_filter
  rewriterule1 message PWD=[^ ]+ ; USER=[^ ]+ ; COMMAND=.*$ sudo_parse_it
  rewriterule2 message .* clear
</match>

# This one parses the message field and emits it with the sudoer, pwd and 
# command. Then, it emits the parsed event with the tag "sudo_parsed"
<match sudo_parse_it>
  type parser
  key_name message # this is the field to be parsed
  format /PWD=(?<pwd>[^ ]+) ; USER=(?<sudoer>[^ ]+) ; COMMAND=(?<command>.*)$/
  tag sudo_parsed
</match>

# Finally, emitting the data to stdout to confirm the behavior!
<match sudo_parsed>
    type stdout
</match>

<match clear>
  type null
</match>
```
Restart td-agent
```
$ sudo service td-agent restart
```
And run some sudo command. Since I have Docker running as root, let me peek into /var/lib/docker.
```
~$ sudo ls -alh /var/lib/docker
total 76K
drwx------  10 root root 4.0K Jun  1 19:41 .
drwxr-xr-x  41 root root 4.0K May 30 23:02 ..
drwxr-xr-x   2 root root 4.0K Apr 17 06:06 apparmor
drwxr-xr-x   5 root root 4.0K Apr 15 19:59 aufs
drwx------   4 root root 4.0K Jun  1 19:41 containers
drwx------   3 root root 4.0K Apr 15 19:59 execdriver
drwx------  64 root root  12K Jun  1 01:20 graph
drwx------   2 root root 4.0K May 31 05:55 init
-rw-r--r--   1 root root 7.0K Jun  1 19:41 linkgraph.db
-rw-------   1 root root 1.4K Jun  1 01:20 repositories-aufs
drwx------   2 root root 4.0K May 30 23:22 vfs
drwx------ 147 root root  20K May 30 22:37 volumes
```
Now, let's check to make sure my furtive sudo attempt was logged:
```
$ sudo tail /var/log/td-agent/td-agent.log
2014-06-01 23:26:50 +0000 [info]: adding match pattern="system.**" type="rewrite_tag_filter"
2014-06-01 23:26:50 +0000 [info]: adding rewrite_tag_filter rule: rewriterule1 ["ident", /^sudo$/, "", "sudo"]
2014-06-01 23:26:50 +0000 [info]: adding rewrite_tag_filter rule: rewriterule2 ["ident", /.*/, "", "clear"]
2014-06-01 23:26:50 +0000 [info]: adding match pattern="sudo" type="rewrite_tag_filter"
2014-06-01 23:26:50 +0000 [info]: adding rewrite_tag_filter rule: rewriterule1 ["message", /PWD=[^ ]+ ; USER=[^ ]+ ; COMMAND=.*$/, "", "sudo_parse_it"]
2014-06-01 23:26:50 +0000 [info]: adding rewrite_tag_filter rule: rewriterule2 ["message", /.*/, "", "clear"]
2014-06-01 23:26:50 +0000 [info]: adding match pattern="sudo_parse_it" type="parser"
2014-06-01 23:26:50 +0000 [info]: adding match pattern="sudo_parsed" type="stdout"
2014-06-01 23:26:50 +0000 [info]: adding match pattern="clear" type="null"
2014-06-01 23:27:14 +0000 sudo_parsed: {"pwd":"/home/vagrant","sudoer":"root","command":"/bin/ls -alh /var/lib/docker"}
```
There it is, as you can see in the last line!


## Conclusion
Fluentd makes it easy to ingest syslog events. You can immediately send the data to output systems like MongoDB and Elasticsearch, but also you can do filtering and further parsing inside Fluentd before passing the processed data onto output destinations.


  
  
