data "aws_instances" "VolterraBu1Instances" {
  count            = var.waitForAssisted ? 0 : 1
  instance_tags = {
    "ves.io/site_name" = volterra_aws_tgw_site.acmeBu1.name
  }

  instance_state_names = ["running"]
  depends_on           = [volterra_tf_params_action.applyBu1]
}

data "aws_instances" "VolterraBu2Instances" {
  count            = var.waitForAssisted ? 0 : 1
  instance_tags = {
    "ves.io/site_name" = volterra_aws_tgw_site.acmeBu2.name
  }

  instance_state_names = ["running"]
  depends_on           = [volterra_tf_params_action.applyBu2]
}

data "aws_instances" "VolterraAcmeInstances" {
  count            = var.waitForAssisted ? 0 : 1
  instance_tags = {
    "ves.io/site_name" = volterra_aws_tgw_site.acmeAcme.name
  }

  instance_state_names = ["running"]
  depends_on           = [volterra_tf_params_action.applyAcme]
}

data "aws_network_interface" "bu1" {
  count            = var.waitForAssisted ? 0 : 1
  filter {
    name   = "attachment.instance-id"
    values = [data.aws_instances.VolterraBu1Instances[0].ids[0]]
  }
  filter {
    name   = "tag:ves.io/interface-type"
    values = ["site-local-inside"]
  }
}

data "aws_network_interface" "bu2" {
  count            = var.waitForAssisted ? 0 : 1
  filter {
    name   = "attachment.instance-id"
    values = [data.aws_instances.VolterraBu2Instances[0].ids[0]]
  }
  filter {
    name   = "tag:ves.io/interface-type"
    values = ["site-local-inside"]
  }
}

data "aws_network_interface" "acme" {
  count            = var.waitForAssisted ? 0 : 1
  filter {
    name   = "attachment.instance-id"
    values = [data.aws_instances.VolterraBu1Instances[0].ids[0]]
  }
  filter {
    name   = "tag:ves.io/interface-type"
    values = ["site-local-inside"]
  }
}

#output "VolterraBu1Instances" {
#  description = "List of public ip's for the jumphosts"
#  value       = data.aws_instances.VolterraBu1Instances.ids[0]
#}
#output "aws_network_interface" {
#  description = "List of public ip's for the jumphosts"
#  value       = data.aws_network_interface.bar.private_ip
#}

resource "aws_route53_resolver_endpoint" "resolverBu1" {
  count            = var.waitForAssisted ? 0 : 1
  name      = "resolverBu1"
  direction = "OUTBOUND"

  security_group_ids = [module.vpcTransitBu1.default_security_group_id]

  ip_address {
    subnet_id = module.vpcTransitBu1.public_subnets[0]
  }

  ip_address {
    subnet_id = module.vpcTransitBu1.public_subnets[1]
  }

  tags = {
    Name  = "${var.projectPrefix}-resolverBu1-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}


resource "aws_route53_resolver_rule" "route53RuleBu1" {
  count            = var.waitForAssisted ? 0 : 1
  name                 = "route53RuleBu1-${random_id.buildSuffix.hex}"
  domain_name          = "shared.acme.com"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.resolverBu1[0].id

  target_ip {
    ip = data.aws_network_interface.bu1[0].private_ip
  }

  tags = {
    resourceOwner = var.resourceOwner
    Name          = "${var.projectPrefix}-route53RuleBu1-${random_id.buildSuffix.hex}"
  }
}

resource "aws_route53_resolver_rule_association" "ruleAssociationBu1" {
  count            = var.waitForAssisted ? 0 : 1
  resolver_rule_id = aws_route53_resolver_rule.route53RuleBu1[0].id
  vpc_id           = module.vpcBu1.vpc_id
}


#bu2 resolver

resource "aws_route53_resolver_endpoint" "resolverBu2" {
  count            = var.waitForAssisted ? 0 : 1
  name      = "resolverBu2"
  direction = "OUTBOUND"

  security_group_ids = [module.vpcTransitBu2.default_security_group_id]

  ip_address {
    subnet_id = module.vpcTransitBu2.public_subnets[0]
  }

  ip_address {
    subnet_id = module.vpcTransitBu2.public_subnets[1]
  }

  tags = {
    Name  = "${var.projectPrefix}-resolverBu2-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}


resource "aws_route53_resolver_rule" "route53RuleBu2" {
  count            = var.waitForAssisted ? 0 : 1
  name                 = "route53RuleBu2-${random_id.buildSuffix.hex}"
  domain_name          = "shared.acme.com"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.resolverBu2[0].id

  target_ip {
    ip = data.aws_network_interface.bu2[0].private_ip
  }

  tags = {
    resourceOwner = var.resourceOwner
    Name          = "${var.projectPrefix}-route53RuleBu2-${random_id.buildSuffix.hex}"
  }
}

resource "aws_route53_resolver_rule_association" "ruleAssociationBu2" {
  count            = var.waitForAssisted ? 0 : 1
  resolver_rule_id = aws_route53_resolver_rule.route53RuleBu2[0].id
  vpc_id           = module.vpcBu2.vpc_id
}

#acme resolver

resource "aws_route53_resolver_endpoint" "resolverAcme" {
  count            = var.waitForAssisted ? 0 : 1
  name      = "resolverAcme"
  direction = "OUTBOUND"

  security_group_ids = [module.vpcTransitAcme.default_security_group_id]

  ip_address {
    subnet_id = module.vpcTransitAcme.public_subnets[0]
  }

  ip_address {
    subnet_id = module.vpcTransitAcme.public_subnets[1]
  }

  tags = {
    Name  = "${var.projectPrefix}-resolverAcme-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}


resource "aws_route53_resolver_rule" "route53RuleAcme" {
  count            = var.waitForAssisted ? 0 : 1
  name                 = "route53RuleAcme-${random_id.buildSuffix.hex}"
  domain_name          = "shared.acme.com"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.resolverAcme[0].id

  target_ip {
    ip = data.aws_network_interface.acme[0].private_ip
  }

  tags = {
    resourceOwner = var.resourceOwner
    Name          = "${var.projectPrefix}-route53RuleAcme-${random_id.buildSuffix.hex}"
  }
}

resource "aws_route53_resolver_rule_association" "ruleAssociationAcme" {
  count            = var.waitForAssisted ? 0 : 1
  resolver_rule_id = aws_route53_resolver_rule.route53RuleAcme[0].id
  vpc_id           = module.vpcAcme.vpc_id
}
