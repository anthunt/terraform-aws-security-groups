aws = {
    region = "ap-northeast-2"
    profile = "SAM-DEV"
}

security_groups = {

    SAM-DEV-SG-APP-SVC = {
        vpc_id = "vpc-xxxxxxxxxxxxxxxxx"
        description = "SG for DEV Application EC2"
        tags = {}
        ingress = [
            # tcp 443 port access allow for private cidr range
            [443, 443, "tcp", ["10.102.62.0/24", "10.102.61.0/24"], "All QA Private Resources", false],
            # all tcp port access allow for sg-xxxxxxx
            [0, 65536, "tcp", ["sg-xxxxxxxxx"], "allow for sg-xxxxxxx", false],
            # all tcp port access allow for self sg
            [0, 0, "-1", [], "allow for self sg", true]
        ]
        egress = [
            # alltraffic access allow for any cidr
            [0, 0, "-1", ["0.0.0.0/0"], "", false]
        ]
    }

    SAM-DEV-SG-DB-SVC = {
        vpc_id = "vpc-xxxxxxxxxx"
        description = "SG for DEV DBs"
        tags = {}
        ingress = [
            # tcp 3306 port access allow for SAM-DEV-SG-APP-SVC SG
            [3306, 3306, "tcp", ["SAM-DEV-SG-APP-SVC"], "All QA Private Resources", false],
            # all tcp port access allow for sg-xxxxxxx
            [0, 65536, "tcp", ["sg-xxxxxxxxx"], "allow for sg-xxxxxxx", false],
            # all tcp port access allow for self sg
            [0, 0, "-1", [], "allow for self sg", true]
        ]
        egress = [
            # alltraffic access allow for any cidr
            [0, 0, "-1", ["0.0.0.0/0"], "", false]
        ]
    }
}