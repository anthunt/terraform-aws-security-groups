locals {

    sg_rules = {
        for rules in flatten([
            for key, val in var.security_groups : concat(
                [
                    for index, rule in val.ingress : {
                        security_group_name = key
                        index               = index
                        type                = "ingress"
                        from_port           = rule[0]
                        to_port             = rule[1]
                        protocol            = rule[2]
                        cidr_blocks         = (rule[3] == null || length(rule[3]) == 0) ? null : (
                            (((rule[5] == true) || ((substr(rule[3][0], 0, 3) == "sg-" || lookup(var.security_groups, rule[3][0], null) != null) && length(rule[3]) == 1))) ? null : [
                                for x in rule[3] : x if can(regex(".+[.].+", x))
                            ]
                        )
                        source_security_group_id = ((rule[5] != true) && length(rule[3]) == 1) ? (
                            substr(rule[3][0], 0, 3) == "sg-" ? rule[3][0] : (
                                can(regex(".+[.].+", rule[3][0])) || can(regex(".+[:].+", rule[3][0])) || substr(rule[3][0], 0, 3) == "pl-" ? null : aws_security_group.security_groups[rule[3][0]].id
                            )
                        ) : null
                        ipv6_cidr_blocks    = [for x in rule[3] : x if can(regex(".+[:].+", x))]
                        prefix_list_ids     = [for x in rule[3] : x if substr(x, 0, 3) == "pl-"]
                        description         = rule[4]
                        self                = rule[5] == false ? null : rule[5]
                    }
                ],
                [
                    for index, rule in val.egress : {
                        security_group_name = key
                        index               = index
                        type                = "egress"
                        from_port           = rule[0]
                        to_port             = rule[1]
                        protocol            = rule[2]                        
                        cidr_blocks         = (rule[3] == null || length(rule[3]) == 0) ? null : (
                            (((rule[5] == true) || ((substr(rule[3][0], 0, 3) == "sg-" || lookup(var.security_groups, rule[3][0], null) != null) && length(rule[3]) == 1))) ? null : [
                                for x in rule[3] : x if can(regex(".+[.].+", x))
                            ]
                        )
                        source_security_group_id = ((rule[5] != true) && length(rule[3]) == 1) ? (
                            substr(rule[3][0], 0, 3) == "sg-" ? rule[3][0] : (
                                can(regex(".+[.].+", rule[3][0])) || can(regex(".+[:].+", rule[3][0])) || substr(rule[3][0], 0, 3) == "pl-" ? null : aws_security_group.security_groups[rule[3][0]].id
                            )
                        ) : null
                        ipv6_cidr_blocks    = [for x in rule[3] : x if can(regex(".+[:].+", x))]
                        prefix_list_ids     = [for x in rule[3] : x if substr(x, 0, 3) == "pl-"]
                        description         = rule[4]
                        self                = rule[5] == false ? null : rule[5]
                    }
                ]
            )
        ]): "${rules.security_group_name}.${rules.type}[${rules.index}]" => rules
    }

}