This repo provide a terraform code to create Aviatrix Transit Firenet in AWS. 

Here are the components created
- Aviatrix Transit GW
- Two Aviatrix Spoke GW
- S3 bucket for PANW FW bootstrap
- Two PANW firewalls bootstrapped with all required config.

The following example tfvars can be used for deploying this MCNA.
```
name        = "ab"                                     // Name prefix for Transit GW and Firenet Firewalls
cloud       = "aws"                                    
region      = "us-east-2"                              // Region for Transit Firenet VPC
cidr        = "10.132.0.0/16"                          // CIDR for Transit Firenet VPC
account     = "aws-main"                               // AWS account name on Aviatrix Controller
fw_version  = "10.1.3"                                 // PANW firewall software version
sp_name     = ["ac", "ad"]                             // List of prefix names for spokes 
sp_cidr     = "172.17.0.0/16"                          // CIDR for both spoke VPCs. 
sp_region   = ["us-east-2", "us-west-2"]               // List of AWS regions for spoke GWs
tags        = { "owner" : "user", "env" : "testing" }
```
Save the above variables and values as testing.tfvars file and pass it to plan and apply
```
terraform init
terraform plan -var-file=testing.tfvars
terraform apply -var-file=testing.tfvars
```