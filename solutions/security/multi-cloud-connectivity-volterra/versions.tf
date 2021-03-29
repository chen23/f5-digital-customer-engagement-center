
terraform {
  required_version = ">= 0.12.7"

  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.2.1"
    }
    aws = ">= 2.24"
  }
}
