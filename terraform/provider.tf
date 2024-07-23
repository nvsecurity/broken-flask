provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "broken-flask"
      Repository  = "nvsecurity/broken-flask"
      Managed-By  = "Terraform"
      Environment = "sandbox"
      Note        = "This is a vulnerable application for educational purposes."
    }
  }
}
