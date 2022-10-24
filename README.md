# Terraform for Security Group

## 1. tfvars usage

```terraform
# Cofiguration for AWS Provider Auth
aws = {
    region = "Region Id"
    profile = "AWS CLI profile name"
}

# Configuration for Security Groups
security_groups = {

    # terraform map for a security group
    "[Your SecurityGroupName]" = {
        vpc_id = "[VPC Id for SecurityGroup]"
        description = "[Description]"
        tags = {} # tags for SecurityGroup
        ingress = [
            [<from port as number>, <to port as number>, "[protocol]", ["[source as string]]"], "[description]", <self as bool>]
        ]

        egress = [
            [<from port as number>, <to port as number>, "[protocol]", ["[target as string]]"], "[description]", <self as bool>]
        ]
    }

}
```

## 2. tfvars example

```terraform
aws = {
    region = "ap-northeast-2"
    profile = "SAM-DEV"
}

security_groups = {

    "SAM-SG-DEV-ENDPOINT" = {
        vpc_id = "vpc-xxxxxxxxxxx"
        description = "SG for DEV Endpoints"
        tags = {
            "Name" = "SAM DEV for Endpoint"
            "Stage" = "DEV"
        }

        ingress = [
            # tcp 443 port access allow for private cidr range
            [443, 443, "tcp", ["10.102.62.0/24", "10.102.61.0/24"], "All QA Private Resources", false],
            # all tcp port access allow for sg-xxxxxxx
            [0, 65536, "tcp", ["sg-xxxxxxxxx"], "allow for sg-xxxxxxx", false],
            # all tcp port access allow for self sg
            [0, 0, "-1", [], "allow for self sg", true]
        ]

        egress = [
            # alltraffic access allow for any cidr
            [0, 0, "-1", ["0.0.0.0/0"], "", false]
        ]
    }

    "SAM-SG-DEV-ENDPOINT2" = {
        vpc_id = "vpc-xxxxxxxxxxxx"
        description = "SG for DEV Endpoints2"
        tags = {}

        ingress = [
            # tcp 443 port access allow for private cidr range
            [443, 443, "tcp", ["10.10.62.0/24", "10.10.61.0/24"], "All QA Private Resources", false],
            # all tcp port access allow for sg-xxxxxxx
            [0, 65536, "tcp", ["sg-xxxxxxxxx"], "allow for sg-xxxxxxx", false]
        ]

        egress = [
            # alltraffic access allow for any cidr
            [0, 0, "-1", ["0.0.0.0/0"], "", false]
        ]
    }

}
```

### ※ ingress and egress options

ingress and egress variable is array list  tuple type data

| Option           | data type    |  Description |
|------------------|--------------|---------------|
| from port        | number       | start port |
| to port          | number       | end port |
| protocol         | string       | **protocol** :<br/> - tcp : tcp<br/> - udp : udp<br/> - alltraffic : -1<br/>**※ if protocol is alltraffic then from/to port both are have to be 0** |
| source or target | list(string) | cidr or security group id or security group name<br/>cidr can be multiple value but security group id and security group name have to be single value<br/><br/>**Example:**<br/>cidr => ["10.0.0.0/8", "127.0.0.1/32"]<br/> security group id => ["sg-xxxxxxxxx"]<br/> security group name => ["WebServerSG"] |
| description      | string       | description for a rule |
| self             | bool         | source or target is self sg then true and source or target have to be '[]' |

## 3. Run

When using the Terraform command directly, it is inconvenient to put the location of the tfvars and tfstate files as options and run it. You can use it by checking the basic directory configuration of the module and the usage of the run.cmd file below.

- tfvars file in [modules]/conf
- tfstate files in [modules]/state
- **running module :** run.cmd

```PowerShell command prompt
PS>./run.cmd

--------------------------------------------------
 Managing module for AWS SecurityGroups
 This is the Terraform execution command.
--------------------------------------------------
 Usage :
    -Profile name:
        Format: [Prefix]-[Name]
        Using the profile name from the ~/.aws/credentails and ~/.aws/config

    -Configuration file location:
        It should be created in the "conf/[prefix]/" directory in the same location as run.cmd.

    -Configuration file name:
        [Profile name].tfvars

    -Option : 
        y/Y : terraform apply with terraform init
        s/S : terraform apply without terraform init
        i/I : continue with terraform init

    -MFA : 
        no arguments then will show input prompt. 
        with arguments then have to input 3rd argument AWS CLI Profile Name. 
        it is not Profile Name (for tfvars). 
        if you want to use mfa then you have to set mfa_serial your AWS CLI Profile.

 Run : 
    - Syntax : 
         ./run.cmd [Profile name] [s|y] [AWS CLI Profile Name]
         ./run.cmd [Profile name] [i] [terraform resource key] [aws resource key]

    - Example : 
         case1) ./run.cmd 
         case2) ./run.cmd gpt-qa
         case3) ./run.cmd gpt-qa s
         case4) ./run.cmd gpt-qa s GPORTAL-QA
--------------------------------------------------

profile name must start with three digit alphabet(prefix)
if you set profile name q or Q then will be exit.

Set profile name : [profile name]
```

## 4. How to synchronize AWS SecurityGroup resources that have already been created

```
PS>./export.cmd [AWS CLI Profile Name] [Region ID]
```

### - Extraction result
> - conf/[3 digit of vpc-name]/[vpc-name].tfvars    // SecurityGroup configuration information file
> - conf/[3 digit of vpc-name]/[vpc-name].cmd       // terraform import executable

cmd file, it must be executed from the corresponding location.
When executed, terraform import is executed, and the state file for the setting is synchronized with the already created SecurityGroup resource.


# Note: Terraform Import command

- aws_security_group

./run sam-dev i 'aws_security_group.security_groups[\"EC2-SAM-OSPP-AN2-DEV-NETBASTION-MANAGEMENT\"]' sg-0bb7b90a5d30eeaed

- aws_security_group_rule

``` powershell

./run sam-dev i 'aws_security_group_rule.sg-rules[\"EC2-SAM-OSPP-AN2-DEV-NETBASTION-MANAGEMENT.ingress[0]\"]' sg-0bb7b90a5d30eeaed_ingress_tcp_22_22_10.237.1.15/32

./run sam-dev i 'aws_security_group_rule.sg-rules[\"EC2-SAM-OSPP-AN2-DEV-NETBASTION-MANAGEMENT.egress[0]\"]' sg-0bb7b90a5d30eeaed_egress_-1_0_0_0.0.0.0/0
```
