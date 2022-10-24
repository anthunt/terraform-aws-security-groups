variable "AWS_SESSION_TOKEN" {
    type = string
    default = null
    description = "don't use this variable in tfvars."
}

variable "AWS_SESSION_ACCESSKEY" {
    type = string
    default = null
    description = "don't use this variable in tfvars."
}

variable "AWS_SESSION_SECRETKEY" {
    type = string
    default = null
    description = "don't use this variable in tfvars."
}

variable aws {
    type = object({
        region  = string
        profile = string
    })
}

variable security_groups {
    type = map(object({

        vpc_id      = string
        description = string
        tags        = map(string)

        ingress     = list(tuple([number, number, string, list(string), string, bool]))
        egress      = list(tuple([number, number, string, list(string), string, bool]))

    }))
}