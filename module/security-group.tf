resource "aws_security_group" "security_groups" {
    for_each    = var.security_groups
    name        = each.key
    description = each.value.description
    vpc_id      = data.aws_vpc.sg_vpc[each.key].id

    tags        = merge({"Name": each.key}, each.value.tags)
}

resource "aws_security_group_rule" "sg-rules" {
    for_each                    = local.sg_rules
    type                        = each.value.type
    from_port                   = each.value.from_port
    to_port                     = each.value.to_port
    protocol                    = each.value.protocol
    cidr_blocks                 = each.value.cidr_blocks
    source_security_group_id    = each.value.source_security_group_id
    ipv6_cidr_blocks            = length(each.value.ipv6_cidr_blocks) == 0 ? null : each.value.ipv6_cidr_blocks
    prefix_list_ids             = each.value.prefix_list_ids
    description                 = each.value.description
    self                        = each.value.self
    security_group_id           = aws_security_group.security_groups[each.value.security_group_name].id
}