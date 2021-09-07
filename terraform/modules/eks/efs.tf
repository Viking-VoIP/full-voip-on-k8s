resource "aws_security_group" "efs_security_group" {
    name        = "efs_security_group"
    description = "Allow NFS from SGs"
    vpc_id      = var.vpc_id
    ingress {
        description = "EFS mount target"
        from_port   = 2049
        to_port     = 2049
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_efs_file_system" "efs" {
    creation_token   = "EFS Shared Data"
    performance_mode = "generalPurpose"
    tags = {
        Name = "EFS Vociemail Backend"
    }
}

resource "aws_efs_mount_target" "efs_0" {
    file_system_id  = "${aws_efs_file_system.efs.id}"
    subnet_id       = flatten(var.private_subnets_ids)[0]
    security_groups = [ "${aws_security_group.efs_security_group.id}" ]
}

resource "aws_efs_mount_target" "efs_1" {
    file_system_id  = "${aws_efs_file_system.efs.id}"
    subnet_id       = flatten(var.private_subnets_ids)[1]
    security_groups = [ "${aws_security_group.efs_security_group.id}" ]
}

resource "aws_efs_mount_target" "efs_2" {
    file_system_id  = "${aws_efs_file_system.efs.id}"
    subnet_id       = flatten(var.private_subnets_ids)[2]
    security_groups = [ "${aws_security_group.efs_security_group.id}" ]
}
