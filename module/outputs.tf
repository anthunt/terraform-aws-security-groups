data "aws_caller_identity" "current" {}

output "current_account_id" {
    value = data.aws_caller_identity.current.account_id
}

output "security_groups" {
    value = {
        for key, val in aws_security_group.security_groups: key => {
            id                  = val.id
            name                = val.name
            ingress_rule_count  = length(val.ingress)
            egress_rule_count   = length(val.egress)
        }
    }
}