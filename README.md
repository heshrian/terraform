# EC2 with Terraform 

## Get Terraform
Download terraform from https://www.terraform.io/downloads.html  
Unzip the file and move it to usr/local/bin ( there you'll find docker and fuck if you have it)  

## Set up Terraform  
After installation check with a command  
`$ terraform`   
to see if it is installed.  
You can use on or as many files as you want terraform command will run all .tf files in your folder.  
In this case I created many files instead of one.  
Create a provider.tf that contains your server provider, profile and region to use.

`provider "aws" {
  profile                 = "default"
  region                  = "eu-west-2"
}`

Default profile => The profile attribute here refers to the AWS Config File in ~/.aws/credentials on MacOS and Linux. (To verify an AWS profile install AWS CLI and run aws configure)

## Create security group

If you want to install dependencies, run apps right after server startups you will have to create a security group on AWS. In this case I needed to open **port 22** to **ssh** in the server and **port 80** to allow **HTTP access** (to see our running app)

`resource "aws_security_group" "your_security_group_name" {`

​		`name = "the name that you will see on AWS"`

`   ingress { this is for SSH`
   `from_port   = 22`
    `to_port     = 22`

`protocol    = "tcp"`
    `cidr_blocks = ["0.0.0.0/0"]`
`  }`  
`   ingress { this is for HTTP`
  `  from_port   = 80`
`    to_port     = 80`
`    protocol    = "tcp"`
`    cidr_blocks = ["0.0.0.0/0"]`
`  }`

`   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}`

## Define your instance

We'll need to define the count for how many instances we'd like to start up (''x"), which AMI we'd like to use (AMI = An Amazon Machine Image (AMI) is a special type of virtual appliance that is used to create a virtual machine within the Amazon Elastic Compute Cloud ("EC2"). It serves as the basic unit of deployment for services delivered using EC2.), instance type is the size of the server (t2.micro is the smallest available), key_name - in this case I have already created a key-pair with a keyname.pem file saved on my computer, just used the keyname as a source. We have to define the security group that we just set up a step before.

`resource "aws_instance" "viktorka" {
   count         = x
   ami           = "ami-0be057a22c63962cb"
   instance_type = "t2.micro"
   key_name      = "your-key-name"
 security_groups = ["${aws_security_group.your_security_group_name.name}"]`

`tags = [count.index] to name your servers differently`

Within this resource we'll need to define some provisioners. 



## Variables in Terraform

We can create a variable.tf file where we can define everything we do not wish to go public.

`variable "private_key"{ `

`type = list`

 `default = ["path/to/your-key-name.pem"]`

  `}  `

We can refer to this as `var.private_key` (we can replace  private_key = file("~/your/path/to/your-key-name.pem") with this.

## Create dependencies/ define provisioners

Provisioners can be used to model specific actions on the local machine or on a remote machine in order to prepare servers or other infrastructure objects for service.

`provisioner "file"{`

`source = "path/to/your/file.sh"`

`destination= "where/to/copy/your/file.sh(/temp/yourfile.sh)"`

`}`

File provisioner will copy your chosen file ( in this case our .sh scripts) to the newly built instance.

`provisioner "remote-exec" {
           inline = [
            "bash where/is/your/copied/file.sh(/temp/yourfile.sh)"
        ]`

Remote-exec provisioner invokes a script on the remote instance after it is created.

`connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("~/your/path/to/your-key-name.pem")
        }
    }`

Most provisioners require access to the remote resource via SSH and expect a nested connection block with details about how to connect.

Type - ssh connection, host - self.public_ip for AWS instances, user = "ubuntu" for Amazon linux, it would be different for all the other OS types (red hat, suse, etc...).

Or we can just download the script from (for example github) the internet and run the downloaded script from there, but in that case we'd need to use "remote-exec" provisioner and know where the downloaded script is on the instance to be able to run it..

## Deploy the application

Provisioners are the key! Another script could be pre-made and run with "remote-exec", so then we can run our docker container from the image downloaded from dockerhub ( or in other cases, download the files, create the image locally and run it from the instance. We can copy our variables directly with "file" provisioner and build the image locally to avoid leaking information such as secret keys and stuff.)