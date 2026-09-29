terraform {
  backend "s3" {
    key          = "student-gitops/dev/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}