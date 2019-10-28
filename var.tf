variable "server_names" {
  type     = "list"
  default  = [
    "viktorka-dev",
    "viktorka-staging",
    "viktorka-production"
  ]
}

variable "cidr_blocks" {
          type = "list"
        default = [ "0.0.0.0/0" ]
} 


# variable "vpc_id" {
#  description = "VPC ID for AWS resources."
#}

