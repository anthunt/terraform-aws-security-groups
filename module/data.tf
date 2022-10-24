data "aws_vpc" "sg_vpc" {
    for_each = var.security_groups
    id = substr(each.value.vpc_id, 0, 4) == "vpc-" ? each.value.vpc_id : null

    dynamic filter {
        for_each = substr(each.value.vpc_id, 0, 4) == "vpc-" ? [] : ["1"]
        content {
            name = "tag:Name"
            values = [each.value.vpc_id]
        }
    }
}