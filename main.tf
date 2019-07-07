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
    iterator = e

    content {

      device_name = e.value.device_name

      encrypted   = lookup(e.value, "encrypted",   null)
      iops        = lookup(e.value, "iops",        null)
      snapshot_id = lookup(e.value, "snapshot_id", null)
      volume_size = lookup(e.value, "volume_size", null)
      volume_type = lookup(e.value, "volume_type", null)

      delete_on_termination = lookup(
                 e.value, "delete_on_termination", null)
    }
  }

  user_data = templatefile("${path.module}/user-data.sh.tmpl", {
    merged = [
      for index, x in var.ebs_block_device:
      merge(x, {"mount_point" = var.mount_point[index]})
    ]
  })
}
