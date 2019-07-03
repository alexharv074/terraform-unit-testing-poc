variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
  default     = "ami-08589eca6dcc9b39c"
}

variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t2.micro"
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance"
  type        = list(map(string))
  default = [
    {
      device_name           = "/dev/sdg"
      volume_size           = 5
      volume_type           = "gp2"
      delete_on_termination = false
      mount_point           = "/data"
    },
    {
      device_name           = "/dev/sdh"
      volume_size           = 5
      volume_type           = "gp2"
      delete_on_termination = false
      mount_point           = "/home"
    }
  ]
}
