locals {
  key_name = "default"
}

resource "aws_instance" "this" {

  count = var.instance_count

  ami           = var.ami
  instance_type = var.instance_type
  key_name      = local.key_name

  dynamic "ebs_block_device" {

    for_each = var.ebs_block_device
    content {

      device_name = ebs_block_device.value.device_name

      encrypted   = lookup(ebs_block_device.value, "encrypted",   null)
      iops        = lookup(ebs_block_device.value, "iops",        null)
      snapshot_id = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size = lookup(ebs_block_device.value, "volume_size", null)
      volume_type = lookup(ebs_block_device.value, "volume_type", null)
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
    }
  }

  // This doesn't work but would if Terraform had enumerate.
  user_data = templatefile("${path.module}/user-data.sh.tmpl", {
    ebs_block_device = [for index, x in enumerate(var.ebs_block_device): {
      merge(x, {mount_point => var.mount_point[index]})
    }])
}
