resource "aws_instance" "viktorka" {
  count         = 3
  ami           = "ami-0be057a22c63962cb"
  instance_type = "t2.micro"
  key_name      = "viktorka"
    security_groups = ["${aws_security_group.viktorka_security.name}"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/path/to.pem")
    host        = self.public_ip
  }

  tags = {
    Name = var.server_names[count.index]
  }

  provisioner "file" {
      source      = "dockerInstall.sh"
      destination = "/tmp/dockerInstall.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/path/to.pem")
      host        = self.public_ip
    }
  }
  provisioner "remote-exec" {
           inline = [
            "bash /tmp/dockerInstall.sh"
        ]
        connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("~/path/to.pem")
        }
    }  
  provisioner "file" {
      source      = "pullDocker.sh"
      destination = "/tmp/pullDocker.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/path/to.pem")
      host        = self.public_ip
    }
  }
  provisioner "remote-exec" {
           inline = [
            "bash /tmp/pullDocker.sh"
        ]
        connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("~/path/to.pem")
        }
    }

}


